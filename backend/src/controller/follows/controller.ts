import { prisma } from '../../database'
import type { AuthenticatedRequest } from '../../lib/auth'
import { authenticate } from '../../lib/auth'
import type { ServerInstance } from '../../lib/fastify'
import {
  errorResponseSchema,
  followBodySchema,
  followRequestCreatedResponseSchema,
  followResponseSchema,
  successResponseSchema,
  unfollowParamsSchema,
} from './schema'

export default async function (fastify: ServerInstance) {
  // POST /api/follows - フォロー（認証必須）
  fastify.post(
    '/',
    {
      preHandler: [authenticate],
      schema: {
        tags: ['Follows'],
        summary: 'フォロー',
        description: '対象ユーザーをフォローします。鍵垢の場合はフォローリクエストが作成されます。',
        body: followBodySchema,
        response: {
          201: followResponseSchema,
          202: followRequestCreatedResponseSchema,
          400: errorResponseSchema,
          404: errorResponseSchema,
          409: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const followerId = (request as AuthenticatedRequest).user.sub
      const { followingId } = request.body as { followingId: string }

      // 自己フォロー防止
      if (followerId === followingId) {
        return reply.status(400).send({ message: '自分自身をフォローできません' })
      }

      // 対象ユーザーの存在確認
      const targetUser = await prisma.user.findUnique({
        where: { id: followingId },
        select: { id: true, isPrivate: true },
      })

      if (!targetUser) {
        return reply.status(404).send({ message: 'ユーザーが見つかりません' })
      }

      // 既存のフォロー関係を確認
      const existingFollow = await prisma.follow.findUnique({
        where: { followerId_followingId: { followerId, followingId } },
      })

      if (existingFollow) {
        return reply.status(409).send({ message: '既にフォロー済みです' })
      }

      // 既存のフォローリクエストを確認
      const existingRequest = await prisma.followRequest.findUnique({
        where: { requesterId_targetId: { requesterId: followerId, targetId: followingId } },
      })

      if (existingRequest) {
        return reply.status(409).send({ message: '既にリクエスト送信済みです' })
      }

      // 鍵垢の場合はフォローリクエストを作成
      if (targetUser.isPrivate) {
        const followRequest = await prisma.followRequest.create({
          data: {
            requesterId: followerId,
            targetId: followingId,
          },
        })

        return reply.status(202).send({
          message: 'フォローリクエストを送信しました',
          followRequest: {
            id: followRequest.id,
            requesterId: followRequest.requesterId,
            targetId: followRequest.targetId,
            createdAt: followRequest.createdAt.toISOString(),
          },
        })
      }

      // 公開アカウントの場合は即座にフォロー
      const follow = await prisma.follow.create({
        data: { followerId, followingId },
      })

      return reply.status(201).send({
        message: 'フォローしました',
        follow: {
          id: follow.id,
          followerId: follow.followerId,
          followingId: follow.followingId,
          createdAt: follow.createdAt.toISOString(),
        },
      })
    },
  )

  // DELETE /api/follows/:followingId - アンフォロー（認証必須）
  fastify.delete(
    '/:followingId',
    {
      preHandler: [authenticate],
      schema: {
        tags: ['Follows'],
        summary: 'アンフォロー',
        description: '対象ユーザーへのフォローを解除します。',
        params: unfollowParamsSchema,
        response: {
          200: successResponseSchema,
          404: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const followerId = (request as AuthenticatedRequest).user.sub
      const { followingId } = request.params as { followingId: string }

      const existing = await prisma.follow.findUnique({
        where: { followerId_followingId: { followerId, followingId } },
      })

      if (!existing) {
        return reply.status(404).send({ message: 'フォロー関係が見つかりません' })
      }

      await prisma.follow.delete({
        where: { followerId_followingId: { followerId, followingId } },
      })

      return reply.send({ message: 'アンフォローしました' })
    },
  )
}
