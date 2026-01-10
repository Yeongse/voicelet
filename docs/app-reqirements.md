# Voicelet（ボイセレ） - プロダクト要件定義書

## 1. プロダクト概要

### 1.1 コンセプト
**Voicelet（ボイセレ）** は、24時間で消える30秒音声日記を共有するSNSアプリケーション。寝る前のつぶやきを音声で気軽に投稿し、フォローしている人の声を聴くことができる。

「Voicelet」は「voice + -let（小さい）」の造語で、「小さな声の断片」を意味する。

### 1.2 ターゲットユーザー
- テキストや動画より気軽に発信したい人
- 寝る前の習慣として日記をつけたい人
- 声でゆるく繋がりたい人

### 1.3 技術スタック
| レイヤー | 技術 |
|---------|------|
| モバイルアプリ | Flutter |
| 認証 | Supabase Auth |
| データベース | Supabase PostgreSQL |
| API サーバー | Cloud Run (NestJS) |
| 音声ストレージ | Google Cloud Storage |
| 定期実行 | Cloud Scheduler |
| 広告 | AdMob |

---

## 2. 機能要件

### 2.1 認証機能

#### 2.1.1 サインイン
- Apple Sign In（iOS必須）
- Google Sign In
- Supabase Authを使用してJWTトークンを発行

#### 2.1.2 プロフィール初期設定
サインイン後、以下を設定：
- ユーザー名（一意、英数字とアンダースコア、3〜30文字）
- 表示名（1〜50文字）
- アイコン画像（任意）

#### 2.1.3 ログアウト・退会
- ログアウト: ローカルのトークンを削除
- 退会: ユーザーデータ、投稿、フォロー関係を全て削除

---

### 2.2 音声投稿機能

#### 2.2.1 録音
- 最大録音時間: 30秒
- 録音中は残り時間をカウントダウン表示
- 30秒経過で自動停止
- 録音中にキャンセル可能

#### 2.2.2 音声フォーマット
```yaml
フォーマット: AAC (.m4a)
サンプルレート: 44100Hz
ビットレート: 64kbps
最大ファイルサイズ: 約250KB
```

#### 2.2.3 投稿フロー
1. 録音ボタンをタップして録音開始
2. 録音完了後、プレビュー画面で再生確認
3. 「再録音」または「投稿」を選択
4. 投稿確定後、Cloud Storageにアップロード
5. APIを呼び出してpostsレコードを作成

#### 2.2.4 投稿の自動削除
- 投稿から24時間後に自動削除
- Cloud Storageのファイルも同時に削除
- Cloud Schedulerで毎時実行

---

### 2.3 タイムライン機能

#### 2.3.1 フォロータブ（ホーム画面上部）
- フォロー中ユーザーの投稿を横スクロールで表示
- Instagramストーリーと同様のUI
- 未視聴: カラーリング表示
- 視聴済み: グレーアウト表示（タップ可能）
- 8ユーザーごとに広告スロットを挿入

#### 2.3.2 発見タブ（ホーム画面下部）
- 全体公開の投稿を縦スクロールで表示
- 新着順またはおすすめ順（初期は新着順）
- 無限スクロール（ページネーション）
- 未視聴/視聴済みの表示はフォロータブと同様

---

### 2.4 視聴機能

#### 2.4.1 視聴ルール
```yaml
初回視聴: 無料で再生可能
視聴済み: グレーアウト表示、タップ可能
再視聴: リワード広告視聴後に再生可能
```

#### 2.4.2 視聴フロー（未視聴）
1. 投稿をタップ
2. 再生画面に遷移
3. 音声が自動再生される
4. 再生完了後、次の投稿へスワイプまたは自動遷移
5. listensテーブルに視聴記録を保存

#### 2.4.3 視聴フロー（視聴済み）
1. グレーアウトされた投稿をタップ
2. ダイアログ表示:「視聴済みです。広告を見てもう一度聴きますか？」
3. 「広告を見てもう一度聴く」をタップ
4. リワード広告を再生
5. 広告視聴完了後、音声を再生

