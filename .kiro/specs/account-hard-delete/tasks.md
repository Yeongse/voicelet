# Implementation Plan

## Task Overview

アカウント完全削除機能の実装タスク。Backend（Storage/Auth/Controller拡張）とMobile（設定画面/削除フロー）の2軸で並行開発可能。

---

## Tasks

- [x] 1. Backend: Storage Service 拡張
- [x] 1.1 (P) Whisper音声ファイル一括削除機能の追加
  - ユーザーの全Whisperファイルを並列削除する関数を実装
  - 個別ファイル削除失敗時はログ記録して続行（ベストエフォート）
  - 削除結果として成功/失敗件数を返却
  - 既存の `deleteAvatarFiles` パターンに準拠
  - _Requirements: 3.1, 3.3, 3.4_

- [x] 2. Backend: Auth Library 拡張
- [x] 2.1 (P) Supabase Auth ユーザー削除機能の追加
  - Supabase Admin API を使用してユーザーを物理削除する関数を実装
  - 既存の Supabase クライアント（service_role_key）を活用
  - 削除失敗時はエラー情報を返却（呼び出し元でログ記録）
  - _Requirements: 4.1, 4.2, 4.3_

- [x] 3. Backend: Profile Controller 拡張
- [x] 3.1 削除APIの完全実装
  - 既存の `DELETE /api/profiles/me` エンドポイントを拡張
  - 削除処理順序: Whisperファイル名取得 → Storage削除 → DB削除 → Auth削除
  - 認証済みユーザー自身のアカウントのみ削除許可（既存の authenticate を使用）
  - Prisma Cascade Delete により関連テーブル（whispers, follows, follow_requests, whisper_views, reward_ad_usages, legal_consents）は自動削除
  - 各フェーズの開始・完了・失敗をログ記録
  - Storage/Auth 削除失敗時はログ記録して続行、DB 削除失敗時は 500 エラー返却
  - _Requirements: 1.1, 1.3, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 3.2, 3.3, 3.4, 4.2, 4.3, 6.1, 6.2, 6.3_

- [x] 4. Mobile: 設定画面の作成
- [x] 4.1 (P) 設定画面UIの実装
  - 設定画面を新規作成し、アカウント削除オプションを配置
  - 既存の profile_drawer から設定画面への遷移を実装
  - go_router にルート `/settings` を追加
  - 既存の profile_page スタイルに準拠したUI設計
  - _Requirements: 5.1_

- [x] 5. Mobile: アカウント削除プロバイダーの作成
- [x] 5.1 (P) 削除状態管理プロバイダーの実装
  - DELETE API 呼び出しを行うプロバイダーを作成
  - 削除成功時: ローカルデータクリア、Supabase セッションクリア
  - 削除失敗時: エラー状態を管理
  - 既存の AuthProvider.signOut() パターンを参考に実装
  - _Requirements: 5.4, 5.5_

- [x] 6. Mobile: 削除確認ダイアログの実装
- [x] 6.1 削除確認フローUIの実装
  - 削除影響の説明を明確に表示（全データの永久削除、復元不可）
  - 「削除」キーワード入力による最終確認を実装
  - 入力値が「削除」と完全一致した場合のみ削除ボタン有効化
  - 削除処理中のローディング表示
  - 失敗時のエラーメッセージ表示とリトライ誘導
  - 既存の showDestructiveConfirmDialog パターンを参考
  - _Requirements: 5.2, 5.3, 5.4, 5.5_

- [x] 7. 統合: エンドツーエンド動作確認
- [x] 7.1 削除フローの統合とテスト
  - 設定画面 → 削除ダイアログ → API呼び出し → ログイン画面遷移の一連のフローを確認
  - 削除成功後のローカルデータクリアとログイン画面への遷移を検証
  - エラー発生時のUI挙動（エラーメッセージ表示、リトライ）を確認
  - Backend ログ出力の確認（削除開始・完了・部分失敗）
  - _Requirements: 5.4, 6.1, 6.3_

---

## Deferred Requirements

| Requirement | Reason |
|-------------|--------|
| 1.2 | 再認証要求は将来の拡張として requirements.md に明記済み |
| 6.4 | 削除処理中の競合防止は初期実装から除外（設計レビューで合意） |

---

## Parallel Execution Guide

以下のタスクは並行実行可能:

| Group | Tasks | Notes |
|-------|-------|-------|
| Backend Services | 1.1, 2.1 | 異なるファイル（storage.ts, auth.ts）を編集 |
| Mobile Foundation | 4.1, 5.1 | 異なるファイルを編集、相互依存なし |

**依存関係**:
- 3.1 → 1.1, 2.1 に依存（Storage/Auth 関数を使用）
- 6.1 → 5.1 に依存（AccountDeletionProvider を使用）
- 7.1 → 全タスク完了後
