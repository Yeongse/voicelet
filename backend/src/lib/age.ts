/**
 * 生年月から年齢を計算する
 * @param birthMonth YYYY-MM形式の生年月
 * @returns 計算された年齢、無効な形式の場合はnull
 */
export function calculateAge(birthMonth: string | null): number | null {
  if (!birthMonth) return null

  const match = birthMonth.match(/^(\d{4})-(0[1-9]|1[0-2])$/)
  if (!match) return null

  const birthYear = Number.parseInt(match[1], 10)
  const birthMonthNum = Number.parseInt(match[2], 10)

  const now = new Date()
  const currentYear = now.getFullYear()
  const currentMonth = now.getMonth() + 1 // 0-indexed to 1-indexed

  let age = currentYear - birthYear

  // 現在の月が誕生月より前の場合は1歳引く
  if (currentMonth < birthMonthNum) {
    age -= 1
  }

  return age
}
