import { z } from 'zod'
import { createPaginatedResponseSchema, paginationQuerySchema } from '../../lib/pagination'

// 共通エラーレスポンス
export const errorResponseSchema = z.object({
  message: z.string(),
})

// ===========================================
// POST /api/whispers/signed-url
// ===========================================

export const signedUrlRequestSchema = z.object({
  fileName: z.string().min(1).max(255),
  userId: z.string().min(1).max(100),
})

export type SignedUrlRequest = z.infer<typeof signedUrlRequestSchema>

export const signedUrlResponseSchema = z.object({
  signedUrl: z.string().url(),
  bucketName: z.string(),
  fileName: z.string(),
  expiresAt: z.string(),
})

export type SignedUrlResponse = z.infer<typeof signedUrlResponseSchema>

// ===========================================
// POST /api/whispers
// ===========================================

export const createWhisperRequestSchema = z.object({
  userId: z.string().min(1).max(100),
  fileName: z.string().min(1).max(255),
  duration: z.number().int().min(1).max(30),
})

export type CreateWhisperRequest = z.infer<typeof createWhisperRequestSchema>

export const whisperResponseSchema = z.object({
  id: z.string(),
  userId: z.string(),
  bucketName: z.string(),
  fileName: z.string(),
  duration: z.number(),
  createdAt: z.string(),
})

// ===========================================
// GET /api/whispers/:whisperId/audio-url
// ===========================================

export const audioUrlResponseSchema = z.object({
  signedUrl: z.string().url(),
  expiresAt: z.string(),
})

export type WhisperResponse = z.infer<typeof whisperResponseSchema>

export const createWhisperResponseSchema = z.object({
  message: z.string(),
  whisper: whisperResponseSchema,
})

// ===========================================
// GET /api/whispers
// ===========================================

export const listWhispersQuerySchema = paginationQuerySchema.extend({
  userId: z.string().min(1).max(100).optional(),
})

export type ListWhispersQuery = z.infer<typeof listWhispersQuerySchema>

export const listWhispersResponseSchema = createPaginatedResponseSchema(whisperResponseSchema)
