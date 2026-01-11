import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

// デモユーザーID（モバイルアプリと共通）
const DEMO_USER_ID = 'demo-user-001'

async function main() {
  console.log('🌱 Seeding database...')

  // デモユーザーを作成（upsertで冪等性を確保）
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

  // サンプルユーザーを作成
  const users = await prisma.user.createMany({
    data: [
      { email: 'user1@example.com', name: 'User 1' },
      { email: 'user2@example.com', name: 'User 2' },
      { email: 'user3@example.com', name: 'User 3' },
    ],
    skipDuplicates: true,
  })

  console.log(`✅ Created ${users.count} sample users`)
  console.log('🎉 Seeding completed!')
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed:', e)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
