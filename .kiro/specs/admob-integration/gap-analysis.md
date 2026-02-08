# Gap Analysis: AdMob Integration

## 1. 現状調査

### 1.1 関連する既存アセット

#### バックエンド
| ファイル | 用途 | 備考 |
|---------|------|------|
| `backend/prisma/schema.prisma` | DBスキーマ | `WhisperView` モデルあり (userId, whisperId, viewedAt) |
| `backend/src/controller/whisper-views/controller.ts` | 視聴履歴API | POST (upsert) のみ、DELETE なし |
| `backend/src/controller/whisper-views/schema.ts` | Zodスキーマ | 基本的なバリデーション |

#### モバイルクライアント
| ファイル | 用途 | 備考 |
|---------|------|------|
| `mobile-client/lib/features/home/pages/home_page.dart` | ホーム画面 | SafeArea + Column レイアウト、TabBarView |
| `mobile-client/lib/features/home/widgets/following_tab.dart` | フォロー中タブ | GridView、バナー広告配置候補 |
| `mobile-client/lib/features/home/pages/story_viewer_page.dart` | 投稿閲覧画面 | 視聴時にAPIを呼び出し |
| `mobile-client/lib/features/home/providers/home_providers.dart` | 状態管理 | viewedStoryIds, viewedUserIds など |
| `mobile-client/lib/features/home/services/home_api_service.dart` | APIサービス | recordView() メソッドあり |

#### ネイティブ設定
| ファイル | 現状 |
|---------|------|
| `mobile-client/ios/Runner/Info.plist` | ATT権限宣言なし、AdMob App ID なし |
| `mobile-client/android/app/src/main/AndroidManifest.xml` | AdMob meta-data なし |
| `mobile-client/pubspec.yaml` | google_mobile_ads パッケージなし |

### 1.2 既存パターン・規約

- **バックエンド**: Controller-Service-Model パターン、Zodスキーマ併設
- **モバイル**: Feature-first 構成、Riverpod状態管理、Freezedモデル
- **API**: Supabase認証トークン自動付与、RESTful設計

---

## 2. 要件フィジビリティ分析

### 2.1 技術要件マッピング

| 要件 | 必要なコンポーネント | 既存 | ギャップ |
|------|---------------------|------|---------|
| Req 1: バナー広告表示 | AdMob SDK, Banner Widget | ✗ | **Missing** |
| Req 2: リワード広告表示 | AdMob SDK, Reward Service | ✗ | **Missing** |
| Req 3: 使用回数制限 | 回数管理モデル、API | ✗ | **Missing** |
| Req 4: 視聴履歴クリア | 削除API、対象範囲計算 | △ | **Missing** (モデルあり、APIなし) |
| Req 5: SDK統合 | ネイティブ設定、初期化 | ✗ | **Missing** |

### 2.2 ギャップ詳細

#### Missing: 完全に不足
1. **google_mobile_ads パッケージ** - pubspec.yaml に追加必要
2. **AdMob App ID 設定** - iOS Info.plist, Android AndroidManifest.xml
3. **ATT (App Tracking Transparency)** - iOS 14+ で必須
4. **バナー広告ウィジェット** - BannerAd ラッパー
5. **リワード広告サービス** - RewardedAd ロード・表示・コールバック
6. **リワード使用回数管理** - バックエンドモデル + API
7. **視聴履歴一括削除API** - DELETE /api/whisper-views/today

#### Unknown: 要調査
1. **AdMob テスト広告ID** - 開発時に使用する公式テストID
2. **GDPR同意管理** - EEA向け、UMPまたはカスタム同意フロー
3. **広告ユニットID管理** - 環境変数 or Firebase Remote Config

### 2.3 複雑さシグナル

| カテゴリ | 複雑さ |
|---------|--------|
| CRUD操作 | 低 (視聴履歴削除は単純なDELETE) |
| 外部統合 | **中〜高** (AdMob SDK、ネイティブ設定) |
| ビジネスロジック | 中 (午前5時リセット、回数制限) |
| UI/UX | 低〜中 (バナー配置、ローディング状態) |

