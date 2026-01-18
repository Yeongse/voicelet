import { prisma } from '../../../../database'
import type { ServerInstance } from '../../../../lib/fastify'
import {
  errorResponseSchema,
  viewersParamsSchema,
  viewersQuerySchema,
  viewersResponseSchema,
} from './schema'

export default async function (fastify: ServerInstance) {
  // ===========================================
  // GET /api/whispers/:whisperId/viewers
  // 指定Whisperの閲覧者一覧を取得
  // ===========================================
  fastify.get(
    '/',
    {
      schema: {
        tags: ['Whisper'],
        summary: '閲覧者一覧取得',
        description: '指定されたWhisperの閲覧者一覧を取得します。オーナーのみアクセス可能。',
        params: viewersParamsSchema,
        querystring: viewersQuerySchema,
        response: {
          200: viewersResponseSchema,
          400: errorResponseSchema,
          403: errorResponseSchema,
          404: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const { whisperId } = request.params
      const { userId } = request.query

      // Whisperの存在確認
      const whisper = await prisma.whisper.findUnique({
        where: { id: whisperId },
      })

      if (!whisper) {
        return reply.status(404).send({ message: 'ストーリーが見つかりません' })
      }

      // オーナー検証
      if (whisper.userId !== userId) {
        return reply.status(403).send({ message: '閲覧者一覧を確認する権限がありません' })
      }

      // 閲覧者一覧を取得（閲覧日時の降順）
      const views = await prisma.whisperView.findMany({
        where: { whisperId },
        include: {
          user: {
            select: {
              id: true,
              name: true,
              avatarPath: true,
            },
          },
        },
        orderBy: { viewedAt: 'desc' },
      })

      const viewers = views.map((view) => ({
        id: view.user.id,
        name: view.user.name ?? '',
        avatarUrl: view.user.avatarPath,
        viewedAt: view.viewedAt.toISOString(),
      }))

      return reply.send({
        data: viewers,
        totalCount: viewers.length,
      })
    },
  )
}
