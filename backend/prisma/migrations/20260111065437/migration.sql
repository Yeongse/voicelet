-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT NOT NULL,
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

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "whispers_user_id_idx" ON "whispers"("user_id");

-- CreateIndex
CREATE INDEX "whispers_created_at_idx" ON "whispers"("created_at");

-- CreateIndex
CREATE INDEX "whispers_expires_at_idx" ON "whispers"("expires_at");

-- AddForeignKey
ALTER TABLE "whispers" ADD CONSTRAINT "whispers_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
