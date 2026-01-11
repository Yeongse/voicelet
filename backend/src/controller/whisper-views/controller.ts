import { prisma } from '../../database'
import { type ServerInstance } from '../../lib/fastify'
import { viewBodySchema, viewResponseSchema, errorResponseSchema } from './schema'

export default async function (fastify: ServerInstance) {
  // POST /api/whisper-views - 視聴履歴記録
  fastify.post(
    '/',
    {
      schema: {
        tags: ['WhisperViews'],
        summary: '視聴履歴記録',
        body: viewBodySchema,
        response: {
          201: viewResponseSchema,
          409: viewResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const { userId, whisperId } = request.body as { userId: string; whisperId: string }

      // 既存の視聴履歴をチェック
      const existing = await prisma.whisperView.findUnique({
        where: { userId_whisperId: { userId, whisperId } },
      })

      if (existing) {
        return reply.status(409).send({
          message: '既に視聴済みです',
          view: {
            id: existing.id,
            userId: existing.userId,
            whisperId: existing.whisperId,
            viewedAt: existing.viewedAt.toISOString(),
          },
        })
      }

      const view = await prisma.whisperView.create({
        data: { userId, whisperId },
      })

      return reply.status(201).send({
        message: '視聴履歴を記録しました',
        view: {
          id: view.id,
          userId: view.userId,
          whisperId: view.whisperId,
          viewedAt: view.viewedAt.toISOString(),
        },
      })
    },
  )
}
