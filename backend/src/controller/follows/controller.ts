import { prisma } from '../../database'
import { type ServerInstance } from '../../lib/fastify'
import { followBodySchema, followResponseSchema, unfollowBodySchema, errorResponseSchema } from './schema'

export default async function (fastify: ServerInstance) {
  // POST /api/follows - フォロー
  fastify.post(
    '/',
    {
      schema: {
        tags: ['Follows'],
        summary: 'フォロー',
        body: followBodySchema,
        response: {
          201: followResponseSchema,
          400: errorResponseSchema,
          409: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const { followerId, followingId } = request.body as { followerId: string; followingId: string }

      if (followerId === followingId) {
        return reply.status(400).send({ message: '自分自身をフォローできません' })
      }

      const existing = await prisma.follow.findUnique({
        where: { followerId_followingId: { followerId, followingId } },
      })

      if (existing) {
        return reply.status(409).send({ message: '既にフォロー済みです' })
      }

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

  // DELETE /api/follows - アンフォロー
  fastify.delete(
    '/',
    {
      schema: {
        tags: ['Follows'],
        summary: 'アンフォロー',
        body: unfollowBodySchema,
        response: {
          200: { type: 'object', properties: { message: { type: 'string' } } },
          404: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const { followerId, followingId } = request.body as { followerId: string; followingId: string }

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
