import { prisma } from '../../database'
import type { ServerInstance } from '../../lib/fastify'
import { buildPaginationResponse, calculatePagination } from '../../lib/pagination'
import { generateAvatarDownloadSignedUrl } from '../../services/storage'
import { errorResponseSchema, searchUsersQuerySchema, searchUsersResponseSchema } from './schema'

export default async function (fastify: ServerInstance) {
  /**
   * GET /api/search/users
   * ユーザー検索
   */
  fastify.get(
    '/users',
    {
      schema: {
        tags: ['Search'],
        summary: 'ユーザー検索',
        description: '表示名またはユーザー名でユーザーを検索します。2文字以上のクエリが必要です。',
        querystring: searchUsersQuerySchema,
        response: {
          200: searchUsersResponseSchema,
          400: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const { query, userId, page, limit } = request.query
      const { skip, take } = calculatePagination({ page, limit })

      // 部分一致検索（name または username）
      const whereCondition = {
        OR: [
          {
            name: {
              contains: query,
              mode: 'insensitive' as const,
            },
          },
          {
            username: {
              contains: query,
              mode: 'insensitive' as const,
            },
          },
        ],
      }

      const [users, total] = await Promise.all([
        prisma.user.findMany({
          where: whereCondition,
          skip,
          take,
          orderBy: { name: 'asc' },
        }),
        prisma.user.count({
          where: whereCondition,
        }),
      ])

      // ログインユーザーのフォロー状態を取得
      const userIds = users.map((u) => u.id)
      let followingSet = new Set<string>()
      let requestedSet = new Set<string>()

      if (userId) {
        const [follows, requests] = await Promise.all([
          prisma.follow.findMany({
            where: { followerId: userId, followingId: { in: userIds } },
            select: { followingId: true },
          }),
          prisma.followRequest.findMany({
            where: { requesterId: userId, targetId: { in: userIds } },
            select: { targetId: true },
          }),
        ])
        followingSet = new Set(follows.map((f) => f.followingId))
        requestedSet = new Set(requests.map((r) => r.targetId))
      }

      // アバターURLを生成
      const data = await Promise.all(
        users.map(async (user) => {
          let avatarUrl: string | null = null
          if (user.avatarPath) {
            try {
              avatarUrl = await generateAvatarDownloadSignedUrl(user.avatarPath, 60)
            } catch (err) {
              fastify.log.warn(
                { err, avatarPath: user.avatarPath },
                'Failed to generate avatar URL',
              )
            }
          }

          // フォロー状態を判定
          let followStatus: 'none' | 'following' | 'requested' = 'none'
          if (followingSet.has(user.id)) {
            followStatus = 'following'
          } else if (requestedSet.has(user.id)) {
            followStatus = 'requested'
          }

          return {
            id: user.id,
            username: user.username,
            name: user.name,
            avatarUrl,
            isPrivate: user.isPrivate,
            followStatus,
          }
        }),
      )

      return reply.send(buildPaginationResponse({ data, total, page, limit }))
    },
  )
}
