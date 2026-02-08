import { z } from 'zod'
import { createPaginatedResponseSchema } from '../../lib/pagination'

export const searchUsersQuerySchema = z.object({
  query: z.string().min(1, '検索キーワードを入力してください'),
  userId: z.string().optional(),
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(50).default(20),
})

export const searchUserSchema = z.object({
  id: z.string(),
  username: z.string().nullable(),
  name: z.string().nullable(),
  avatarUrl: z.string().nullable(),
  isPrivate: z.boolean(),
  followStatus: z.enum(['none', 'following', 'requested']),
})

export const searchUsersResponseSchema = createPaginatedResponseSchema(searchUserSchema)

export const errorResponseSchema = z.object({
  message: z.string(),
})

export type SearchUsersQuery = z.infer<typeof searchUsersQuerySchema>
export type SearchUser = z.infer<typeof searchUserSchema>
