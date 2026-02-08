import Fastify from 'fastify'
import type { FastifyInstance } from 'fastify'
import { serializerCompiler, validatorCompiler } from 'fastify-type-provider-zod'
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest'
import { prisma } from '../../../../database'
import viewersController from './controller'

describe('GET /api/whispers/:whisperId/viewers - 閲覧者一覧API', () => {
  let app: FastifyInstance
  let ownerUser: { id: string; email: string }
  let viewer1: { id: string; email: string; name: string | null }
  let viewer2: { id: string; email: string; name: string | null }
  let whisper: { id: string }

  beforeAll(async () => {
    app = Fastify()
    app.setValidatorCompiler(validatorCompiler)
    app.setSerializerCompiler(serializerCompiler)
    // パラメータ付きでコントローラーを登録
    await app.register(viewersController, { prefix: '/:whisperId/viewers' })
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
    viewer1 = await prisma.user.create({
      data: { email: 'viewer1@test.com', name: 'Viewer One', avatarPath: 'avatars/viewer1.jpg' },
    })
    viewer2 = await prisma.user.create({
      data: { email: 'viewer2@test.com', name: 'Viewer Two' },
    })

    const now = new Date()
    const tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000)

    whisper = await prisma.whisper.create({
      data: {
        userId: ownerUser.id,
        bucketName: 'test-bucket',
        fileName: 'test.mp3',
        duration: 10,
        expiresAt: tomorrow,
      },
    })
  })

  it('閲覧者一覧を取得できる', async () => {
    // 閲覧履歴を作成
    await prisma.whisperView.create({
      data: {
        userId: viewer1.id,
        whisperId: whisper.id,
      },
    })

    const response = await app.inject({
      method: 'GET',
      url: `/${whisper.id}/viewers?userId=${ownerUser.id}`,
    })

    const body = JSON.parse(response.body)
    expect(response.statusCode).toBe(200)
    expect(body.data).toHaveLength(1)
    expect(body.totalCount).toBe(1)
    expect(body.data[0].id).toBe(viewer1.id)
    expect(body.data[0].name).toBe('Viewer One')
    expect(body.data[0].avatarUrl).toBe('avatars/viewer1.jpg')
  })

  it('閲覧日時の降順で並べられる', async () => {
    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000)
    const twoHoursAgo = new Date(Date.now() - 2 * 60 * 60 * 1000)

    await prisma.whisperView.create({
      data: {
        userId: viewer1.id,
        whisperId: whisper.id,
        viewedAt: twoHoursAgo,
      },
    })
    await prisma.whisperView.create({
      data: {
        userId: viewer2.id,
        whisperId: whisper.id,
        viewedAt: oneHourAgo,
      },
    })

    const response = await app.inject({
      method: 'GET',
      url: `/${whisper.id}/viewers?userId=${ownerUser.id}`,
    })

    const body = JSON.parse(response.body)
    expect(response.statusCode).toBe(200)
    expect(body.data).toHaveLength(2)
    // viewer2が先（より新しい）
    expect(body.data[0].id).toBe(viewer2.id)
    expect(body.data[1].id).toBe(viewer1.id)
  })

  it('閲覧者がいない場合は空配列を返す', async () => {
    const response = await app.inject({
      method: 'GET',
      url: `/${whisper.id}/viewers?userId=${ownerUser.id}`,
    })

    const body = JSON.parse(response.body)
    expect(response.statusCode).toBe(200)
    expect(body.data).toHaveLength(0)
    expect(body.totalCount).toBe(0)
  })

  it('存在しないWhisperの場合は404を返す', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/non-existent-id/viewers?userId=' + ownerUser.id,
    })

    expect(response.statusCode).toBe(404)
    const body = JSON.parse(response.body)
    expect(body.message).toBeDefined()
  })

  it('オーナー以外がアクセスした場合は403を返す', async () => {
    const response = await app.inject({
      method: 'GET',
      url: `/${whisper.id}/viewers?userId=${viewer1.id}`,
    })

    expect(response.statusCode).toBe(403)
    const body = JSON.parse(response.body)
    expect(body.message).toBeDefined()
  })

  it('userIdが指定されていない場合は400を返す', async () => {
    const response = await app.inject({
      method: 'GET',
      url: `/${whisper.id}/viewers`,
    })

    expect(response.statusCode).toBe(400)
  })

  it('閲覧日時がレスポンスに含まれる', async () => {
    const viewedAt = new Date()
    await prisma.whisperView.create({
      data: {
        userId: viewer1.id,
        whisperId: whisper.id,
        viewedAt,
      },
    })

    const response = await app.inject({
      method: 'GET',
      url: `/${whisper.id}/viewers?userId=${ownerUser.id}`,
    })

    const body = JSON.parse(response.body)
    expect(response.statusCode).toBe(200)
    expect(body.data[0].viewedAt).toBeDefined()
    expect(new Date(body.data[0].viewedAt).getTime()).toBeCloseTo(viewedAt.getTime(), -3)
  })
})
