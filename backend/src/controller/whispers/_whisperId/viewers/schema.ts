import { z } from 'zod'

// 共通エラーレスポンス
export const errorResponseSchema = z.object({
  message: z.string(),
})

// ===========================================
// GET /api/whispers/:whisperId/viewers
// ===========================================

export const viewersParamsSchema = z.object({
  whisperId: z.string().min(1),
})

export type ViewersParams = z.infer<typeof viewersParamsSchema>

export const viewersQuerySchema = z.object({
  userId: z.string().min(1),
})

export type ViewersQuery = z.infer<typeof viewersQuerySchema>

export const viewerSchema = z.object({
  id: z.string(),
  name: z.string(),
  avatarUrl: z.string().nullable(),
  viewedAt: z.string(),
})

export type Viewer = z.infer<typeof viewerSchema>

export const viewersResponseSchema = z.object({
  data: z.array(viewerSchema),
  totalCount: z.number(),
})

export type ViewersResponse = z.infer<typeof viewersResponseSchema>
