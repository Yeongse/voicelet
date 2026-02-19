# Research & Design Decisions: Apple認証

---
**Purpose**: Apple認証実装のための技術調査と設計判断の記録

---

## Summary
- **Feature**: `apple-auth`
- **Discovery Scope**: Extension（既存認証システムの拡張）
- **Key Findings**:
  - `sign_in_with_apple` パッケージ + Supabase `signInWithIdToken` で実装可能
  - nonce生成には `supabase.auth.generateRawNonce()` を使用
  - Server-to-Server通知は署名付きJWTで送信され、Apple OIDC公開鍵で検証

## Research Log

### sign_in_with_apple パッケージとSupabase統合

- **Context**: ネイティブApple認証のFlutter実装方法の調査
- **Sources Consulted**:
  - [Supabase: Sign in with ID token](https://supabase.com/docs/reference/dart/auth-signinwithidtoken)
  - [Supabase: Login with Apple Guide](https://supabase.com/docs/guides/auth/social-login/auth-apple)
  - [Native Mobile Auth Support Blog](https://supabase.com/blog/native-mobile-auth)
- **Findings**:
  - `supabase_flutter` v2では`sign_in_with_apple`は別途依存関係として追加が必要
  - `signInWithIdToken(provider: OAuthProvider.apple, idToken: idToken, nonce: rawNonce)` で認証
  - nonce: `supabase.auth.generateRawNonce()` で生成し、SHA256ハッシュ化してAppleに渡す
  - Supabase DashboardでBundle IDの登録が必要
- **Implications**: Google認証と同様のパターンで実装可能。既存コードの拡張で対応。

### Apple Server-to-Server Notification

- **Context**: ユーザーがApple設定から認証を取り消した場合の通知処理
- **Sources Consulted**:
  - [Apple Developer Forums: Server-to-Server Notifications](https://developer.apple.com/forums/thread/655485)
  - [Sign in with Apple Token Revocation Guide](https://medium.com/@dabhir16/a-comprehensive-guide-to-implementing-apple-sign-in-token-revocation-in-ios-applications-e30d36c43e33)
  - [Backend Token Verification](https://sarunw.com/posts/sign-in-with-apple-3/)
- **Findings**:
  - 通知は署名付きJWT（JWS）として送信される
  - 検証にはApple OIDC公開鍵（JWKS）を使用
  - イベントタイプ: `consent-revoked`（認証取り消し時）
  - エンドポイント要件: HTTPS必須、POST JSON、認証なし
  - JWT検証項目: `iss`（Apple）、`aud`（Bundle ID）、`exp`、`iat`
- **Implications**: 新規エンドポイント `/api/auth/apple/revocation` が必要。JWKSによるJWT検証を実装。

### Apple Human Interface Guidelines準拠

- **Context**: Sign in with Appleボタンのデザイン要件
- **Sources Consulted**:
  - Apple Human Interface Guidelines (Sign in with Apple)
  - sign_in_with_apple パッケージドキュメント
- **Findings**:
  - `sign_in_with_apple`パッケージが標準準拠ボタンを提供
  - `SignInWithAppleButton`ウィジェットを使用
  - ボタンスタイル: black, white, whiteOutline から選択
- **Implications**: パッケージ提供のボタンを使用し、カスタムデザインは避ける

## Architecture Pattern Evaluation

| Option | Description | Strengths | Risks / Limitations | Notes |
|--------|-------------|-----------|---------------------|-------|
| A: 既存拡張 | auth_provider.dartを拡張 | 最小変更、一貫性 | Server-to-Server通知は別途必要 | Google認証と同パターン |
| B: 新規モジュール | 独立したApple認証サービス作成 | 分離、テスト容易 | ファイル増加、パターン逸脱 | 過剰設計の可能性 |
| C: ハイブリッド | A + 通知エンドポイント分離 | バランス、段階実装可能 | 設計判断必要 | **推奨** |

## Design Decisions

### Decision: ネイティブSDK統合方式

- **Context**: 現在のOAuthリダイレクト方式からネイティブ認証への移行
- **Alternatives Considered**:
  1. OAuth redirect維持 — ブラウザ経由、UX劣る
  2. signInWithIdToken方式 — ネイティブ認証ダイアログ、UX良好
- **Selected Approach**: signInWithIdToken方式
- **Rationale**: Google認証と同じパターンで一貫性あり、ネイティブUXを提供
- **Trade-offs**: sign_in_with_appleパッケージ追加が必要
- **Follow-up**: Xcode capabilities設定の確認

### Decision: Server-to-Server通知のセッション処理

- **Context**: 認証取り消し時のユーザー処理方針
- **Alternatives Considered**:
  1. セッション無効化のみ — 再ログイン要求
  2. アカウント無効化 — アカウント状態変更
  3. アカウント削除 — 完全削除
- **Selected Approach**: セッション無効化のみ（Option 1）
- **Rationale**: ユーザーが再度Apple認証で戻る可能性あり。アカウントデータは保持。
- **Trade-offs**: ユーザーが別の認証方法でログインする場合の考慮が必要
- **Follow-up**: アカウント削除要求との整合性確認

### Decision: Androidでの対応方針

- **Context**: Sign in with AppleはiOS向けであり、Android対応の方針
- **Alternatives Considered**:
  1. iOS限定 — Androidでは非表示
  2. OAuth redirect維持 — AndroidではWebView経由
- **Selected Approach**: iOS限定（Option 1）
- **Rationale**: Voiceletは現在iOS中心、Android対応は後日検討
- **Trade-offs**: Androidユーザーには別認証方法のみ提供
- **Follow-up**: Android対応の優先度は製品判断

## Risks & Mitigations

- **Apple Developer設定の複雑さ** — ドキュメント化とチェックリスト作成で対応
- **Server-to-Server通知テストの困難さ** — モック/スタブでの単体テスト + 本番環境での手動検証
- **nonce管理の複雑さ** — Supabase提供の`generateRawNonce()`使用で簡略化

## References

- [Supabase: Sign in with ID token (native sign-in)](https://supabase.com/docs/reference/dart/auth-signinwithidtoken)
- [Supabase: Login with Apple Guide](https://supabase.com/docs/guides/auth/social-login/auth-apple)
- [sign_in_with_apple package](https://pub.dev/packages/sign_in_with_apple)
- [Apple Developer: Server-to-Server Notifications](https://developer.apple.com/forums/thread/655485)
- [JWT Validation for Sign in with Apple](https://sarunw.com/posts/sign-in-with-apple-3/)
