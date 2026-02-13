import Fastify from 'fastify'
import type { FastifyInstance } from 'fastify'
import { SignJWT, exportJWK, generateKeyPair } from 'jose'
import { serializerCompiler, validatorCompiler } from 'fastify-type-provider-zod'
import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest'
import controller from './controller'

// Supabaseモック
vi.mock('@supabase/supabase-js', () => ({
  createClient: vi.fn(() => ({
    auth: {
      admin: {
        listUsers: vi.fn().mockResolvedValue({
          data: {
            users: [
              {
                id: 'test-user-id',
                identities: [
                  { provider: 'apple', id: 'apple-sub-12345' }
                ]
              }
            ]
          },
          error: null
        }),
        signOut: vi.fn().mockResolvedValue({ error: null })
      }
    }
  }))
}))

describe('POST /api/auth/apple/revocation', () => {
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

  it('should return 400 for empty payload', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/revocation',
      payload: { payload: '' },
    })

    expect(response.statusCode).toBe(400)
  })

  it('should return 400 for invalid JWT', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/revocation',
      payload: { payload: 'invalid-jwt-token' },
    })

    expect(response.statusCode).toBe(400)
    const body = JSON.parse(response.payload)
    expect(body.message).toBe('Invalid JWT')
  })

  it('should validate JWT issuer', async () => {
    // 偽のキーペアを生成
    const { privateKey } = await generateKeyPair('RS256')

    // 不正なissuerでJWTを生成
    const jwt = await new SignJWT({
      events: JSON.stringify({
        type: 'consent-revoked',
        sub: 'apple-sub-12345',
        event_time: Date.now() / 1000
      })
    })
      .setProtectedHeader({ alg: 'RS256' })
      .setIssuer('https://malicious-site.com')
      .setAudience('com.example.app')
      .setIssuedAt()
      .sign(privateKey)

    const response = await app.inject({
      method: 'POST',
      url: '/revocation',
      payload: { payload: jwt },
    })

    // Apple JWKSで検証できないため400エラー
    expect(response.statusCode).toBe(400)
  })
})

describe('Apple Event Payload Validation', () => {
  it('should parse consent-revoked event', async () => {
    const { appleEventPayloadSchema } = await import('./schema')

    const validPayload = {
      type: 'consent-revoked',
      sub: 'apple-user-sub-12345',
      event_time: 1234567890
    }

    const result = appleEventPayloadSchema.safeParse(validPayload)
    expect(result.success).toBe(true)
    if (result.success) {
      expect(result.data.type).toBe('consent-revoked')
      expect(result.data.sub).toBe('apple-user-sub-12345')
    }
  })

  it('should parse account-delete event', async () => {
    const { appleEventPayloadSchema } = await import('./schema')

    const validPayload = {
      type: 'account-delete',
      sub: 'apple-user-sub-12345',
      event_time: 1234567890
    }

    const result = appleEventPayloadSchema.safeParse(validPayload)
    expect(result.success).toBe(true)
  })

  it('should reject invalid event type', async () => {
    const { appleEventPayloadSchema } = await import('./schema')

    const invalidPayload = {
      type: 'invalid-event',
      sub: 'apple-user-sub-12345',
      event_time: 1234567890
    }

    const result = appleEventPayloadSchema.safeParse(invalidPayload)
    expect(result.success).toBe(false)
  })

  it('should reject payload without sub', async () => {
    const { appleEventPayloadSchema } = await import('./schema')

    const invalidPayload = {
      type: 'consent-revoked',
      event_time: 1234567890
    }

    const result = appleEventPayloadSchema.safeParse(invalidPayload)
    expect(result.success).toBe(false)
  })
})

describe('Apple Revocation Request Schema', () => {
  it('should validate request with payload', async () => {
    const { appleRevocationRequestSchema } = await import('./schema')

    const validRequest = {
      payload: 'eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.signature'
    }

    const result = appleRevocationRequestSchema.safeParse(validRequest)
    expect(result.success).toBe(true)
  })

  it('should reject request without payload', async () => {
    const { appleRevocationRequestSchema } = await import('./schema')

    const invalidRequest = {}

    const result = appleRevocationRequestSchema.safeParse(invalidRequest)
    expect(result.success).toBe(false)
  })

  it('should reject request with empty payload', async () => {
    const { appleRevocationRequestSchema } = await import('./schema')

    const invalidRequest = { payload: '' }

    const result = appleRevocationRequestSchema.safeParse(invalidRequest)
    expect(result.success).toBe(false)
  })
})
