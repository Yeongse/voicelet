/**
 * フォロー関係を登録するseeder
 *
 * 使い方:
 *   pnpm db:seed:follows
 *
 * オプション:
 *   --target-email <email>  特定ユーザーにフォロワーを追加（省略時はシードユーザー間でランダムなフォロー関係を作成）
 *   --follow-count <number> 各ユーザーがフォローする人数の最大値（デフォルト: 8）
 */
import { PrismaClient } from '@prisma/client'
import { config } from 'dotenv'

config()

const prisma = new PrismaClient()

// コマンドライン引数をパース
function parseArgs() {
  const args = process.argv.slice(2)
  const options: { targetEmail?: string; followCount: number } = {
    followCount: 8,
  }

  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--target-email' && args[i + 1]) {
      options.targetEmail = args[i + 1]
      i++
    } else if (args[i] === '--follow-count' && args[i + 1]) {
      options.followCount = Number.parseInt(args[i + 1], 10)
      i++
    }
  }

  return options
}

async function main() {
  const options = parseArgs()

  console.log('🌱 Seeding follow relationships...')

  if (options.targetEmail) {
    // 特定ユーザーへのフォロワー追加モード
    await seedFollowersForTarget(options.targetEmail)
  } else {
    // シードユーザー間のランダムなフォロー関係作成モード
    await seedRandomFollows(options.followCount)
  }

  console.log('🎉 Follow seeding completed!')
}

// 特定ユーザーへのフォロワー追加
async function seedFollowersForTarget(targetEmail: string) {
  const targetUser = await prisma.user.findUnique({
    where: { email: targetEmail },
  })

  if (!targetUser) {
    console.log(`⚠️ Target user (${targetEmail}) not found.`)
    return
  }

  console.log(`📧 Target user: ${targetUser.name ?? targetUser.email}`)

  // シードユーザーを取得
  const seedUsers = await prisma.user.findMany({
    where: {
      email: { endsWith: '@voicelet-seed.local' },
      id: { not: targetUser.id },
    },
  })

  if (seedUsers.length === 0) {
    console.log('⚠️ No seed users found. Run seedUsers first.')
    return
  }

  let followCount = 0
  for (const user of seedUsers) {
    await prisma.follow.upsert({
      where: {
        followerId_followingId: {
          followerId: user.id,
          followingId: targetUser.id,
        },
      },
      update: {},
      create: {
        followerId: user.id,
        followingId: targetUser.id,
      },
    })
    followCount++
  }

  console.log(`✅ Target user now has ${followCount} new followers`)
}

// シードユーザー間のランダムなフォロー関係作成
async function seedRandomFollows(maxFollowCount: number) {
  // シードユーザーを取得（公開アカウントのみ）
  const seedUsers = await prisma.user.findMany({
    where: {
      email: { endsWith: '@voicelet-seed.local' },
      isPrivate: false,
    },
  })

  if (seedUsers.length === 0) {
    console.log('⚠️ No seed users found. Run seedUsers first.')
    return
  }

  console.log(`📋 Found ${seedUsers.length} public seed users`)

  let totalFollows = 0

  for (const user of seedUsers) {
    // 各ユーザーが3〜maxFollowCount人をランダムにフォロー
    const followCount = 3 + Math.floor(Math.random() * (maxFollowCount - 2))
    const shuffled = [...seedUsers]
      .filter((u) => u.id !== user.id)
      .sort(() => Math.random() - 0.5)
      .slice(0, followCount)

    for (const target of shuffled) {
      await prisma.follow.upsert({
        where: {
          followerId_followingId: {
            followerId: user.id,
            followingId: target.id,
          },
        },
        update: {},
        create: {
          followerId: user.id,
          followingId: target.id,
        },
      })
      totalFollows++
    }
  }

  console.log(`✅ Created ${totalFollows} follow relationships`)
}

main()
  .catch((e) => {
    console.error('❌ Follow seeding failed:', e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
