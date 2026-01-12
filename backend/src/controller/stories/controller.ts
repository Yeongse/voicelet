import { prisma } from '../../database'
import type { ServerInstance } from '../../lib/fastify'
import { errorResponseSchema, storiesQuerySchema, storiesResponseSchema } from './schema'

export default async function (fastify: ServerInstance) {
  // GET /api/stories - フォロー中ユーザーのストーリー取得
  fastify.get(
    '/',
    {
      schema: {
        tags: ['Stories'],
        summary: 'フォロー中ユーザーのストーリー取得',
        description: 'フォロー中ユーザーの24時間以内のWhisperをユーザー単位でグループ化して取得',
        querystring: storiesQuerySchema,
        response: {
          200: storiesResponseSchema,
          401: errorResponseSchema,
        },
      },
    },
    async (request, reply) => {
      const { userId } = request.query as { userId: string }

      const user = await prisma.user.findUnique({ where: { id: userId } })
      if (!user) {
        return reply.status(401).send({ message: 'ユーザーが見つかりません' })
      }

      const twentyFourHoursAgo = new Date()
      twentyFourHoursAgo.setHours(twentyFourHoursAgo.getHours() - 24)

      // フォロー中ユーザーのIDを取得
      const following = await prisma.follow.findMany({
        where: { followerId: userId },
        select: { followingId: true },
      })
      const followingIds = following.map((f) => f.followingId)

      if (followingIds.length === 0) {
        return reply.send({ data: [] })
      }

      // フォロー中ユーザーの有効なWhisperを取得（視聴済みも含む）
      const whispers = await prisma.whisper.findMany({
        where: {
          userId: { in: followingIds },
          createdAt: { gte: twentyFourHoursAgo },
          expiresAt: { gt: new Date() },
        },
        include: {
          user: { select: { id: true, name: true, avatarPath: true } },
          views: { where: { userId }, select: { id: true } },
        },
        orderBy: { createdAt: 'desc' },
      })

      // ユーザーごとにグループ化
      const userStoriesMap = new Map<
        string,
        {
          user: { id: string; name: string; avatarUrl: string | null }
          stories: Array<{ id: string; duration: number; createdAt: string; isViewed: boolean }>
          latestCreatedAt: Date
          hasUnviewed: boolean
        }
      >()

      for (const whisper of whispers) {
        const isViewed = whisper.views.length > 0
        const storyItem = {
          id: whisper.id,
          duration: whisper.duration,
          createdAt: whisper.createdAt.toISOString(),
          isViewed,
        }

        const existing = userStoriesMap.get(whisper.userId)
        if (existing) {
          existing.stories.push(storyItem)
          if (whisper.createdAt > existing.latestCreatedAt) {
            existing.latestCreatedAt = whisper.createdAt
          }
          if (!isViewed) {
            existing.hasUnviewed = true
          }
        } else {
          userStoriesMap.set(whisper.userId, {
            user: {
              id: whisper.user.id,
              name: whisper.user.name ?? '',
              avatarUrl: whisper.user.avatarPath,
            },
            stories: [storyItem],
            latestCreatedAt: whisper.createdAt,
            hasUnviewed: !isViewed,
          })
        }
      }

      // 各ユーザーのストーリーを古い順にソート
      for (const userStory of userStoriesMap.values()) {
        userStory.stories.sort(
          (a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime(),
        )
      }

      // ユーザーを最新投稿順でソート
      const data = Array.from(userStoriesMap.values())
        .sort((a, b) => b.latestCreatedAt.getTime() - a.latestCreatedAt.getTime())
        .map(({ user, stories, hasUnviewed }) => ({ user, stories, hasUnviewed }))

      return reply.send({ data })
    },
  )
}
