import { authenticate } from '../../../../lib/auth'
import type { ServerInstance } from '../../../../lib/fastify'
import { generateAvatarUploadSignedUrl } from '../../../../services/storage'
import {
  avatarUploadRequestSchema,
  avatarUploadResponseSchema,
  errorResponseSchema,
} from '../../schema'

export default async function (fastify: ServerInstance) {
  /**
   * POST /api/profiles/me/avatar/upload-url
   * アバターアップロード用の署名付きURLを生成
   */
  fastify.post(
    '/upload-url',
    {
      preHandler: [authenticate],
      schema: {
        tags: ['Profile'],
        summary: 'アバターアップロードURL生成',
        description:
          'アバター画像をCloud Storageに直接アップロードするための署名付きURLを生成します。',
        body: avatarUploadRequestSchema,
        response: {
          200: avatarUploadResponseSchema,
          400: errorResponseSchema,
          401: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const userId = request.user.sub
      const { contentType, fileSize, fileName } = request.body

      try {
        const result = await generateAvatarUploadSignedUrl({
          userId,
          contentType,
          fileSize,
          fileName,
        })

        return reply.send({
          uploadUrl: result.signedUrl,
          avatarPath: result.avatarPath,
          expiresAt: result.expiresAt.toISOString(),
        })
      } catch (err) {
        fastify.log.error({ err }, 'Failed to generate avatar upload URL')
        return reply.status(400).send({ message: '署名付きURLの生成に失敗しました' })
      }
    },
  )
}
