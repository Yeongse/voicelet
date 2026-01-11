import { z } from 'zod'

export const errorResponseSchema = z.object({
  message: z.string(),
})

export const successResponseSchema = z.object({
  message: z.string(),
})

// POST /api/follows - 認証ユーザーがフォロー
export const followBodySchema = z.object({
  followingId: z.string().min(1),
})

export const followResponseSchema = z.object({
  message: z.string(),
  follow: z.object({
    id: z.string(),
    followerId: z.string(),
    followingId: z.string(),
    createdAt: z.string(),
  }),
})

// 鍵垢の場合のフォローリクエスト作成レスポンス
export const followRequestCreatedResponseSchema = z.object({
  message: z.string(),
  followRequest: z.object({
    id: z.string(),
    requesterId: z.string(),
    targetId: z.string(),
    createdAt: z.string(),
  }),
})

// DELETE /api/follows/:followingId - アンフォロー
export const unfollowParamsSchema = z.object({
  followingId: z.string().min(1),
})

// DELETE /api/followers/:followerId - フォロワー削除
export const removeFollowerParamsSchema = z.object({
  followerId: z.string().min(1),
})

// GET /api/users/:userId/following, /api/users/:userId/followers - userId params
export const userIdParamsSchema = z.object({
  userId: z.string().min(1),
})

// GET /api/users/:userId/following, /api/users/:userId/followers - ページネーション
export const paginationQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
})

// ユーザー情報（フォロー状態付き）
export const userWithFollowStatusSchema = z.object({
  id: z.string(),
  name: z.string().nullable(),
  bio: z.string().nullable(),
  avatarUrl: z.string().nullable(),
  isPrivate: z.boolean(),
  followStatus: z.enum(['none', 'following', 'requested']),
})

// ページネーション付きユーザー一覧レスポンス
export const userListResponseSchema = z.object({
  data: z.array(userWithFollowStatusSchema),
  pagination: z.object({
    page: z.number(),
    limit: z.number(),
    total: z.number(),
    hasMore: z.boolean(),
  }),
})

export type FollowBody = z.infer<typeof followBodySchema>
export type UnfollowParams = z.infer<typeof unfollowParamsSchema>
export type RemoveFollowerParams = z.infer<typeof removeFollowerParamsSchema>
export type PaginationQuery = z.infer<typeof paginationQuerySchema>
