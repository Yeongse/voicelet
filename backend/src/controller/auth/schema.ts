import { z } from 'zod'

/**
 * 認証コールバックリクエストスキーマ
 */
export const authCallbackRequestSchema = z.object({
  accessToken: z.string().min(1, 'アクセストークンは必須です'),
})

/**
 * 認証コールバックレスポンススキーマ
 * isRegistered: DBにユーザーが登録済みかどうか
 */
export const authCallbackResponseSchema = z.object({
  id: z.string(),
  email: z.string(),
  isRegistered: z.boolean(),
})

/**
 * エラーレスポンススキーマ
 */
export const errorResponseSchema = z.object({
  message: z.string(),
})

export type AuthCallbackRequest = z.infer<typeof authCallbackRequestSchema>
export type AuthCallbackResponse = z.infer<typeof authCallbackResponseSchema>
