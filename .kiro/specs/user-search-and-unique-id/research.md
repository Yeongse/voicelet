# Research & Design Decisions

## Summary
- **Feature**: user-search-and-unique-id
- **Discovery Scope**: Extension（既存システムへの機能追加）
- **Key Findings**:
  - Userモデルに`username`フィールドを追加し、`@unique`制約で一意性を保証
  - 既存の`/api/users`コントローラーに検索機能を拡張、または新規`/api/search`コントローラーを作成
  - おすすめフィード（discover）のクエリに`isPrivate: false`条件を追加

## Research Log

### 既存のUserモデル構造
- **Context**: usernameフィールド追加のためのスキーマ変更調査
- **Sources Consulted**: `backend/prisma/schema.prisma`
- **Findings**:
  - 現在のUserモデルには`email`のみがunique制約を持つ
  - `name`フィールドは表示名として既に存在（nullable）
  - `isPrivate`フィールドは既に存在し、鍵アカウント機能の基盤がある
- **Implications**: `username`フィールドを追加し、`@unique`制約と適切なインデックスを設定

### 既存の検索機能パターン
- **Context**: ユーザー検索APIの設計調査
- **Sources Consulted**: `backend/src/controller/users/controller.ts`
- **Findings**:
  - 既存の`/api/users`エンドポイントで`search`クエリパラメータをサポート
  - `name`と`email`に対する`contains`検索を実装済み
  - ページネーションユーティリティ（`calculatePagination`, `buildPaginationResponse`）が利用可能
- **Implications**: 新規`/api/search/users`エンドポイントとして実装し、username検索を含める

### おすすめフィード（Discover）の実装
- **Context**: 鍵アカウント除外機能の調査
- **Sources Consulted**: `backend/src/controller/discover/controller.ts`
- **Findings**:
  - 現在`isPrivate`による絞り込みは実装されていない
  - `whispers.some`で有効なWhisperを持つユーザーを取得
  - フォロー中ユーザーを除外するロジックが存在
- **Implications**: `isPrivate: false`条件を追加して公開アカウントのみ表示

### モバイルクライアントのパターン
- **Context**: 検索機能のUI/Provider設計調査
- **Sources Consulted**: `mobile-client/lib/features/`配下の各機能
- **Findings**:
  - Feature-firstアーキテクチャ（models/, pages/, providers/）
  - Freezedによるイミュータブルモデル生成
  - Riverpodによる状態管理
  - go_routerによるナビゲーション
- **Implications**: 新規`search`フィーチャーディレクトリを作成

## Architecture Pattern Evaluation

| Option | Description | Strengths | Risks / Limitations | Notes |
|--------|-------------|-----------|---------------------|-------|
| 既存usersコントローラー拡張 | `/api/users`に検索機能を追加 | 変更が少ない | 責務が増える、検索専用ロジックが混在 | 不採用 |
| 新規searchコントローラー | `/api/search/users`として独立 | 責務分離、拡張性が高い | 新規ファイル作成が必要 | 採用 |

## Design Decisions

### Decision: usernameフィールドの追加
- **Context**: TwitterやInstagramのような@ユーザー名機能が必要
- **Alternatives Considered**:
  1. 既存のnameフィールドに一意制約を追加
  2. 新規usernameフィールドを追加
- **Selected Approach**: 新規`username`フィールドを追加（`name`は表示名として残す）
- **Rationale**: 表示名（name）は自由に設定可能、usernameは一意識別子として分離
- **Trade-offs**: DBマイグレーションが必要、既存ユーザーへの対応が必要
- **Follow-up**: 既存ユーザーにはnullを許容するか、デフォルト値を生成するか決定

### Decision: username形式の制約
- **Context**: 不正な文字や重複を防ぐバリデーション
- **Selected Approach**:
  - 半角英数字、アンダースコア（_）、ピリオド（.）のみ許可
  - 3文字以上30文字以下
  - 大文字小文字を区別しない（DB側でcase-insensitive unique）
- **Rationale**: Twitter/Instagramの一般的なパターンに準拠

### Decision: 検索APIの設計
- **Context**: フリーテキストでユーザーを検索
- **Selected Approach**: 新規`/api/search/users`エンドポイント
- **Rationale**:
  - 検索機能を独立したモジュールとして管理
  - 将来的にWhisper検索など拡張可能
  - 既存のusersコントローラーの責務を増やさない

### Decision: 検索結果での鍵アカウント表示
- **Context**: 検索結果に鍵アカウントを表示するか
- **Selected Approach**: 検索結果には鍵アカウントも表示する
- **Rationale**:
  - ユーザーは鍵アカウントの存在を知ってフォローリクエストを送れる
  - おすすめフィードとの差別化（おすすめは公開のみ）

## Risks & Mitigations
- **Risk 1**: 既存ユーザーにusernameがない → マイグレーション時にnull許容、プロフィール編集時に設定を促す
- **Risk 2**: username変更時の一意性チェック → トランザクション内で確認と更新を行う
- **Risk 3**: 検索パフォーマンス → username/nameにインデックスを追加、LIKE検索の最適化

## References
- [Prisma Unique Constraint](https://www.prisma.io/docs/concepts/components/prisma-schema/relations#unique-constraints) - ユニーク制約の設定方法
- [PostgreSQL Text Search](https://www.postgresql.org/docs/current/textsearch.html) - 将来的な全文検索の参考
