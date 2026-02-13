import { z } from 'zod'
import { prisma } from '../../database'
import type { ServerInstance } from '../../lib/fastify'
import { authenticate, optionalAuthenticate, type AuthenticatedRequest } from '../../lib/auth'
import { buildPaginationResponse, calculatePagination } from '../../lib/pagination'
import {
  fileExists,
  generateDownloadSignedUrl,
  generateUploadSignedUrl,
  getBucketName,
} from '../../services/storage'
import {
  audioUrlResponseSchema,
  createWhisperRequestSchema,
  createWhisperResponseSchema,
  errorResponseSchema,
  listWhispersQuerySchema,
  listWhispersResponseSchema,
  signedUrlRequestSchema,
  signedUrlResponseSchema,
} from './schema'

export default async function (fastify: ServerInstance) {
  // ===========================================
  // POST /api/whispers/signed-url
  // アップロード用の署名付きURLを生成
  // ===========================================
  fastify.post(
    '/signed-url',
    {
      preHandler: [authenticate],
      schema: {
        tags: ['Whisper'],
        summary: '署名付きURL生成',
        description: 'GCSへのアップロード用署名付きURLを生成します。',
        body: signedUrlRequestSchema,
        response: {
          200: signedUrlResponseSchema,
          401: errorResponseSchema,
          404: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const { fileName } = request.body
      const userId = (request as AuthenticatedRequest).user.sub

      // ユーザー存在確認
      const user = await prisma.user.findUnique({
        where: { id: userId },
      })

      if (!user) {
        return reply.status(404).send({ message: 'ユーザーが見つかりません' })
      }

      const { signedUrl, expiresAt } = await generateUploadSignedUrl({
        fileName,
        contentType: 'audio/mp4',
        expiresInMinutes: 15,
      })

      return reply.send({
        signedUrl,
        bucketName: getBucketName(),
        fileName,
        expiresAt: expiresAt.toISOString(),
      })
    },
  )

  // ===========================================
  // POST /api/whispers
  // 音声投稿を作成
  // ===========================================
  fastify.post(
    '/',
    {
      preHandler: [authenticate],
      schema: {
        tags: ['Whisper'],
        summary: '音声投稿作成',
        description: 'GCSへのアップロード完了後に呼び出し、音声投稿のメタデータを保存します。',
        body: createWhisperRequestSchema,
        response: {
          201: createWhisperResponseSchema,
          400: errorResponseSchema,
          401: errorResponseSchema,
          404: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const { fileName, duration } = request.body
      const userId = (request as AuthenticatedRequest).user.sub

      // ユーザー存在確認
      const user = await prisma.user.findUnique({
        where: { id: userId },
      })

      if (!user) {
        return reply.status(404).send({ message: 'ユーザーが見つかりません' })
      }

      // ファイルがGCSに存在するか確認
      const exists = await fileExists(fileName)
      if (!exists) {
        return reply.status(400).send({
          message: '音声ファイルがアップロードされていません',
        })
      }

      const bucketName = getBucketName()

      // expiresAt = createdAt + 24時間
      const now = new Date()
      const expiresAt = new Date(now.getTime() + 24 * 60 * 60 * 1000)

      const whisper = await prisma.whisper.create({
        data: {
          userId,
          bucketName,
          fileName,
          duration,
          expiresAt,
        },
      })

      return reply.status(201).send({
        message: '音声投稿を作成しました',
        whisper: {
          id: whisper.id,
          userId: whisper.userId,
          bucketName: whisper.bucketName,
          fileName: whisper.fileName,
          duration: whisper.duration,
          createdAt: whisper.createdAt.toISOString(),
          expiresAt: whisper.expiresAt.toISOString(),
        },
      })
    },
  )

  // ===========================================
  // GET /api/whispers
  // 音声投稿一覧を取得
  // ===========================================
  fastify.get(
    '/',
    {
      preHandler: [authenticate],
      schema: {
        tags: ['Whisper'],
        summary: '音声投稿一覧',
        description: '音声投稿の一覧を取得します。userIdでフィルタ可能。',
        querystring: listWhispersQuerySchema,
        response: {
          200: listWhispersResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const { page, limit, userId: targetUserId } = request.query
      const currentUserId = (request as AuthenticatedRequest).user.sub

      const { skip, take } = calculatePagination({ page, limit })

      // targetUserIdが指定されている場合、プライバシーチェック
      if (targetUserId && targetUserId !== currentUserId) {
        const targetUser = await prisma.user.findUnique({
          where: { id: targetUserId },
          select: { id: true, isPrivate: true },
        })

        if (targetUser?.isPrivate) {
          const isFollower = await prisma.follow.findUnique({
            where: {
              followerId_followingId: {
                followerId: currentUserId,
                followingId: targetUserId,
              },
            },
          })

          if (!isFollower) {
            return reply.status(403).send({ message: 'このユーザーの投稿を表示する権限がありません' })
          }
        }
      }

      const where = targetUserId ? { userId: targetUserId } : {}

      const [whispers, total] = await Promise.all([
        prisma.whisper.findMany({
          where,
          skip,
          take,
          orderBy: { createdAt: 'desc' },
        }),
        prisma.whisper.count({ where }),
      ])

      const whispersData = whispers.map((whisper) => ({
        id: whisper.id,
        userId: whisper.userId,
        bucketName: whisper.bucketName,
        fileName: whisper.fileName,
        duration: whisper.duration,
        createdAt: whisper.createdAt.toISOString(),
        expiresAt: whisper.expiresAt.toISOString(),
      }))

      const response = buildPaginationResponse({
        data: whispersData,
        total,
        page,
        limit,
      })

      return reply.send(response)
    },
  )

  // ===========================================
  // GET /api/whispers/:whisperId/audio-url
  // 再生用署名付きURLを取得
  // ===========================================
  fastify.get(
    '/:whisperId/audio-url',
    {
      preHandler: [authenticate],
      schema: {
        tags: ['Whisper'],
        summary: '再生用署名付きURL取得',
        description: '指定されたWhisperの再生用署名付きURLを生成します。',
        params: z.object({
          whisperId: z.string(),
        }),
        response: {
          200: audioUrlResponseSchema,
          401: errorResponseSchema,
          403: errorResponseSchema,
          404: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const { whisperId } = request.params as { whisperId: string }
      const currentUserId = (request as AuthenticatedRequest).user.sub

      const whisper = await prisma.whisper.findUnique({
        where: { id: whisperId },
        include: {
          user: {
            select: { id: true, isPrivate: true },
          },
        },
      })

      if (!whisper) {
        return reply.status(404).send({ message: '投稿が見つかりません' })
      }

      // 鍵垢の場合、フォロワーかオーナーのみアクセス可能
      if (whisper.user.isPrivate && whisper.userId !== currentUserId) {
        const isFollower = await prisma.follow.findUnique({
          where: {
            followerId_followingId: {
              followerId: currentUserId,
              followingId: whisper.userId,
            },
          },
        })

        if (!isFollower) {
          return reply.status(403).send({ message: 'この投稿を再生する権限がありません' })
        }
      }

      // GCS上にファイルが存在するか確認
      const exists = await fileExists(whisper.fileName)
      if (!exists) {
        fastify.log.warn({ fileName: whisper.fileName, whisperId }, 'Audio file not found in GCS')
        return reply.status(404).send({ message: '音声ファイルが見つかりません' })
      }

      const expiresInMinutes = 60
      const expiresAt = new Date()
      expiresAt.setMinutes(expiresAt.getMinutes() + expiresInMinutes)

      const signedUrl = await generateDownloadSignedUrl(whisper.fileName, expiresInMinutes)

      return reply.send({
        signedUrl,
        expiresAt: expiresAt.toISOString(),
      })
    },
  )
}
