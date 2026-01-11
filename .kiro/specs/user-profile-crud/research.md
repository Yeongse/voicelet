# Research & Design Decisions

---
**Purpose**: ユーザープロフィールCRUD機能の設計に関する調査結果と技術的決定事項を記録する。

**Usage**:
- ディスカバリーフェーズで収集した情報を記録
- design.mdに反映される設計決定の根拠を文書化
---

## Summary
- **Feature**: `user-profile-crud`
- **Discovery Scope**: Complex Integration（Supabase Auth + Cloud Storage + 既存システム拡張）
- **Key Findings**:
  - 既存のCloud Storage署名付きURL実装（storage.ts）を再利用可能
  - Supabase Auth連携にはfastify-jwtプラグインでJWT検証を行う
  - 既存Userモデルを拡張してプロフィールフィールド（bio, birthMonth, avatarPath）を追加

## Research Log

### Supabase Auth Flutter統合
- **Context**: モバイルクライアントでのSupabase Auth実装方法の調査
- **Sources Consulted**:
  - [Supabase Flutter Quickstart](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
  - [supabase_flutter package](https://pub.dev/packages/supabase_flutter)
  - [Flutter Auth UI](https://supabase.com/docs/guides/auth/auth-helpers/flutter-auth-ui)
- **Findings**:
  - `supabase_flutter`パッケージを使用（v2推奨）
  - PKCE flowがデフォルトで有効（より安全なディープリンク認証）
  - `onAuthStateChange`リスナーで認証状態変更を監視
  - Google/Apple Sign-inはネイティブサポートあり
- **Implications**:
  - 既存のauth_provider.dartをSupabase Authベースに置き換え
  - セッション永続化はSupabase SDKが自動管理

### Supabase Auth Fastify/Node.js統合
- **Context**: バックエンドでのJWT検証とSupabase連携方法の調査
- **Sources Consulted**:
  - [fastify-supabase plugin](https://github.com/psteinroe/fastify-supabase)
  - [Supabase JWT Docs](https://supabase.com/docs/guides/auth/jwts)
  - [JWT Claims Reference](https://supabase.com/docs/guides/auth/jwt-fields)
- **Findings**:
  - `@fastify/jwt`と`@psteinroe/fastify-supabase`プラグインで連携
  - JWT検証はSupabase JWT Secretを使用
  - RS256（非対称キー）推奨、JWKS Endpoint検証も可能
  - JWTからuser_idを抽出して認可に使用
- **Implications**:
  - 認証ミドルウェアを新規作成（onRequestフック）
  - request.userにユーザー情報を格納する設計

### 既存実装分析

#### Cloud Storage実装（backend/src/services/storage.ts）
- **Context**: 既存の署名付きURL実装の再利用可能性を調査
- **Findings**:
  - `@google-cloud/storage`を使用
  - `generateUploadSignedUrl`と`generateDownloadSignedUrl`が実装済み
  - 有効期限設定可能（デフォルト: upload 15分、download 60分）
  - バケット名は環境変数`GCS_BUCKET_NAME`で設定
- **Implications**:
  - アバター用のContent-Type（image/jpeg, image/png, image/webp）サポートを追加
  - ファイルパス命名規則を定義（`avatars/{userId}/{timestamp}.{ext}`）

#### 既存Userモデル（prisma/schema.prisma）
- **Context**: プロフィール情報の追加方法を調査
- **Findings**:
  - 既存フィールド: id, email, name, avatarUrl, createdAt, updatedAt
  - 関連: whispers, followers, following, views
  - avatarUrlはすでに存在（nullableなString型）
- **Implications**:
  - 新規フィールド追加: bio (String?), birthMonth (String?, YYYY-MM形式)
  - avatarUrlをavatarPathにリネーム（署名付きURL生成のため）

#### 既存Controller/Schemaパターン
- **Context**: APIエンドポイント設計パターンの確認
- **Findings**:
  - Zod schemaでリクエスト/レスポンス定義
  - fastify-autoloadでルート自動登録
  - `_paramName`ディレクトリでURLパラメータ定義
  - Prismaクライアントを直接使用（サービス層なし）
- **Implications**:
  - プロフィール用のcontrollerディレクトリ構成: `controller/profiles/` または既存の`controller/users/`を拡張
  - 認証エンドポイントは`controller/auth/`に分離

## Architecture Pattern Evaluation

| Option | Description | Strengths | Risks / Limitations | Notes |
|--------|-------------|-----------|---------------------|-------|
| 既存Controller拡張 | users controllerにプロフィール機能を追加 | 最小限の変更、既存パターン踏襲 | controllerが肥大化する可能性 | CRUD操作が増える場合は分離を検討 |
| 専用Controller分離 | auth, profilesを独立controllerに | 責任の明確な分離 | ファイル数増加 | 採用：認証とプロフィールは異なる関心事 |
| Service層追加 | ビジネスロジックをserviceに分離 | テスタビリティ向上 | 既存パターンからの逸脱 | 今回は見送り、controllerにロジック配置 |

## Design Decisions

### Decision: 認証アーキテクチャ
- **Context**: Supabase Authとバックエンド連携の方式
- **Alternatives Considered**:
  1. Supabase APIを直接呼び出し（クライアントのみ）
  2. バックエンドでJWT検証 + Supabase Admin SDK
- **Selected Approach**: バックエンドでJWT検証を行い、ユーザーIDを抽出してDB操作
- **Rationale**:
  - 既存のPrisma/PostgreSQL構成を活用
  - RLSではなくアプリケーションレベルの認可
  - バックエンドで完全なアクセス制御
- **Trade-offs**: Supabase DBのRLS機能は未使用
- **Follow-up**: Supabase JWT Secretの環境変数設定が必要

### Decision: アバター画像ストレージパス設計
- **Context**: Cloud Storageでのファイル命名規則
- **Alternatives Considered**:
  1. `avatars/{userId}.{ext}` - 単一ファイル上書き
  2. `avatars/{userId}/{timestamp}.{ext}` - 履歴保持
  3. `avatars/{uuid}.{ext}` - ランダムID
- **Selected Approach**: `avatars/{userId}/{timestamp}.{ext}`
- **Rationale**:
  - ユーザーIDでグルーピング（将来の一括削除が容易）
  - タイムスタンプでキャッシュ無効化
  - 古い画像は定期削除バッチで対応可能
- **Trade-offs**: ストレージ使用量が増加する可能性
- **Follow-up**: 古いアバター画像の削除ポリシー検討

### Decision: 生年月のデータ形式
- **Context**: 年齢計算のための生年月保存形式
- **Alternatives Considered**:
  1. Date型（日付は1日固定）
  2. String型（YYYY-MM）
  3. 2つのIntフィールド（year, month）
- **Selected Approach**: String型でYYYY-MM形式
- **Rationale**:
  - シンプルなバリデーション（正規表現）
  - フロントエンドでの扱いやすさ
  - DBマイグレーションが容易
- **Trade-offs**: 日付計算にはパースが必要
- **Follow-up**: 年齢計算ユーティリティ関数の実装

## Risks & Mitigations
- **Risk**: Supabase Auth設定の複雑さ - Mitigation: 段階的導入（まずメール/パスワード認証のみ）
- **Risk**: 既存デモユーザーとの互換性 - Mitigation: デモモード時はSupabase Authをバイパス
- **Risk**: 署名付きURL期限切れ時のUX - Mitigation: クライアント側でリトライロジック実装

## References
- [Supabase Flutter Quickstart](https://supabase.com/docs/guides/getting-started/quickstarts/flutter) — Flutter統合の公式ガイド
- [supabase_flutter package](https://pub.dev/packages/supabase_flutter) — pub.devパッケージページ
- [fastify-supabase plugin](https://github.com/psteinroe/fastify-supabase) — Fastify用Supabaseプラグイン
- [Supabase JWT Docs](https://supabase.com/docs/guides/auth/jwts) — JWT検証の公式ドキュメント
- [@google-cloud/storage](https://cloud.google.com/storage/docs/reference/libraries) — Cloud Storage Node.js SDK
