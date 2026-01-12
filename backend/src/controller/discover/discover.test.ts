import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import { prisma } from '../../database'
import Fastify from 'fastify'
import type { FastifyInstance } from 'fastify'
import {
  serializerCompiler,
  validatorCompiler,
} from 'fastify-type-provider-zod'
import discoverController from './controller'

describe('GET /api/discover - おすすめユーザー一覧API', () => {
  let app: FastifyInstance
  let viewerUser: { id: string; email: string }
  let otherUser: { id: string; email: string }
  let viewedWhisper: { id: string }
  let unviewedWhisper: { id: string }

  beforeAll(async () => {
    app = Fastify()
    app.setValidatorCompiler(validatorCompiler)
    app.setSerializerCompiler(serializerCompiler)
    await app.register(discoverController)
    await app.ready()
  })

  afterAll(async () => {
    await app.close()
  })

  beforeEach(async () => {
    // テストデータをクリーンアップ
    await prisma.whisperView.deleteMany({})
    await prisma.whisper.deleteMany({})
    await prisma.follow.deleteMany({})
    await prisma.user.deleteMany({})

    // テストユーザーを作成
    viewerUser = await prisma.user.create({
      data: { email: 'viewer@test.com', name: 'Viewer' },
    })
    otherUser = await prisma.user.create({
      data: { email: 'other@test.com', name: 'Other User' },
    })

    const now = new Date()
    const tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000)

    // 視聴済みのWhisper
    viewedWhisper = await prisma.whisper.create({
      data: {
        userId: otherUser.id,
        bucketName: 'test-bucket',
        fileName: 'viewed.mp3',
        duration: 10,
        expiresAt: tomorrow,
      },
    })

    // 未視聴のWhisper
    unviewedWhisper = await prisma.whisper.create({
      data: {
        userId: otherUser.id,
        bucketName: 'test-bucket',
        fileName: 'unviewed.mp3',
        duration: 15,
        expiresAt: tomorrow,
      },
    })

    // 視聴記録を作成
    await prisma.whisperView.create({
      data: {
        userId: viewerUser.id,
        whisperId: viewedWhisper.id,
      },
    })
  })

  it('視聴済みWhisperのみを持つユーザーも一覧に表示される', async () => {
    // 未視聴Whisperを削除（視聴済みのみにする）
    await prisma.whisper.delete({ where: { id: unviewedWhisper.id } })

    const response = await app.inject({
      method: 'GET',
      url: `/?userId=${viewerUser.id}&page=1&limit=10`,
    })

    const body = JSON.parse(response.body)
    expect(response.statusCode).toBe(200)
    expect(body.data).toHaveLength(1)
    expect(body.data[0].hasUnviewed).toBe(false)
  })

  it('未視聴Whisperを持つユーザーはhasUnviewedがtrueになる', async () => {
    const response = await app.inject({
      method: 'GET',
      url: `/?userId=${viewerUser.id}&page=1&limit=10`,
    })

    const body = JSON.parse(response.body)
    expect(response.statusCode).toBe(200)
    expect(body.data).toHaveLength(1)
    expect(body.data[0].id).toBe(otherUser.id)
    expect(body.data[0].hasUnviewed).toBe(true)
    // whisperCountは全てのWhisperをカウント
    expect(body.data[0].whisperCount).toBe(2)
  })

  it('有効期限切れのWhisperは除外される（既存機能）', async () => {
    const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000)
    await prisma.whisper.update({
      where: { id: unviewedWhisper.id },
      data: { expiresAt: yesterday },
    })
    // 視聴済みWhisperも期限切れにする
    await prisma.whisper.update({
      where: { id: viewedWhisper.id },
      data: { expiresAt: yesterday },
    })

    const response = await app.inject({
      method: 'GET',
      url: `/?userId=${viewerUser.id}&page=1&limit=10`,
    })

    const body = JSON.parse(response.body)
    expect(response.statusCode).toBe(200)
    expect(body.data).toHaveLength(0)
  })
})

describe('GET /api/discover/:targetUserId/stories - おすすめユーザーストーリーAPI', () => {
  let app: FastifyInstance
  let viewerUser: { id: string; email: string }
  let targetUser: { id: string; email: string }
  let viewedWhisper: { id: string }
  let unviewedWhisper: { id: string }

  beforeAll(async () => {
    app = Fastify()
    app.setValidatorCompiler(validatorCompiler)
    app.setSerializerCompiler(serializerCompiler)
    await app.register(discoverController)
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
    targetUser = await prisma.user.create({
      data: { email: 'target@test.com', name: 'Target User' },
    })

    const now = new Date()
    const tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000)

    viewedWhisper = await prisma.whisper.create({
      data: {
        userId: targetUser.id,
        bucketName: 'test-bucket',
        fileName: 'viewed.mp3',
        duration: 10,
        expiresAt: tomorrow,
      },
    })

    unviewedWhisper = await prisma.whisper.create({
      data: {
        userId: targetUser.id,
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
      url: `/${targetUser.id}/stories?userId=${viewerUser.id}`,
    })

    const body = JSON.parse(response.body)
    expect(response.statusCode).toBe(200)
    expect(body.stories).toHaveLength(2)
  })

  it('isViewedフラグで視聴済みかどうかを判別できる', async () => {
    const response = await app.inject({
      method: 'GET',
      url: `/${targetUser.id}/stories?userId=${viewerUser.id}`,
    })

    const body = JSON.parse(response.body)
    expect(response.statusCode).toBe(200)

    const viewedStory = body.stories.find(
      (s: { id: string }) => s.id === viewedWhisper.id,
    )
    const unviewedStory = body.stories.find(
      (s: { id: string }) => s.id === unviewedWhisper.id,
    )

    expect(viewedStory.isViewed).toBe(true)
    expect(unviewedStory.isViewed).toBe(false)
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
      url: `/${targetUser.id}/stories?userId=${viewerUser.id}`,
    })

    const body = JSON.parse(response.body)
    expect(response.statusCode).toBe(200)
    expect(body.stories).toHaveLength(2)
    expect(body.hasUnviewed).toBe(false)
  })
})
