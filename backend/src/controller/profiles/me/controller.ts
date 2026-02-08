import { prisma } from '../../../database'
import { calculateAge } from '../../../lib/age'
import { authenticate } from '../../../lib/auth'
import type { ServerInstance } from '../../../lib/fastify'
import { generateAvatarDownloadSignedUrl } from '../../../services/storage'
import {
  errorResponseSchema,
  myProfileResponseSchema,
  registerProfileRequestSchema,
  successResponseSchema,
  updateProfileRequestSchema,
} from '../schema'

export default async function (fastify: ServerInstance) {
  /**
   * POST /api/profiles/me
   * プロフィールを新規登録（ユーザーをDBに永続化）
   */
  fastify.post(
    '/',
    {
      preHandler: [authenticate],
      schema: {
        tags: ['Profile'],
        summary: 'プロフィール新規登録',
        description:
          '認証済みユーザーのプロフィールを新規登録します。表示名は必須です。このエンドポイントでユーザーがDBに永続化されます。',
        body: registerProfileRequestSchema,
        response: {
          201: myProfileResponseSchema,
          400: errorResponseSchema,
          401: errorResponseSchema,
          409: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const userId = request.user.sub
      const email = request.user.email
      const { username, name, bio, birthMonth, avatarPath } = request.body

      // 既にユーザーが存在するかチェック
      const existingUser = await prisma.user.findUnique({
        where: { id: userId },
      })

      if (existingUser) {
        return reply.status(409).send({ message: '既に登録済みです' })
      }

      // usernameの重複チェック（case-insensitive）
      const existingUsername = await prisma.user.findFirst({
        where: {
          username: {
            equals: username,
            mode: 'insensitive',
          },
        },
      })

      if (existingUsername) {
        return reply.status(409).send({ message: 'このユーザー名は既に使用されています' })
      }

      // 新規ユーザーを作成
      const user = await prisma.user.create({
        data: {
          id: userId,
          email: email || '',
          username,
          name,
          bio: bio || null,
          birthMonth: birthMonth || null,
          avatarPath: avatarPath || null,
        },
      })

      // アバター画像の署名付きURLを生成
      let avatarUrl: string | null = null
      if (user.avatarPath) {
        try {
          avatarUrl = await generateAvatarDownloadSignedUrl(user.avatarPath, 60)
        } catch (err) {
          fastify.log.warn({ err, avatarPath: user.avatarPath }, 'Failed to generate avatar URL')
        }
      }

      return reply.status(201).send({
        id: user.id,
        email: user.email,
        username: user.username,
        name: user.name,
        bio: user.bio,
        birthMonth: user.birthMonth,
        age: calculateAge(user.birthMonth),
        avatarUrl,
        isPrivate: user.isPrivate,
        followingCount: 0,
        followersCount: 0,
        createdAt: user.createdAt.toISOString(),
        updatedAt: user.updatedAt.toISOString(),
      })
    },
  )

  /**
   * GET /api/profiles/me
   * 自分のプロフィールを取得
   */
  fastify.get(
    '/',
    {
      preHandler: [authenticate],
      schema: {
        tags: ['Profile'],
        summary: '自分のプロフィール取得',
        description: '認証済みユーザーの完全なプロフィール情報を取得します。',
        response: {
          200: myProfileResponseSchema,
          401: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const userId = request.user.sub

      const user = await prisma.user.findUnique({
        where: { id: userId },
        include: {
          _count: {
            select: {
              following: true,
              followers: true,
            },
          },
        },
      })

      if (!user) {
        return reply.status(401).send({ message: 'ユーザーが見つかりません' })
      }

      // アバター画像の署名付きURLを生成
      let avatarUrl: string | null = null
      if (user.avatarPath) {
        try {
          avatarUrl = await generateAvatarDownloadSignedUrl(user.avatarPath, 60)
        } catch (err) {
          // ストレージエラーは無視してnullを返す
          fastify.log.warn({ err, avatarPath: user.avatarPath }, 'Failed to generate avatar URL')
        }
      }

      return reply.send({
        id: user.id,
        email: user.email,
        username: user.username,
        name: user.name,
        bio: user.bio,
        birthMonth: user.birthMonth,
        age: calculateAge(user.birthMonth),
        avatarUrl,
        isPrivate: user.isPrivate,
        followingCount: user._count.following,
        followersCount: user._count.followers,
        createdAt: user.createdAt.toISOString(),
        updatedAt: user.updatedAt.toISOString(),
      })
    },
  )

  /**
   * PATCH /api/profiles/me
   * 自分のプロフィールを更新
   */
  fastify.patch(
    '/',
    {
      preHandler: [authenticate],
      schema: {
        tags: ['Profile'],
        summary: 'プロフィール更新',
        description: '認証済みユーザーのプロフィール情報を更新します。',
        body: updateProfileRequestSchema,
        response: {
          200: myProfileResponseSchema,
          400: errorResponseSchema,
          401: errorResponseSchema,
          409: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const userId = request.user.sub
      const { username, name, bio, birthMonth, avatarPath, isPrivate } = request.body

      // usernameが変更される場合、重複チェック
      if (username !== undefined) {
        const existingUsername = await prisma.user.findFirst({
          where: {
            username: {
              equals: username,
              mode: 'insensitive',
            },
            NOT: {
              id: userId,
            },
          },
        })

        if (existingUsername) {
          return reply.status(409).send({ message: 'このユーザー名は既に使用されています' })
        }
      }

      const user = await prisma.user.update({
        where: { id: userId },
        data: {
          ...(username !== undefined && { username }),
          ...(name !== undefined && { name }),
          ...(bio !== undefined && { bio }),
          ...(birthMonth !== undefined && { birthMonth }),
          ...(avatarPath !== undefined && { avatarPath }),
          ...(isPrivate !== undefined && { isPrivate }),
        },
        include: {
          _count: {
            select: {
              following: true,
              followers: true,
            },
          },
        },
      })

      // アバター画像の署名付きURLを生成
      let avatarUrl: string | null = null
      if (user.avatarPath) {
        try {
          avatarUrl = await generateAvatarDownloadSignedUrl(user.avatarPath, 60)
        } catch (err) {
          fastify.log.warn({ err, avatarPath: user.avatarPath }, 'Failed to generate avatar URL')
        }
      }

      return reply.send({
        id: user.id,
        email: user.email,
        username: user.username,
        name: user.name,
        bio: user.bio,
        birthMonth: user.birthMonth,
        age: calculateAge(user.birthMonth),
        avatarUrl,
        isPrivate: user.isPrivate,
        followingCount: user._count.following,
        followersCount: user._count.followers,
        createdAt: user.createdAt.toISOString(),
        updatedAt: user.updatedAt.toISOString(),
      })
    },
  )

  /**
   * DELETE /api/profiles/me
   * 自分のアカウントを削除
   */
  fastify.delete(
    '/',
    {
      preHandler: [authenticate],
      schema: {
        tags: ['Profile'],
        summary: 'アカウント削除',
        description: '認証済みユーザーのアカウントを削除します。',
        response: {
          200: successResponseSchema,
          401: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const userId = request.user.sub

      const user = await prisma.user.findUnique({
        where: { id: userId },
      })

      if (!user) {
        return reply.status(401).send({ message: 'ユーザーが見つかりません' })
      }

      // TODO: Cloud Storageからアバター画像を削除
      // TODO: Supabase Authからユーザーを削除

      // ローカルDBからユーザーを削除
      await prisma.user.delete({
        where: { id: userId },
      })

      return reply.send({ message: 'アカウントを削除しました' })
    },
  )
}
