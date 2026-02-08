-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "username" VARCHAR(30),
    "name" TEXT,
    "bio" VARCHAR(500),
    "birth_month" CHAR(7),
    "avatar_path" TEXT,
    "is_private" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "whispers" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "bucket_name" TEXT NOT NULL,
    "file_name" TEXT NOT NULL,
    "duration" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "whispers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "follows" (
    "id" TEXT NOT NULL,
    "follower_id" TEXT NOT NULL,
    "following_id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "follows_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "whisper_views" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "whisper_id" TEXT NOT NULL,
    "viewed_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "whisper_views_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "follow_requests" (
    "id" TEXT NOT NULL,
    "requester_id" TEXT NOT NULL,
    "target_id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "follow_requests_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reward_ad_usages" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "usage_count" INTEGER NOT NULL DEFAULT 0,
    "usage_date" DATE NOT NULL,
    "last_used_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "reward_ad_usages_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "users_username_key" ON "users"("username");

-- CreateIndex
CREATE INDEX "whispers_user_id_idx" ON "whispers"("user_id");

-- CreateIndex
CREATE INDEX "whispers_created_at_idx" ON "whispers"("created_at");

-- CreateIndex
CREATE INDEX "whispers_expires_at_idx" ON "whispers"("expires_at");

-- CreateIndex
CREATE INDEX "follows_follower_id_idx" ON "follows"("follower_id");

-- CreateIndex
CREATE INDEX "follows_following_id_idx" ON "follows"("following_id");

-- CreateIndex
CREATE UNIQUE INDEX "follows_follower_id_following_id_key" ON "follows"("follower_id", "following_id");

-- CreateIndex
CREATE INDEX "whisper_views_user_id_idx" ON "whisper_views"("user_id");

-- CreateIndex
CREATE INDEX "whisper_views_whisper_id_idx" ON "whisper_views"("whisper_id");

-- CreateIndex
CREATE UNIQUE INDEX "whisper_views_user_id_whisper_id_key" ON "whisper_views"("user_id", "whisper_id");

-- CreateIndex
CREATE INDEX "follow_requests_requester_id_idx" ON "follow_requests"("requester_id");

-- CreateIndex
CREATE INDEX "follow_requests_target_id_idx" ON "follow_requests"("target_id");

-- CreateIndex
CREATE UNIQUE INDEX "follow_requests_requester_id_target_id_key" ON "follow_requests"("requester_id", "target_id");

-- CreateIndex
CREATE UNIQUE INDEX "reward_ad_usages_user_id_key" ON "reward_ad_usages"("user_id");

-- CreateIndex
CREATE INDEX "reward_ad_usages_user_id_idx" ON "reward_ad_usages"("user_id");

-- CreateIndex
CREATE INDEX "reward_ad_usages_usage_date_idx" ON "reward_ad_usages"("usage_date");

-- AddForeignKey
ALTER TABLE "whispers" ADD CONSTRAINT "whispers_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "follows" ADD CONSTRAINT "follows_follower_id_fkey" FOREIGN KEY ("follower_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "follows" ADD CONSTRAINT "follows_following_id_fkey" FOREIGN KEY ("following_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "whisper_views" ADD CONSTRAINT "whisper_views_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "whisper_views" ADD CONSTRAINT "whisper_views_whisper_id_fkey" FOREIGN KEY ("whisper_id") REFERENCES "whispers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "follow_requests" ADD CONSTRAINT "follow_requests_requester_id_fkey" FOREIGN KEY ("requester_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "follow_requests" ADD CONSTRAINT "follow_requests_target_id_fkey" FOREIGN KEY ("target_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reward_ad_usages" ADD CONSTRAINT "reward_ad_usages_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