---

## 3. 実装アプローチオプション

### Option A: 既存コンポーネント拡張

**概要**: 最小限の新規ファイルで既存構造を拡張

**変更対象**:
- `home_page.dart` に直接 BannerAd を追加
- `home_providers.dart` にリワード広告プロバイダー追加
- `whisper-views/controller.ts` に DELETE エンドポイント追加
- Prisma スキーマに `RewardAdUsage` モデル追加

**トレードオフ**:
- ✅ 既存パターンを活用、学習コスト低
- ✅ ファイル数増加を最小化
- ❌ home_providers.dart が肥大化
- ❌ 広告ロジックが分散

### Option B: 新規フィーチャーモジュール作成

**概要**: `features/ads/` に広告専用モジュールを作成

**新規作成**:
```
mobile-client/lib/features/ads/
├── models/
│   └── reward_usage.dart
├── providers/
│   └── ad_provider.dart
├── services/
│   └── ad_service.dart
└── widgets/
    ├── banner_ad_widget.dart
    └── reward_ad_button.dart

backend/src/controller/reward-ads/
├── controller.ts
└── schema.ts
```

**トレードオフ**:
- ✅ 関心の分離が明確
- ✅ テストしやすい
- ✅ 将来の拡張に対応しやすい
- ❌ ファイル数増加
- ❌ 既存画面との統合ポイントの設計が必要

### Option C: ハイブリッドアプローチ（推奨）

**概要**: 広告サービスは新規モジュール、視聴履歴は既存拡張

**変更対象**:
- **新規作成**: `features/ads/` モジュール（サービス、プロバイダー、ウィジェット）
- **既存拡張**: `whisper-views/controller.ts` にDELETEエンドポイント
- **既存拡張**: `home_page.dart`, `following_tab.dart` にバナー広告配置

**トレードオフ**:
- ✅ 広告ロジックは独立、視聴履歴は既存活用
- ✅ 適度なファイル数
- ✅ 既存パターンとの整合性を維持
- ❌ 2つのアプローチの混在

---

## 4. 努力量・リスク評価

### 努力量: **M (3-7日)**

**根拠**:
- AdMob SDK統合は確立されたパターンがあるが、ネイティブ設定変更が必要
- リワード広告のコールバック処理とUIフロー
- バックエンドのリワード使用回数管理
- ATT/GDPR同意フローの実装

### リスク: **中**

| リスク要因 | 説明 | 緩和策 |
|-----------|------|--------|
| AdMob 審査 | 本番広告表示には審査が必要 | テスト広告IDで開発、審査は並行 |
| ATT拒否時の動作 | 広告収益への影響 | 拒否時もコンテキスト広告は表示可能 |
| リワード広告の可用性 | 在庫切れ時の対応 | ローディング失敗時のエラーハンドリング |
| 午前5時リセットロジック | タイムゾーン考慮 | サーバー側でJST基準で計算 |

---

## 5. 設計フェーズへの推奨事項

### 推奨アプローチ: **Option C (ハイブリッド)**

### 主要な設計決定
1. **広告フィーチャーモジュール構成** - サービス、プロバイダー、ウィジェットの責務分離
2. **バナー広告配置位置** - following_tab.dart のグリッド上部 or 下部
3. **リワード広告トリガーUI** - ホーム画面のどこに配置するか
4. **使用回数管理のデータフロー** - サーバー主導 vs クライアントキャッシュ

### 要調査項目（Research Needed）
1. **AdMob Flutter 最新ベストプラクティス** - google_mobile_ads パッケージの最新API
2. **ATT同意フローのUX** - 適切なタイミングと説明文
3. **GDPR/UMP統合** - EEA向けユーザー同意管理
4. **Flutterでのリワード広告コールバック** - 完了・エラーハンドリング

---

## 6. 次のステップ

1. `/kiro:spec-design admob-integration` で技術設計を開始
2. 設計フェーズでAdMob公式ドキュメントを参照
3. ATT/GDPR対応の詳細を決定
