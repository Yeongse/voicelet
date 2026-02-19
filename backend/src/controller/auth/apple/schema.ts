import { z } from 'zod'

/**
 * Apple Server-to-Server通知リクエストスキーマ
 * Appleからの通知はJWT形式でペイロードが送信される
 */
export const appleRevocationRequestSchema = z.object({
  payload: z.string().min(1, 'ペイロードは必須です'),
})

/**
 * Apple通知イベントのペイロードスキーマ
 */
export const appleEventPayloadSchema = z.object({
  type: z.enum(['consent-revoked', 'account-delete']),
  sub: z.string(),
  event_time: z.number(),
})

/**
 * エラーレスポンススキーマ
 */
export const errorResponseSchema = z.object({
  message: z.string(),
})

export type AppleRevocationRequest = z.infer<typeof appleRevocationRequestSchema>
export type AppleEventPayload = z.infer<typeof appleEventPayloadSchema>