#### 2.4.4 再生画面UI
```
┌─────────────────────────────────────┐
│      @username                      │
│      表示名                          │
│                                     │
│    ◉ 波形ビジュアライザー            │
│                                     │
│       advancement bar ○───── 0:15/0:30             │
│                                     │
│    [←前へ]           [次へ→]        │
│                                     │
├─────────────────────────────────────┤
│    【 バナー広告 320×100 】          │
└─────────────────────────────────────┘
```

---

### 2.5 ソーシャル機能

#### 2.5.1 フォロー/フォロー解除
- 公開アカウント: 即座にフォロー成立
- 鍵アカウント: フォローリクエストを送信

#### 2.5.2 フォローリクエスト（鍵アカウント用）
- リクエスト送信 → 相手に通知
- 相手が承認 → フォロー成立
- 相手が拒否 → リクエスト削除

#### 2.5.3 ブロック
- ブロックしたユーザーの投稿は表示されない
- ブロックしたユーザーからのフォロー/リクエストは無効
- 相互フォロー中にブロックした場合、フォロー関係を解除

#### 2.5.4 通報
- 投稿またはユーザーを通報可能
- 通報理由を選択（スパム、不適切なコンテンツ、嫌がらせ等）
- 通報データは管理者が確認

---

### 2.6 プロフィール機能

#### 2.6.1 プロフィール情報
- ユーザー名（一意）
- 表示名
- アイコン画像
- 自己紹介（最大140文字）
- フォロー数/フォロワー数
- 鍵アカウント設定

#### 2.6.2 鍵アカウント（プライベートアカウント）
- ONの場合: 投稿はフォロワーのみ閲覧可能
- 発見タブには表示されない
- フォローにはリクエスト承認が必要

#### 2.6.3 プロフィール編集
- 表示名、アイコン、自己紹介、鍵設定を変更可能
- ユーザー名は変更不可（初期設定時のみ）

---

### 2.7 通知機能

#### 2.7.1 通知種別
| 種別 | 内容 |
|------|------|
| フォロー | 「@username があなたをフォローしました」 |
| フォローリクエスト | 「@username からフォローリクエストが届きました」 |
| リクエスト承認 | 「@username があなたのリクエストを承認しました」 |

#### 2.7.2 プッシュ通知
- Firebase Cloud Messaging (FCM) を使用
- 通知設定でON/OFF切り替え可能

---

### 2.8 広告機能

#### 2.8.1 再生画面バナー広告
```yaml
配置: 再生画面下部
サイズ: 適応型バナー（320×100推奨）
表示タイミング: 音声再生中は常時表示
リフレッシュ: 次の投稿再生時に更新
実装: AdMob Banner Ad
```

#### 2.8.2 ストーリー間広告
```yaml
配置: フォロータブの横スクロール内
頻度: 8ユーザーごとに1広告スロット
形式: AdMob Banner Ad
タップ時: 広告主のページへ遷移
```

#### 2.8.3 リワード広告
```yaml
トリガー: 視聴済み投稿をタップした時
形式: AdMob Rewarded Ad（15〜30秒動画）
報酬: 対象の投稿を1回再生可能
```

#### 2.8.4 AdMob設定
```yaml
必要な広告ユニット:
  - バナー広告（再生画面用）
  - バナー広告（ストーリー間用）
  - リワード広告（再視聴用）

その他設定:
  - app-ads.txt設置
  - テストモード確実にOFF（本番環境）
  - 適応型バナー使用
```

---

## 3. 画面一覧

