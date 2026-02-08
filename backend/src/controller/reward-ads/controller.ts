import { prisma } from '../../database'
import type { ServerInstance } from '../../lib/fastify'
import { authenticate, type AuthenticatedRequest } from '../../lib/auth'
import {
  errorResponseSchema,
  statusResponseSchema,
  useResponseSchema,
  tooManyRequestsResponseSchema,
} from './schema'

// リワード広告の1日あたりの使用回数上限
const DAILY_REWARD_LIMIT = 3
// リセット時刻（JST 午前5時）
const RESET_HOUR_JST = 5

/**
 * JST午前5時を基準とした「アプリ日付」の開始時刻を計算
 * 例: 2024-01-15 04:59 JST -> 2024-01-14 05:00 JST
 *     2024-01-15 05:00 JST -> 2024-01-15 05:00 JST
 */
function getAppDayStartJST(now: Date = new Date()): Date {
  // JSTに変換（UTC + 9時間）
  const jstOffset = 9 * 60 * 60 * 1000
  const jstNow = new Date(now.getTime() + jstOffset)

  // JST基準の年月日時を取得
  const jstYear = jstNow.getUTCFullYear()
  const jstMonth = jstNow.getUTCMonth()
  const jstDate = jstNow.getUTCDate()
  const jstHour = jstNow.getUTCHours()

  // 午前5時より前なら前日の午前5時が開始
  let startDate: Date
  if (jstHour < RESET_HOUR_JST) {
    startDate = new Date(Date.UTC(jstYear, jstMonth, jstDate - 1, RESET_HOUR_JST - 9, 0, 0, 0))
  } else {
    startDate = new Date(Date.UTC(jstYear, jstMonth, jstDate, RESET_HOUR_JST - 9, 0, 0, 0))
  }

  return startDate
}

/**
 * 次のリセット時刻を計算（JST 午前5時）
 */
function getNextResetTimeJST(now: Date = new Date()): Date {
  const appDayStart = getAppDayStartJST(now)
  // 次のリセットは現在のアプリ日付の翌日午前5時
  return new Date(appDayStart.getTime() + 24 * 60 * 60 * 1000)
}

export default async function (fastify: ServerInstance) {
  // GET /api/reward-ads/status - リワード広告ステータス取得
  fastify.get(
    '/status',
    {
      preHandler: [authenticate],
      schema: {
        tags: ['RewardAds'],
        summary: 'リワード広告ステータス取得',
        description: '本日の残り使用回数と次のリセット時刻を取得します',
        response: {
          200: statusResponseSchema,
          401: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const userId = (request as AuthenticatedRequest).user.sub
      const now = new Date()
      const appDayStart = getAppDayStartJST(now)
      const nextResetAt = getNextResetTimeJST(now)

      // ユーザーの使用履歴を取得
      const usage = await prisma.rewardAdUsage.findUnique({
        where: { userId },
      })

      let remainingCount = DAILY_REWARD_LIMIT
      let todayClearedCount = 0

      if (usage) {
        // usageDate が今日のアプリ日付と一致するか確認
        const usageDayStart = getAppDayStartJST(usage.usageDate)
        if (usageDayStart.getTime() === appDayStart.getTime()) {
          // 同じ日なら使用回数を反映
          remainingCount = Math.max(0, DAILY_REWARD_LIMIT - usage.usageCount)
        }
        // 異なる日なら使用回数はリセット（remainingCount = 3 のまま）
      }

      return reply.status(200).send({
        remainingCount,
        nextResetAt: nextResetAt.toISOString(),
        todayClearedCount,
      })
    },
  )

  // POST /api/reward-ads/use - リワード広告使用
  fastify.post(
    '/use',
    {
      preHandler: [authenticate],
      schema: {
        tags: ['RewardAds'],
        summary: 'リワード広告使用',
        description: 'リワード広告を使用して本日の視聴履歴をクリアします',
        response: {
          200: useResponseSchema,
          401: errorResponseSchema,
          429: tooManyRequestsResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const userId = (request as AuthenticatedRequest).user.sub
      const now = new Date()
      const appDayStart = getAppDayStartJST(now)
      const appDayEnd = new Date(appDayStart.getTime() + 24 * 60 * 60 * 1000)
      const nextResetAt = getNextResetTimeJST(now)

      // トランザクションで使用回数チェックと更新を実行
      const result = await prisma.$transaction(async (tx) => {
        // 既存の使用履歴を取得
        const usage = await tx.rewardAdUsage.findUnique({
          where: { userId },
        })

        let currentUsageCount = 0
        let isNewDay = true

        if (usage) {
          const usageDayStart = getAppDayStartJST(usage.usageDate)
          if (usageDayStart.getTime() === appDayStart.getTime()) {
            // 同じ日
            currentUsageCount = usage.usageCount
            isNewDay = false
          }
        }

        // 残り回数チェック
        if (currentUsageCount >= DAILY_REWARD_LIMIT) {
          return {
            success: false,
            remainingCount: 0,
            clearedCount: 0,
          }
        }

        // 使用回数を更新
        const newUsageCount = isNewDay ? 1 : currentUsageCount + 1

        await tx.rewardAdUsage.upsert({
          where: { userId },
          create: {
            userId,
            usageCount: 1,
            usageDate: appDayStart,
            lastUsedAt: now,
          },
          update: {
            usageCount: newUsageCount,
            usageDate: appDayStart,
            lastUsedAt: now,
          },
        })

        // 当日の視聴履歴を削除
        const deleteResult = await tx.whisperView.deleteMany({
          where: {
            userId,
            viewedAt: {
              gte: appDayStart,
              lt: appDayEnd,
            },
          },
        })

        return {
          success: true,
          remainingCount: DAILY_REWARD_LIMIT - newUsageCount,
          clearedCount: deleteResult.count,
        }
      })

      if (!result.success) {
        return reply.status(429).send({
          message: '本日の利用上限に達しました',
          remainingCount: 0,
          nextResetAt: nextResetAt.toISOString(),
        })
      }

      return reply.status(200).send({
        success: true,
        clearedCount: result.clearedCount,
        remainingCount: result.remainingCount,
        nextResetAt: nextResetAt.toISOString(),
      })
    },
  )
}
