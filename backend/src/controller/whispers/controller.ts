import { prisma } from "../../database";
import { type ServerInstance } from "../../lib/fastify";
import {
  buildPaginationResponse,
  calculatePagination,
} from "../../lib/pagination";
import {
  generateUploadSignedUrl,
  generateDownloadSignedUrl,
  getBucketName,
  fileExists,
} from "../../services/storage";
import {
  signedUrlRequestSchema,
  signedUrlResponseSchema,
  createWhisperRequestSchema,
  createWhisperResponseSchema,
  listWhispersQuerySchema,
  listWhispersResponseSchema,
  audioUrlResponseSchema,
  errorResponseSchema,
} from "./schema";

export default async function (fastify: ServerInstance) {
  // ===========================================
  // POST /api/whispers/signed-url
  // アップロード用の署名付きURLを生成
  // ===========================================
  fastify.post(
    "/signed-url",
    {
      schema: {
        tags: ["Whisper"],
        summary: "署名付きURL生成",
        description: "GCSへのアップロード用署名付きURLを生成します。",
        body: signedUrlRequestSchema,
        response: {
          200: signedUrlResponseSchema,
          404: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const { fileName, userId } = request.body;

      // ユーザー存在確認
      const user = await prisma.user.findUnique({
        where: { id: userId },
      });

      if (!user) {
        return reply.status(404).send({ message: "ユーザーが見つかりません" });
      }

      const { signedUrl, expiresAt } = await generateUploadSignedUrl({
        fileName,
        contentType: "audio/mp4",
        expiresInMinutes: 15,
      });

      return reply.send({
        signedUrl,
        bucketName: getBucketName(),
        fileName,
        expiresAt: expiresAt.toISOString(),
      });
    }
  );

  // ===========================================
  // POST /api/whispers
  // 音声投稿を作成
  // ===========================================
  fastify.post(
    "/",
    {
      schema: {
        tags: ["Whisper"],
        summary: "音声投稿作成",
        description:
          "GCSへのアップロード完了後に呼び出し、音声投稿のメタデータを保存します。",
        body: createWhisperRequestSchema,
        response: {
          201: createWhisperResponseSchema,
          400: errorResponseSchema,
          404: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const { userId, fileName, duration } = request.body;

      // ユーザー存在確認
      const user = await prisma.user.findUnique({
        where: { id: userId },
      });

      if (!user) {
        return reply.status(404).send({ message: "ユーザーが見つかりません" });
      }

      // ファイルがGCSに存在するか確認
      const exists = await fileExists(fileName);
      if (!exists) {
        return reply.status(400).send({
          message: "音声ファイルがアップロードされていません",
        });
      }

      const bucketName = getBucketName();

      const whisper = await prisma.whisper.create({
        data: {
          userId,
          bucketName,
          fileName,
          duration,
        },
      });

      return reply.status(201).send({
        message: "音声投稿を作成しました",
        whisper: {
          id: whisper.id,
          userId: whisper.userId,
          bucketName: whisper.bucketName,
          fileName: whisper.fileName,
          duration: whisper.duration,
          createdAt: whisper.createdAt.toISOString(),
        },
      });
    }
  );

  // ===========================================
  // GET /api/whispers
  // 音声投稿一覧を取得
  // ===========================================
  fastify.get(
    "/",
    {
      schema: {
        tags: ["Whisper"],
        summary: "音声投稿一覧",
        description: "音声投稿の一覧を取得します。userIdでフィルタ可能。",
        querystring: listWhispersQuerySchema,
        response: {
          200: listWhispersResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const { page, limit, userId } = request.query;

      const { skip, take } = calculatePagination({ page, limit });

      const where = userId ? { userId } : {};

      const [whispers, total] = await Promise.all([
        prisma.whisper.findMany({
          where,
          skip,
          take,
          orderBy: { createdAt: "desc" },
        }),
        prisma.whisper.count({ where }),
      ]);

      const whispersData = whispers.map((whisper) => ({
        id: whisper.id,
        userId: whisper.userId,
        bucketName: whisper.bucketName,
        fileName: whisper.fileName,
        duration: whisper.duration,
        createdAt: whisper.createdAt.toISOString(),
      }));

      const response = buildPaginationResponse({
        data: whispersData,
        total,
        page,
        limit,
      });

      return reply.send(response);
    }
  );

  // ===========================================
  // GET /api/whispers/:whisperId/audio-url
  // 再生用署名付きURLを取得
  // ===========================================
  fastify.get(
    "/:whisperId/audio-url",
    {
      schema: {
        tags: ["Whisper"],
        summary: "再生用署名付きURL取得",
        description: "指定されたWhisperの再生用署名付きURLを生成します。",
        params: {
          type: "object",
          properties: {
            whisperId: { type: "string" },
          },
          required: ["whisperId"],
        },
        response: {
          200: audioUrlResponseSchema,
          404: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const { whisperId } = request.params as { whisperId: string };

      const whisper = await prisma.whisper.findUnique({
        where: { id: whisperId },
      });

      if (!whisper) {
        return reply.status(404).send({ message: "投稿が見つかりません" });
      }

      const expiresInMinutes = 60;
      const expiresAt = new Date();
      expiresAt.setMinutes(expiresAt.getMinutes() + expiresInMinutes);

      const signedUrl = await generateDownloadSignedUrl(
        whisper.fileName,
        expiresInMinutes
      );

      return reply.send({
        signedUrl,
        expiresAt: expiresAt.toISOString(),
      });
    }
  );
}
