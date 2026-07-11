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
      include: {
        ledger: {
          orderBy: { createdAt: 'desc' },
          take: 10
        }
      }
    });

    if (!user) return NextResponse.json({ error: 'User not found' }, { status: 404 });

    return NextResponse.json({
      id: user.id,
      name: user.name,
      email: user.email,
      image: user.image,
      xpBalance: user.xpBalance,
      joinedAt: user.createdAt,
      recentTransactions: user.ledger
    });

  } catch (error) {
    console.error('Error fetching profile:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}
