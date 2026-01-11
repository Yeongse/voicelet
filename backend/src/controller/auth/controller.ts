import { createClient } from '@supabase/supabase-js'
import { prisma } from '../../database'
import type { ServerInstance } from '../../lib/fastify'
import {
  authCallbackRequestSchema,
  authCallbackResponseSchema,
  errorResponseSchema,
} from './schema'

// Supabaseクライアント（サーバーサイド用）
const supabase = createClient(
  process.env.SUPABASE_URL || '',
  process.env.SUPABASE_SERVICE_ROLE_KEY || '',
)

export default async function (fastify: ServerInstance) {
  /**
   * POST /api/auth/callback
   * Supabase Auth認証後のコールバック処理
   * トークンを検証し、DBに登録済みかどうかを返す（永続化はしない）
   */
  fastify.post(
    '/callback',
    {
      schema: {
        tags: ['Auth'],
        summary: '認証コールバック',
        description:
          'Supabase Auth認証後にコールされ、ユーザーがDBに登録済みかどうかを返します。ユーザーの永続化は行いません。',
        body: authCallbackRequestSchema,
        response: {
          200: authCallbackResponseSchema,
          400: errorResponseSchema,
          401: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const { accessToken } = request.body

      // Supabase APIを使ってトークンを検証し、ユーザー情報を取得
      const { data, error } = await supabase.auth.getUser(accessToken)

      if (error || !data.user) {
        console.error('[Supabase Auth Error]', error)
        return reply.status(401).send({ message: '無効なアクセストークンです' })
      }

      const supabaseUserId = data.user.id
      const email = data.user.email

      if (!supabaseUserId || !email) {
        return reply.status(400).send({ message: '無効なユーザー情報です' })
      }

      // DBにユーザーが存在するかチェック（IDまたはemailで検索）
      const existingUser = await prisma.user.findFirst({
        where: {
          OR: [{ id: supabaseUserId }, { email }],
        },
      })

      return reply.send({
        id: supabaseUserId,
        email,
        isRegistered: existingUser !== null,
      })
    },
  )
}
