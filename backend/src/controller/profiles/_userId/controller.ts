import { prisma } from '../../../database'
import { calculateAge } from '../../../lib/age'
import type { ServerInstance } from '../../../lib/fastify'
import { generateAvatarDownloadSignedUrl } from '../../../services/storage'
import { errorResponseSchema, publicProfileResponseSchema } from '../schema'
import { getUserProfileParamsSchema } from './schema'

export default async function (fastify: ServerInstance) {
  /**
   * GET /api/profiles/:userId
   * 他ユーザーの公開プロフィールを取得
   */
  fastify.get(
    '/',
    {
      schema: {
        tags: ['Profile'],
        summary: '他ユーザーのプロフィール取得',
        description: '指定されたユーザーの公開プロフィール情報を取得します。',
        params: getUserProfileParamsSchema,
        response: {
          200: publicProfileResponseSchema,
          404: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const { userId } = request.params

      const user = await prisma.user.findUnique({
        where: { id: userId },
      })

      if (!user) {
        return reply.status(404).send({ message: 'ユーザーが見つかりません' })
      }

      // アバター画像の署名付きURLを生成
      let avatarUrl: string | null = null
      if (user.avatarPath) {
        try {
          avatarUrl = await generateAvatarDownloadSignedUrl(user.avatarPath, 60)
        } catch (err) {
          fastify.log.warn({ err, avatarPath: user.avatarPath }, 'Failed to generate avatar URL')
        }
      }

      // 公開プロフィールはbirthMonthを含めない（ageのみ）
      return reply.send({
        id: user.id,
        email: user.email,
        name: user.name,
        bio: user.bio,
        age: calculateAge(user.birthMonth),
        avatarUrl,
        createdAt: user.createdAt.toISOString(),
        updatedAt: user.updatedAt.toISOString(),
      })
    },
  )
}