### 3.1 画面構成
```
├── スプラッシュ画面
├── 認証
│   ├── サインイン画面
│   └── プロフィール初期設定画面
├── メイン（BottomNavigation）
│   ├── ホーム画面
│   │   ├── フォロータブ（横スクロール）
│   │   └── 発見タブ（縦スクロール）
│   ├── 検索画面
│   ├── 録音ボタン（中央）
│   ├── 通知画面
│   └── マイプロフィール画面
├── 録音フロー
│   ├── 録音画面
│   ├── プレビュー画面
│   └── 投稿完了画面
├── 再生画面（フルスクリーン）
├── ユーザー詳細画面
│   ├── プロフィール情報
│   └── フォロー/フォロワーリスト
├── フォローリクエスト一覧画面
└── 設定画面
    ├── アカウント設定
    ├── プライバシー設定
    ├── 通知設定
    ├── ブロックリスト
    └── ログアウト/退会
```

### 3.2 各画面詳細

#### ホーム画面
- 上部: フォロータブ（横スクロール、ストーリー形式）
- 下部: 発見タブ（縦スクロール、カード形式）
- タブ切り替えでフォロー/発見を切り替え

#### 録音画面
- 中央に大きな録音ボタン
- 録音中はカウントダウンタイマー表示
- 波形ビジュアライザー表示
- キャンセルボタン

#### 再生画面
- ユーザーアイコン・名前・表示名
- 波形ビジュアライザー
- プログレスバー
- 左右スワイプで前後の投稿へ
- 下部にバナー広告

#### ユーザー詳細画面
- プロフィール情報
- フォロー/フォロー解除ボタン
- 鍵アカウントの場合はフォローリクエストボタン
- フォロー数/フォロワー数（タップでリスト表示）

---

## 4. データモデル

### 4.1 ERD概要
```
users ─┬─< posts
       ├─< follows (follower)
       ├─< follows (following)
       ├─< follow_requests (requester)
       ├─< follow_requests (target)
       ├─< listens
       ├─< blocks (blocker)
       ├─< blocks (blocked)
       └─< reports
```

### 4.2 テーブル定義

#### users
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_id UUID UNIQUE NOT NULL,
  username VARCHAR(30) UNIQUE NOT NULL,
  display_name VARCHAR(50) NOT NULL,
  avatar_url TEXT,
  bio VARCHAR(140),
  is_private BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_auth_id ON users(auth_id);
```

#### posts
```sql
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  audio_url TEXT NOT NULL,
  duration_ms INTEGER NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_posts_user_id ON posts(user_id, created_at DESC);
CREATE INDEX idx_posts_expires_at ON posts(expires_at);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
```

#### follows
```sql
CREATE TABLE follows (
  follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (follower_id, following_id)
);

CREATE INDEX idx_follows_follower ON follows(follower_id);
CREATE INDEX idx_follows_following ON follows(following_id);
```

#### follow_requests
```sql
CREATE TABLE follow_requests (
  requester_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  target_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (requester_id, target_id)
);

CREATE INDEX idx_follow_requests_target ON follow_requests(target_id);
```

#### listens
```sql
CREATE TABLE listens (
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  listened_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, post_id)
);

CREATE INDEX idx_listens_user ON listens(user_id);
```

#### blocks
```sql
CREATE TABLE blocks (
  blocker_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  blocked_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (blocker_id, blocked_id)
);

CREATE INDEX idx_blocks_blocker ON blocks(blocker_id);
```

#### reports
```sql
CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID NOT NULL REFERENCES users(id),
  post_id UUID REFERENCES posts(id) ON DELETE SET NULL,
  reported_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  reason TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### device_tokens（プッシュ通知用）
```sql
CREATE TABLE device_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token TEXT NOT NULL,
  platform VARCHAR(10) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, token)
);
```

#### notifications
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(30) NOT NULL,
  actor_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id, created_at DESC);
```

---

## 5. API設計

### 5.1 認証
```yaml
POST /auth/signup:
  description: プロフィール初期設定
  headers:
    Authorization: Bearer <supabase_jwt>
  body:
    username: string (3-30文字、英数字_のみ)
    display_name: string (1-50文字)
    avatar_url?: string
  response:
    user: User

GET /auth/me:
  description: 自分の情報取得
  headers:
    Authorization: Bearer <jwt>
  response:
    user: User
