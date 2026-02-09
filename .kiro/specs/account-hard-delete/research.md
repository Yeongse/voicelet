# Research & Design Decisions: account-hard-delete

---
**Purpose**: アカウント完全削除機能の設計を情報提供するための調査結果と意思決定の記録。
---

## Summary
- **Feature**: `account-hard-delete`
- **Discovery Scope**: Extension（既存システムの拡張）
- **Key Findings**:
  - Supabase Admin API `deleteUser` は `service_role_key` で利用可能（既存クライアント設定済み）
  - Prisma Cascade Delete により関連テーブルは自動削除される
  - Cloud Storage の avatar 一括削除関数は既存、whisper 一括削除は新規追加が必要

## Research Log

### Supabase Auth Admin API
- **Context**: アカウント削除時に認証プロバイダーからユーザーを削除する必要がある
- **Sources Consulted**:
  - [Supabase Auth Admin deleteUser API Reference](https://supabase.com/docs/reference/javascript/auth-admin-deleteuser)
  - [Supabase Admin API Overview](https://supabase.com/docs/reference/javascript/admin-api)
- **Findings**:
  - メソッドシグネチャ: `supabase.auth.admin.deleteUser(id, shouldSoftDelete)`
  - `id`: ユーザーID（`auth.users.id` カラムに対応）
  - `shouldSoftDelete`: `false` でハードデリート（デフォルト）、`true` でソフトデリート
  - 戻り値: `Promise<{ data, error }>`
  - 要件: `service_role_key` が必要（サーバーサイド専用）
- **Implications**:
  - 既存の `backend/src/lib/auth.ts` で `service_role_key` 付きクライアントが初期化済み
  - 新規関数 `deleteAuthUser(userId)` を追加するだけで実装可能

### GCS Whisper ファイル一括削除
- **Context**: ユーザーの全 Whisper 音声ファイルを削除する必要がある
- **Sources Consulted**:
  - 既存コード: `backend/src/services/storage.ts`
  - `@google-cloud/storage` ドキュメント
- **Findings**:
  - 既存の `deleteWhisperFile(fileName)` は単一ファイル削除
  - Whisper ファイル命名規則: `{uuid}` 形式（ユーザーIDベースのプレフィックスなし）
  - アバターは `avatars/{userId}/` プレフィックスで prefix 検索可能
- **Implications**:
  - Whisper ファイルはプレフィックス検索不可 → DB から fileName リストを取得し、個別削除が必要
  - 新規関数 `deleteWhisperFiles(fileNames: string[])` を追加

### 既存削除エンドポイント調査
- **Context**: 既存の `DELETE /api/profiles/me` を拡張する
- **Sources Consulted**:
  - `backend/src/controller/profiles/me/controller.ts:288-323`
- **Findings**:
  - 既存実装は DB 削除のみ
  - TODO コメントで Cloud Storage / Supabase Auth 削除が残っている
  - Prisma Cascade Delete により関連テーブルは自動削除
- **Implications**:
  - 既存エンドポイントを拡張するアプローチが最適
  - 新規 API パス不要

## Architecture Pattern Evaluation

| Option | Description | Strengths | Risks / Limitations | Notes |
|--------|-------------|-----------|---------------------|-------|
| A: Controller 拡張のみ | 既存 controller.ts に全ロジック追加 | 変更最小 | controller 肥大化 | 単純だがテスト困難 |
| B: 専用 Service 作成 | `account-deletion.ts` サービス新規作成 | 責務分離明確 | ファイル数増加、既存パターンと乖離 | 現コードベースに service 層少ない |
| **C: ハイブリッド** | auth.ts / storage.ts に関数追加、controller で統合 | 既存パターン踏襲、再利用可能 | 複数ファイル変更 | **推奨**: 最小限の拡張で既存責務維持 |

## Design Decisions

### Decision: ハイブリッドアプローチ採用
- **Context**: 削除ロジックの配置場所を決定する必要がある
- **Alternatives Considered**:
  1. Option A — controller のみ拡張（シンプルだが肥大化リスク）
  2. Option B — 専用サービス層（過剰な抽象化）
  3. Option C — 既存モジュールに関数追加（推奨）
- **Selected Approach**: Option C（ハイブリッド）
- **Rationale**:
  - `auth.ts` は認証関連、`storage.ts` はストレージ関連という既存責務に沿う
  - 追加関数は他機能でも再利用可能
  - controller は統合・オーケストレーションのみ担当
- **Trade-offs**:
  - ✅ 既存パターン踏襲、テスト容易
  - ❌ 3 ファイルへの変更が必要

### Decision: 削除処理順序
- **Context**: Cloud Storage / DB / Supabase Auth の削除順序を決定
- **Selected Approach**:
  1. Cloud Storage 削除（ベストエフォート）
  2. DB 削除（トランザクション）
  3. Supabase Auth 削除（ベストエフォート）
- **Rationale**:
  - Storage 削除は DB から fileName を取得する必要があるため先に実行
  - DB 削除が失敗した場合のロールバックを考慮し、Auth 削除は最後
  - Storage / Auth 削除失敗はログ記録して続行（ユーザーデータ漏洩リスクより削除完了を優先）
- **Trade-offs**:
  - ✅ 部分失敗時もユーザー削除は完了
  - ❌ Storage / Auth に孤立データが残る可能性（ログで監視）

### Decision: モバイル UI フロー
- **Context**: 誤削除防止と UX のバランス
- **Selected Approach**: 2 段階確認
  1. 説明付き確認ダイアログ
  2. 「削除」キーワード入力
- **Rationale**:
  - Apple / Google のアプリストア要件でアカウント削除機能が必須
  - 誤操作防止のため複数ステップを設ける
  - ユーザー名入力は文字数が多いため「削除」固定が UX 的に優れる
- **Trade-offs**:
  - ✅ 誤削除リスク最小化
  - ❌ 削除までのステップ数増加

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Cloud Storage 削除失敗 | Low（データ漏洩リスク低、課金影響小） | エラーログ記録、定期的な孤立ファイルクリーンアップジョブ検討 |
| Supabase Auth 削除失敗 | Medium（ログイン試行時エラー） | エラーログ記録、手動対応フロー準備 |
| 大量ファイル削除のパフォーマンス | Low（ユーザーあたりの Whisper 数は限定的） | `Promise.allSettled` で並列削除、タイムアウト設定 |
| 削除処理中の競合リクエスト | Low（稀なケース） | 初期実装では対応せず、問題発生時に楽観的ロック検討 |

## References
- [Supabase Auth Admin deleteUser API](https://supabase.com/docs/reference/javascript/auth-admin-deleteuser)
- [Supabase Admin API Overview](https://supabase.com/docs/reference/javascript/admin-api)
- [Google Cloud Storage Node.js Client](https://cloud.google.com/storage/docs/reference/libraries#client-libraries-install-nodejs)
