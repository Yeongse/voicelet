import { z } from 'zod'
import { prisma } from '../../../database'
import type { ServerInstance } from '../../../lib/fastify'
import { deleteWhisperFile } from '../../../services/storage'

const errorResponseSchema = z.object({
  message: z.string(),
})

const deleteQuerySchema = z.object({
  userId: z.string().min(1),
})

const deleteResponseSchema = z.object({
  message: z.string(),
})

const paramsSchema = z.object({
  whisperId: z.string().min(1),
})

export default async function (fastify: ServerInstance) {
  // ===========================================
  // DELETE /api/whispers/:whisperId
  // 指定Whisperを削除
  // ===========================================
  fastify.delete(
    '/',
    {
      schema: {
        tags: ['Whisper'],
        summary: 'ストーリー削除',
        description: '指定されたWhisperを削除します。オーナーのみ実行可能。',
        params: paramsSchema,
        querystring: deleteQuerySchema,
        response: {
          200: deleteResponseSchema,
          400: errorResponseSchema,
          403: errorResponseSchema,
          404: errorResponseSchema,
          500: errorResponseSchema,
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
        return reply.status(403).send({ message: 'ストーリーを削除する権限がありません' })
      }

      try {
        // GCSから音声ファイルを削除
        await deleteWhisperFile(whisper.fileName)

        // DBからWhisperを削除（WhisperViewはカスケード削除）
        await prisma.whisper.delete({
          where: { id: whisperId },
        })

        return reply.send({ message: 'ストーリーを削除しました' })
      } catch (error) {
        fastify.log.error(error, 'Failed to delete whisper')
        return reply.status(500).send({ message: 'ストーリーの削除に失敗しました' })
      }
    },
  )
}