```

### 5.2 ユーザー
```yaml
GET /users/:username:
  description: ユーザープロフィール取得
  response:
    user: User
    is_following: boolean
    is_followed_by: boolean
    has_requested: boolean
    followers_count: number
    following_count: number

GET /users/:id/followers:
  description: フォロワー一覧
  query:
    cursor?: string
    limit?: number (default: 20)
  response:
    users: User[]
    next_cursor?: string

GET /users/:id/following:
  description: フォロー中一覧
  query:
    cursor?: string
    limit?: number (default: 20)
  response:
    users: User[]
    next_cursor?: string

PATCH /users/me:
  description: プロフィール更新
  body:
    display_name?: string
    avatar_url?: string
    bio?: string
    is_private?: boolean
  response:
    user: User

GET /users/search:
  description: ユーザー検索
  query:
    q: string
    limit?: number (default: 20)
  response:
    users: User[]
```

### 5.3 フォロー
```yaml
POST /follows/:userId:
  description: フォローまたはリクエスト送信
  response:
    status: 'followed' | 'requested'

DELETE /follows/:userId:
  description: フォロー解除
  response:
    success: boolean

GET /follow-requests:
  description: 受信したフォローリクエスト一覧
  response:
    requests: { user: User, created_at: string }[]

POST /follow-requests/:requesterId/accept:
  description: フォローリクエスト承認
  response:
    success: boolean

DELETE /follow-requests/:requesterId:
  description: フォローリクエスト拒否
  response:
    success: boolean
```

### 5.4 投稿
```yaml
POST /posts/upload-url:
  description: 署名付きアップロードURL取得
  response:
    upload_url: string
    audio_url: string

POST /posts:
  description: 投稿作成
  body:
    audio_url: string
    duration_ms: number
  response:
    post: Post

GET /posts/following:
  description: フォロー中ユーザーの投稿取得
  response:
    posts: PostWithUser[]

GET /posts/discover:
  description: 発見タブ用投稿取得
  query:
    cursor?: string
    limit?: number (default: 20)
  response:
    posts: PostWithUser[]
    next_cursor?: string

POST /posts/:id/listen:
  description: 視聴記録
  response:
    success: boolean
```

### 5.5 ブロック・通報
```yaml
POST /blocks/:userId:
  description: ユーザーをブロック
  response:
    success: boolean

DELETE /blocks/:userId:
  description: ブロック解除
  response:
    success: boolean

GET /blocks:
  description: ブロックリスト取得
  response:
    users: User[]

POST /reports:
  description: 通報
  body:
    post_id?: string
    user_id?: string
    reason: string
  response:
    success: boolean
```

### 5.6 通知
```yaml
GET /notifications:
  description: 通知一覧取得
  query:
    cursor?: string
    limit?: number (default: 20)
  response:
    notifications: Notification[]
    next_cursor?: string

POST /notifications/read:
  description: 通知を既読にする
  body:
    notification_ids: string[]
  response:
    success: boolean

POST /device-tokens:
  description: デバイストークン登録
  body:
    token: string
    platform: 'ios' | 'android'
  response:
    success: boolean

DELETE /device-tokens/:token:
  description: デバイストークン削除
  response:
    success: boolean
```

---

## 6. 型定義

### 6.1 レスポンス型
```typescript
interface User {
  id: string;
  username: string;
  display_name: string;
  avatar_url: string | null;
  bio: string | null;
  is_private: boolean;
  created_at: string;
}

interface Post {
  id: string;
  user_id: string;
  audio_url: string;
  duration_ms: number;
  expires_at: string;
  created_at: string;
}

interface PostWithUser extends Post {
  user: User;
  is_listened: boolean;
}

interface Notification {
  id: string;
  type: 'follow' | 'follow_request' | 'request_accepted';
  actor: User;
  is_read: boolean;
  created_at: string;
}
```

---

## 7. インフラ構成

### 7.1 アーキテクチャ図
```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                       │
│                  (iOS / Android)                            │
└─────────────────────┬───────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
┌──────────────┐ ┌─────────────┐ ┌─────────────────┐
│ Cloud Run    │ │ Supabase    │ │ Cloud Storage   │
│ (API Server) │ │ Auth        │ │ (Audio Files)   │
│              │ └─────────────┘ │                 │
│ - NestJS     │                 │ - 署名付きURL    │
│ - JWT検証    │                 │ - Lifecycle     │
└──────┬───────┘                 │   (25h削除)     │
       │                         └─────────────────┘
       ▼
