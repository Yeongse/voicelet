import { z } from 'zod'

export const errorResponseSchema = z.object({
  message: z.string(),
})

// GET /api/stories
export const storiesQuerySchema = z.object({
  userId: z.string().min(1),
})

export const storyItemSchema = z.object({
  id: z.string(),
  visaudioUrlSchema: z.string(),
  duration: z.number(),
  createdAt: z.string(),
  isViewed: z.boolean(),
})

export const userStorySchema = z.object({
  user: z.object({
    id: z.string(),
    name: z.string(),
    avatarUrl: z.string().nullable(),
  }),
  stories: z.array(z.object({
    id: z.string(),
    duration: z.number(),
    createdAt: z.string(),
    isViewed: z.boolean(),
  })),
  hasUnviewed: z.boolean(),
})

export const storiesResponseSchema = z.object({
  data: z.array(userStorySchema),
})
