import { NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { verifyAuth, unauthorizedResponse } from '@/lib/auth';

const prisma = new PrismaClient();

export async function GET(request) {
  try {
    const userAuth = await verifyAuth(request);
    if (!userAuth) return unauthorizedResponse();

    // Fetch user activities to calculate emissions
    const activities = await prisma.activity.findMany({
      where: { userId: userAuth.userId },
      orderBy: { date: 'desc' },
    });

    // Simple aggregations
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    let todayEmissions = 0;
    let totalEmissions = 0;

    const breakdown = {
      TRANSPORT: 0,
      FOOD: 0,
      ENERGY: 0
    };

    activities.forEach(act => {
      totalEmissions += act.carbonValue;
      breakdown[act.type] = (breakdown[act.type] || 0) + act.carbonValue;
      
      const actDate = new Date(act.date);
      if (actDate >= today) {
        todayEmissions += act.carbonValue;
      }
    });

    // Fetch User XP
    const user = await prisma.user.findUnique({
      where: { id: userAuth.userId },
      select: { xpBalance: true }
    });

    return NextResponse.json({
      todayEmissions,
      totalEmissions,
      breakdown,
      xpBalance: user?.xpBalance || 0,
      recentActivities: activities.slice(0, 5) // Last 5
    });

  } catch (error) {
    console.error('Error fetching dashboard:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
