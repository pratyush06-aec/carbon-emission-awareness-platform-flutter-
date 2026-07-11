import { NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { verifyAuth, unauthorizedResponse } from '@/lib/auth';

const prisma = new PrismaClient();

export async function GET(request) {
  try {
    const userAuth = await verifyAuth(request);
    if (!userAuth) return unauthorizedResponse();

    const user = await prisma.user.findUnique({
      where: { id: userAuth.userId },
      select: { xpBalance: true }
    });

    const xp = user?.xpBalance || 0;

    // Define basic gamification tiers based on XP
    const achievements = [
      { id: '1', title: 'Eco Starter', description: 'Joined the platform', unlocked: true },
      { id: '2', title: 'First Quiz', description: 'Complete a learning challenge', unlocked: xp >= 10 },
      { id: '3', title: 'Green Commuter', description: 'Save 50kg CO2 on transport', unlocked: xp >= 100 },
      { id: '4', title: 'Carbon Master', description: 'Earn 1000 XP', unlocked: xp >= 1000 },
    ];

    const currentLevel = Math.floor(xp / 100) + 1;

    return NextResponse.json({
      level: currentLevel,
      xpToNextLevel: (currentLevel * 100) - xp,
      totalXp: xp,
      achievements
    });

  } catch (error) {
    console.error('Error fetching achievements:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
