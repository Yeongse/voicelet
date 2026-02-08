import { PrismaClient } from "@prisma/client";
import { config } from "dotenv";

config();

const prisma = new PrismaClient();

const TARGET_WHISPER_ID = "fb68aae9-2243-4d38-b15e-5c524828fca3";

async function main() {
  // Whisperの存在確認
  const whisper = await prisma.whisper.findUnique({
    where: { id: TARGET_WHISPER_ID },
    include: { user: true },
  });

  if (!whisper) {
    console.error(`❌ Whisper ${TARGET_WHISPER_ID} が見つかりません`);
    return;
  }

  console.log(
    `🎯 対象Whisper: ${TARGET_WHISPER_ID} (投稿者: ${
      whisper.user.name ?? whisper.user.email
    })`
  );

  // 投稿者自身と既に視聴済みのユーザーを除外
  const existingViews = await prisma.whisperView.findMany({
    where: { whisperId: TARGET_WHISPER_ID },
    select: { userId: true },
  });

  const excludeIds = new Set([
    whisper.userId,
    ...existingViews.map((v) => v.userId),
  ]);

  // 候補ユーザーを取得（ランダムに8人）
  const candidates = await prisma.user.findMany({
    where: {
      id: { notIn: [...excludeIds] },
    },
    take: 50,
  });

  // シャッフルして8人選ぶ
  const shuffled = candidates.sort(() => Math.random() - 0.5).slice(0, 8);

  if (shuffled.length === 0) {
    console.log("⚠️ 視聴記録を追加できる候補ユーザーがいません");
    return;
  }

  console.log(`👁️ ${shuffled.length} 件の視聴記録を作成します...`);

  for (const viewer of shuffled) {
    const view = await prisma.whisperView.create({
      data: {
        userId: viewer.id,
        whisperId: TARGET_WHISPER_ID,
      },
    });
    console.log(
      `  ✅ ${viewer.name ?? viewer.username ?? viewer.email} が視聴 (${
        view.id
      })`
    );
  }

  console.log("🎉 完了!");
}

main()
  .catch((e) => {
    console.error("❌ エラー:", e);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
