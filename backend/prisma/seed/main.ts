import { PrismaClient, type User } from '@prisma/client'
import { config } from 'dotenv'

// .envファイルを読み込み
config()

const prisma = new PrismaClient()

// デモユーザーID（モバイルアプリと共通）
const DEMO_USER_ID = 'demo-user-001'

// 実際のユーザーメールアドレス
const REAL_USER_EMAIL = 'yeongsekm@gmail.com'

// 音声ファイル用バケット名（環境変数から取得）
const GCS_BUCKET_NAME = process.env.GCS_BUCKET_NAME ?? 'voicelet-audio-voicelet'

// テスト用の固定音声ファイル名（再生動作確認用）
const DEMO_AUDIO_FILE = 'f7974ff5-fb84-47aa-b255-198874396a0c_1768662992629.m4a'

// リアルなユーザーデータ
const REALISTIC_USERS = [
  {
    username: 'yuki_music',
    name: '結城ゆき',
    bio: '音楽とカフェ巡りが好き☕️ 週末はよくライブに行ってます。邦ロック/シティポップ/R&B',
    birthMonth: '1998-03',
    isPrivate: false,
  },
  {
    username: 'takeshi_dev',
    name: 'たけし',
    bio: 'フロントエンドエンジニア | React/TypeScript | 趣味はキャンプとコーヒー焙煎',
    birthMonth: '1995-11',
    isPrivate: false,
  },
  {
    username: 'sakura.photo',
    name: '桜井さくら',
    bio: '📸 フォトグラファー | 風景写真メイン | Nikon Z8愛用 | 撮影依頼はDMまで',
    birthMonth: '1992-04',
    isPrivate: false,
  },
  {
    username: 'kenta_runner',
    name: '健太',
    bio: 'サブ3目指して練習中🏃‍♂️ フルマラソン: 3:12:45 | 朝ラン派',
    birthMonth: '1990-08',
    isPrivate: false,
  },
  {
    username: 'mina.cooking',
    name: 'みなみ',
    bio: '料理研究家 | 簡単レシピを発信中 | 著書「今日から始める時短ごはん」',
    birthMonth: '1988-12',
    isPrivate: false,
  },
  {
    username: 'ryo_gaming',
    name: 'りょう',
    bio: 'ゲーム配信者 | Apex/Valorant | 毎日21時から配信 | チャンネル登録よろしく！',
    birthMonth: '2001-05',
    isPrivate: false,
  },
  {
    username: 'ayumi_travel',
    name: '歩美',
    bio: '旅行が生きがい✈️ 47都道府県制覇 | 次の目標は世界一周 | 旅の記録をシェアしてます',
    birthMonth: '1996-07',
    isPrivate: false,
  },
  {
    username: 'shota_film',
    name: '翔太',
    bio: '映画監督を目指す大学生 | 自主制作映画公開中 | シネフィル',
    birthMonth: '2003-02',
    isPrivate: false,
  },
  {
    username: 'nanami.yoga',
    name: 'ななみ',
    bio: 'ヨガインストラクター | RYT500 | 心と体を整えるヨガを広めたい | スタジオ経営',
    birthMonth: '1991-09',
    isPrivate: false,
  },
  {
    username: 'daiki_basketball',
    name: '大輝',
    bio: 'バスケ一筋15年🏀 社会人リーグ所属 | ポジション: PG | NBA観戦',
    birthMonth: '1997-01',
    isPrivate: false,
  },
  {
    username: 'emi.handmade',
    name: 'えみ',
    bio: 'ハンドメイド作家 | アクセサリー販売中 | minne/Creema | オーダー承ります',
    birthMonth: '1994-06',
    isPrivate: false,
  },
  {
    username: 'yusuke_startup',
    name: '雄介',
    bio: 'スタートアップCEO | EdTech | 教育×テクノロジーで世界を変える | 採用中',
    birthMonth: '1989-10',
    isPrivate: false,
  },
  {
    username: 'haruka.art',
    name: '遥',
    bio: 'イラストレーター | 水彩画/デジタルアート | 個展開催中 | お仕事依頼受付中',
    birthMonth: '1999-03',
    isPrivate: false,
  },
  {
    username: 'tomo_fishing',
    name: 'トモヤ',
    bio: '釣りバカ日誌🎣 バス釣り/ソルト | 琵琶湖がホーム | 釣果報告します',
    birthMonth: '1993-04',
    isPrivate: false,
  },
  {
    username: 'mai.piano',
    name: '舞',
    bio: 'ピアニスト | クラシック/ジャズ | 音大卒 | 演奏依頼受付中 | 生徒募集',
    birthMonth: '1995-12',
    isPrivate: false,
  },
  {
    username: 'kenji_coffee',
    name: '健二',
    bio: 'バリスタ | 自家焙煎コーヒー店オーナー | SCA認定 | 豆の話なら何時間でも',
    birthMonth: '1987-08',
    isPrivate: false,
  },
  {
    username: 'asuka.dance',
    name: '明日香',
    bio: 'ダンサー | K-POP/ストリート | レッスン講師 | チーム所属 | 踊ることが全て',
    birthMonth: '2000-11',
    isPrivate: false,
  },
  {
    username: 'hiroshi_diy',
    name: 'ひろし',
    bio: 'DIY愛好家 | 家具作り/リノベ | 工具マニア | YouTubeでDIY動画公開中',
    birthMonth: '1986-05',
    isPrivate: false,
  },
  {
    username: 'yui.books',
    name: '結衣',
    bio: '本の虫📚 年間200冊読破 | 読書記録/レビュー | 小説/ビジネス書/エッセイ',
    birthMonth: '1998-09',
    isPrivate: false,
  },
  {
    username: 'sho_surf',
    name: '翔',
    bio: 'サーファー🏄 湘南在住 | プロを目指して練習中 | 海が好きすぎる',
    birthMonth: '1999-07',
    isPrivate: false,
  },
  {
    username: 'miki.nail',
    name: 'みき',
    bio: 'ネイリスト | 自宅サロン経営 | トレンドデザイン | ご予約はDMで',
    birthMonth: '1992-02',
    isPrivate: false,
  },
  {
    username: 'naoto_design',
    name: '直人',
    bio: 'UIデザイナー | Figma信者 | デザインシステム構築 | 副業でロゴ制作',
    birthMonth: '1994-10',
    isPrivate: false,
  },
  {
    username: 'sayaka.garden',
    name: 'さやか',
    bio: 'ガーデニング歴10年🌱 バラ栽培 | ベランダ菜園 | 植物のある暮らし',
    birthMonth: '1985-06',
    isPrivate: false,
  },
  {
    username: 'tatsuya_mma',
    name: '達也',
    bio: '格闘家 | MMA | 総合格闘技ジム所属 | 次の試合に向けて減量中',
    birthMonth: '1996-01',
    isPrivate: false,
  },
  {
    username: 'chika.sweets',
    name: '千佳',
    bio: 'パティシエ | ケーキ屋勤務 | スイーツ巡り | 休日はお菓子作り',
    birthMonth: '1997-04',
    isPrivate: false,
  },
  {
    username: 'masaki_bike',
    name: 'まさき',
    bio: 'バイク乗り🏍️ Ninja650 | ツーリング記録 | 日本一周達成',
    birthMonth: '1991-03',
    isPrivate: false,
  },
  {
    username: 'rina.fashion',
    name: '莉奈',
    bio: 'アパレル店員 | コーデ紹介 | 古着好き | セレクトショップ勤務',
    birthMonth: '2000-08',
    isPrivate: false,
  },
  {
    username: 'kazuki_manga',
    name: '一樹',
    bio: '漫画家志望 | 同人誌制作 | 週刊少年ジャンプ投稿中 | 絵を描くのが好き',
    birthMonth: '2001-12',
    isPrivate: false,
  },
  {
    username: 'nozomi.voice',
    name: '希',
    bio: '声優 | 養成所通い中 | アニメ/ゲーム | 夢に向かって挑戦中',
    birthMonth: '2002-05',
    isPrivate: false,
  },
  {
    username: 'ryota_architect',
    name: '亮太',
    bio: '建築士 | 住宅設計 | 一級建築士 | 建築巡りが趣味 | 安藤忠雄ファン',
    birthMonth: '1988-11',
    isPrivate: false,
  },
  // 鍵アカウント（検索には出るが、おすすめには出ない）
  {
    username: 'secret.life',
    name: 'ひみつ',
    bio: '日常の記録用 | 知り合いのみ',
    birthMonth: '1995-07',
    isPrivate: true,
  },
  {
    username: 'private.thoughts',
    name: 'プライベート',
    bio: '非公開アカウントです',
    birthMonth: '1998-02',
    isPrivate: true,
  },
  {
    username: 'close_friends',
    name: '親しい友人用',
    bio: 'リア友だけ | フォロリク承認制',
    birthMonth: '2000-09',
    isPrivate: true,
  },
  // さらに追加
  {
    username: 'aoi.tennis',
    name: '葵',
    bio: 'テニスプレイヤー🎾 | 市民大会優勝 | 週4で練習 | ラケット3本持ち',
    birthMonth: '1999-01',
    isPrivate: false,
  },
  {
    username: 'shin_investor',
    name: 'しん',
    bio: '個人投資家 | 米国株/仮想通貨 | FIRE目指して資産形成中 | 投資歴5年',
    birthMonth: '1990-06',
    isPrivate: false,
  },
  {
    username: 'hana.beauty',
    name: '華',
    bio: '美容系YouTuber | メイク/スキンケア | コスメレビュー | 垢抜けたい人集まれ',
    birthMonth: '1997-10',
    isPrivate: false,
  },
  {
    username: 'kouta_rugby',
    name: '航太',
    bio: 'ラグビー選手 | FW | 社会人リーグ | ONE TEAMの精神',
    birthMonth: '1994-03',
    isPrivate: false,
  },
  {
    username: 'misaki.calligraphy',
    name: '美咲',
    bio: '書道家 | 師範 | 作品販売中 | 書道教室運営 | 伝統と現代の融合',
    birthMonth: '1989-12',
    isPrivate: false,
  },
  {
    username: 'yuya_drums',
    name: '裕也',
    bio: 'ドラマー | バンド活動中 | セッション参加歓迎 | Pearl愛用',
    birthMonth: '1996-08',
    isPrivate: false,
  },
  {
    username: 'akane.writer',
    name: '茜',
    bio: '小説家 | ライター | 電撃小説大賞佳作 | 執筆の日々',
    birthMonth: '1993-05',
    isPrivate: false,
  },
  {
    username: 'jun_climbing',
    name: 'じゅん',
    bio: 'クライマー🧗 | ボルダリング/リード | 岩場遠征 | 2段',
    birthMonth: '1998-11',
    isPrivate: false,
  },
  {
    username: 'momoka.cat',
    name: 'ももか',
    bio: '猫2匹と暮らしてます🐱 | スコティッシュ/マンチカン | 猫グッズ収集',
    birthMonth: '1995-04',
    isPrivate: false,
  },
  {
    username: 'takuma_chess',
    name: '拓真',
    bio: 'チェスプレイヤー♟️ | レーティング1800 | オンライン対戦募集中',
    birthMonth: '2001-07',
    isPrivate: false,
  },
  {
    username: 'saki.pottery',
    name: '咲希',
    bio: '陶芸家 | 器作り | 展示会情報はこちら | オーダーメイド承ります',
    birthMonth: '1991-02',
    isPrivate: false,
  },
  {
    username: 'hayato_baseball',
    name: '隼人',
    bio: '草野球チーム所属⚾️ | ポジション: SS | 元高校球児 | 野球観戦も好き',
    birthMonth: '1992-09',
    isPrivate: false,
  },
  {
    username: 'rena.skincare',
    name: 'れな',
    bio: '美肌オタク | スキンケア研究 | 肌荒れ克服 | おすすめコスメ紹介',
    birthMonth: '1999-06',
    isPrivate: false,
  },
  {
    username: 'makoto_shogi',
    name: '誠',
    bio: '将棋アマ四段 | 詰将棋作家 | 将棋ウォーズ六段 | 観る将も指す将も',
    birthMonth: '1987-10',
    isPrivate: false,
  },
  {
    username: 'hikari.violin',
    name: '光',
    bio: 'ヴァイオリニスト | オーケストラ団員 | 室内楽 | 音楽の力を信じて',
    birthMonth: '1994-01',
    isPrivate: false,
  },
  {
    username: 'soma_snowboard',
    name: '颯馬',
    bio: 'スノーボーダー🏂 | パーク/グラトリ | 冬は白馬に篭る | シーズン50日',
    birthMonth: '1997-12',
    isPrivate: false,
  },
]

