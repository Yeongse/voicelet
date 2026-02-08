import { z } from 'zod'
import { prisma } from '../../database'
import type { ServerInstance } from '../../lib/fastify'
import { authenticate, type AuthenticatedRequest } from '../../lib/auth'
import { discoverQuerySchema, discoverResponseSchema, discoverStoriesResponseSchema, errorResponseSchema } from './schema'

export default async function (fastify: ServerInstance) {
  // GET /api/discover - おすすめユーザー一覧
  fastify.get(
    '/',
    {
      preHandler: [authenticate],
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
      const { page, limit } = request.query as {
        page: number
        limit: number
      }
      const userId = (request as AuthenticatedRequest).user.sub

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

      const now = new Date()

      // おすすめユーザーを取得（自分とフォロー中を除く、鍵アカウントも除外）
      // Whisperがあるユーザーを優先し、ないユーザーも含める
      const discoverUsers = await prisma.user.findMany({
        where: {
          id: { notIn: [userId, ...followingIds] },
          isPrivate: false,
        },
        include: {
          whispers: {
            where: {
              expiresAt: { gt: now },
            },
            include: {
              views: { where: { userId }, select: { id: true } },
            },
            orderBy: { createdAt: 'desc' },
          },
          _count: {
            select: {
              whispers: {
                where: {
                  expiresAt: { gt: now },
                },
              },
            },
          },
        },
        orderBy: { createdAt: 'desc' },
      })

      // Whisperがあるユーザーを優先してソート
      const sortedUsers = discoverUsers.sort((a, b) => {
        const aHasWhispers = a._count.whispers > 0
        const bHasWhispers = b._count.whispers > 0
        if (aHasWhispers && !bHasWhispers) return -1
        if (!aHasWhispers && bHasWhispers) return 1
        // 両方Whisperがある場合は最新のWhisper日時でソート
        if (aHasWhispers && bHasWhispers) {
          const aLatest = a.whispers[0]?.createdAt ?? new Date(0)
          const bLatest = b.whispers[0]?.createdAt ?? new Date(0)
          return bLatest.getTime() - aLatest.getTime()
        }
        // 両方Whisperがない場合は登録日時でソート
        return b.createdAt.getTime() - a.createdAt.getTime()
      })

      const total = sortedUsers.length
      const totalPages = Math.ceil(total / limit)
      const skip = (page - 1) * limit

      const paginatedUsers = sortedUsers.slice(skip, skip + limit)

      const data = paginatedUsers.map((u) => {
        // 未視聴のWhisperがあるかチェック
        const hasUnviewed = u.whispers.some((w) => w.views.length === 0)
        return {
          id: u.id,
          name: u.name ?? '',
          bio: u.bio,
          avatarUrl: u.avatarPath,
          whisperCount: u._count.whispers,
          latestWhisperAt: u.whispers[0]?.createdAt.toISOString() || '',
          hasUnviewed,
        }
      })

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
      preHandler: [authenticate],
      schema: {
        tags: ['Discover'],
        summary: 'おすすめユーザーのストーリー取得',
        params: z.object({ targetUserId: z.string() }),
        response: {
          200: discoverStoriesResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const { targetUserId } = request.params as { targetUserId: string }
      const userId = (request as AuthenticatedRequest).user.sub

      // 対象ユーザーのプライバシーチェック
      const targetUser = await prisma.user.findUnique({
        where: { id: targetUserId },
        select: { id: true, name: true, avatarPath: true, isPrivate: true },
      })

      if (!targetUser) {
        return reply.send({ user: null, stories: [], hasUnviewed: false })
      }

      // 鍵垢の場合、フォロワーかオーナーのみアクセス可能
      if (targetUser.isPrivate && targetUserId !== userId) {
        const isFollower = await prisma.follow.findUnique({
          where: {
            followerId_followingId: {
              followerId: userId,
              followingId: targetUserId,
            },
          },
        })

        if (!isFollower) {
          return reply.status(403).send({ message: 'このユーザーのストーリーを表示する権限がありません' })
        }
      }

      const now = new Date()
      // 有効なWhisperを取得（視聴済みも含む）
      const whispers = await prisma.whisper.findMany({
        where: {
          userId: targetUserId,
          expiresAt: { gt: now },
        },
        include: {
          user: { select: { id: true, name: true, avatarPath: true } },
          views: { where: { userId }, select: { id: true } },
        },
        orderBy: { createdAt: 'asc' },
      })

      if (whispers.length === 0) {
        const user = {
          id: targetUser.id,
          name: targetUser.name ?? '',
          avatarUrl: targetUser.avatarPath,
        }
        return reply.send({ user, stories: [], hasUnviewed: false })
      }

      const firstUser = whispers[0].user
      const user = {
        id: firstUser.id,
        name: firstUser.name ?? '',
        avatarUrl: firstUser.avatarPath,
      }
      const stories = whispers.map((w) => ({
        id: w.id,
        duration: w.duration,
        createdAt: w.createdAt.toISOString(),
        isViewed: w.views.length > 0,
      }))
      const hasUnviewed = whispers.some((w) => w.views.length === 0)

      return reply.send({ user, stories, hasUnviewed })
    },
  )
}
