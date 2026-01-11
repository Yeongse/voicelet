import { z } from 'zod'

export const errorResponseSchema = z.object({
  message: z.string(),
})

// GET /api/discover
export const discoverQuerySchema = z.object({
  userId: z.string().min(1),
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
})

export const discoverUserSchema = z.object({
  id: z.string(),
  name: z.string(),
  avatarUrl: z.string().nullable(),
  whisperCount: z.number(),
  latestWhisperAt: z.string(),
})

export const discoverResponseSchema = z.object({
  data: z.array(discoverUserSchema),
  pagination: z.object({
    total: z.number(),
    page: z.number(),
    limit: z.number(),
    totalPages: z.number(),
    hasNext: z.boolean(),
    hasPrev: z.boolean(),
  }),
})
