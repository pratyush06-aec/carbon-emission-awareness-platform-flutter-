import { getServerSession } from "next-auth/next";
import { authOptions } from "../auth/[...nextauth]/route";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

export async function GET(req) {
  try {
    const session = await getServerSession(authOptions);
    if (!session || !session.user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401 });
    }

    const userId = session.user.id;

    // Fetch activities from the last 90 days
    const ninetyDaysAgo = new Date();
    ninetyDaysAgo.setDate(ninetyDaysAgo.getDate() - 90);

    const activities = await prisma.activity.findMany({
      where: {
        userId: userId,
        date: {
          gte: ninetyDaysAgo
        }
      },
      select: {
        date: true,
        type: true,
        xpEarned: true
      },
      orderBy: {
        date: 'asc'
      }
    });

    // Group activities by date string (YYYY-MM-DD)
    const contributions = {};
    
    activities.forEach(act => {
      const dateStr = new Date(act.date).toISOString().split('T')[0];
      if (!contributions[dateStr]) {
        contributions[dateStr] = { count: 0, xp: 0, types: new Set() };
      }
      contributions[dateStr].count += 1;
      contributions[dateStr].xp += act.xpEarned;
      contributions[dateStr].types.add(act.type);
    });

    // Format output
    const formattedData = Object.keys(contributions).map(date => ({
      date,
      count: contributions[date].count,
      xp: contributions[date].xp,
      types: Array.from(contributions[date].types)
    }));

    return new Response(JSON.stringify({ data: formattedData }), { status: 200 });

  } catch (error) {
    console.error("Contributions API Error:", error.message || error);
    return new Response(JSON.stringify({ error: "Internal Server Error" }), { status: 500 });
  }
}
