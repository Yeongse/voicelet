# Backend Template

開発合宿用のFastifyバックエンドテンプレート

## 技術スタック

- **Framework:** Fastify 4.x
- **Language:** TypeScript 5.x
- **ORM:** Prisma 5.x
- **Validation:** Zod
- **Database:** MySQL

## セットアップ

```bash
# 依存関係のインストール
npm install

# Prismaクライアント生成
npm run db:generate

# データベースマイグレーション
npm run db:migrate

# 開発サーバー起動
npm run dev
```

## ディレクトリ構成

```
backend/
├── src/
│   ├── controller/     # APIルート定義
│   │   └── user/       # ユーザーAPI例
│   │       ├── controller.ts
│   │       ├── schema.ts
│   │       └── _userId/  # パラメータルート
│   │           ├── controller.ts
│   │           └── hook.ts
│   ├── model/          # Zodスキーマ定義
│   ├── lib/            # ユーティリティ
│   ├── main.ts         # エントリーポイント
│   └── database.ts     # Prismaクライアント
├── prisma/
│   ├── schema.prisma   # データベーススキーマ
│   └── seed/           # シードデータ
└── package.json
```

## API エンドポイント

### User API

| Method | Path | Description |
|--------|------|-------------|
| GET | /api/user | ユーザー一覧取得 |
| GET | /api/user/:userId | ユーザー詳細取得 |
| POST | /api/user | ユーザー作成 |
| PUT | /api/user/:userId | ユーザー更新 |
| DELETE | /api/user/:userId | ユーザー削除 |

## 開発ガイド

### 新しいAPIを追加する

1. `src/model/` にZodスキーマを追加
2. `src/controller/` にディレクトリを作成
3. `schema.ts` でAPIスキーマを定義
4. `controller.ts` でハンドラーを実装
5. 必要に応じて `hook.ts` でpreHandlerを追加

### RORO原則

全ての関数はオブジェクト形式で引数を受け取り、オブジェクト形式で返す:

```typescript
// Good
function calculatePagination(params: { page: number; limit: number }): { skip: number; take: number } {
  const { page, limit } = params
  return { skip: (page - 1) * limit, take: limit }
}

// Bad
function calculatePagination(page: number, limit: number): [number, number] {
  return [(page - 1) * limit, limit]
}
```

## スクリプト

| Script | Description |
|--------|-------------|
| `npm run dev` | 開発サーバー起動 |
| `npm run build` | TypeScriptビルド |
| `npm run db:generate` | Prismaクライアント生成 |
| `npm run db:migrate` | マイグレーション実行 |
| `npm run db:seed` | シードデータ投入 |
| `npm run lint` | Lintチェック |
| `npm run lint:fix` | Lint自動修正 |

## API ドキュメント

開発環境では `/docs` でSwagger UIにアクセス可能

---

## GCS（Google Cloud Storage）セットアップ

このバックエンドは音声ファイルのアップロード/ダウンロードに署名付きURLを使用します。
ローカル開発時にGCS関連の機能を使うには、以下の設定が必要です。

### エラーが出る場合

```
Permission 'iam.serviceAccounts.signBlob' denied on resource
```

このエラーは、署名付きURLを生成する権限がないことを示しています。

### 解決方法

#### 方法1: Impersonation（推奨・キーファイル不要）

サービスアカウントに「なりすまし」て認証する方法です。

**前提条件:**
- Terraformで `developer_emails` にあなたのGoogleアカウントが追加されていること
- `terraform apply` が実行済みであること

```bash
# 1. Terraformで開発者メールアドレスを設定（初回のみ）
# infra/terraform/locals.tf の developer_emails にメールアドレスを追加

# 2. Terraform適用（初回のみ）
cd infra/terraform
terraform apply

# 3. Impersonationで認証（毎回必要）
gcloud auth application-default login \
  --impersonate-service-account=voicelet-run-app-executor@voicelet.iam.gserviceaccount.com
```

#### 方法2: サービスアカウントキーを使用

JSONキーファイルをダウンロードして使用する方法です。

```bash
# 1. GCPコンソールでサービスアカウントキーをダウンロード
#    IAM > サービスアカウント > voicelet-run-app-executor > キー > 新しいキーを作成

# 2. 環境変数を設定
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/voicelet-run-app-executor-key.json

# 3. バックエンドを起動
npm run dev
```

### 必要な環境変数

`.env` ファイルに以下を設定：

```bash
# GCSバケット名（必須）
GCS_BUCKET_NAME=voicelet-audio-voicelet

# サービスアカウントキーを使う場合のみ
GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json
```

### Cloud Run（本番環境）について

Cloud Runでは、Terraformで以下のロールが自動的に付与されるため、追加設定は不要です：

- `roles/storage.objectAdmin` - GCSオブジェクトの読み書き
- `roles/iam.serviceAccountTokenCreator` - 署名付きURL生成

---

## Terraformの適用手順（インフラ管理者向け）

GCS署名付きURLの権限を設定するために、以下を実行：

```bash
# 1. プロジェクト所有者/編集者権限を持つアカウントで認証
gcloud auth application-default login

# 2. Terraformディレクトリに移動
cd infra/terraform

# 3. 変更内容を確認
terraform plan

# 4. 適用
terraform apply
```

### 変更内容

- サービスアカウントに `roles/storage.objectAdmin` を付与
- サービスアカウントに `roles/iam.serviceAccountTokenCreator` を付与
- 開発者のImpersonation権限を設定（`developer_emails` に追加した場合）
