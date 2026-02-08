import { prisma } from '../../database'
import type { ServerInstance } from '../../lib/fastify'
import { authenticate, type AuthenticatedRequest } from '../../lib/auth'
import {
  errorResponseSchema,
  viewBodySchema,
  viewResponseSchema,
  alreadyViewedResponseSchema,
} from './schema'

export default async function (fastify: ServerInstance) {
  // POST /api/whisper-views - 視聴履歴記録
  fastify.post(
    '/',
    {
      preHandler: [authenticate],
      schema: {
        tags: ['WhisperViews'],
        summary: '視聴履歴記録',
        description: '視聴履歴を記録します。既に視聴済みの場合は409を返します。',
        body: viewBodySchema,
        response: {
          201: viewResponseSchema,
          401: errorResponseSchema,
          409: alreadyViewedResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const { whisperId } = request.body as { whisperId: string }
      const userId = (request as AuthenticatedRequest).user.sub

      // 既存レコードを先に確認
      const existing = await prisma.whisperView.findUnique({
        where: { userId_whisperId: { userId, whisperId } },
      })

      if (existing) {
        // 既に視聴済みの場合は409を返す
        return reply.status(409).send({
          message: '既に視聴済みです',
          viewedAt: existing.viewedAt.toISOString(),
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
