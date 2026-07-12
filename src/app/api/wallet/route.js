import { verifyAuth, unauthorizedResponse } from '@/lib/auth'
import { PrismaClient } from "@prisma/client"

const prisma = new PrismaClient()

export async function GET(req) {
  try {
    const userAuth = await verifyAuth(req)

    if (!userAuth) {
      return unauthorizedResponse()
    }

    const userId = userAuth.userId

    // Fetch user with ledger entries
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        ledger: {
          orderBy: { createdAt: 'desc' }
        }
      }
    })

    if (!user) {
      return new Response(JSON.stringify({ error: "User not found" }), { status: 404 })
    }

    return new Response(JSON.stringify({
      xpBalance: user.xpBalance,
      ledger: user.ledger
    }), { status: 200 })

  } catch (error) {
    console.error("Wallet Fetch Error:", error)
    return new Response(JSON.stringify({ error: "Internal Server Error" }), { status: 500 })
  }
}
