import { z } from 'zod'

export const getUserProfileParamsSchema = z.object({
  userId: z.string().uuid(),
})
