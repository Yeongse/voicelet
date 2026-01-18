import { PrismaClient } from '@prisma/client'
import { config } from 'dotenv'

// .envファイルを読み込み
config()

const prisma = new PrismaClient()

// テスト用ユーザーのメールアドレス
const VIEWER_TEST_USER_EMAIL = 'yognse14@gmail.com'

// 音声ファイル用バケット名（環境変数から取得）
const GCS_BUCKET_NAME = process.env.GCS_BUCKET_NAME ?? 'voicelet-audio-voicelet'

// テスト用の固定音声ファイル名
const TEST_AUDIO_FILE = 'f7974ff5-fb84-47aa-b255-198874396a0c_1768662992629.m4a'

/**
 * 閲覧者一覧機能のテスト用seed
 * - yognse14@gmail.comのユーザーを検索（事前にGoogleログインで作成されている必要あり）
 * - そのユーザーのwhisperを作成
 * - 既存ユーザー5人がそのwhisperを閲覧済みに
 *
 * 使い方:
 * 1. まずyognse14@gmail.comでGoogleログインする（ユーザーが自動作成される）
 * 2. pnpm db:seed-second を実行する
 */
async function main() {
  console.log('🔍 Seeding viewer test data...')

  // テスト用ユーザーを検索（事前にGoogleログインで作成されている必要あり）
  const testUser = await prisma.user.findUnique({
    where: { email: VIEWER_TEST_USER_EMAIL },
  })

  if (!testUser) {
    console.log(`⚠️ Test user (${VIEWER_TEST_USER_EMAIL}) not found.`)
    console.log('   Please sign in with this Google account first to create the user.')
    return
  }
  console.log(`✅ Viewer test user found: ${testUser.email} (id: ${testUser.id})`)

  // テスト用Whisperを作成
  const now = new Date()
  const expiresAt = new Date(now.getTime() + 24 * 60 * 60 * 1000)

  const testWhisper = await prisma.whisper.upsert({
    where: { id: 'viewer-test-whisper' },
    update: {
      // 再実行時はexpiresAtを更新
      expiresAt,
    },
    create: {
      id: 'viewer-test-whisper',
      userId: testUser.id,
      bucketName: GCS_BUCKET_NAME,
      fileName: TEST_AUDIO_FILE,
      duration: 15,
      expiresAt,
    },
  })
  console.log(`✅ Viewer test whisper ready: ${testWhisper.id}`)

  // 既存のユーザーから5人を取得（テストユーザー以外）
  const existingUsers = await prisma.user.findMany({
    where: {
      id: { not: testUser.id },
    },
    take: 5,
  })

  if (existingUsers.length === 0) {
    console.log('⚠️ No existing users found. Run main seed first.')
    return
  }

  console.log(`📋 Found ${existingUsers.length} users to add as viewers`)

  // 各ユーザーがWhisperを閲覧したことにする
  for (let i = 0; i < existingUsers.length; i++) {
    const user = existingUsers[i]
    // 閲覧時間を少しずつずらす（新しい順に並ぶようにするため）
    const viewedAt = new Date(now.getTime() - i * 60 * 1000) // 1分ずつ過去に

    await prisma.whisperView.upsert({
      where: {
        userId_whisperId: {
          userId: user.id,
          whisperId: testWhisper.id,
        },
      },
      update: {
        viewedAt,
      },
      create: {
        userId: user.id,
        whisperId: testWhisper.id,
        viewedAt,
      },
    })
    console.log(`  👁️ ${user.name} viewed the whisper`)
  }

  console.log('✅ Viewer test seed completed!')
}

main()
  .catch((e) => {
    console.error('❌ Viewer test seed failed:', e)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
