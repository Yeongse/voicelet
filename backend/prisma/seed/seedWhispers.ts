/**
 * Whisperを登録するseeder
 *
 * 使い方:
 *   pnpm db:seed:whispers
 *
 * オプション:
 *   --audio-file <filename>  使用する音声ファイル名（必須）
 *   --target-email <email>   特定ユーザーにWhisperを追加（省略時はシードユーザー全員に追加）
 *   --count <number>         各ユーザーに追加するWhisper数（デフォルト: 1〜3のランダム）
 *   --duration <seconds>     Whisperの再生時間（デフォルト: 5〜30秒のランダム）
 *   --expires-hours <hours>  有効期限（デフォルト: 24時間）
 *
 * 例:
 *   pnpm db:seed:whispers --audio-file "test_audio.m4a"
 *   pnpm db:seed:whispers --audio-file "test_audio.m4a" --target-email "user@example.com" --count 3
 */
import { PrismaClient } from "@prisma/client";
import { config } from "dotenv";

config();

const prisma = new PrismaClient();

// 環境変数からバケット名を取得
const GCS_BUCKET_NAME =
  process.env.GCS_BUCKET_NAME ?? "voicelet-audio-voicelet";

// デフォルトの音声ファイル名（GCSバケット内に実在するファイル）
const DEFAULT_AUDIO_FILE =
  "71a78290-a576-4cfc-b711-bf30ccb93963_1771002617078.m4a";

interface Options {
  audioFile: string;
  targetEmail?: string;
  count?: number;
  duration?: number;
  expiresHours: number;
}

// コマンドライン引数をパース
function parseArgs(): Options {
  const args = process.argv.slice(2);
  const options: Options = {
    audioFile: DEFAULT_AUDIO_FILE,
    expiresHours: 24,
  };

  for (let i = 0; i < args.length; i++) {
    if (args[i] === "--audio-file" && args[i + 1]) {
      options.audioFile = args[i + 1];
      i++;
    } else if (args[i] === "--target-email" && args[i + 1]) {
      options.targetEmail = args[i + 1];
      i++;
    } else if (args[i] === "--count" && args[i + 1]) {
      options.count = Number.parseInt(args[i + 1], 10);
      i++;
    } else if (args[i] === "--duration" && args[i + 1]) {
      options.duration = Number.parseInt(args[i + 1], 10);
      i++;
    } else if (args[i] === "--expires-hours" && args[i + 1]) {
      options.expiresHours = Number.parseInt(args[i + 1], 10);
      i++;
    }
  }

  return options;
}

async function main() {
  const options = parseArgs();

  console.log("🌱 Seeding whispers...");
  console.log(`  📁 Audio file: ${options.audioFile}`);
  console.log(`  🪣 Bucket: ${GCS_BUCKET_NAME}`);
  console.log(`  ⏰ Expires in: ${options.expiresHours} hours`);

  const now = new Date();
  const expiresAt = new Date(
    now.getTime() + options.expiresHours * 60 * 60 * 1000
  );

  if (options.targetEmail) {
    // 特定ユーザーへのWhisper追加モード
    await seedWhispersForTarget(options, expiresAt);
  } else {
    // シードユーザー全員にWhisper追加モード
    await seedWhispersForAll(options, expiresAt);
  }

  console.log("🎉 Whisper seeding completed!");
}

// 特定ユーザーへのWhisper追加
async function seedWhispersForTarget(options: Options, expiresAt: Date) {
  const targetUser = await prisma.user.findUnique({
    where: { email: options.targetEmail },
  });

  if (!targetUser) {
    console.log(`⚠️ Target user (${options.targetEmail}) not found.`);
    return;
  }

  console.log(`📧 Target user: ${targetUser.name ?? targetUser.email}`);

  const count = options.count ?? Math.floor(Math.random() * 3) + 1;

  for (let i = 1; i <= count; i++) {
    const duration = options.duration ?? 5 + Math.floor(Math.random() * 25);
    const whisperId = `seed-${targetUser.id}-whisper-${Date.now()}-${i}`;

    await prisma.whisper.create({
      data: {
        id: whisperId,
        userId: targetUser.id,
        bucketName: GCS_BUCKET_NAME,
        fileName: options.audioFile,
        duration,
        expiresAt,
      },
    });
    console.log(`  ✅ Created whisper ${i}/${count} (duration: ${duration}s)`);
  }

  console.log(
    `✅ Created ${count} whispers for ${targetUser.name ?? targetUser.email}`
  );
}

// シードユーザー全員にWhisper追加
async function seedWhispersForAll(options: Options, expiresAt: Date) {
  // シードユーザーを取得（公開アカウントのみ）
  const seedUsers = await prisma.user.findMany({
    where: {
      email: { endsWith: "@voicelet-seed.local" },
      isPrivate: false,
    },
  });

  if (seedUsers.length === 0) {
    console.log("⚠️ No seed users found. Run seedUsers first.");
    return;
  }

  console.log(`📋 Found ${seedUsers.length} public seed users`);

  let totalWhispers = 0;

  for (const user of seedUsers) {
    const count = options.count ?? Math.floor(Math.random() * 2) + 1;

    for (let i = 1; i <= count; i++) {
      const duration = options.duration ?? 5 + Math.floor(Math.random() * 25);
      const whisperId = `seed-${user.id}-whisper-${i}`;

      await prisma.whisper.upsert({
        where: { id: whisperId },
        update: {
          bucketName: GCS_BUCKET_NAME,
          fileName: options.audioFile,
          duration,
          expiresAt,
        },
        create: {
          id: whisperId,
          userId: user.id,
          bucketName: GCS_BUCKET_NAME,
          fileName: options.audioFile,
          duration,
          expiresAt,
        },
      });
      totalWhispers++;
    }
  }

  console.log(
    `✅ Created ${totalWhispers} whispers for ${seedUsers.length} users`
  );
}

main()
  .catch((e) => {
    console.error("❌ Whisper seeding failed:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
