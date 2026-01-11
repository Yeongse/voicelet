import { z } from 'zod'

/**
 * 自分のプロフィールレスポンススキーマ（birthMonth含む）
 */
export const myProfileResponseSchema = z.object({
  id: z.string(),
  email: z.string(),
  name: z.string().nullable(),
  bio: z.string().nullable(),
  birthMonth: z.string().nullable(),
  age: z.number().nullable(),
  avatarUrl: z.string().nullable(),
  createdAt: z.string(),
  updatedAt: z.string(),
})

/**
 * 公開プロフィールレスポンススキーマ（birthMonth含まない）
 */
export const publicProfileResponseSchema = z.object({
  id: z.string(),
  email: z.string(),
  name: z.string().nullable(),
  bio: z.string().nullable(),
  age: z.number().nullable(),
  avatarUrl: z.string().nullable(),
  createdAt: z.string(),
  updatedAt: z.string(),
})

/**
 * プロフィール新規登録リクエストスキーマ
 * 表示名は必須
 */
export const registerProfileRequestSchema = z.object({
  name: z.string().min(1, '表示名は必須です').max(100),
  bio: z.string().max(500).optional(),
  birthMonth: z
    .string()
    .regex(/^\d{4}-(0[1-9]|1[0-2])$/, '生年月はYYYY-MM形式で入力してください')
    .refine(
      (val) => {
        const [year, month] = val.split('-').map(Number)
        const now = new Date()
        const birthDate = new Date(year, month - 1)
        return birthDate <= now
      },
      { message: '将来の日付は指定できません' },
    )
    .optional(),
  avatarPath: z.string().optional(),
})

/**
 * プロフィール更新リクエストスキーマ
 */
export const updateProfileRequestSchema = z.object({
  name: z.string().min(1).max(100).optional(),
  bio: z.string().max(500).optional(),
  birthMonth: z
    .string()
    .regex(/^\d{4}-(0[1-9]|1[0-2])$/, '生年月はYYYY-MM形式で入力してください')
    .refine(
      (val) => {
        const [year, month] = val.split('-').map(Number)
        const now = new Date()
        const birthDate = new Date(year, month - 1)
        return birthDate <= now
      },
      { message: '将来の日付は指定できません' },
    )
    .optional(),
  avatarPath: z.string().optional(),
})

/**
 * アバターアップロードURLリクエストスキーマ
 */
export const avatarUploadRequestSchema = z.object({
  contentType: z.enum(['image/jpeg', 'image/png', 'image/webp'], {
    message: 'ファイル形式はJPEG、PNG、WebPのいずれかである必要があります',
  }),
  fileSize: z
    .number()
    .max(5 * 1024 * 1024, 'ファイルサイズは5MB以下である必要があります'),
  fileName: z
    .string()
    .regex(/^[a-f0-9-]+_\d+$/, 'ファイル名はuuid_timestampの形式で指定してください'),
})

/**
 * アバターアップロードURLレスポンススキーマ
 */
export const avatarUploadResponseSchema = z.object({
  uploadUrl: z.string(),
  avatarPath: z.string(),
  expiresAt: z.string(),
})

/**
 * エラーレスポンススキーマ
 */
export const errorResponseSchema = z.object({
  message: z.string(),
})

/**
 * 成功レスポンススキーマ
 */
export const successResponseSchema = z.object({
  message: z.string(),
})

export type MyProfileResponse = z.infer<typeof myProfileResponseSchema>
export type PublicProfileResponse = z.infer<typeof publicProfileResponseSchema>
export type RegisterProfileRequest = z.infer<typeof registerProfileRequestSchema>
export type UpdateProfileRequest = z.infer<typeof updateProfileRequestSchema>
export type AvatarUploadRequest = z.infer<typeof avatarUploadRequestSchema>
export type AvatarUploadResponse = z.infer<typeof avatarUploadResponseSchema>
