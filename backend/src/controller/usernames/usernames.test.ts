import Fastify from 'fastify'
import type { FastifyInstance } from 'fastify'
import { serializerCompiler, validatorCompiler } from 'fastify-type-provider-zod'
import { afterAll, beforeAll, describe, expect, it } from 'vitest'
import controller from './controller'

describe('GET /api/usernames/check', () => {
  let app: FastifyInstance

  beforeAll(async () => {
    app = Fastify()
    app.setValidatorCompiler(validatorCompiler)
    app.setSerializerCompiler(serializerCompiler)
    await app.register(controller)
    await app.ready()
  })

  afterAll(async () => {
    await app.close()
  })

  it('should return available: true for unused username', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/check',
      query: { username: 'newuser123' },
    })

    expect(response.statusCode).toBe(200)
    const body = JSON.parse(response.payload)
    expect(body.available).toBe(true)
  })

  it('should return 400 for username shorter than 3 characters', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/check',
      query: { username: 'ab' },
    })

    expect(response.statusCode).toBe(400)
  })

  it('should return 400 for username longer than 30 characters', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/check',
      query: { username: 'a'.repeat(31) },
    })

    expect(response.statusCode).toBe(400)
  })

  it('should return 400 for username with invalid characters', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/check',
      query: { username: 'user@name!' },
    })

    expect(response.statusCode).toBe(400)
  })

  it('should accept username with alphanumeric, underscore, and period', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/check',
      query: { username: 'user_name.123' },
    })

    expect(response.statusCode).toBe(200)
    const body = JSON.parse(response.payload)
    expect(body.available).toBe(true)
  })
})
