import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import { prisma } from '../../database'
import Fastify from 'fastify'
import type { FastifyInstance } from 'fastify'
import {
  serializerCompiler,
  validatorCompiler,
} from 'fastify-type-provider-zod'
import whisperViewsController from './controller'

describe('POST /api/whisper-views - 視聴履歴記録API', () => {
  let app: FastifyInstance
  let viewer: { id: string; email: string }
  let whisperOwner: { id: string; email: string }
  let whisper: { id: string }

  beforeAll(async () => {
    app = Fastify()
    app.setValidatorCompiler(validatorCompiler)
    app.setSerializerCompiler(serializerCompiler)
    await app.register(whisperViewsController)
    await app.ready()
  })

  afterAll(async () => {
    await app.close()
  })

  beforeEach(async () => {
    await prisma.whisperView.deleteMany({})
    await prisma.whisper.deleteMany({})
    await prisma.user.deleteMany({})

    viewer = await prisma.user.create({
      data: { email: 'viewer@test.com', name: 'Viewer' },
    })
    whisperOwner = await prisma.user.create({
      data: { email: 'owner@test.com', name: 'Owner' },
    })

    const now = new Date()
    const tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000)

    whisper = await prisma.whisper.create({
      data: {
        userId: whisperOwner.id,
        bucketName: 'test-bucket',
        fileName: 'test.mp3',
        duration: 10,
        expiresAt: tomorrow,
      },
    })
  })

  it('新規視聴履歴を作成できる', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/',
      payload: {
        userId: viewer.id,
        whisperId: whisper.id,
      },
    })

    expect(response.statusCode).toBe(201)
    const body = JSON.parse(response.body)
    expect(body.message).toBeDefined()
    expect(body.view.userId).toBe(viewer.id)
    expect(body.view.whisperId).toBe(whisper.id)
  })

  it('同一ユーザーが同一ストーリーを再度閲覧した場合、閲覧日時のみ更新する', async () => {
    // 最初の閲覧
    const pastDate = new Date(Date.now() - 60 * 60 * 1000)
    await prisma.whisperView.create({
      data: {
        userId: viewer.id,
        whisperId: whisper.id,
        viewedAt: pastDate,
      },
    })

    // 再閲覧
    const response = await app.inject({
      method: 'POST',
      url: '/',
      payload: {
        userId: viewer.id,
        whisperId: whisper.id,
      },
    })

    expect(response.statusCode).toBe(200)
    const body = JSON.parse(response.body)
    expect(body.message).toBeDefined()

    // 閲覧日時が更新されていることを確認
    const updatedView = await prisma.whisperView.findUnique({
      where: { userId_whisperId: { userId: viewer.id, whisperId: whisper.id } },
    })
    expect(updatedView).not.toBeNull()
    expect(new Date(updatedView!.viewedAt).getTime()).toBeGreaterThan(pastDate.getTime())
  })

  it('再閲覧時に重複レコードを作成しない', async () => {
    // 最初の閲覧
    await prisma.whisperView.create({
      data: {
        userId: viewer.id,
        whisperId: whisper.id,
      },
    })

    // 再閲覧
    await app.inject({
      method: 'POST',
      url: '/',
      payload: {
        userId: viewer.id,
        whisperId: whisper.id,
      },
    })

    // レコード数を確認
    const viewCount = await prisma.whisperView.count({
      where: { userId: viewer.id, whisperId: whisper.id },
    })
    expect(viewCount).toBe(1)
  })
})
