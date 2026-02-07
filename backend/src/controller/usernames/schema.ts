import { z } from 'zod'

export const usernameCheckQuerySchema = z.object({
  username: z
    .string()
    .min(3, 'ユーザー名は3文字以上です')
    .max(30, 'ユーザー名は30文字以下です')
    .regex(/^[a-zA-Z0-9_.]+$/, '半角英数字、アンダースコア、ピリオドのみ使用できます'),
})

export const usernameCheckResponseSchema = z.object({
  available: z.boolean(),
  message: z.string().optional(),
})

export const errorResponseSchema = z.object({
  message: z.string(),
})

export type UsernameCheckQuery = z.infer<typeof usernameCheckQuerySchema>
export type UsernameCheckResponse = z.infer<typeof usernameCheckResponseSchema>
