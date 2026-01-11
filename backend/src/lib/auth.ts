import { createClient } from "@supabase/supabase-js";
import type { FastifyInstance, FastifyReply, FastifyRequest } from "fastify";

/**
 * JWTペイロードの型定義（Supabase Auth JWT）
 */
export interface JwtPayload {
  sub: string; // Supabase User ID
  email: string;
  iat: number;
  exp: number;
}

/**
 * 認証済みリクエストの型定義
 */
export interface AuthenticatedRequest extends FastifyRequest {
  user: JwtPayload;
}

// Supabaseクライアント（サーバーサイド用）
const supabase = createClient(
  process.env.SUPABASE_URL || "",
  process.env.SUPABASE_SERVICE_ROLE_KEY || ""
);

/**
 * JWT認証プラグインを登録
 * 注意: SupabaseはES256アルゴリズムを使用しているため、
 * @fastify/jwtは互換性のためにのみ登録し、
 * 実際の検証はSupabase APIを使用します
 */
export async function registerJwtAuth(fastify: FastifyInstance): Promise<void> {
  // @fastify/jwtは他のプラグインとの互換性のために登録
  // 実際のトークン検証はSupabase APIを使用
  await fastify.register(import("@fastify/jwt"), {
    secret: "dummy-secret-supabase-uses-es256",
  });

  // 認証デコレーターを追加（Supabase APIを使用）
  fastify.decorate(
    "authenticate",
    async (request: FastifyRequest, reply: FastifyReply) => {
      const authHeader = request.headers.authorization;
      if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return reply.status(401).send({ message: "認証が必要です" });
      }

      const token = authHeader.substring(7);
      const { data, error } = await supabase.auth.getUser(token);

      if (error || !data.user) {
        return reply.status(401).send({ message: "認証が必要です" });
      }

      // リクエストにユーザー情報を追加
      (request as AuthenticatedRequest).user = {
        sub: data.user.id,
        email: data.user.email || "",
        iat: 0,
        exp: 0,
      };
    }
  );
}

/**
 * 認証が必要なエンドポイント用のpreHandlerフック
 */
export async function authenticate(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  const authHeader = request.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return reply.status(401).send({ message: "認証が必要です" });
  }

  const token = authHeader.substring(7);
  const { data, error } = await supabase.auth.getUser(token);

  if (error || !data.user) {
    return reply.status(401).send({ message: "認証が必要です" });
  }

  // リクエストにユーザー情報を追加
  (request as AuthenticatedRequest).user = {
    sub: data.user.id,
    email: data.user.email || "",
    iat: 0,
    exp: 0,
  };
}

// Fastifyの型拡張
declare module "fastify" {
  interface FastifyInstance {
    authenticate: (
      request: FastifyRequest,
      reply: FastifyReply
    ) => Promise<void>;
  }
}

declare module "@fastify/jwt" {
  interface FastifyJWT {
    payload: JwtPayload;
    user: JwtPayload;
  }
}
