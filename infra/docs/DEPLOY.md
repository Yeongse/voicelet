# Voicelet インフラ デプロイ手順

このドキュメントでは、Voicelet のインフラを GCP 上に構築する手順を説明します。

## 前提条件

- [gcloud CLI](https://cloud.google.com/sdk/docs/install) がインストール済み
- [Terraform](https://developer.hashicorp.com/terraform/install) がインストール済み（v1.5.0 以上）
- [Docker](https://www.docker.com/get-started/) がインストール済み
- GCP プロジェクトが作成済み
- Supabase プロジェクトが作成済み

---

## デプロイの流れ

```
┌─────────────────────────────────────────────────────────────────┐
│  Step 1: GCP 認証 & API 有効化                                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  Step 2: 基盤リソース作成（Artifact Registry, Secrets 等）        │
│          terraform apply -target=...                            │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  Step 3: Docker イメージをビルド & プッシュ                       │
│          ./backend/push-to-registry.sh                          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  Step 4: シークレットに値を設定                                   │
│          ./infra/bin/setup-secrets.sh                           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  Step 5: 残りのリソース作成（Cloud Run, Cloud Scheduler）         │
│          terraform apply                                        │
└─────────────────────────────────────────────────────────────────┘
```

---

## Step 1: GCP 認証 & API 有効化

### 1.1 GCP にログイン

```bash
gcloud auth login
gcloud config set project voicelet
```

### 1.2 API を有効化

```bash
cd /path/to/voicelet/infra
./bin/enable-api.sh
```

### 1.3 Artifact Registry に認証

```bash
gcloud auth configure-docker asia-northeast1-docker.pkg.dev
```

---

## Step 2: 基盤リソース作成

Artifact Registry、Service Account、Secret Manager、Storage を先に作成します。

### 2.1 locals.tf を編集

`infra/terraform/locals.tf` の値を設定：

```hcl
locals {
  project      = "voicelet"        # GCP プロジェクト ID
  service_name = "voicelet"        # サービス名（小文字英数字とハイフン）
  location     = "asia-northeast1"
}
```

### 2.2 Terraform 初期化

```bash
cd infra/terraform
terraform init
```

### 2.3 基盤リソースのみ作成

```bash
terraform apply \
  -target=module.artifact-registry \
  -target=module.account \
  -target=module.secrets \
  -target=module.storage
```

`yes` を入力して適用。

---

## Step 3: Docker イメージをビルド & プッシュ

### 3.1 バックエンドイメージをプッシュ

```bash
cd /path/to/voicelet/backend
./push-to-registry.sh
```

または手動で：

```bash
cd /path/to/voicelet/backend

docker build -t asia-northeast1-docker.pkg.dev/voicelet/voicelet-app-repository-docker/app-backend:latest .

docker push asia-northeast1-docker.pkg.dev/voicelet/voicelet-app-repository-docker/app-backend:latest
```

---

## Step 4: シークレットに値を設定

### 4.1 Supabase の認証情報を取得

[Supabase Dashboard](https://supabase.com/dashboard) から以下を取得：

**Project Settings → API:**
- **Project URL**: `https://xxxxx.supabase.co`
- **service_role key**: `eyJhbGciOiJIUzI1NiIs...`

**Project Settings → Database → Connection string → Transaction pooler:**
- **Database URL**: `postgresql://postgres.xxxxx:password@aws-0-ap-northeast-1.pooler.supabase.com:6543/postgres`

> ⚠️ **重要**: Cloud Run（サーバーレス）では **Transaction pooler（ポート 6543）** を使用してください。Session pooler（ポート 5432）は使用しないでください。

### 4.2 JWT Secret を生成

JWT 署名用のシークレットを生成し、**安全な場所に保存**してください：

```bash
openssl rand -base64 32
# 出力例: K7xY2pQ9mN3vR8wT1sF6gH4jL0aB5cD=
```

> ⚠️ **重要**: この値は再生成できません。必ず安全な場所（パスワードマネージャー等）に保存してください。

### 4.3 シークレット登録スクリプトを実行

4つの引数すべてを指定して実行します：

```bash
cd /path/to/voicelet/infra

./bin/setup-secrets.sh \
  "https://xxxxx.supabase.co" \
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  "K7xY2pQ9mN3vR8wT1sF6gH4jL0aB5cD=" \
  "postgresql://postgres.xxxxx:password@aws-0-ap-northeast-1.pooler.supabase.com:6543/postgres"
```

| 引数 | 説明 |
|-----|------|
| 第1引数 | Supabase Project URL |
| 第2引数 | Supabase service_role key |
| 第3引数 | JWT Secret（Step 4.2 で生成した値）|
| 第4引数 | Database URL（Transaction pooler, ポート 6543）|

### 4.4 設定確認

```bash
gcloud secrets versions list voicelet-supabase-url
gcloud secrets versions list voicelet-supabase-service-key
gcloud secrets versions list voicelet-jwt-secret
gcloud secrets versions list voicelet-database-url
```

各シークレットにバージョン 1 が表示されれば OK。

---

## Step 5: 残りのリソース作成

Cloud Run と Cloud Scheduler を作成します。

```bash
cd /path/to/voicelet/infra/terraform
terraform apply
```

`yes` を入力して適用。

---

## デプロイ完了後

### Cloud Run URL の確認

```bash
terraform output
# または
gcloud run services describe voicelet-run-service-app --region=asia-northeast1 --format="value(status.url)"
```

### 動作確認

```bash
# ヘルスチェック
curl https://<cloud-run-url>/health
```

---

## トラブルシューティング

### エラー: Secret ... was not found

シークレットに値が設定されていません。Step 4 を実行してください。

### エラー: Image ... not found

Docker イメージがプッシュされていません。Step 3 を実行してください。

### エラー: API has not been used in project

API が有効化されていません。Step 1.2 を実行してください。

---

## リソースの削除

```bash
cd /path/to/voicelet/infra/terraform
terraform destroy
```

---

## クイックコマンド一覧

```bash
# 全ステップを順番に実行
cd /path/to/voicelet

# Step 1: GCP 認証 & API 有効化
gcloud auth login
gcloud config set project voicelet
./infra/bin/enable-api.sh
gcloud auth configure-docker asia-northeast1-docker.pkg.dev

# Step 2: 基盤リソース作成
cd infra/terraform
terraform init
terraform apply \
  -target=module.artifact-registry \
  -target=module.account \
  -target=module.secrets \
  -target=module.storage

# Step 3: Docker イメージをプッシュ
cd ../../backend
./push-to-registry.sh

# Step 4: JWT Secret を生成してシークレット登録
openssl rand -base64 32  # この出力を保存！

cd ../infra
./bin/setup-secrets.sh \
  "https://xxxxx.supabase.co" \
  "eyJhbGciOiJIUzI1NiIs..." \
  "生成したJWTシークレット" \
  "postgresql://postgres.xxxxx:password@aws-0-ap-northeast-1.pooler.supabase.com:6543/postgres"

# Step 5: Cloud Run を作成
cd terraform
terraform apply
```

