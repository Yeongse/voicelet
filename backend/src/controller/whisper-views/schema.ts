import { z } from 'zod'

export const errorResponseSchema = z.object({
  message: z.string(),
})

export const viewBodySchema = z.object({
  userId: z.string().min(1),
  whisperId: z.string().min(1),
})

export const viewResponseSchema = z.object({
  message: z.string(),
  view: z.object({
    id: z.string(),
    userId: z.string(),
    whisperId: z.string(),
    viewedAt: z.string(),
  }),
})
