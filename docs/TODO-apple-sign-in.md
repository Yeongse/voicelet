# Apple Sign-In 実装 TODO

## ステータス: Pending

Apple Sign-Inは現在Pendingとし、まずはGoogle認証のみで開発を進めます。

---

## 概要

Apple Sign-Inを実装するためには、Apple Developer Console、Supabase Dashboard、およびFlutterクライアントの設定が必要です。

---

## 必要な情報

| 項目 | 説明 | 取得場所 |
|------|------|----------|
| Team ID | Apple Developer Programの10文字のチームID | Apple Developer Console → Membership |
| Key ID | Sign in with Apple用のキーID | Apple Developer Console → Keys |
| .p8秘密鍵ファイル | Sign in with Appleの秘密鍵（ダウンロードは1回のみ） | Apple Developer Console → Keys |
| Service ID | Web認証用のサービスID | Apple Developer Console → Identifiers |

---

## 設定手順

### 1. Team IDの取得

1. [Apple Developer Console](https://developer.apple.com/account) にアクセス
2. 左メニューから **Membership** を選択
3. **Team ID** をコピー（10文字の英数字）

### 2. Sign in with Apple用のKeyの作成

1. Apple Developer Console → **Certificates, Identifiers & Profiles**
2. 左メニューから **Keys** を選択
3. **+** ボタンをクリックして新しいキーを作成
4. キー名を入力（例: `Voicelet Sign In Key`）
5. **Sign in with Apple** にチェックを入れる
6. **Configure** をクリック
7. Primary App ID でアプリのBundle ID（`com.voicelet.app`）を選択
8. **Save** → **Continue** → **Register**
9. 作成後、**Key ID** をメモ
10. **.p8ファイルをダウンロード**（1回しかダウンロードできないので安全な場所に保管）

### 3. Service IDの作成（Web/サーバー認証用）

1. Apple Developer Console → **Certificates, Identifiers & Profiles**
2. 左メニューから **Identifiers** を選択
3. **+** ボタンをクリック
4. **Services IDs** を選択して **Continue**
5. 以下を入力:
   - Description: `Voicelet Auth Service`
   - Identifier: `com.voicelet.auth`
6. **Continue** → **Register**
7. 作成したService IDをクリックして編集
8. **Sign in with Apple** にチェックを入れて **Configure**
9. Domains and Subdomains に追加:
   - `[your-supabase-project-ref].supabase.co`
10. Return URLs に追加:
    - `https://[your-supabase-project-ref].supabase.co/auth/v1/callback`
11. **Save** → **Continue** → **Save**

### 4. Supabaseの設定

1. [Supabase Dashboard](https://supabase.com/dashboard) にアクセス
2. プロジェクトを選択
3. **Authentication** → **Providers** → **Apple**
4. 以下を設定:
   - **Enabled**: ON
   - **Service ID (for OAuth)**: `com.voicelet.auth`
   - **Secret Key**: .p8ファイルの内容をそのままコピー&ペースト
     ```
     -----BEGIN PRIVATE KEY-----
     ...
     -----END PRIVATE KEY-----
     ```
   - **Key ID**: Apple Developer Consoleで取得したKey ID
   - **Team ID**: Membershipページで取得したTeam ID
5. **Save**

### 5. iOSクライアントの設定

Xcodeでの設定が必要:

1. Xcode でプロジェクトを開く
2. ターゲットを選択 → **Signing & Capabilities**
3. **+ Capability** → **Sign in with Apple** を追加

`ios/Runner/Info.plist` は既に以下が設定済み:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.voicelet.app</string>
        </array>
    </dict>
</array>
```

### 6. Server-to-Server Notification Endpoint（オプション）

トークンの失効通知などを受け取る場合:

1. Apple Developer Console → **Certificates, Identifiers & Profiles**
2. **More** → **Configure Sign in with Apple for the Web**
3. **Server-to-Server Notification Endpoint** に設定:
   - `https://[your-backend-url]/api/auth/apple/notifications`

※ 現時点では不要。実装する場合はバックエンドにエンドポイントを追加する必要あり。

---

## 実装チェックリスト

- [ ] Team IDの取得
- [ ] Sign in with Apple用Keyの作成
- [ ] .p8秘密鍵ファイルの保管
- [ ] Key IDのメモ
- [ ] Service IDの作成と設定
- [ ] Supabase Dashboardでの設定
- [ ] Xcode Capabilityの追加
- [ ] 動作確認（シミュレータ不可、実機で確認）

---

## 注意事項

- **実機テストが必要**: Apple Sign-Inはシミュレータでは動作しません
- **.p8ファイルは1回しかダウンロードできない**: 紛失した場合はKeyを再作成する必要があります
- **Service IDのReturn URL**: Supabaseプロジェクトの正しいURLを設定してください

---

## 関連ファイル

- `mobile-client/lib/features/auth/providers/auth_provider.dart` - `signInWithApple()`メソッド
- `mobile-client/lib/features/auth/pages/signin_page.dart` - Apple Sign-Inボタン
- `mobile-client/lib/features/auth/pages/signup_page.dart` - Apple Sign-Upボタン
- `mobile-client/ios/Runner/Info.plist` - URL Schemes設定

---

## 参考リンク

- [Apple Developer - Sign in with Apple](https://developer.apple.com/sign-in-with-apple/)
- [Supabase Auth - Apple](https://supabase.com/docs/guides/auth/social-login/auth-apple)
- [sign_in_with_apple package](https://pub.dev/packages/sign_in_with_apple)
