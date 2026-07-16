import { GoogleGenerativeAI } from '@google/generative-ai';
import { NextResponse } from 'next/server';
import { verifyAuth, unauthorizedResponse } from '@/lib/auth';

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

export async function POST(request) {
  try {
    const userAuth = await verifyAuth(request);
    if (!userAuth) return unauthorizedResponse();

    const body = await request.json();
    const { activityText } = body;

    if (!activityText) {
      return NextResponse.json({ error: 'No activity text provided' }, { status: 400 });
    }

    const model = genAI.getGenerativeModel({ model: 'gemini-flash-latest' });

    const prompt = `
      You are an eco-friendly AI assistant named 'Carbon Twin'.
      The user has just provided a summary of their day: "${activityText}".

      First, write a short, encouraging analysis message acknowledging their activities and smoothly transitioning into a mini-quiz challenge.
      Then, generate EXACTLY 3 multiple-choice trivia/challenge questions related to the specific activities they mentioned (or general carbon-reduction tips if the activities are vague).
      Each question must have exactly 3 options.
      Provide the correct answer index (0, 1, or 2) and a short explanation of why it's the best eco-friendly choice.

      Return ONLY a JSON response in the exact format below, with no markdown, no \`\`\`json wrappers, just the raw JSON text:
      {
        "analysisMessage": "Your analysis message here... Entering Challenge Mode! 🎮",
        "questions": [
          {
            "questionText": "Question 1 text...",
            "options": ["Option A", "Option B", "Option C"],
            "correctAnswerIndex": 1,
            "explanation": "Explanation for why Option B is correct."
          },
          {
            "questionText": "Question 2 text...",
            "options": ["Option A", "Option B", "Option C"],
            "correctAnswerIndex": 2,
            "explanation": "Explanation for why Option C is correct."
          },
          {
            "questionText": "Question 3 text...",
            "options": ["Option A", "Option B", "Option C"],
            "correctAnswerIndex": 0,
            "explanation": "Explanation for why Option A is correct."
          }
        ]
      }
    `;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const text = response.text().trim();
    
    // Clean up potential markdown JSON wrappers
    let jsonText = text;
    if (jsonText.startsWith('```json')) {
      jsonText = jsonText.substring(7);
    }
    if (jsonText.endsWith('```')) {
      jsonText = jsonText.substring(0, jsonText.length - 3);
    }
    
    const parsedData = JSON.parse(jsonText.trim());

    return NextResponse.json(parsedData);
  } catch (error) {
    console.error('Error in daily-checkin API:', error);
    return NextResponse.json({ error: 'Failed to generate questions' }, { status: 500 });
  }
}
