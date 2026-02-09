import { Storage } from '@google-cloud/storage'

const storage = new Storage()

const bucketName = process.env.GCS_BUCKET_NAME || 'voicelet-audio-voicelet'

/**
 * 署名付きURL生成のオプション
 */
interface SignedUrlOptions {
  fileName: string
  contentType?: string
  expiresInMinutes?: number
}

/**
 * アップロード用の署名付きURLを生成
 */
export async function generateUploadSignedUrl(
  options: SignedUrlOptions,
): Promise<{ signedUrl: string; expiresAt: Date }> {
  const { fileName, contentType = 'audio/mp4', expiresInMinutes = 15 } = options

  const bucket = storage.bucket(bucketName)
  const file = bucket.file(fileName)

  const expiresAt = new Date()
  expiresAt.setMinutes(expiresAt.getMinutes() + expiresInMinutes)

  const [signedUrl] = await file.getSignedUrl({
    version: 'v4',
    action: 'write',
    expires: expiresAt,
    contentType,
  })

  return { signedUrl, expiresAt }
}

/**
 * ダウンロード用の署名付きURLを生成
 */
export async function generateDownloadSignedUrl(
  fileName: string,
  expiresInMinutes = 60,
): Promise<string> {
  const bucket = storage.bucket(bucketName)
  const file = bucket.file(fileName)

  const expiresAt = new Date()
  expiresAt.setMinutes(expiresAt.getMinutes() + expiresInMinutes)

  const [signedUrl] = await file.getSignedUrl({
    version: 'v4',
    action: 'read',
    expires: expiresAt,
  })

  return signedUrl
}

/**
 * ファイルが存在するか確認
 */
export async function fileExists(fileName: string): Promise<boolean> {
  const bucket = storage.bucket(bucketName)
  const file = bucket.file(fileName)
  const [exists] = await file.exists()
  return exists
}

/**
 * バケット名を取得
 */
export function getBucketName(): string {
  return bucketName
}

/**
 * Whisperの音声ファイルを削除
 */
export async function deleteWhisperFile(fileName: string): Promise<void> {
  const bucket = storage.bucket(bucketName)
  const file = bucket.file(fileName)
  const [exists] = await file.exists()
  if (exists) {
    await file.delete()
  }
}

/**
 * 複数のWhisper音声ファイルを一括削除（ベストエフォート）
 * 個別ファイルの削除失敗はログ記録して続行
 * @param fileNames 削除対象のファイル名配列
 * @param logger オプショナルなロガー（エラーログ用）
 * @returns 削除結果（成功/失敗件数）
 */
export async function deleteWhisperFiles(
  fileNames: string[],
  logger?: { warn: (obj: object, msg: string) => void },
): Promise<{ succeeded: number; failed: number }> {
  if (fileNames.length === 0) {
    return { succeeded: 0, failed: 0 }
  }

  const bucket = storage.bucket(bucketName)
  let succeeded = 0
  let failed = 0

  await Promise.all(
    fileNames.map(async (fileName) => {
      try {
        const file = bucket.file(fileName)
        const [exists] = await file.exists()
        if (exists) {
          await file.delete()
        }
        succeeded++
      } catch (err) {
        failed++
        if (logger) {
          logger.warn({ err, fileName }, 'Failed to delete whisper file')
        }
      }
    }),
  )

  return { succeeded, failed }
}

// ===========================================
// アバター画像用関数
// ===========================================

const avatarBucketName = process.env.GCS_AVATAR_BUCKET_NAME || 'voicelet-avatar-voicelet'

/**
 * アバターアップロード用オプション
 */
interface AvatarUploadOptions {
  userId: string
  contentType: 'image/jpeg' | 'image/png' | 'image/webp'
  fileSize: number
  fileName: string // uuid_timestamp形式
}

/**
 * アバターアップロード結果
 */
interface AvatarUploadResult {
  signedUrl: string
  avatarPath: string
  expiresAt: Date
}

/**
 * Content-Typeから拡張子を取得
 */
function getExtensionFromContentType(contentType: string): string {
  const map: Record<string, string> = {
    'image/jpeg': 'jpg',
    'image/png': 'png',
    'image/webp': 'webp',
  }
  return map[contentType] || 'jpg'
}

/**
 * アバター用署名付きアップロードURLを生成
 * パス命名規則: avatars/{userId}/{fileName}.{ext}
 * fileNameはクライアントから渡されたuuid_timestamp形式
 */
export async function generateAvatarUploadSignedUrl(
  options: AvatarUploadOptions,
): Promise<AvatarUploadResult> {
  const { userId, contentType, fileName } = options

  const ext = getExtensionFromContentType(contentType)
  const avatarPath = `avatars/${userId}/${fileName}.${ext}`

  const bucket = storage.bucket(avatarBucketName)
  const file = bucket.file(avatarPath)

  const expiresAt = new Date()
  expiresAt.setMinutes(expiresAt.getMinutes() + 15)

  const [signedUrl] = await file.getSignedUrl({
    version: 'v4',
    action: 'write',
    expires: expiresAt,
    contentType,
  })

  return { signedUrl, avatarPath, expiresAt }
}

/**
 * アバター用署名付きダウンロードURLを生成
 */
export async function generateAvatarDownloadSignedUrl(
  avatarPath: string,
  expiresInMinutes = 60,
): Promise<string> {
  const bucket = storage.bucket(avatarBucketName)
  const file = bucket.file(avatarPath)

  const expiresAt = new Date()
  expiresAt.setMinutes(expiresAt.getMinutes() + expiresInMinutes)

  const [signedUrl] = await file.getSignedUrl({
    version: 'v4',
    action: 'read',
    expires: expiresAt,
  })

  return signedUrl
}

/**
 * ユーザーのアバターファイルを一括削除
 */
export async function deleteAvatarFiles(userId: string): Promise<void> {
  const bucket = storage.bucket(avatarBucketName)
  const prefix = `avatars/${userId}/`

  const [files] = await bucket.getFiles({ prefix })

  await Promise.all(files.map((file) => file.delete()))
}
