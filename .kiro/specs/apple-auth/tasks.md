# Implementation Plan

## Task Overview

Apple認証機能の実装タスク。モバイルクライアントとバックエンドの作業は独立して並行実行可能。

---

## Tasks

- [x] 1. モバイル: 依存関係とプロジェクト設定
- [x] 1.1 sign_in_with_appleパッケージの追加と設定
  - pubspec.yamlにsign_in_with_apple依存関係を追加
  - cryptoパッケージの追加（SHA256ハッシュ用）
  - iOSプロジェクトのCapabilities設定（Sign in with Apple有効化）
  - Info.plistへの必要なエントリ追加
  - _Requirements: 1.1, 1.4_

- [x] 2. モバイル: Apple認証フロー実装
- [x] 2.1 AuthProviderへのネイティブApple認証メソッド実装
  - 既存のsignInWithAppleメソッドをネイティブSDK方式に置換
  - nonce生成（generateRawNonce）とSHA256ハッシュ化
  - SignInWithApple.getAppleIDCredentialの呼び出し
  - signInWithIdToken(provider: apple)でSupabase認証
  - _syncWithBackendとの連携維持
  - iOSプラットフォームチェック（Platform.isIOS）
  - _Requirements: 1.1, 1.2, 1.3, 3.1, 3.2, 3.3, 3.4, 4.1, 4.4_

- [x] 2.2 Apple認証エラーハンドリング実装
  - AuthorizationErrorCode.canceledの静的処理（エラー表示なし）
  - AuthorizationErrorCode.failed/invalidResponse/notHandledのエラーメッセージ
  - ネットワークエラー時のメッセージ表示
  - Supabaseエラー時のメッセージ表示
  - ローディング状態中の重複タップ防止
  - _Requirements: 1.3, 5.1, 5.2, 5.3, 5.4_

- [x] 3. モバイル: ログイン画面UI実装
- [x] 3.1 (P) LoginPageへのAppleサインインボタン追加
  - SignInWithAppleButtonウィジェットの追加
  - Apple Human Interface Guidelines準拠のボタンスタイル
  - iOSのみボタン表示（Platform.isIOSチェック）
  - ローディング状態でのボタン無効化
  - 既存のログインフォームとの視覚的整合性
  - _Requirements: 1.1, 1.4, 5.4_

- [x] 4. バックエンド: Server-to-Server通知エンドポイント
- [x] 4.1 (P) joseパッケージの追加とJWT検証サービス実装
  - npm install jose
  - Apple JWKS取得とキャッシュ機能
  - JWT署名検証ロジック
  - ペイロード検証（iss, aud, exp, iat）
  - _Requirements: 6.1, 6.2_

- [x] 4.2 Apple認証取り消し通知エンドポイント実装
  - POST /api/auth/apple/revocation エンドポイント作成
  - Zodスキーマ定義（リクエストボディ）
  - consent-revokedイベントの処理
  - Apple subからSupabaseユーザーの特定（Admin API listUsers使用）
  - セッション無効化処理
  - エラーレスポンス（400 invalid JWT, 500）
  - ログ出力（受信、検証結果、処理結果）
  - _Requirements: 6.1, 6.2, 6.3_

- [x] 5. 統合テストと動作確認
- [x] 5.1 モバイル認証フローのテスト
  - signInWithApple()のモックテスト（nonce生成、状態遷移）
  - エラーハンドリングの各ケーステスト
  - _Requirements: 1.1, 1.2, 1.3, 5.1, 5.2, 5.3, 5.4_

- [x] 5.2 (P) バックエンドServer-to-Server通知のテスト
  - JWT検証ロジックの単体テスト
  - モックJWTでのエンドポイントテスト
  - ユーザー特定・セッション無効化フローのテスト
  - _Requirements: 6.1, 6.2, 6.3_

---

## Requirements Coverage

| Requirement | Tasks |
|-------------|-------|
| 1.1 | 1.1, 2.1, 3.1 |
| 1.2 | 2.1 |
| 1.3 | 2.1, 2.2, 5.1 |
| 1.4 | 1.1, 3.1 |
| 2.1-2.5 | Supabase signInWithIdToken経由（2.1で統合） |
| 3.1-3.4 | 2.1（Supabase + 既存_syncWithBackend） |
| 3.5 | Supabase Auth内部処理 |
| 4.1-4.4 | 2.1（Supabase Session管理） |
| 5.1-5.4 | 2.2, 3.1, 5.1 |
| 6.1-6.3 | 4.1, 4.2, 5.2 |

## Parallel Execution Notes

- **タスク3.1 / 4.1 / 4.2**: モバイルUIとバックエンドは異なるコードベースのため並行実行可能
- **タスク5.1 / 5.2**: テストはそれぞれの実装完了後に独立して実行可能
