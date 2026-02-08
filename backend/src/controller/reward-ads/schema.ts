import { z } from 'zod'

export const errorResponseSchema = z.object({
  message: z.string(),
})

// GET /api/reward-ads/status
export const statusResponseSchema = z.object({
  remainingCount: z.number().int().min(0).max(3),
  nextResetAt: z.string(),
  todayClearedCount: z.number().int().min(0),
})

// POST /api/reward-ads/use
export const useResponseSchema = z.object({
  success: z.boolean(),
  clearedCount: z.number().int().min(0),
  remainingCount: z.number().int().min(0).max(3),
  nextResetAt: z.string(),
})

// Error 429: Too Many Requests
export const tooManyRequestsResponseSchema = z.object({
  message: z.string(),
  remainingCount: z.literal(0),
  nextResetAt: z.string(),
})
