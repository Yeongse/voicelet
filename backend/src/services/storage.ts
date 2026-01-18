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
