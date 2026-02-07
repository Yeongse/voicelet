import { PrismaClient } from "@prisma/client";
import { config } from "dotenv";

config();

const prisma = new PrismaClient();

// フォローリクエストを受け取るユーザーのID
const TARGET_USER_ID = "f7974ff5-fb84-47aa-b255-198874396a0c";

async function main() {
  // ターゲットユーザーの存在確認
  const targetUser = await prisma.user.findUnique({
    where: { id: TARGET_USER_ID },
  });

  if (!targetUser) {
    console.error(`❌ ユーザー ${TARGET_USER_ID} が見つかりません`);
    return;
  }

  console.log(
    `🎯 ターゲットユーザー: ${targetUser.name ?? targetUser.email} (${
      targetUser.id
    })`
  );

  // ターゲット以外のユーザーをランダムに取得（既にフォロー済み/リクエスト済みを除外）
  const existingFollowers = await prisma.follow.findMany({
    where: { followingId: TARGET_USER_ID },
    select: { followerId: true },
  });

  const existingRequests = await prisma.followRequest.findMany({
    where: { targetId: TARGET_USER_ID },
    select: { requesterId: true },
  });

  const excludeIds = new Set([
    TARGET_USER_ID,
    ...existingFollowers.map((f) => f.followerId),
    ...existingRequests.map((r) => r.requesterId),
  ]);

  const candidates = await prisma.user.findMany({
    where: {
      id: { notIn: [...excludeIds] },
    },
    take: 5,
    orderBy: { createdAt: "desc" },
  });

  if (candidates.length === 0) {
    console.log("⚠️ フォローリクエストを送れる候補ユーザーがいません");
    return;
  }

  console.log(`📨 ${candidates.length} 件のフォローリクエストを作成します...`);

  for (const requester of candidates) {
    const request = await prisma.followRequest.create({
      data: {
        requesterId: requester.id,
        targetId: TARGET_USER_ID,
      },
    });
    console.log(
      `  ✅ ${
        requester.name ?? requester.username ?? requester.email
      } → リクエスト送信 (${request.id})`
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
