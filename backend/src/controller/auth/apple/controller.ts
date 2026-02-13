import { createRemoteJWKSet, jwtVerify, errors } from 'jose'
import { createClient } from '@supabase/supabase-js'
import type { ServerInstance } from '../../../lib/fastify'
import { prisma } from '../../../database'
import { deleteAuthUser } from '../../../lib/auth'
import { deleteAvatarFiles, deleteWhisperFiles } from '../../../services/storage'
import { appleRevocationRequestSchema, appleEventPayloadSchema, errorResponseSchema } from './schema'

// Apple OIDC公開鍵のURL
const APPLE_JWKS_URL = 'https://appleid.apple.com/auth/keys'

// JWKSをキャッシュ（パフォーマンス最適化）
const appleJWKS = createRemoteJWKSet(new URL(APPLE_JWKS_URL))

// Supabaseクライアント（サービスロールキー使用）
const supabase = createClient(
  process.env.SUPABASE_URL || '',
  process.env.SUPABASE_SERVICE_ROLE_KEY || '',
)

// Apple Bundle ID（環境変数から取得）
const APPLE_BUNDLE_ID = process.env.APPLE_BUNDLE_ID || ''

export default async function (fastify: ServerInstance) {
  /**
   * POST /api/auth/apple/revocation
   * Apple Server-to-Server通知の受信エンドポイント
   * ユーザーがApple設定からVoiceletの認証を取り消した時に呼び出される
   */
  fastify.post(
    '/revocation',
    {
      schema: {
        tags: ['Auth'],
        summary: 'Apple認証取り消し通知',
        description:
          'Apple Server-to-Server通知を受信し、ユーザーセッションを無効化します。',
        body: appleRevocationRequestSchema,
        response: {
          200: {},
          400: errorResponseSchema,
          500: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const { payload } = request.body

      try {
        // JWT署名を検証
        const { payload: jwtPayload } = await jwtVerify(payload, appleJWKS, {
          issuer: 'https://appleid.apple.com',
          audience: APPLE_BUNDLE_ID,
        })

        fastify.log.info({ jwtPayload }, 'Apple通知JWTを検証しました')

        // eventsフィールドを取得（JSON文字列）
        const eventsStr = jwtPayload.events as string | undefined
        if (!eventsStr) {
          fastify.log.warn('eventsフィールドがありません')
          return reply.status(400).send({ message: 'Invalid payload: events field missing' })
        }

        // eventsをパース
        const eventsData = JSON.parse(eventsStr)
        const eventPayload = appleEventPayloadSchema.safeParse(eventsData)

        if (!eventPayload.success) {
          fastify.log.warn({ error: eventPayload.error }, 'イベントペイロードが不正です')
          return reply.status(400).send({ message: 'Invalid event payload' })
        }

        const { type, sub } = eventPayload.data

        fastify.log.info({ type, sub }, 'Appleイベントを受信しました')

        // consent-revokedイベントの処理
        if (type === 'consent-revoked') {
          // Apple subからSupabaseユーザーを検索
          // Supabase Auth管理でApple User IDはidentitiesに保存される
          const { data: users, error: listError } = await supabase.auth.admin.listUsers()

          if (listError) {
            fastify.log.error({ error: listError }, 'ユーザー一覧の取得に失敗しました')
            return reply.status(500).send({ message: 'Internal server error' })
          }

          // Apple subに一致するユーザーを検索
          const targetUser = users.users.find((user) =>
            user.identities?.some(
              (identity) => identity.provider === 'apple' && identity.id === sub
            )
          )

          if (targetUser) {
            // ユーザーのセッションを無効化（サインアウト）
            const { error: signOutError } = await supabase.auth.admin.signOut(
              targetUser.id,
              'global' // すべてのセッションをログアウト
            )

            if (signOutError) {
              fastify.log.error({ error: signOutError, userId: targetUser.id }, 'セッション無効化に失敗しました')
              return reply.status(500).send({ message: 'Failed to invalidate session' })
            }

            fastify.log.info({ userId: targetUser.id, appleSub: sub }, 'ユーザーセッションを無効化しました')
          } else {
            fastify.log.warn({ appleSub: sub }, '対象ユーザーが見つかりませんでした')
          }
        }

        // account-deleteイベント: アカウントを完全に削除
        if (type === 'account-delete') {
          fastify.log.info({ sub }, 'account-deleteイベントを受信しました')

          // Apple subからSupabaseユーザーを検索
          const { data: usersForDelete, error: listErrorForDelete } = await supabase.auth.admin.listUsers()

          if (listErrorForDelete) {
            fastify.log.error({ error: listErrorForDelete }, 'ユーザー一覧の取得に失敗しました')
            return reply.status(500).send({ message: 'Internal server error' })
          }

          // Apple subに一致するユーザーを検索
          const userToDelete = usersForDelete.users.find((user) =>
            user.identities?.some(
              (identity) => identity.provider === 'apple' && identity.id === sub
            )
          )

          if (userToDelete) {
            const userId = userToDelete.id
            fastify.log.info({ userId, appleSub: sub }, 'アカウント削除を開始します')

            // ユーザーとWhisperファイル名を取得
            const dbUser = await prisma.user.findUnique({
              where: { id: userId },
              include: {
                whispers: {
                  select: { fileName: true },
                },
              },
            })

            if (dbUser) {
              // 1. Cloud Storageからファイルを削除
              // Whisper音声ファイルの削除（ベストエフォート）
              const whisperFileNames = dbUser.whispers.map((w) => w.fileName)
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
                return reply.status(500).send({ message: 'Failed to delete user from database' })
              }
            } else {
              fastify.log.warn({ userId }, 'DBにユーザーが存在しません（Auth側のみ削除）')
            }

            // 3. Supabase Authからユーザーを削除
            fastify.log.info({ userId }, 'Deleting user from Supabase Auth')
            const authResult = await deleteAuthUser(userId)
            if (authResult.success) {
              fastify.log.info({ userId }, 'User deleted from Supabase Auth')
            } else {
              fastify.log.warn({ userId, error: authResult.error }, 'Failed to delete user from Supabase Auth')
            }

            fastify.log.info({ userId, appleSub: sub }, 'アカウント削除が完了しました')
          } else {
            fastify.log.warn({ appleSub: sub }, '対象ユーザーが見つかりませんでした')
          }
        }

        return reply.status(200).send()
      } catch (error) {
        // JWT検証エラー（joseエラー）
        if (
          error instanceof errors.JOSEError ||
          error instanceof errors.JWTExpired ||
          error instanceof errors.JWTClaimValidationFailed ||
          error instanceof errors.JWSSignatureVerificationFailed ||
          error instanceof errors.JWKSNoMatchingKey
        ) {
          fastify.log.warn({ error: (error as Error).message }, 'JWT検証に失敗しました')
          return reply.status(400).send({ message: 'Invalid JWT' })
        }

        fastify.log.error({ error }, 'Apple通知の処理中にエラーが発生しました')
        return reply.status(500).send({ message: 'Internal server error' })
      }
    },
  )
}
