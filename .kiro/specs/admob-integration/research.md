# Research & Design Decisions: AdMob Integration

---
**Purpose**: AdMob広告統合に関するディスカバリー調査の記録
**Discovery Type**: Full Discovery（外部SDK統合を含む新機能）
---

## Summary
- **Feature**: `admob-integration`
- **Discovery Scope**: Complex Integration（外部SDK + ネイティブ設定 + バックエンドAPI）
- **Key Findings**:
  - google_mobile_ads v7.0.0 が最新、Flutter 3.27.0+ 推奨
  - iOS ATT対応には app_tracking_transparency パッケージと UMP SDK が推奨
  - リワード広告は1回のみ表示可能、再利用には再ロードが必要

## Research Log

### google_mobile_ads パッケージ調査
- **Context**: Flutter での AdMob 統合方法の確認
- **Sources Consulted**:
  - [google_mobile_ads | pub.dev](https://pub.dev/packages/google_mobile_ads)
  - [Set up Google Mobile Ads Flutter Plugin](https://developers.google.com/admob/flutter/quick-start)
  - [Adding AdMob ads to a Flutter app | Codelabs](https://codelabs.developers.google.com/codelabs/admob-ads-in-flutter)
- **Findings**:
  - 最新バージョン: 7.0.0（53日前リリース）
  - 対応フォーマット: Banner, Interstitial, Rewarded, Native
  - 初期化: `MobileAds.instance.initialize()` をできるだけ早期に呼び出す
  - SDK初期化は30秒タイムアウト付きのFutureを返す
- **Implications**:
  - main.dart または splash_page.dart で初期化を実行
  - 初期化完了を待ってから広告をロードする設計

### テスト広告ID
- **Context**: 開発時に使用する公式テストIDの確認
- **Sources Consulted**:
  - [Test ads | Google Developers](https://developers.google.com/admob/flutter/test-ads)
  - [Rewarded ads | Google Developers](https://developers.google.com/admob/flutter/rewarded)
- **Findings**:
  | 広告タイプ | Android | iOS |
  |-----------|---------|-----|
  | Banner | ca-app-pub-3940256099942544/6300978111 | ca-app-pub-3940256099942544/2934735716 |
  | Rewarded | ca-app-pub-3940256099942544/5224354917 | ca-app-pub-3940256099942544/1712485313 |
- **Implications**:
  - 開発環境では必ずテストIDを使用（本番IDは審査違反リスク）
  - エミュレータ/シミュレータは自動でテストモード

### リワード広告ライフサイクル
- **Context**: リワード広告の実装パターンとコールバック処理
- **Sources Consulted**:
  - [Rewarded | Flutter | Google Developers](https://developers.google.com/admob/flutter/rewarded)
- **Findings**:
  - `RewardedAd.load()` で事前ロード
  - `RewardedAd.show()` で表示、`onUserEarnedReward` でリワード付与
  - 広告は1回のみ表示可能（再表示には再ロード必要）
  - `FullScreenContentCallback` でライフサイクルイベント監視
  - `onAdDismissedFullScreenContent` で dispose() を呼び出す
- **Implications**:
  - 広告表示前にプリロードしておく設計が必要
  - 視聴完了時のみリワード付与（途中離脱は付与なし）

### iOS ATT (App Tracking Transparency)
- **Context**: iOS 14+ でのトラッキング許可ダイアログ対応
- **Sources Consulted**:
  - [app_tracking_transparency | pub.dev](https://pub.dev/packages/app_tracking_transparency)
  - [IDFA support | Google Developers](https://developers.google.com/admob/flutter/privacy/idfa)
- **Findings**:
  - `app_tracking_transparency` パッケージで許可ダイアログ表示
  - `requestTrackingAuthorization` は1インストールにつき1回のみ
  - ATT拒否時も広告は表示可能（IDFAなしでリクエスト）
  - UMP SDK で説明メッセージを事前表示推奨
- **Implications**:
  - アプリ初回起動時にATTダイアログを表示
  - Info.plist に `NSUserTrackingUsageDescription` を追加
  - 拒否されても広告機能は動作継続

### ネイティブ設定要件
- **Context**: iOS/Android のプラットフォーム固有設定
- **Sources Consulted**:
  - [Quick Start | Google Developers](https://developers.google.com/admob/flutter/quick-start)
- **Findings**:
  - **Android**: AndroidManifest.xml に `com.google.android.gms.ads.APPLICATION_ID` meta-data
  - **iOS**: Info.plist に `GADApplicationIdentifier` と ATT説明文
  - minSdkVersion 21+（Android）、iOS 12.0+
- **Implications**:
  - 本番/開発で App ID を切り替える仕組みが必要
  - .env または dart-define で環境管理

## Architecture Pattern Evaluation

| Option | Description | Strengths | Risks / Limitations | Notes |
|--------|-------------|-----------|---------------------|-------|
| Option A: 既存拡張 | home_providers.dart に広告ロジック追加 | 最小変更、既存パターン活用 | providers 肥大化、関心の分離不明確 | 小規模なら有効 |
| Option B: 新規モジュール | features/ads/ に独立モジュール | 関心の分離、テスト容易 | ファイル数増加 | 推奨: 広告固有の責務を分離 |
| Option C: ハイブリッド | 広告は新規、視聴履歴は既存拡張 | バランス良好 | 2アプローチ混在 | **採用**: 適度な分離と既存活用 |

## Design Decisions

### Decision: 広告モジュール構成
- **Context**: 広告関連コードの配置場所
- **Alternatives Considered**:
  1. 既存の home feature に追加
  2. 新規 features/ads/ モジュールを作成
- **Selected Approach**: 新規 `features/ads/` モジュールを作成し、ウィジェット・サービス・プロバイダーを分離
- **Rationale**: 広告は独立した関心事であり、将来の変更や削除が容易になる
- **Trade-offs**: ファイル数増加だが、責務が明確
- **Follow-up**: ad_service.dart で AdMob SDK ラッパーを実装

### Decision: リワード使用回数管理
- **Context**: 1日3回制限と午前5時リセットの実装方法
- **Alternatives Considered**:
  1. クライアントのみで管理（ローカルストレージ）
  2. サーバーで管理（DB + API）
  3. ハイブリッド（サーバー主導 + クライアントキャッシュ）
- **Selected Approach**: サーバー主導で管理、クライアントは取得・更新のみ
- **Rationale**: 不正防止、複数デバイス対応、午前5時リセットはサーバー時刻で正確に計算
- **Trade-offs**: API呼び出し必要だが、信頼性が高い
- **Follow-up**: RewardAdUsage モデルとエンドポイント設計

### Decision: 視聴履歴クリア対象範囲
- **Context**: 「その日」の定義と対象範囲
- **Alternatives Considered**:
  1. UTC 0:00 リセット
  2. JST 0:00 リセット
  3. JST 5:00 リセット（リワード回数と統一）
- **Selected Approach**: JST 午前5時を日付境界とする
- **Rationale**: リワード回数リセットと統一し、深夜帯のユーザー体験を考慮
- **Trade-offs**: タイムゾーン計算が複雑になるが、ユーザー期待に一致
- **Follow-up**: バックエンドで JST 基準の日付範囲クエリを実装

### Decision: バナー広告配置位置
- **Context**: 投稿閲覧画面でのバナー広告配置
- **Alternatives Considered**:
  1. StoryViewerPage の上部
  2. StoryViewerPage の下部
  3. FollowingTab のリスト内
- **Selected Approach**: FollowingTab の GridView 下部（固定位置）
- **Rationale**: 視聴体験を妨げない、SafeArea 内で見切れない
- **Trade-offs**: 投稿閲覧中は非表示になるが、ホーム画面滞在時間が長いため収益機会は確保
- **Follow-up**: Adaptive Banner で画面幅に応じたサイズ調整

## Risks & Mitigations
- **AdMob審査遅延** — テスト広告IDで開発を進め、審査は並行して申請
- **ATT拒否率高** — コンテキスト広告でも収益確保可能、説明文を丁寧に記載
- **リワード広告在庫切れ** — ロード失敗時のエラーハンドリングとリトライUI
- **午前5時リセットのエッジケース** — サーバー側でJST固定、クライアントは表示のみ

## References
- [google_mobile_ads | pub.dev](https://pub.dev/packages/google_mobile_ads) — Flutter AdMob SDK
- [Quick Start | Google Developers](https://developers.google.com/admob/flutter/quick-start) — 統合ガイド
- [Rewarded Ads | Google Developers](https://developers.google.com/admob/flutter/rewarded) — リワード広告実装
- [app_tracking_transparency | pub.dev](https://pub.dev/packages/app_tracking_transparency) — iOS ATT対応
- [IDFA Support | Google Developers](https://developers.google.com/admob/flutter/privacy/idfa) — ATT + AdMob統合
