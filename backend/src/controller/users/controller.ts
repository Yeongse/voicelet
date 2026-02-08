import { prisma } from '../../database'
import type { ServerInstance } from '../../lib/fastify'
import { authenticate, type AuthenticatedRequest } from '../../lib/auth'
import { buildPaginationResponse, calculatePagination } from '../../lib/pagination'
import {
  commandResponseSchema,
  createUserRequestSchema,
  errorResponseSchema,
  listUsersQuerySchema,
  listUsersResponseSchema,
} from './schema'

function formatUserResponse(user: {
  id: string
  name: string | null
  createdAt: Date
  updatedAt: Date
}) {
  return {
    id: user.id,
    name: user.name ?? '',
    createdAt: user.createdAt.toISOString(),
    updatedAt: user.updatedAt.toISOString(),
  }
}

export default async function (fastify: ServerInstance) {
  fastify.get(
    '/',
    {
      preHandler: [authenticate],
      schema: {
        tags: ['User'],
        summary: 'ユーザー一覧取得',
        description: 'ユーザーの一覧を取得します。ページネーションと検索に対応しています。',
        querystring: listUsersQuerySchema,
        response: {
          200: listUsersResponseSchema,
          401: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const { page, limit, search } = request.query

      const { skip, take } = calculatePagination({ page, limit })

      // 検索はnameとusernameのみ（メールアドレスで検索しない）
      const where = search
        ? {
            OR: [
              { name: { contains: search, mode: 'insensitive' as const } },
              { username: { contains: search, mode: 'insensitive' as const } },
            ],
          }
        : {}

      const [users, total] = await Promise.all([
        prisma.user.findMany({
          where,
          skip,
          take,
          orderBy: { createdAt: 'desc' },
        }),
        prisma.user.count({ where }),
      ])

      const response = buildPaginationResponse({
        data: users.map((user) => formatUserResponse(user)),
        total,
        page,
        limit,
      })

      return reply.send(response)
    },
  )

  fastify.post(
    '/',
    {
      schema: {
        tags: ['User'],
        summary: 'ユーザー作成',
        description: '新しいユーザーを作成します。',
        body: createUserRequestSchema,
        response: {
          201: commandResponseSchema,
          400: errorResponseSchema,
          409: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const { email, name } = request.body

      const existingUser = await prisma.user.findUnique({
        where: { email },
      })

      if (existingUser) {
        return reply.status(409).send({ message: 'このメールアドレスは既に登録されています' })
      }

      await prisma.user.create({
        data: { email, name },
      })

      return reply.status(201).send({ message: 'ユーザーを作成しました' })
    },
  )
}