async function main() {
  console.log('🌱 Seeding database...')

  // デモユーザーを作成
  const demoUser = await prisma.user.upsert({
    where: { id: DEMO_USER_ID },
    update: {},
    create: {
      id: DEMO_USER_ID,
      email: 'demo@voicelet.app',
      name: 'Demo User',
    },
  })
  console.log(`✅ Demo user ready: ${demoUser.id}`)

  // フォロー対象のサンプルユーザーを作成
  const followingUsers: User[] = []
  for (let i = 1; i <= 5; i++) {
    const user = await prisma.user.upsert({
      where: { email: `following${i}@example.com` },
      update: {},
      create: {
        email: `following${i}@example.com`,
        name: `フォロー中 ${i}`,
      },
    })
    followingUsers.push(user)
  }
  console.log(`✅ Created ${followingUsers.length} following users`)

  // おすすめ用のサンプルユーザーを作成
  const discoverUsers: User[] = []
  for (let i = 1; i <= 5; i++) {
    const user = await prisma.user.upsert({
      where: { email: `discover${i}@example.com` },
      update: {},
      create: {
        email: `discover${i}@example.com`,
        name: `おすすめ ${i}`,
      },
    })
    discoverUsers.push(user)
  }
  console.log(`✅ Created ${discoverUsers.length} discover users`)

  // デモユーザーがフォロー中ユーザーをフォロー
  for (const user of followingUsers) {
    await prisma.follow.upsert({
      where: {
        followerId_followingId: {
          followerId: DEMO_USER_ID,
          followingId: user.id,
        },
      },
      update: {},
      create: {
        followerId: DEMO_USER_ID,
        followingId: user.id,
      },
    })
  }
  console.log(`✅ Demo user follows ${followingUsers.length} users`)

  // デモユーザー自身のWhisperを作成
  const now = new Date()
  const expiresAt = new Date(now.getTime() + 24 * 60 * 60 * 1000)

  for (let i = 1; i <= 3; i++) {
    await prisma.whisper.upsert({
      where: { id: `demo-whisper-${i}` },
      update: {},
      create: {
        id: `demo-whisper-${i}`,
        userId: DEMO_USER_ID,
        bucketName: GCS_BUCKET_NAME,
        fileName: DEMO_AUDIO_FILE,
        duration: 10 + i * 5,
        expiresAt,
      },
    })
  }
  console.log('✅ Created demo user whispers')

  // フォロー中ユーザーのWhisperを作成
  for (const user of followingUsers) {
    const whisperCount = Math.floor(Math.random() * 3) + 1
    for (let i = 1; i <= whisperCount; i++) {
      await prisma.whisper.upsert({
        where: { id: `${user.id}-whisper-${i}` },
        update: {},
        create: {
          id: `${user.id}-whisper-${i}`,
          userId: user.id,
          bucketName: GCS_BUCKET_NAME,
          fileName: DEMO_AUDIO_FILE,
          duration: 5 + Math.floor(Math.random() * 25),
          expiresAt,
        },
      })
    }
  }
  console.log('✅ Created following users whispers')

  // おすすめユーザーのWhisperを作成
  for (const user of discoverUsers) {
    const whisperCount = Math.floor(Math.random() * 3) + 1
    for (let i = 1; i <= whisperCount; i++) {
      await prisma.whisper.upsert({
        where: { id: `${user.id}-whisper-${i}` },
        update: {},
        create: {
          id: `${user.id}-whisper-${i}`,
          userId: user.id,
          bucketName: GCS_BUCKET_NAME,
          fileName: DEMO_AUDIO_FILE,
          duration: 5 + Math.floor(Math.random() * 25),
          expiresAt,
        },
      })
    }
  }
  console.log('✅ Created discover users whispers')

  // リアルなユーザーを作成（検索テスト用）
  const realisticUsers: User[] = []
  for (const userData of REALISTIC_USERS) {
    const email = `${userData.username}@voicelet-seed.local`
    const user = await prisma.user.upsert({
      where: { email },
      update: {
        username: userData.username,
        name: userData.name,
        bio: userData.bio,
        birthMonth: userData.birthMonth,
        isPrivate: userData.isPrivate,
      },
      create: {
        email,
        username: userData.username,
        name: userData.name,
        bio: userData.bio,
        birthMonth: userData.birthMonth,
        isPrivate: userData.isPrivate,
      },
    })
    realisticUsers.push(user)
  }
  console.log(`✅ Created ${realisticUsers.length} realistic users for search testing`)

  // リアルなユーザーのWhisperを作成（非公開ユーザー以外）
  for (const user of realisticUsers) {
    // 非公開ユーザーはWhisper作成をスキップ（おすすめには出ないので）
    if (user.isPrivate) continue

    const whisperCount = Math.floor(Math.random() * 2) + 1
    for (let i = 1; i <= whisperCount; i++) {
      await prisma.whisper.upsert({
        where: { id: `realistic-${user.id}-whisper-${i}` },
        update: {},
        create: {
          id: `realistic-${user.id}-whisper-${i}`,
          userId: user.id,
          bucketName: GCS_BUCKET_NAME,
          fileName: DEMO_AUDIO_FILE,
          duration: 5 + Math.floor(Math.random() * 25),
          expiresAt,
        },
      })
    }
  }
  console.log('✅ Created realistic users whispers')

  // リアルなユーザー間のフォロー関係を作成
  // 多様なフォロー関係を作成（相互フォロー、一方向フォローなど）
  const publicRealisticUsers = realisticUsers.filter((u) => !u.isPrivate)

  for (let i = 0; i < publicRealisticUsers.length; i++) {
    const user = publicRealisticUsers[i]

    // 各ユーザーが3〜8人をランダムにフォロー
    const followCount = 3 + Math.floor(Math.random() * 6)
    const shuffled = [...publicRealisticUsers]
      .filter((u) => u.id !== user.id)
      .sort(() => Math.random() - 0.5)
      .slice(0, followCount)

    for (const target of shuffled) {
      await prisma.follow.upsert({
        where: {
          followerId_followingId: {
            followerId: user.id,
            followingId: target.id,
          },
        },
        update: {},
        create: {
          followerId: user.id,
          followingId: target.id,
        },
      })
    }
  }
  console.log('✅ Created follow relationships between realistic users')

  // 実際のユーザー（yeongsekm@gmail.com）へのフォロワー追加
  const realUser = await prisma.user.findUnique({
    where: { email: REAL_USER_EMAIL },
  })

  if (realUser) {
    console.log(`📧 Found real user: ${realUser.email}`)

    // フォロー中ユーザー、おすすめユーザー、リアルなユーザーが実際のユーザーをフォロー
    const allSeedUsers = [...followingUsers, ...discoverUsers, ...realisticUsers]
    for (const user of allSeedUsers) {
      await prisma.follow.upsert({
        where: {
          followerId_followingId: {
            followerId: user.id,
            followingId: realUser.id,
          },
        },
        update: {},
        create: {
          followerId: user.id,
          followingId: realUser.id,
        },
      })
    }
    console.log(`✅ Real user now has ${allSeedUsers.length} followers`)

    // 実際のユーザーがフォロー中ユーザーをフォロー（フォロー中タブに表示されるように）
    for (const user of followingUsers) {
      await prisma.follow.upsert({
        where: {
          followerId_followingId: {
            followerId: realUser.id,
            followingId: user.id,
          },
        },
        update: {},
        create: {
          followerId: realUser.id,
          followingId: user.id,
        },
      })
    }
    console.log(`✅ Real user now follows ${followingUsers.length} users`)
  } else {
    console.log(`⚠️ Real user (${REAL_USER_EMAIL}) not found. Sign in first to create the user.`)
  }

  console.log('🎉 Seeding completed!')
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed:', e)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
