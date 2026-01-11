import { z } from 'zod'
import { prisma } from '../../database'
import { type ServerInstance } from '../../lib/fastify'
import { discoverQuerySchema, discoverResponseSchema, errorResponseSchema } from './schema'

export default async function (fastify: ServerInstance) {
  // GET /api/discover - おすすめユーザー一覧
  fastify.get(
    '/',
    {
      schema: {
        tags: ['Discover'],
        summary: 'おすすめユーザー一覧',
        description: 'フォローしていないユーザーで、有効なWhisperを持つユーザーを取得',
        querystring: discoverQuerySchema,
        response: {
          200: discoverResponseSchema,
          401: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const { userId, page, limit } = request.query as { userId: string; page: number; limit: number }

      const user = await prisma.user.findUnique({ where: { id: userId } })
      if (!user) {
        return reply.status(401).send({ message: 'ユーザーが見つかりません' })
      }

      // フォロー中ユーザーのID
      const following = await prisma.follow.findMany({
        where: { followerId: userId },
        select: { followingId: true },
      })
      const followingIds = following.map((f) => f.followingId)

      // 有効なWhisperを持つユーザー（自分とフォロー中を除く）
      const now = new Date()
      const usersWithWhispers = await prisma.user.findMany({
        where: {
          id: { notIn: [userId, ...followingIds] },
          whispers: {
            some: { expiresAt: { gt: now } },
          },
        },
        include: {
          whispers: {
            where: { expiresAt: { gt: now } },
            orderBy: { createdAt: 'desc' },
            take: 1,
          },
          _count: {
            select: {
              whispers: { where: { expiresAt: { gt: now } } },
            },
          },
        },
        orderBy: { createdAt: 'desc' },
      })

      const total = usersWithWhispers.length
      const totalPages = Math.ceil(total / limit)
      const skip = (page - 1) * limit

      const paginatedUsers = usersWithWhispers.slice(skip, skip + limit)

      const data = paginatedUsers.map((u) => ({
        id: u.id,
        name: u.name,
        avatarUrl: u.avatarUrl,
        whisperCount: u._count.whispers,
        latestWhisperAt: u.whispers[0]?.createdAt.toISOString() || '',
      }))

      return reply.send({
        data,
        pagination: {
          total,
          page,
          limit,
          totalPages,
          hasNext: page < totalPages,
          hasPrev: page > 1,
        },
      })
    },
  )

  // GET /api/discover/:userId/stories - おすすめユーザーのストーリー
  fastify.get(
    '/:targetUserId/stories',
    {
      schema: {
        tags: ['Discover'],
        summary: 'おすすめユーザーのストーリー取得',
        params: z.object({ targetUserId: z.string() }),
        querystring: z.object({ userId: z.string() }),
      },
    },
    async (request, reply) => {
      const { targetUserId } = request.params as { targetUserId: string }
      const { userId } = request.query as { userId: string }

      const now = new Date()
      const whispers = await prisma.whisper.findMany({
        where: {
          userId: targetUserId,
          expiresAt: { gt: now },
        },
        include: {
          user: { select: { id: true, name: true, avatarUrl: true } },
          views: { where: { userId }, select: { id: true } },
        },
        orderBy: { createdAt: 'asc' },
      })

      if (whispers.length === 0) {
        return reply.send({ user: null, stories: [] })
      }

      const user = whispers[0].user
      const stories = whispers.map((w) => ({
        id: w.id,
        duration: w.duration,
        createdAt: w.createdAt.toISOString(),
        isViewed: w.views.length > 0,
      }))

      return reply.send({ user, stories })
    },
  )
}
