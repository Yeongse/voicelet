import { Storage } from "@google-cloud/storage";

const storage = new Storage();

const bucketName = process.env.GCS_BUCKET_NAME || "voicelet-audio-voicelet";

/**
 * 署名付きURL生成のオプション
 */
interface SignedUrlOptions {
  fileName: string;
  contentType?: string;
  expiresInMinutes?: number;
}

/**
 * アップロード用の署名付きURLを生成
 */
export async function generateUploadSignedUrl(
  options: SignedUrlOptions
): Promise<{ signedUrl: string; expiresAt: Date }> {
  const { fileName, contentType = "audio/mp4", expiresInMinutes = 15 } = options;

  const bucket = storage.bucket(bucketName);
  const file = bucket.file(fileName);

  const expiresAt = new Date();
  expiresAt.setMinutes(expiresAt.getMinutes() + expiresInMinutes);

  const [signedUrl] = await file.getSignedUrl({
    version: "v4",
    action: "write",
    expires: expiresAt,
    contentType,
  });

  return { signedUrl, expiresAt };
}

/**
 * ダウンロード用の署名付きURLを生成
 */
export async function generateDownloadSignedUrl(
  fileName: string,
  expiresInMinutes = 60
): Promise<string> {
  const bucket = storage.bucket(bucketName);
  const file = bucket.file(fileName);

  const expiresAt = new Date();
  expiresAt.setMinutes(expiresAt.getMinutes() + expiresInMinutes);

  const [signedUrl] = await file.getSignedUrl({
    version: "v4",
    action: "read",
    expires: expiresAt,
  });

  return signedUrl;
}

/**
 * ファイルが存在するか確認
 */
export async function fileExists(fileName: string): Promise<boolean> {
  const bucket = storage.bucket(bucketName);
  const file = bucket.file(fileName);
  const [exists] = await file.exists();
  return exists;
}

/**
 * バケット名を取得
 */
export function getBucketName(): string {
  return bucketName;
}
