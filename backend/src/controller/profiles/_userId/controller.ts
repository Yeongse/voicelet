import { prisma } from '../../../database'
import { calculateAge } from '../../../lib/age'
import type { AuthenticatedRequest } from '../../../lib/auth'
import { optionalAuthenticate } from '../../../lib/auth'
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
      preHandler: [optionalAuthenticate],
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
      const currentUserId = (request as AuthenticatedRequest).user?.sub

      const user = await prisma.user.findUnique({
        where: { id: userId },
        include: {
          _count: {
            select: {
              followers: true,
              following: true,
            },
          },
        },
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

      // フォロー状態を判定
      let followStatus: 'none' | 'following' | 'requested' = 'none'
      const isOwnProfile = currentUserId === userId

      if (currentUserId && !isOwnProfile) {
        // フォロー中かチェック
        const existingFollow = await prisma.follow.findUnique({
          where: {
            followerId_followingId: {
              followerId: currentUserId,
              followingId: userId,
            },
          },
        })

        if (existingFollow) {
          followStatus = 'following'
        } else {
          // リクエスト中かチェック
          const existingRequest = await prisma.followRequest.findUnique({
            where: {
              requesterId_targetId: {
                requesterId: currentUserId,
                targetId: userId,
              },
            },
          })

          if (existingRequest) {
            followStatus = 'requested'
          }
        }
      }

      // 公開プロフィールはbirthMonthを含めない（ageのみ）
      return reply.send({
        id: user.id,
        email: user.email,
        username: user.username,
        name: user.name,
        bio: user.bio,
        age: calculateAge(user.birthMonth),
        avatarUrl,
        isPrivate: user.isPrivate,
        followersCount: user._count.followers,
        followingCount: user._count.following,
        followStatus,
        isOwnProfile,
        createdAt: user.createdAt.toISOString(),
        updatedAt: user.updatedAt.toISOString(),
      })
    },
  )
}
