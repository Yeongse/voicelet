# Gap Analysis: Apple認証

## 概要

既存のコードベースを分析した結果、VoiceletはSupabase Authを使用した認証システムを実装済みであり、Apple認証の基盤は部分的に存在する。ただし、現在のApple認証はOAuthリダイレクト方式であり、ネイティブのSign in with Apple体験を提供するには追加の実装が必要。

---

## 1. 現状調査

### 既存の認証アーキテクチャ

| コンポーネント | 現状 | ファイル |
|--------------|------|---------|
| バックエンド認証 | Supabase Auth SDK経由でトークン検証 | `backend/src/lib/auth.ts` |
| 認証コールバック | `/api/auth/callback`でDB登録状態を確認 | `backend/src/controller/auth/controller.ts` |
| モバイル認証状態 | Riverpod StateNotifierで管理 | `mobile-client/lib/features/auth/providers/auth_provider.dart` |
| Google認証 | ネイティブ実装済み（`signInWithIdToken`使用） | `auth_provider.dart:192-244` |
| Apple認証 | OAuthリダイレクト方式（ブラウザ経由） | `auth_provider.dart:247-270` |

### 既存のパターンと規約

- **認証フロー**: OAuth Provider → Supabase `signInWithIdToken` → バックエンド `/api/auth/callback` → 登録状態確認
- **セッション管理**: Supabase Auth SDK内蔵のセッション管理を使用
- **トークン保存**: Supabase Flutter SDKがセキュアストレージを管理
- **エラーハンドリング**: `AuthState` sealed classで状態管理

### 依存関係

```yaml
# 現在のAuth関連パッケージ (pubspec.yaml)
supabase_flutter: ^2.8.0
google_sign_in: ^7.2.0
sign_in_button: ^4.0.0  # ソーシャルログインボタン
```

---

## 2. 要件実現性分析

### 要件とアセットのマッピング

| 要件 | 技術的ニーズ | 現状 | ギャップ |
|-----|------------|------|---------|
| **Req 1**: Apple認証フロー | ネイティブSign in with Apple | OAuth redirect実装あり | **Missing**: ネイティブSDK統合 |
| **Req 2**: バックエンドトークン検証 | Apple Identity Token検証 | Supabase経由で対応可能 | **None**: 既存インフラで対応 |
| **Req 3**: アカウント作成・連携 | ユーザー作成・重複チェック | 既存フローで対応可能 | **None**: 既存インフラで対応 |
| **Req 4**: セッション管理 | JWT発行・保存 | Supabase SDK管理 | **None**: 既存インフラで対応 |
| **Req 5**: エラーハンドリング | エラーメッセージ表示 | AuthState sealed class | **Minor**: Apple固有エラー追加 |
| **Req 6**: 認証取り消し対応 | Server-to-Server通知 | 未実装 | **Missing**: Webhook endpoint |

### 欠落している機能

1. **ネイティブApple Sign-In SDK統合**
   - 現在: `signInWithOAuth` → ブラウザ経由
   - 必要: `sign_in_with_apple` パッケージ + `signInWithIdToken`

2. **Apple Server-to-Server Notification エンドポイント**
   - 現在: 未実装
   - 必要: `/api/auth/apple/revocation` エンドポイント

3. **Xcode設定**
   - Sign in with Apple capability追加
   - Associated Domains設定

### 制約事項

- **Supabase依存**: バックエンドはSupabase Auth APIを使用しており、独自JWT発行は不要
- **iOSのみ**: Sign in with Appleはネイティブ実装がiOSのみ（Android対応は別検討）
- **Apple Developer設定**: App ID, Service ID, Key設定が必要

### 複雑性シグナル

- **外部統合**: Apple Identity Services、Supabase Auth
- **プラットフォーム設定**: Xcode capabilities、Apple Developer Console
- **Webhook処理**: Server-to-Server通知（非同期処理）

---

## 3. 実装アプローチオプション

### Option A: 既存コンポーネント拡張

**対象ファイル**:
- `auth_provider.dart`: `signInWithApple` メソッドをネイティブSDK使用に変更
- `login_page.dart`: Apple Sign-Inボタン追加

**説明**:
Google認証と同様のパターンで、既存の`signInWithApple`メソッドを`signInWithIdToken`方式に変更。

**トレードオフ**:
- ✅ 最小限のファイル変更
- ✅ 既存パターンとの一貫性
- ✅ Supabase統合を活用
- ❌ Server-to-Server通知は別途実装必要

### Option B: 新規コンポーネント作成

**新規ファイル**:
- `backend/src/controller/auth/apple/controller.ts`: Apple固有エンドポイント
- `mobile-client/lib/features/auth/services/apple_auth_service.dart`: Apple認証サービス

**説明**:
Apple認証を独立したモジュールとして実装し、将来的な拡張性を確保。

**トレードオフ**:
- ✅ 責務の明確な分離
- ✅ テストしやすい構造
- ❌ ファイル数増加
- ❌ 既存パターンからの逸脱

### Option C: ハイブリッドアプローチ（推奨）

**変更ファイル**:
- `auth_provider.dart`: ネイティブSDK統合（Option A）
- `login_page.dart`: Apple Sign-Inボタン追加

**新規ファイル**:
- `backend/src/controller/auth/apple/controller.ts`: Server-to-Server通知専用

**説明**:
認証フロー自体はOption Aでシンプルに実装し、Server-to-Server通知のみ新規エンドポイントとして分離。

**トレードオフ**:
- ✅ バランスの取れたアプローチ
- ✅ 既存パターン活用 + 必要な分離
- ✅ 段階的実装が可能
- ❌ 設計判断が必要

---

## 4. 実装複雑性とリスク

### 工数見積もり: **M (3-7日)**

**根拠**:
- 既存認証パターンを活用可能（Google認証と類似）
- Apple Developer Console設定が必要
- Server-to-Server通知は追加実装
- テスト環境構築（実機テスト必要）

### リスク評価: **Medium**

**根拠**:
- Apple認証はプラットフォーム設定依存が高い
- Supabase + Apple IDの統合は既知のパターン
- Server-to-Server通知のテストが困難

---

## 5. 設計フェーズへの推奨事項

### 推奨アプローチ
**Option C（ハイブリッド）** を推奨

### 設計フェーズで決定すべき事項
1. Server-to-Server通知時のユーザー処理（セッション無効化 vs アカウント無効化）
2. Androidでの代替フロー（OAuth redirect維持 or 非対応）
3. メールアドレス重複時の挙動（リンク提案 vs エラー）

### Research Items
- [ ] `sign_in_with_apple` パッケージのSupabase統合方法
- [ ] Apple Server-to-Server Notification JWT検証方法
- [ ] App Storeガイドライン準拠要件

---

## 6. 参考: Google認証の実装パターン（既存）

```dart
// auth_provider.dart:192-226 - 参考実装
Future<void> signInWithGoogle() async {
  // 1. Google Sign-In SDK でネイティブ認証
  final googleUser = await googleSignIn.authenticate();
  final idToken = googleUser.authentication.idToken;

  // 2. Supabase signInWithIdToken でセッション作成
  final response = await _supabase.auth.signInWithIdToken(
    provider: OAuthProvider.google,
    idToken: idToken,
  );

  // 3. バックエンドと同期
  await _syncWithBackend(response.session!);
}
```

Apple認証も同様のパターンで実装可能。
