import { GoogleGenerativeAI } from '@google/generative-ai';
import { getServerSession } from "next-auth/next";
import { authOptions } from "../../auth/[...nextauth]/route";
import { PrismaClient } from "@prisma/client";

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const prisma = new PrismaClient();

export async function GET(req) {
  try {
    const session = await getServerSession(authOptions);
    if (!session || !session.user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401 });
    }

    // Fetch the latest ROUTINE activity
    const latestRoutine = await prisma.activity.findFirst({
      where: {
        userId: session.user.id,
        type: "ROUTINE"
      },
      orderBy: {
        date: 'desc'
      }
    });

    const routineText = latestRoutine?.description || "I drove my car 20 miles to work, kept the AC running all day, ate a large beef steak for lunch, and left all the lights on at home.";

    const model = genAI.getGenerativeModel({ model: 'gemini-flash-lite-latest' });

    const prompt = `You are an advanced Digital Twin carbon estimator for the CarbonSense app.
Based on the following user routine, estimate their current carbon footprint and a "greener" alternative version.

User Routine: "${routineText}"

Provide the response in the following strict JSON format, without markdown wrappers or code blocks:
{
  "currentTwin": {
    "tonsPerYear": "A realistic number, e.g. 4.2",
    "summary": "A short 4-5 word summary of the bad habits, e.g. 'Heavy AC Usage, Daily Car Commute'"
  },
  "greenerTwin": {
    "tonsPerYear": "A realistic lower number, e.g. 2.8",
    "summary": "A short 4-5 word summary of the fix, e.g. 'Optimized Cooling, Metro Commute'"
  },
  "simulations": [
    {
      "title": "Actionable title, e.g. 'Work from home 2 days/week'",
      "description": "Details e.g. 'Current: 1.2 tons/yr -> Alternative: 0.9 tons/yr'",
      "badge": "e.g. '25% Savings' or 'High Impact'"
    },
    {
      "title": "Actionable title 2",
      "description": "Details",
      "badge": "Badge text"
    }
  ]
}`;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const text = response.text().trim();

    let jsonText = text;
    if (jsonText.startsWith('```json')) {
      jsonText = jsonText.substring(7);
    } else if (jsonText.startsWith('```')) {
      jsonText = jsonText.substring(3);
    }
    if (jsonText.endsWith('```')) {
      jsonText = jsonText.substring(0, jsonText.length - 3);
    }

    const parsed = JSON.parse(jsonText.trim());

    return new Response(JSON.stringify(parsed), { status: 200 });

  } catch (error) {
    console.error("Digital Twin API Error:", error.message || error);
    return new Response(JSON.stringify({ error: "Failed to fetch twin data", details: error.message }), { status: 500 });
  }
}
