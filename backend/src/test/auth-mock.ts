import type { FastifyReply, FastifyRequest } from 'fastify'
import { vi } from 'vitest'
import type { AuthenticatedRequest } from '../lib/auth'

// 現在の認証ユーザーIDを保持
export let currentAuthUserId: string | null = null

// 認証ユーザーを設定
export function setAuthUser(userId: string | null) {
  currentAuthUserId = userId
}

// 認証モック関数
export const mockAuthenticate = vi.fn(async (request: FastifyRequest, reply: FastifyReply) => {
  if (!currentAuthUserId) {
    return reply.status(401).send({ message: '認証が必要です' })
  }
  ;(request as AuthenticatedRequest).user = {
    sub: currentAuthUserId,
    email: 'test@test.com',
    iat: 0,
    exp: 0,
  }
})

export const mockOptionalAuthenticate = vi.fn(async (request: FastifyRequest) => {
  if (currentAuthUserId) {
    ;(request as AuthenticatedRequest).user = {
      sub: currentAuthUserId,
      email: 'test@test.com',
      iat: 0,
      exp: 0,
    }
  }
})

// auth moduleをモックするためのセットアップ
export function setupAuthMock() {
  vi.mock('../lib/auth', () => ({
    authenticate: mockAuthenticate,
    optionalAuthenticate: mockOptionalAuthenticate,
  }))
}
