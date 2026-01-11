import { z } from 'zod'

export const errorResponseSchema = z.object({
  message: z.string(),
})

// POST /api/follows
export const followBodySchema = z.object({
  followerId: z.string().min(1),
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

// DELETE /api/follows
export const unfollowBodySchema = z.object({
  followerId: z.string().min(1),
  followingId: z.string().min(1),
})
