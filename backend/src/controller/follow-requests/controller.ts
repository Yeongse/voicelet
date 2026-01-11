import { prisma } from '../../database'
import type { AuthenticatedRequest } from '../../lib/auth'
import { authenticate } from '../../lib/auth'
import type { ServerInstance } from '../../lib/fastify'
import { generateAvatarDownloadSignedUrl } from '../../services/storage'
import {
  type PaginationQuery,
  followRequestCountResponseSchema,
  followRequestListResponseSchema,
  paginationQuerySchema,
  sentFollowRequestListResponseSchema,
} from './schema'

export default async function (fastify: ServerInstance) {
  // GET /api/follow-requests - 受信したフォローリクエスト一覧
  fastify.get(
    '/',
    {
      preHandler: [authenticate],
      schema: {
        tags: ['FollowRequests'],
        summary: 'フォローリクエスト一覧',
        description: '認証ユーザー宛のフォローリクエスト一覧を取得します。',
        querystring: paginationQuerySchema,
        response: {
          200: followRequestListResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const userId = (request as AuthenticatedRequest).user.sub
      const { page, limit } = request.query as PaginationQuery

      const skip = (page - 1) * limit
      const [requests, total] = await Promise.all([
        prisma.followRequest.findMany({
          where: { targetId: userId },
          include: {
            requester: {
              select: {
                id: true,
                name: true,
                avatarPath: true,
              },
            },
          },
          orderBy: { createdAt: 'desc' },
          skip,
          take: limit,
        }),
        prisma.followRequest.count({ where: { targetId: userId } }),
      ])

      const data = await Promise.all(
        requests.map(async (req) => {
          let avatarUrl: string | null = null
          if (req.requester.avatarPath) {
            try {
              avatarUrl = await generateAvatarDownloadSignedUrl(req.requester.avatarPath, 60)
            } catch {
              // ignore
            }
          }

          return {
            id: req.id,
            requester: {
              id: req.requester.id,
              name: req.requester.name,
              avatarUrl,
            },
            createdAt: req.createdAt.toISOString(),
          }
        }),
      )

      return reply.send({
        data,
        pagination: {
          page,
          limit,
          total,
          hasMore: skip + requests.length < total,
        },
      })
    },
  )

  // GET /api/follow-requests/count - リクエスト数取得（バッジ用）
  fastify.get(
    '/count',
    {
      preHandler: [authenticate],
      schema: {
        tags: ['FollowRequests'],
        summary: 'フォローリクエスト数',
        description: 'バッジ表示用の保留中フォローリクエスト数を取得します。',
        response: {
          200: followRequestCountResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const userId = (request as AuthenticatedRequest).user.sub

      const count = await prisma.followRequest.count({
        where: { targetId: userId },
      })

      return reply.send({ count })
    },
  )

  // GET /api/follow-requests/sent - 送信したフォローリクエスト一覧
  fastify.get(
    '/sent',
    {
      preHandler: [authenticate],
      schema: {
        tags: ['FollowRequests'],
        summary: '送信済みフォローリクエスト一覧',
        description: '認証ユーザーが送信したフォローリクエスト一覧を取得します。',
        querystring: paginationQuerySchema,
        response: {
          200: sentFollowRequestListResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const userId = (request as AuthenticatedRequest).user.sub
      const { page, limit } = request.query as PaginationQuery

      const skip = (page - 1) * limit
      const [requests, total] = await Promise.all([
        prisma.followRequest.findMany({
          where: { requesterId: userId },
          include: {
            target: {
              select: {
                id: true,
                name: true,
                avatarPath: true,
              },
            },
          },
          orderBy: { createdAt: 'desc' },
          skip,
          take: limit,
        }),
        prisma.followRequest.count({ where: { requesterId: userId } }),
      ])

      const data = await Promise.all(
        requests.map(async (req) => {
          let avatarUrl: string | null = null
          if (req.target.avatarPath) {
            try {
              avatarUrl = await generateAvatarDownloadSignedUrl(req.target.avatarPath, 60)
            } catch {
              // ignore
            }
          }

          return {
            id: req.id,
            target: {
              id: req.target.id,
              name: req.target.name,
              avatarUrl,
            },
            createdAt: req.createdAt.toISOString(),
          }
        }),
      )

      return reply.send({
        data,
        pagination: {
          page,
          limit,
          total,
          hasMore: skip + requests.length < total,
        },
      })
    },
  )
}
