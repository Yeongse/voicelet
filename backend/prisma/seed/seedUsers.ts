/**
 * ユーザーのみを登録するseeder
 *
 * 使い方:
 *   pnpm db:seed:users
 */
import { PrismaClient, type User } from '@prisma/client'
import { config } from 'dotenv'
import { REALISTIC_USERS } from './data/users.js'

config()

const prisma = new PrismaClient()

async function main() {
  console.log('🌱 Seeding users...')

  const createdUsers: User[] = []

  for (const userData of REALISTIC_USERS) {
    const email = `${userData.username}@voicelet-seed.local`
    const user = await prisma.user.upsert({
      where: { email },
      update: {
        username: userData.username,
        name: userData.name,
        bio: userData.bio,
        birthMonth: userData.birthMonth,
        isPrivate: userData.isPrivate,
      },
      create: {
        email,
        username: userData.username,
        name: userData.name,
        bio: userData.bio,
        birthMonth: userData.birthMonth,
        isPrivate: userData.isPrivate,
      },
    })
    createdUsers.push(user)
  }

  const publicCount = createdUsers.filter((u) => !u.isPrivate).length
  const privateCount = createdUsers.filter((u) => u.isPrivate).length

  console.log(`✅ Created ${createdUsers.length} users (public: ${publicCount}, private: ${privateCount})`)
  console.log('🎉 User seeding completed!')
}

main()
  .catch((e) => {
    console.error('❌ User seeding failed:', e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
