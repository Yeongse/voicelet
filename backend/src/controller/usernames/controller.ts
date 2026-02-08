import { prisma } from '../../database'
import type { ServerInstance } from '../../lib/fastify'
import {
  errorResponseSchema,
  usernameCheckQuerySchema,
  usernameCheckResponseSchema,
} from './schema'

export default async function (fastify: ServerInstance) {
  /**
   * GET /api/usernames/check
   * ユーザー名の使用可否を確認
   */
  fastify.get(
    '/check',
    {
      schema: {
        tags: ['Username'],
        summary: 'ユーザー名使用可否チェック',
        description: '指定されたユーザー名が使用可能かどうかを確認します。',
        querystring: usernameCheckQuerySchema,
        response: {
          200: usernameCheckResponseSchema,
          400: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const { username } = request.query

      // case-insensitiveで重複チェック
      const existingUser = await prisma.user.findFirst({
        where: {
          username: {
            equals: username,
            mode: 'insensitive',
          },
        },
      })

      if (existingUser) {
        return reply.send({
          available: false,
          message: 'このユーザー名は既に使用されています',
        })
      }

      return reply.send({
        available: true,
      })
    },
  )
}
