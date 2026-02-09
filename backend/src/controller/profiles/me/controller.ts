import { prisma } from '../../../database'
import { calculateAge } from '../../../lib/age'
import { authenticate, deleteAuthUser } from '../../../lib/auth'
import type { ServerInstance } from '../../../lib/fastify'
import {
  deleteAvatarFiles,
  deleteWhisperFiles,
  generateAvatarDownloadSignedUrl,
} from '../../../services/storage'
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
      const { username, name, bio, birthMonth, avatarPath, legalConsent } = request.body

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

      // IPアドレスとUser-Agentを取得
      const ipAddress = request.headers['x-forwarded-for']?.toString().split(',')[0] || request.ip
      const userAgent = request.headers['user-agent'] || null

      // トランザクションでユーザーと同意履歴を作成
      const user = await prisma.$transaction(async (tx) => {
        // 新規ユーザーを作成
        const newUser = await tx.user.create({
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

        // 同意履歴を記録
        await tx.legalConsent.create({
          data: {
            userId: newUser.id,
            termsOfServiceVersion: legalConsent.termsOfServiceVersion,
            privacyPolicyVersion: legalConsent.privacyPolicyVersion,
            ipAddress,
            userAgent,
          },
        })

        return newUser
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
   * 自分のアカウントを完全に削除（DB、Cloud Storage、Supabase Auth）
   */
  fastify.delete(
    '/',
    {
      preHandler: [authenticate],
      schema: {
        tags: ['Profile'],
        summary: 'アカウント削除',
        description:
          '認証済みユーザーのアカウントを完全に削除します。DB、Cloud Storage、Supabase Authからすべてのデータを物理削除します。',
        response: {
          200: successResponseSchema,
          401: errorResponseSchema,
          500: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const userId = request.user.sub

      fastify.log.info({ userId }, 'Account deletion started')

      // ユーザーとWhisperファイル名を取得
      const user = await prisma.user.findUnique({
        where: { id: userId },
        include: {
          whispers: {
            select: { fileName: true },
          },
        },
      })

      if (!user) {
        return reply.status(401).send({ message: 'ユーザーが見つかりません' })
      }

      // 1. Cloud Storageからファイルを削除（DBにファイルパス情報があるため先に実行）
      // Whisper音声ファイルの削除（ベストエフォート）
      const whisperFileNames = user.whispers.map((w) => w.fileName)
      if (whisperFileNames.length > 0) {
        fastify.log.info({ userId, fileCount: whisperFileNames.length }, 'Deleting whisper files')
        const whisperResult = await deleteWhisperFiles(whisperFileNames, fastify.log)
        fastify.log.info(
          { userId, succeeded: whisperResult.succeeded, failed: whisperResult.failed },
          'Whisper files deletion completed',
        )
      }

      // アバター画像の削除（ベストエフォート）
      try {
        fastify.log.info({ userId }, 'Deleting avatar files')
        await deleteAvatarFiles(userId)
        fastify.log.info({ userId }, 'Avatar files deletion completed')
      } catch (err) {
        fastify.log.warn({ err, userId }, 'Failed to delete avatar files')
      }

      // 2. DBからユーザーを削除（Cascade Deleteで関連レコードも削除）
      try {
        fastify.log.info({ userId }, 'Deleting user from database')
        await prisma.user.delete({
          where: { id: userId },
        })
        fastify.log.info({ userId }, 'User deleted from database')
      } catch (err) {
        fastify.log.error({ err, userId }, 'Failed to delete user from database')
        return reply.status(500).send({ message: 'アカウント削除に失敗しました' })
      }

      // 3. Supabase Authからユーザーを削除（DB削除後に実行）
      fastify.log.info({ userId }, 'Deleting user from Supabase Auth')
      const authResult = await deleteAuthUser(userId)
      if (authResult.success) {
        fastify.log.info({ userId }, 'User deleted from Supabase Auth')
      } else {
        fastify.log.warn({ userId, error: authResult.error }, 'Failed to delete user from Supabase Auth')
      }

      fastify.log.info({ userId }, 'Account deletion completed')
      return reply.send({ message: 'アカウントを削除しました' })
    },
  )
}
