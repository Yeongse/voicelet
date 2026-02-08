import { z } from 'zod'

export const errorResponseSchema = z.object({
  message: z.string(),
})

// GET /api/discover
export const discoverQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
})

export const discoverUserSchema = z.object({
  id: z.string(),
  name: z.string(),
  bio: z.string().nullable(),
  avatarUrl: z.string().nullable(),
  whisperCount: z.number(),
  latestWhisperAt: z.string(),
  hasUnviewed: z.boolean(),
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

// GET /api/discover/:targetUserId/stories
export const discoverStoriesResponseSchema = z.object({
  user: z.object({
    id: z.string(),
    name: z.string(),
    avatarUrl: z.string().nullable(),
  }).nullable(),
  stories: z.array(z.object({
    id: z.string(),
    duration: z.number(),
    createdAt: z.string(),
    isViewed: z.boolean(),
  })),
  hasUnviewed: z.boolean(),
})
