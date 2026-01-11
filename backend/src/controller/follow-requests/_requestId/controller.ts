import { prisma } from '../../../database'
import type { AuthenticatedRequest } from '../../../lib/auth'
import { authenticate } from '../../../lib/auth'
import type { ServerInstance } from '../../../lib/fastify'
import {
  errorResponseSchema,
  followCreatedResponseSchema,
  requestIdParamsSchema,
  successResponseSchema,
} from '../schema'

export default async function (fastify: ServerInstance) {
  // POST /api/follow-requests/:requestId/approve - リクエスト承認
  fastify.post(
    '/approve',
    {
      preHandler: [authenticate],
      schema: {
        tags: ['FollowRequests'],
        summary: 'フォローリクエスト承認',
        description: 'フォローリクエストを承認し、フォロー関係を作成します。',
        params: requestIdParamsSchema,
        response: {
          200: followCreatedResponseSchema,
          403: errorResponseSchema,
          404: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const userId = (request as AuthenticatedRequest).user.sub
      const { requestId } = request.params as { requestId: string }

      const followRequest = await prisma.followRequest.findUnique({
        where: { id: requestId },
      })

      if (!followRequest) {
        return reply.status(404).send({ message: 'フォローリクエストが見つかりません' })
      }

      // 対象ユーザー（自分）宛のリクエストのみ承認可能
      if (followRequest.targetId !== userId) {
        return reply.status(403).send({ message: '権限がありません' })
      }

      // トランザクションでリクエスト削除とフォロー作成（既存のフォローがあればそれを返す）
      const follow = await prisma.$transaction(async (tx) => {
        await tx.followRequest.delete({
          where: { id: requestId },
        })

        // 既にフォロー関係が存在する場合はそれを返す
        const existingFollow = await tx.follow.findFirst({
          where: {
            followerId: followRequest.requesterId,
            followingId: followRequest.targetId,
          },
        })

        if (existingFollow) {
          return existingFollow
        }

        return tx.follow.create({
          data: {
            followerId: followRequest.requesterId,
            followingId: followRequest.targetId,
          },
        })
      })

      return reply.send({
        message: 'フォローリクエストを承認しました',
        follow: {
          id: follow.id,
          followerId: follow.followerId,
          followingId: follow.followingId,
          createdAt: follow.createdAt.toISOString(),
        },
      })
    },
  )

  // POST /api/follow-requests/:requestId/reject - リクエスト拒否
  fastify.post(
    '/reject',
    {
      preHandler: [authenticate],
      schema: {
        tags: ['FollowRequests'],
        summary: 'フォローリクエスト拒否',
        description: 'フォローリクエストを拒否（削除）します。',
        params: requestIdParamsSchema,
        response: {
          200: successResponseSchema,
          403: errorResponseSchema,
          404: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const userId = (request as AuthenticatedRequest).user.sub
      const { requestId } = request.params as { requestId: string }

      const followRequest = await prisma.followRequest.findUnique({
        where: { id: requestId },
      })

      if (!followRequest) {
        return reply.status(404).send({ message: 'フォローリクエストが見つかりません' })
      }

      // 対象ユーザー（自分）宛のリクエストのみ拒否可能
      if (followRequest.targetId !== userId) {
        return reply.status(403).send({ message: '権限がありません' })
      }

      await prisma.followRequest.delete({
        where: { id: requestId },
      })

      return reply.send({ message: 'フォローリクエストを拒否しました' })
    },
  )

  // DELETE /api/follow-requests/:requestId - リクエスト取消（送信者用）
  fastify.delete(
    '/',
    {
      preHandler: [authenticate],
      schema: {
        tags: ['FollowRequests'],
        summary: 'フォローリクエスト取消',
        description: '自分が送信したフォローリクエストを取り消します。',
        params: requestIdParamsSchema,
        response: {
          200: successResponseSchema,
          403: errorResponseSchema,
          404: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const userId = (request as AuthenticatedRequest).user.sub
      const { requestId } = request.params as { requestId: string }

      const followRequest = await prisma.followRequest.findUnique({
        where: { id: requestId },
      })

      if (!followRequest) {
        return reply.status(404).send({ message: 'フォローリクエストが見つかりません' })
      }

      // 送信者本人のみ取消可能
      if (followRequest.requesterId !== userId) {
        return reply.status(403).send({ message: '権限がありません' })
      }

      await prisma.followRequest.delete({
        where: { id: requestId },
      })

      return reply.send({ message: 'フォローリクエストを取り消しました' })
    },
  )
}
