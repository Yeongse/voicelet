import { z } from 'zod'

export const errorResponseSchema = z.object({
  message: z.string(),
})

export const successResponseSchema = z.object({
  message: z.string(),
})

// フォローリクエスト（受信）
export const followRequestSchema = z.object({
  id: z.string(),
  requester: z.object({
    id: z.string(),
    name: z.string().nullable(),
    avatarUrl: z.string().nullable(),
  }),
  createdAt: z.string(),
})

// フォローリクエスト一覧レスポンス（受信）
export const followRequestListResponseSchema = z.object({
  data: z.array(followRequestSchema),
  pagination: z.object({
    page: z.number(),
    limit: z.number(),
    total: z.number(),
    hasMore: z.boolean(),
  }),
})

// フォローリクエスト（送信）
export const sentFollowRequestSchema = z.object({
  id: z.string(),
  target: z.object({
    id: z.string(),
    name: z.string().nullable(),
    avatarUrl: z.string().nullable(),
  }),
  createdAt: z.string(),
})

// 送信済みフォローリクエスト一覧レスポンス
export const sentFollowRequestListResponseSchema = z.object({
  data: z.array(sentFollowRequestSchema),
  pagination: z.object({
    page: z.number(),
    limit: z.number(),
    total: z.number(),
    hasMore: z.boolean(),
  }),
})

// フォローリクエストカウントレスポンス
export const followRequestCountResponseSchema = z.object({
  count: z.number(),
})

// フォロー作成レスポンス（承認時）
export const followCreatedResponseSchema = z.object({
  message: z.string(),
  follow: z.object({
    id: z.string(),
    followerId: z.string(),
    followingId: z.string(),
    createdAt: z.string(),
  }),
})

// リクエストIDパラメータ
export const requestIdParamsSchema = z.object({
  requestId: z.string().min(1),
})

// ページネーションクエリ
export const paginationQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
})

export type PaginationQuery = z.infer<typeof paginationQuerySchema>
