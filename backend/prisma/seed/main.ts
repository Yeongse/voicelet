import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

// デモユーザーID（モバイルアプリと共通）
const DEMO_USER_ID = 'demo-user-001'

async function main() {
  console.log('🌱 Seeding database...')

  // デモユーザーを作成
  const demoUser = await prisma.user.upsert({
    where: { id: DEMO_USER_ID },
    update: {},
    create: {
      id: DEMO_USER_ID,
      email: 'demo@voicelet.app',
      name: 'Demo User',
    },
  })
  console.log(`✅ Demo user ready: ${demoUser.id}`)

  // フォロー対象のサンプルユーザーを作成
  const followingUsers = []
  for (let i = 1; i <= 5; i++) {
    const user = await prisma.user.upsert({
      where: { email: `following${i}@example.com` },
      update: {},
      create: {
        email: `following${i}@example.com`,
        name: `フォロー中 ${i}`,
      },
    })
    followingUsers.push(user)
  }
  console.log(`✅ Created ${followingUsers.length} following users`)

  // おすすめ用のサンプルユーザーを作成
  const discoverUsers = []
  for (let i = 1; i <= 5; i++) {
    const user = await prisma.user.upsert({
      where: { email: `discover${i}@example.com` },
      update: {},
      create: {
        email: `discover${i}@example.com`,
        name: `おすすめ ${i}`,
      },
    })
    discoverUsers.push(user)
  }
  console.log(`✅ Created ${discoverUsers.length} discover users`)

  // デモユーザーがフォロー中ユーザーをフォロー
  for (const user of followingUsers) {
    await prisma.follow.upsert({
      where: {
        followerId_followingId: {
          followerId: DEMO_USER_ID,
          followingId: user.id,
        },
      },
      update: {},
      create: {
        followerId: DEMO_USER_ID,
        followingId: user.id,
      },
    })
  }
  console.log(`✅ Demo user follows ${followingUsers.length} users`)

  // デモユーザー自身のWhisperを作成
  const now = new Date()
  const expiresAt = new Date(now.getTime() + 24 * 60 * 60 * 1000)

  for (let i = 1; i <= 3; i++) {
    await prisma.whisper.upsert({
      where: { id: `demo-whisper-${i}` },
      update: {},
      create: {
        id: `demo-whisper-${i}`,
        userId: DEMO_USER_ID,
        bucketName: 'test-bucket',
        fileName: `demo-audio-${i}.m4a`,
        duration: 10 + i * 5,
        expiresAt,
      },
    })
  }
  console.log('✅ Created demo user whispers')

  // フォロー中ユーザーのWhisperを作成
  for (const user of followingUsers) {
    const whisperCount = Math.floor(Math.random() * 3) + 1
    for (let i = 1; i <= whisperCount; i++) {
      await prisma.whisper.upsert({
        where: { id: `${user.id}-whisper-${i}` },
        update: {},
        create: {
          id: `${user.id}-whisper-${i}`,
          userId: user.id,
          bucketName: 'test-bucket',
          fileName: `${user.id}-audio-${i}.m4a`,
          duration: 5 + Math.floor(Math.random() * 25),
          expiresAt,
        },
      })
    }
  }
  console.log('✅ Created following users whispers')

  // おすすめユーザーのWhisperを作成
  for (const user of discoverUsers) {
    const whisperCount = Math.floor(Math.random() * 3) + 1
    for (let i = 1; i <= whisperCount; i++) {
      await prisma.whisper.upsert({
        where: { id: `${user.id}-whisper-${i}` },
        update: {},
        create: {
          id: `${user.id}-whisper-${i}`,
          userId: user.id,
          bucketName: 'test-bucket',
          fileName: `${user.id}-audio-${i}.m4a`,
          duration: 5 + Math.floor(Math.random() * 25),
          expiresAt,
        },
      })
    }
  }
  console.log('✅ Created discover users whispers')

  console.log('🎉 Seeding completed!')
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed:', e)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
