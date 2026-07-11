import { NextResponse } from 'next/server';
import { PrismaClient } from '@prisma/client';
import { verifyAuth, unauthorizedResponse } from '@/lib/auth';

const prisma = new PrismaClient();

export async function POST(request) {
  try {
    const userAuth = await verifyAuth(request);
    if (!userAuth) return unauthorizedResponse();

    const body = await request.json();
    const { transportScore, foodScore, energyScore, totalFootprint } = body;

    // We save the onboarding result as baseline activities or update a profile if needed.
    // Here we'll log the initial baseline assessment as activities.
    
    await prisma.activity.createMany({
      data: [
        {
          userId: userAuth.userId,
          type: 'TRANSPORT',
          description: 'Baseline Transport Assessment',
          carbonValue: transportScore || 0,
          xpEarned: 10,
        },
        {
          userId: userAuth.userId,
          type: 'FOOD',
          description: 'Baseline Food Assessment',
          carbonValue: foodScore || 0,
          xpEarned: 10,
        },
        {
          userId: userAuth.userId,
          type: 'ENERGY',
          description: 'Baseline Energy Assessment',
          carbonValue: energyScore || 0,
          xpEarned: 10,
        }
      ]
    });

    // Update user's XP for completing onboarding
    const updatedUser = await prisma.user.update({
      where: { id: userAuth.userId },
      data: { xpBalance: { increment: 30 } }
    });

    return NextResponse.json({
      message: 'Carbon Twin created successfully',
      xpEarned: 30,
      newBalance: updatedUser.xpBalance,
      totalFootprint
    });

  } catch (error) {
    console.error('Error creating Carbon Twin:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
