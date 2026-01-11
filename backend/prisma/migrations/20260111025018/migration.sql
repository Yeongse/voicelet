-- CreateTable
CREATE TABLE "whispers" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "bucket_name" TEXT NOT NULL,
    "file_name" TEXT NOT NULL,
    "duration" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "whispers_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "whispers_user_id_idx" ON "whispers"("user_id");

-- CreateIndex
CREATE INDEX "whispers_created_at_idx" ON "whispers"("created_at");

-- AddForeignKey
ALTER TABLE "whispers" ADD CONSTRAINT "whispers_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
