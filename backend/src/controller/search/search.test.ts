import Fastify from 'fastify'
import type { FastifyInstance } from 'fastify'
import { serializerCompiler, validatorCompiler } from 'fastify-type-provider-zod'
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest'
import { prisma } from '../../database'
import controller from './controller'

describe('GET /api/search/users', () => {
  let app: FastifyInstance
  let testUser1: { id: string }
  let testUser2: { id: string }
  let privateUser: { id: string }

  beforeAll(async () => {
    app = Fastify()
    app.setValidatorCompiler(validatorCompiler)
    app.setSerializerCompiler(serializerCompiler)
    await app.register(controller)
    await app.ready()
  })

  beforeEach(async () => {
    await prisma.user.deleteMany({
      where: {
        email: {
          in: [
            'searchtest1@example.com',
            'searchtest2@example.com',
            'privateuser@example.com',
          ],
        },
      },
    })

    testUser1 = await prisma.user.create({
      data: {
        id: 'search-test-user-1',
        email: 'searchtest1@example.com',
        username: 'john_doe',
        name: 'John Doe',
        isPrivate: false,
      },
    })

    testUser2 = await prisma.user.create({
      data: {
        id: 'search-test-user-2',
        email: 'searchtest2@example.com',
        username: 'jane_smith',
        name: 'Jane Smith',
        isPrivate: false,
      },
    })

    privateUser = await prisma.user.create({
      data: {
        id: 'search-private-user',
        email: 'privateuser@example.com',
        username: 'private_user',
        name: 'Private User',
        isPrivate: true,
      },
    })
  })

  afterAll(async () => {
    await prisma.user.deleteMany({
      where: {
        email: {
          in: [
            'searchtest1@example.com',
            'searchtest2@example.com',
            'privateuser@example.com',
          ],
        },
      },
    })
    await app.close()
  })

  it('should search users by name', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/users',
      query: { query: 'John' },
    })

    expect(response.statusCode).toBe(200)
    const body = JSON.parse(response.payload)
    expect(body.data).toHaveLength(1)
    expect(body.data[0].name).toBe('John Doe')
  })

  it('should search users by username', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/users',
      query: { query: 'jane' },
    })

    expect(response.statusCode).toBe(200)
    const body = JSON.parse(response.payload)
    expect(body.data).toHaveLength(1)
    expect(body.data[0].username).toBe('jane_smith')
  })

  it('should search with single character query', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/users',
      query: { query: 'J' },
    })

    expect(response.statusCode).toBe(200)
    const body = JSON.parse(response.payload)
    // John Doe と Jane Smith がヒットするはず
    expect(body.data.length).toBeGreaterThanOrEqual(1)
  })

  it('should return 400 for empty query', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/users',
      query: { query: '' },
    })

    expect(response.statusCode).toBe(400)
  })

  it('should include private users in search results', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/users',
      query: { query: 'private_user' },
    })

    expect(response.statusCode).toBe(200)
    const body = JSON.parse(response.payload)
    expect(body.data.length).toBeGreaterThanOrEqual(1)
    // テスト用プライベートユーザーが含まれていることを確認
    const privateTestUser = body.data.find((u: { username: string }) => u.username === 'private_user')
    expect(privateTestUser).toBeDefined()
    expect(privateTestUser.isPrivate).toBe(true)
  })

  it('should return empty array for no matches', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/users',
      query: { query: 'nonexistent' },
    })

    expect(response.statusCode).toBe(200)
    const body = JSON.parse(response.payload)
    expect(body.data).toHaveLength(0)
  })

  it('should support pagination', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/users',
      query: { query: 'user', page: '1', limit: '1' },
    })

    expect(response.statusCode).toBe(200)
    const body = JSON.parse(response.payload)
    expect(body.pagination).toBeDefined()
    expect(body.pagination.page).toBe(1)
    expect(body.pagination.limit).toBe(1)
  })
})
