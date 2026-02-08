import Fastify from 'fastify'
import type { FastifyInstance, FastifyReply, FastifyRequest } from 'fastify'
import { serializerCompiler, validatorCompiler } from 'fastify-type-provider-zod'
import { afterAll, beforeAll, beforeEach, describe, expect, it, vi } from 'vitest'
import { prisma } from '../../../database'
import type { AuthenticatedRequest } from '../../../lib/auth'
import deleteController from './controller'

// 現在の認証ユーザーを保持
let currentAuthUserId: string | null = null

// auth moduleをモック
vi.mock('../../../lib/auth', () => ({
  authenticate: vi.fn(async (request: FastifyRequest, reply: FastifyReply) => {
    if (!currentAuthUserId) {
      return reply.status(401).send({ message: '認証が必要です' })
    }
    ;(request as AuthenticatedRequest).user = {
      sub: currentAuthUserId,
      email: 'test@test.com',
      iat: 0,
      exp: 0,
    }
  }),
}))

// storage serviceをモック
vi.mock('../../../services/storage', () => ({
  deleteWhisperFile: vi.fn().mockResolvedValue(undefined),
}))

describe('DELETE /api/whispers/:whisperId - ストーリー削除API', () => {
  let app: FastifyInstance
  let ownerUser: { id: string; email: string }
  let otherUser: { id: string; email: string }
  let whisper: { id: string; fileName: string }

  beforeAll(async () => {
    app = Fastify()
    app.setValidatorCompiler(validatorCompiler)
    app.setSerializerCompiler(serializerCompiler)
    await app.register(deleteController, { prefix: '/:whisperId' })
    await app.ready()
  })

  afterAll(async () => {
    await app.close()
  })

  beforeEach(async () => {
    await prisma.whisperView.deleteMany({})
    await prisma.whisper.deleteMany({})
    await prisma.user.deleteMany({})

    ownerUser = await prisma.user.create({
      data: { email: 'owner@test.com', name: 'Owner' },
    })
    otherUser = await prisma.user.create({
      data: { email: 'other@test.com', name: 'Other' },
    })

    const now = new Date()
    const tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000)

    whisper = await prisma.whisper.create({
      data: {
        userId: ownerUser.id,
        bucketName: 'test-bucket',
        fileName: 'test-file.mp3',
        duration: 10,
        expiresAt: tomorrow,
      },
    })
  })

  it('オーナーはストーリーを削除できる', async () => {
    currentAuthUserId = ownerUser.id
    const response = await app.inject({
      method: 'DELETE',
      url: `/${whisper.id}`,
    })

    expect(response.statusCode).toBe(200)
    const body = JSON.parse(response.body)
    expect(body.message).toBeDefined()

    // DBから削除されていることを確認
    const deletedWhisper = await prisma.whisper.findUnique({
      where: { id: whisper.id },
    })
    expect(deletedWhisper).toBeNull()
  })

  it('削除時に関連する閲覧履歴もカスケード削除される', async () => {
    // 閲覧履歴を作成
    await prisma.whisperView.create({
      data: {
        userId: otherUser.id,
        whisperId: whisper.id,
      },
    })

    currentAuthUserId = ownerUser.id
    const response = await app.inject({
      method: 'DELETE',
      url: `/${whisper.id}`,
    })

    expect(response.statusCode).toBe(200)

    // 閲覧履歴も削除されていることを確認
    const views = await prisma.whisperView.findMany({
      where: { whisperId: whisper.id },
    })
    expect(views).toHaveLength(0)
  })

  it('オーナー以外は削除できない', async () => {
    currentAuthUserId = otherUser.id
    const response = await app.inject({
      method: 'DELETE',
      url: `/${whisper.id}`,
    })

    expect(response.statusCode).toBe(403)
    const body = JSON.parse(response.body)
    expect(body.message).toBeDefined()

    // DBに残っていることを確認
    const existingWhisper = await prisma.whisper.findUnique({
      where: { id: whisper.id },
    })
    expect(existingWhisper).not.toBeNull()
  })

  it('存在しないストーリーは404を返す', async () => {
    currentAuthUserId = ownerUser.id
    const response = await app.inject({
      method: 'DELETE',
      url: `/non-existent-id`,
    })

    expect(response.statusCode).toBe(404)
    const body = JSON.parse(response.body)
    expect(body.message).toBeDefined()
  })

  it('認証がない場合は401を返す', async () => {
    currentAuthUserId = null
    const response = await app.inject({
      method: 'DELETE',
      url: `/${whisper.id}`,
    })

    expect(response.statusCode).toBe(401)
  })
})
