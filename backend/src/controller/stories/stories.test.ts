import Fastify from 'fastify'
import type { FastifyInstance } from 'fastify'
import { serializerCompiler, validatorCompiler } from 'fastify-type-provider-zod'
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest'
import { prisma } from '../../database'
import storiesController from './controller'

describe('GET /api/stories - フォロー中ユーザーストーリーAPI', () => {
  let app: FastifyInstance
  let viewerUser: { id: string; email: string }
  let followingUser: { id: string; email: string }
  let viewedWhisper: { id: string }
  let unviewedWhisper: { id: string }

  beforeAll(async () => {
    app = Fastify()
    app.setValidatorCompiler(validatorCompiler)
    app.setSerializerCompiler(serializerCompiler)
    await app.register(storiesController)
    await app.ready()
  })

  afterAll(async () => {
    await app.close()
  })

  beforeEach(async () => {
    await prisma.whisperView.deleteMany({})
    await prisma.whisper.deleteMany({})
    await prisma.follow.deleteMany({})
    await prisma.user.deleteMany({})

    viewerUser = await prisma.user.create({
      data: { email: 'viewer@test.com', name: 'Viewer' },
    })
    followingUser = await prisma.user.create({
      data: { email: 'following@test.com', name: 'Following User' },
    })

    // フォロー関係を作成
    await prisma.follow.create({
      data: {
        followerId: viewerUser.id,
        followingId: followingUser.id,
      },
    })

    const now = new Date()
    const tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000)

    viewedWhisper = await prisma.whisper.create({
      data: {
        userId: followingUser.id,
        bucketName: 'test-bucket',
        fileName: 'viewed.mp3',
        duration: 10,
        expiresAt: tomorrow,
      },
    })

    unviewedWhisper = await prisma.whisper.create({
      data: {
        userId: followingUser.id,
        bucketName: 'test-bucket',
        fileName: 'unviewed.mp3',
        duration: 15,
        expiresAt: tomorrow,
      },
    })

    await prisma.whisperView.create({
      data: {
        userId: viewerUser.id,
        whisperId: viewedWhisper.id,
      },
    })
  })

  it('視聴済み・未視聴の両方の投稿が返される', async () => {
    const response = await app.inject({
      method: 'GET',
      url: `/?userId=${viewerUser.id}`,
    })

    const body = JSON.parse(response.body)
    expect(response.statusCode).toBe(200)
    expect(body.data).toHaveLength(1)
    expect(body.data[0].stories).toHaveLength(2)
  })

  it('isViewedフラグで視聴済みかどうかを判別できる', async () => {
    const response = await app.inject({
      method: 'GET',
      url: `/?userId=${viewerUser.id}`,
    })

    const body = JSON.parse(response.body)
    expect(response.statusCode).toBe(200)

    const viewedStory = body.data[0].stories.find((s: { id: string }) => s.id === viewedWhisper.id)
    const unviewedStory = body.data[0].stories.find(
      (s: { id: string }) => s.id === unviewedWhisper.id,
    )

    expect(viewedStory.isViewed).toBe(true)
    expect(unviewedStory.isViewed).toBe(false)
  })

  it('hasUnviewedフラグで未視聴投稿の有無を判別できる', async () => {
    const response = await app.inject({
      method: 'GET',
      url: `/?userId=${viewerUser.id}`,
    })

    const body = JSON.parse(response.body)
    expect(response.statusCode).toBe(200)
    expect(body.data[0].hasUnviewed).toBe(true)
  })

  it('すべての投稿が視聴済みの場合はhasUnviewedがfalseになる', async () => {
    // 全て視聴済みにする
    await prisma.whisperView.create({
      data: {
        userId: viewerUser.id,
        whisperId: unviewedWhisper.id,
      },
    })

    const response = await app.inject({
      method: 'GET',
      url: `/?userId=${viewerUser.id}`,
    })

    const body = JSON.parse(response.body)
    expect(response.statusCode).toBe(200)
    expect(body.data).toHaveLength(1)
    expect(body.data[0].hasUnviewed).toBe(false)
  })

  it('有効期限切れのWhisperは除外される（既存機能）', async () => {
    const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000)
    await prisma.whisper.updateMany({
      where: { userId: followingUser.id },
      data: { expiresAt: yesterday },
    })

    const response = await app.inject({
      method: 'GET',
      url: `/?userId=${viewerUser.id}`,
    })

    const body = JSON.parse(response.body)
    expect(response.statusCode).toBe(200)
    expect(body.data).toHaveLength(0)
  })
})
