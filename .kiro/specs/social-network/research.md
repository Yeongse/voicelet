# Research & Design Decisions

## Summary
- **Feature**: `social-network`
- **Discovery Scope**: Extension（既存システムへの機能拡張）
- **Key Findings**:
  - 既存のFollowモデルとコントローラが存在し、基本的なフォロー/アンフォロー機能は実装済み
  - UserモデルにisPrivate（鍵垢）フラグが未実装
  - フォローリクエスト（FollowRequest）モデルが必要
  - 既存のページネーションとレスポンスユーティリティを再利用可能

## Research Log

### 既存データベーススキーマの分析
- **Context**: 現在のPrismaスキーマにおけるフォロー関連の実装状況を確認
- **Sources Consulted**: `backend/prisma/schema.prisma`
- **Findings**:
  - Userモデル: id, email, name, bio, birthMonth, avatarPath, createdAt, updatedAt
  - Followモデル: id, followerId, followingId, createdAt（複合ユニーク制約あり）
  - フォロー関係は既に双方向リレーションで定義済み（followers, following）
  - 鍵垢フラグ（isPrivate）は未実装
  - フォローリクエストモデルは未実装
- **Implications**:
  - UserモデルにisPrivateカラムを追加する必要がある
  - FollowRequestモデルを新規作成する必要がある

### 既存APIコントローラパターンの分析
- **Context**: バックエンドのコントローラ実装パターンを理解
- **Sources Consulted**: `backend/src/controller/follows/`, `backend/src/lib/`
- **Findings**:
  - Controller-Service-Modelパターンを採用
  - Zodスキーマによるリクエスト/レスポンス検証
  - 既存のフォローエンドポイント: POST/DELETE /api/follows
  - 自己フォロー防止と重複チェックは実装済み
  - 認証はSupabase Auth + JWT（auth.ts）
  - ページネーションユーティリティ（pagination.ts）が存在
- **Implications**:
  - 既存パターンを踏襲してエンドポイントを拡張
  - 鍵垢判定ロジックをフォロー作成時に追加

### Mobileクライアント構造の分析
- **Context**: Flutterアプリのフィーチャー構造を理解
- **Sources Consulted**: `mobile-client/lib/features/`
- **Findings**:
  - Feature-firstアーキテクチャ: models/, pages/, providers/, services/
  - Freezedによるイミュータブルモデル定義
  - Riverpodによる状態管理
  - プロフィールページは既存だがフォロー/フォロワー数表示は未実装
- **Implications**:
  - social_network/フィーチャーを新規作成
  - 既存のProfileモデルにフォロー関連フィールドを追加

### 認証・認可パターンの分析
- **Context**: 既存の認証フローを理解
- **Sources Consulted**: `backend/src/lib/auth.ts`
- **Findings**:
  - Supabase Authを使用
  - JWTトークンからユーザーID（sub）を取得
  - preHandlerフックで認証を実施
- **Implications**:
  - フォロー操作は認証ユーザーのみ許可
  - フォロワー削除は自分のフォロワーに対してのみ許可

## Architecture Pattern Evaluation

| Option | Description | Strengths | Risks / Limitations | Notes |
|--------|-------------|-----------|---------------------|-------|
| 既存パターン拡張 | 現在のController-Service-Modelパターンを踏襲 | 一貫性、学習コスト低 | 複雑なビジネスロジックの分離が難しい | 採用 |
| Serviceレイヤー追加 | 専用のFollowServiceを作成 | ビジネスロジックの集約 | オーバーエンジニアリングの懸念 | 将来検討 |

## Design Decisions

### Decision: フォローリクエストのデータモデル
- **Context**: 鍵垢ユーザーへのフォローリクエスト管理が必要
- **Alternatives Considered**:
  1. Followモデルにstatusカラムを追加（pending/approved）
  2. 別途FollowRequestモデルを作成
- **Selected Approach**: FollowRequestモデルを別途作成
- **Rationale**:
  - 承認済みフォロー関係とリクエストを明確に分離
  - 既存のFollowモデルへの影響を最小化
  - リクエストの拒否履歴を残さない設計（プライバシー配慮）
- **Trade-offs**: テーブル数は増えるが、クエリがシンプルになる
- **Follow-up**: 承認時のトランザクション処理を確認

### Decision: 鍵垢（isPrivate）の実装位置
- **Context**: ユーザーのプライバシー設定をどこで管理するか
- **Alternatives Considered**:
  1. Userモデルにフラグ追加
  2. 別途UserSettingsモデルを作成
- **Selected Approach**: Userモデルにis_privateカラムを追加
- **Rationale**:
  - シンプルで参照コストが低い
  - 頻繁に参照されるフラグのため、JOINを避けられる
- **Trade-offs**: Userモデルの肥大化リスク
- **Follow-up**: 他の設定項目が増えた場合はUserSettingsへの分離を検討

### Decision: フォロワー/フォロー一覧のエンドポイント設計
- **Context**: 一覧取得APIの設計
- **Alternatives Considered**:
  1. `/api/users/:userId/followers` と `/api/users/:userId/following`
  2. `/api/follows?userId=xxx&type=followers|following`
- **Selected Approach**: リソース指向のネストURL（Option 1）
- **Rationale**:
  - RESTfulな設計に準拠
  - 直感的でドキュメント化しやすい
- **Trade-offs**: URLパスが長くなる
- **Follow-up**: なし

## Risks & Mitigations
- **鍵垢解除時の既存リクエスト**: 鍵垢解除時に保留中のリクエストを自動承認 → 要件として明記、または手動承認を維持
- **フォロワー削除のUX**: 削除されたことが相手に気づかれる可能性 → 通知機能はスコープ外のため問題なし
- **パフォーマンス**: フォロワー数が多いユーザーの一覧取得 → ページネーション必須、インデックス追加

## References
- [Prisma Documentation](https://www.prisma.io/docs) — スキーマ定義とマイグレーション
- [Fastify Documentation](https://www.fastify.io/docs/latest/) — ルーティングとプラグイン
- [Riverpod Documentation](https://riverpod.dev/) — 状態管理
