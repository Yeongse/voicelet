# Gap Analysis: qr-code-follow

## 1. 現状調査

### 1.1 関連する既存アセット

| カテゴリ | ファイル/モジュール | 備考 |
|---------|---------------------|------|
| ルーティング | `mobile-client/lib/main.dart` | go_routerによるルート定義、`/users/:userId`でユーザー詳細への遷移パターンあり |
| プロフィール画面 | `mobile-client/lib/features/profile/pages/profile_page.dart` | 自分のプロフィール表示、AppBar actionsにアイコン配置パターンあり |
| ユーザー詳細画面 | `mobile-client/lib/features/users/pages/user_detail_page.dart` | 他ユーザーのプロフィール表示、フォローボタン統合済み |
| 認証プロバイダー | `mobile-client/lib/features/auth/providers/auth_provider.dart` | `currentUserIdProvider`でユーザーID取得可能 |
| 権限処理パターン | `mobile-client/lib/features/recording/services/recording_service.dart` | `PermissionDeniedException`パターン、録音権限処理の参考 |

### 1.2 抽出されたパターン・規約

- **ディレクトリ構成**: Feature-first（`features/{feature}/pages/`, `providers/`, `services/`）
- **状態管理**: Riverpod（`FutureProvider`, `StateNotifier`）
- **ルーティング**: go_router、`context.push('/path')`
- **UI**: AppTheme統一、`AppTheme.bgPrimary`など
- **権限エラー**: カスタム例外クラス + ユーザーへのフィードバック

### 1.3 統合ポイント

- **ルート追加**: `main.dart`の`_router`に`/qr-code`ルートを追加
- **プロフィール画面**: AppBarにQRコードアイコンを追加（エントリーポイント）
- **ユーザー詳細遷移**: スキャン後に`context.push('/users/$userId')`で遷移

## 2. 要件実現可能性分析

### 2.1 技術的ニーズ

| 要件 | 必要な技術要素 | 既存/新規 |
|------|---------------|-----------|
| QRコード生成 | `qr_flutter`パッケージ | 新規依存 |
| QRコードスキャン | `mobile_scanner`パッケージ | 新規依存 |
| カメラ権限処理 | iOS/Android権限設定、ランタイム権限リクエスト | 新規（録音権限の類似パターンあり） |
| ユーザーID埋め込み | QRコードにuserIdを含める | 新規ロジック |
| プロフィール遷移 | 既存の`/users/:userId`ルート | 既存 |
| オフラインQR表示 | ローカルでQR生成（サーバー不要） | ライブラリで対応可 |

### 2.2 ギャップと制約

| 項目 | 種類 | 詳細 |
|------|------|------|
| QRコード関連パッケージ | **Missing** | `qr_flutter`, `mobile_scanner`の追加が必要 |
| カメラ権限設定 | **Missing** | `Info.plist`（iOS）、`AndroidManifest.xml`の更新が必要 |
| ユーザー存在確認API | **既存** | `userProfileProvider`で対応可能 |
| QRコード画面UI | **Missing** | 新規ページ作成が必要 |
| タブ切り替えUI | **Missing** | TabController/TabBarViewの実装が必要 |

### 2.3 複雑性シグナル

- **シンプルなCRUD**: なし
- **UIウィジェット実装**: QR表示、カメラスキャナー、タブ切り替え
- **外部ライブラリ統合**: 2つの新規パッケージ
- **権限処理**: カメラ権限（既存パターン参考可能）

## 3. 実装アプローチ選択肢

### Option A: 既存コンポーネント拡張

**適用対象**: プロフィール画面へのエントリーポイント追加

| 変更対象 | 変更内容 |
|----------|----------|
| `profile_page.dart` | AppBar actionsにQRアイコンを追加 |
| `main.dart` | `/qr-code`ルートを追加 |

**トレードオフ**:
- ✅ 最小限の変更、既存パターンに沿う
- ✅ ルーティング統一
- ❌ 適用範囲が限定的

### Option B: 新規コンポーネント作成（推奨）

**新規作成対象**:

```
mobile-client/lib/features/qr_code/
├── pages/
│   └── qr_code_page.dart       # メイン画面（タブ: 表示/スキャン）
├── widgets/
│   ├── qr_display_tab.dart     # 自分のQRコード表示タブ
│   └── qr_scanner_tab.dart     # スキャナータブ
└── services/
    └── qr_code_service.dart    # QR生成・解析ロジック
```

**トレードオフ**:
- ✅ 関心の分離が明確
- ✅ テスト容易性が高い
- ✅ 将来的な機能拡張に柔軟
- ❌ 新規ファイル追加

### Option C: ハイブリッドアプローチ

**構成**:
- Option Aのエントリーポイント追加
- Option Bの新規feature作成
- 既存の`userProfileProvider`を再利用

**推奨**: **Option C（ハイブリッド）**

既存パターンを踏襲しつつ、QRコード機能は独立したfeatureとして実装。

## 4. 実装複雑度とリスク

### 工数見積もり: **M（3-7日）**

**根拠**:
- 2つの新規パッケージ統合
- カメラ権限処理（iOS/Android両対応）
- タブ切り替えUI実装
- エラーハンドリング

### リスク評価: **Medium**

| リスク要因 | 詳細 |
|------------|------|
| カメラ権限 | iOS/Android両対応が必要、設定ファイル更新 |
| パッケージ互換性 | `mobile_scanner`と既存依存の互換性確認が必要 |
| UX考慮 | スキャン時のフィードバック、エラー表示のタイミング |

## 5. 設計フェーズへの推奨事項

### 推奨アプローチ
**Option C（ハイブリッド）**: 既存パターン踏襲 + 独立feature作成

### 主要な設計決定事項
1. QRコードに含める情報形式（userId単体 or JSON or URL形式）
2. スキャン後のユーザー存在確認フロー（ローディング表示）
3. タブ切り替えUIのデザイン

### リサーチ項目（設計フェーズで検討）
1. **Research Needed**: `mobile_scanner`のカメラ権限リクエストフロー
2. **Research Needed**: iOS `Info.plist`のカメラ使用理由文言
3. **Research Needed**: QRコードデータ形式のベストプラクティス（Deep Link対応検討）

## 参考リンク

- [mobile_scanner | pub.dev](https://pub.dev/packages/mobile_scanner)
- [qr_flutter | pub.dev](https://pub.dev/packages/qr_flutter)
- [Flutter QR Code Libraries](https://fluttergems.dev/qr-code-bar-code/)
