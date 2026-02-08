import { z } from 'zod'

export const errorResponseSchema = z.object({
  message: z.string(),
})

export const viewBodySchema = z.object({
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

export const alreadyViewedResponseSchema = z.object({
  message: z.string(),
  viewedAt: z.string(),
})
