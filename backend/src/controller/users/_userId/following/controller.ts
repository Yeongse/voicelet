import { prisma } from '../../../../database'
import type { AuthenticatedRequest } from '../../../../lib/auth'
import { authenticate } from '../../../../lib/auth'
import type { ServerInstance } from '../../../../lib/fastify'
import { generateAvatarDownloadSignedUrl } from '../../../../services/storage'
import {
  type PaginationQuery,
  errorResponseSchema,
  paginationQuerySchema,
  userIdParamsSchema,
  userListResponseSchema,
} from '../../../follows/schema'

export default async function (fastify: ServerInstance) {
  // GET /api/users/:userId/following - フォロー中ユーザー一覧
  fastify.get(
    '/',
    {
      preHandler: [authenticate],
      schema: {
        tags: ['Follows'],
        summary: 'フォロー中ユーザー一覧',
        description: '指定ユーザーがフォローしているユーザー一覧を取得します。',
        params: userIdParamsSchema,
        querystring: paginationQuerySchema,
        response: {
          200: userListResponseSchema,
          403: errorResponseSchema,
          404: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const currentUserId = (request as AuthenticatedRequest).user.sub
      const { userId } = request.params as { userId: string }
      const { page, limit } = request.query as PaginationQuery

      // 対象ユーザーの存在・プライバシー確認
      const targetUser = await prisma.user.findUnique({
        where: { id: userId },
        select: { id: true, isPrivate: true },
      })

      if (!targetUser) {
        return reply.status(404).send({ message: 'ユーザーが見つかりません' })
      }

      // 鍵垢の場合、自分自身か、フォロワーでなければ403
      if (targetUser.isPrivate && targetUser.id !== currentUserId) {
        const isFollower = await prisma.follow.findUnique({
          where: { followerId_followingId: { followerId: currentUserId, followingId: userId } },
        })

        if (!isFollower) {
          return reply.status(403).send({ message: 'このユーザーのフォロー一覧は非公開です' })
        }
      }

      // フォロー中ユーザー一覧を取得
      const skip = (page - 1) * limit
      const [follows, total] = await Promise.all([
        prisma.follow.findMany({
          where: { followerId: userId },
          include: {
            following: {
              select: {
                id: true,
                name: true,
                bio: true,
                avatarPath: true,
                isPrivate: true,
              },
            },
          },
          orderBy: { createdAt: 'desc' },
          skip,
          take: limit,
        }),
        prisma.follow.count({ where: { followerId: userId } }),
      ])

      // 現在のユーザーのフォロー状態を取得
      const userIds = follows.map((f) => f.following.id)
      const [myFollows, myRequests] = await Promise.all([
        prisma.follow.findMany({
          where: { followerId: currentUserId, followingId: { in: userIds } },
          select: { followingId: true },
        }),
        prisma.followRequest.findMany({
          where: { requesterId: currentUserId, targetId: { in: userIds } },
          select: { targetId: true },
        }),
      ])

      const followingSet = new Set(myFollows.map((f) => f.followingId))
      const requestedSet = new Set(myRequests.map((r) => r.targetId))

      // アバターURL生成とレスポンス整形
      const data = await Promise.all(
        follows.map(async (f) => {
          let avatarUrl: string | null = null
          if (f.following.avatarPath) {
            try {
              avatarUrl = await generateAvatarDownloadSignedUrl(f.following.avatarPath, 60)
            } catch {
              // ignore
            }
          }

          let followStatus: 'none' | 'following' | 'requested' = 'none'
          if (followingSet.has(f.following.id)) {
            followStatus = 'following'
          } else if (requestedSet.has(f.following.id)) {
            followStatus = 'requested'
          }

          return {
            id: f.following.id,
            name: f.following.name,
            bio: f.following.bio,
            avatarUrl,
            isPrivate: f.following.isPrivate,
            followStatus,
          }
        }),
      )

      return reply.send({
        data,
        pagination: {
          page,
          limit,
          total,
          hasMore: skip + follows.length < total,
        },
      })
    },
  )
}