┌──────────────┐
│ Supabase     │
│ PostgreSQL   │
└──────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Cloud Scheduler                                             │
│ - 毎時: 期限切れ投稿削除バッチ                                │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Firebase Cloud Messaging                                    │
│ - プッシュ通知配信                                           │
└─────────────────────────────────────────────────────────────┘
```

### 7.2 Cloud Storage設定
```yaml
バケット名: voicelet-audio-{env}
リージョン: asia-northeast1
ストレージクラス: Standard

ライフサイクルルール:
  - 条件: age > 25時間
  - アクション: Delete

CORS設定:
  - origin: ["*"]
  - method: ["GET", "PUT"]
  - maxAgeSeconds: 3600
```

### 7.3 Cloud Run設定
```yaml
リージョン: asia-northeast1
メモリ: 512MB
CPU: 1
最小インスタンス: 0
最大インスタンス: 10
タイムアウト: 60s

環境変数:
  - SUPABASE_URL
  - SUPABASE_SERVICE_KEY
  - GCS_BUCKET_NAME
  - JWT_SECRET
```

### 7.4 Cloud Scheduler設定
```yaml
ジョブ名: delete-expired-posts
スケジュール: 0 * * * * (毎時0分)
タイムゾーン: Asia/Tokyo
ターゲット: Cloud Run エンドポイント POST /jobs/cleanup
```

---

## 8. セキュリティ要件

### 8.1 認証・認可
- Supabase AuthのJWTトークンを使用
- APIリクエストには Authorization ヘッダー必須
- Cloud RunでJWT検証を実施

### 8.2 データアクセス制御
- 自分のデータのみ編集可能
- 鍵アカウントの投稿はフォロワーのみ取得可能
- ブロックしたユーザーの投稿は取得対象から除外

### 8.3 Cloud Storage
- 署名付きURLでアップロード（有効期限: 15分）
- 音声ファイルは公開読み取り可能（URLを知っていれば再生可能）

---

## 9. 非機能要件

### 9.1 パフォーマンス
- API レスポンス: 95%ile < 500ms
- 音声ファイルアップロード: < 5秒（250KB）
- アプリ起動時間: < 3秒

### 9.2 可用性
- API稼働率: 99.5%以上
- 計画メンテナンス時は事前告知

### 9.3 スケーラビリティ
- DAU 10万人まで対応可能な設計
- Cloud Runオートスケール設定

---

## 10. 用語集

| 用語 | 説明 |
|------|------|
| Voicelet（ボイセレ） | 本アプリの名称。voice + -let（小さい）の造語 |
| 投稿 (Post) | 30秒以内の音声ファイル、24時間で自動削除 |
| フォロータブ | フォロー中ユーザーの投稿一覧（横スクロール） |
| 発見タブ | 全体公開の投稿一覧（縦スクロール） |
| 鍵アカウント | 投稿がフォロワーのみに公開されるアカウント |
| リワード広告 | 視聴すると報酬（再視聴権）がもらえる動画広告 |
| 視聴済み | 一度再生した投稿の状態 |

---

## 11. 実装優先度

### Phase 1（MVP）
1. 認証（Apple/Google Sign In）
2. プロフィール作成・編集
3. 音声録音・投稿
4. フォロータブ・発見タブ
5. 視聴機能（初回無料）
6. フォロー/フォロー解除

### Phase 2
1. 鍵アカウント・フォローリクエスト
2. 視聴済み再視聴（リワード広告）
3. 再生画面バナー広告
4. ストーリー間広告

### Phase 3
1. ブロック機能
2. 通報機能
3. プッシュ通知