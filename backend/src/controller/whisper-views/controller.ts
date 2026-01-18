import { prisma } from '../../database'
import type { ServerInstance } from '../../lib/fastify'
import { errorResponseSchema, viewBodySchema, viewResponseSchema } from './schema'

export default async function (fastify: ServerInstance) {
  // POST /api/whisper-views - 視聴履歴記録（Upsert対応）
  fastify.post(
    '/',
    {
      schema: {
        tags: ['WhisperViews'],
        summary: '視聴履歴記録',
        description: '視聴履歴を記録します。既に視聴済みの場合は閲覧日時を更新します。',
        body: viewBodySchema,
        response: {
          200: viewResponseSchema,
          201: viewResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const { userId, whisperId } = request.body as { userId: string; whisperId: string }

      // 既存レコードを先に確認
      const existing = await prisma.whisperView.findUnique({
        where: { userId_whisperId: { userId, whisperId } },
      })

      if (existing) {
        // 既存レコードがある場合は閲覧日時のみ更新
        const view = await prisma.whisperView.update({
          where: { userId_whisperId: { userId, whisperId } },
          data: { viewedAt: new Date() },
        })

        return reply.status(200).send({
          message: '視聴履歴を更新しました',
          view: {
            id: view.id,
            userId: view.userId,
            whisperId: view.whisperId,
            viewedAt: view.viewedAt.toISOString(),
          },
        })
      }

      // 新規作成
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
