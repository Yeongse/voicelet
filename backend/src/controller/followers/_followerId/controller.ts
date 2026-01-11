import { prisma } from '../../../database'
import type { AuthenticatedRequest } from '../../../lib/auth'
import { authenticate } from '../../../lib/auth'
import type { ServerInstance } from '../../../lib/fastify'
import {
  errorResponseSchema,
  removeFollowerParamsSchema,
  successResponseSchema,
} from '../../follows/schema'

export default async function (fastify: ServerInstance) {
  // DELETE /api/followers/:followerId - フォロワー削除（認証必須）
  fastify.delete(
    '/',
    {
      preHandler: [authenticate],
      schema: {
        tags: ['Follows'],
        summary: 'フォロワー削除',
        description: '指定したフォロワーを削除します（自分のフォロワーのみ削除可能）。',
        params: removeFollowerParamsSchema,
        response: {
          200: successResponseSchema,
          404: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const userId = (request as AuthenticatedRequest).user.sub
      const { followerId } = request.params as { followerId: string }

      // 対象のフォロー関係を確認（自分をフォローしているユーザー）
      const existing = await prisma.follow.findUnique({
        where: { followerId_followingId: { followerId, followingId: userId } },
      })

      if (!existing) {
        return reply.status(404).send({ message: 'フォロワー関係が見つかりません' })
      }

      await prisma.follow.delete({
        where: { followerId_followingId: { followerId, followingId: userId } },
      })

      return reply.send({ message: 'フォロワーを削除しました' })
    },
  )
}
