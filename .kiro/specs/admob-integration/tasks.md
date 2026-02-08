# Implementation Plan: AdMob Integration

## Tasks

- [x] 1. AdMob SDKとネイティブ設定の統合
- [x] 1.1 Flutter プロジェクトに AdMob パッケージを追加
  - pubspec.yaml に google_mobile_ads ^7.0.0 と app_tracking_transparency ^2.0.0 を追加
  - flutter pub get を実行して依存関係をインストール
  - _Requirements: 5.1_

- [x] 1.2 (P) Android ネイティブ設定を構成
  - AndroidManifest.xml に AdMob Application ID の meta-data を追加
  - テスト用 App ID（ca-app-pub-3940256099942544~3347511713）を設定
  - minSdkVersion が 21 以上であることを確認
  - _Requirements: 5.1, 5.2_

- [x] 1.3 (P) iOS ネイティブ設定を構成
  - Info.plist に GADApplicationIdentifier を追加
  - NSUserTrackingUsageDescription（ATT説明文）を追加
  - SKAdNetworkItems（Google用）を追加
  - _Requirements: 5.1, 5.2, 5.4_

- [x] 1.4 広告ID管理の設定クラスを作成
  - 環境判定ロジック（dart-define による PRODUCTION フラグ）を実装
  - テスト広告ID（バナー・リワード、iOS/Android）を定数として定義
  - 本番広告IDのプレースホルダーを用意
  - _Requirements: 5.2_

- [x] 2. バックエンド API の実装
- [x] 2.1 (P) RewardAdUsage モデルとマイグレーションを作成
  - Prisma スキーマに RewardAdUsage モデルを追加（userId, usageCount, usageDate, lastUsedAt）
  - User モデルとのリレーションを設定
  - マイグレーションを実行してテーブルを作成
  - _Requirements: 3.1, 3.3_

- [x] 2.2 リワード広告ステータス取得 API を実装
  - GET /api/reward-ads/status エンドポイントを作成
  - JST 午前5時を基準とした「アプリ日付」計算ロジックを実装
  - 残り回数（3 - usageCount）と次のリセット時刻を返却
  - 認証ミドルウェアを適用
  - _Requirements: 3.1, 3.3, 3.4_

- [x] 2.3 リワード広告使用 API を実装
  - POST /api/reward-ads/use エンドポイントを作成
  - 残り回数チェックと429エラーハンドリング
  - usageCount のインクリメントと usageDate の更新
  - 当日の視聴履歴削除処理を呼び出し
  - 削除件数と更新後の残り回数を返却
  - _Requirements: 2.2, 3.1, 3.2, 4.1, 4.2_

- [x] 2.4 (P) 視聴履歴の当日分削除ロジックを実装
  - JST 午前5時から翌日午前5時までの範囲クエリを作成
  - viewedAt でフィルタリングして当日分のみ削除
  - 削除件数を返却
  - _Requirements: 4.1, 4.2_

- [x] 3. モバイル広告サービスの実装
- [x] 3.1 AdService クラスを作成
  - MobileAds SDK の初期化メソッドを実装
  - リワード広告のプリロード機能を実装
  - 広告状態（loading, ready, showing, completed, dismissed, failed）のストリームを提供
  - _Requirements: 5.1, 5.3, 2.1, 2.3, 2.4, 2.5_

- [x] 3.2 アプリ起動時の SDK 初期化を統合
  - SplashPage で AdService.initialize() を呼び出し
  - iOS で ATT 許可ダイアログを表示
  - 初期化完了後にリワード広告をプリロード開始
  - _Requirements: 5.3, 5.4_

- [x] 3.3 リワード広告状態管理プロバイダーを作成
  - RewardAdStatus モデル（remainingCount, clearedCount, nextResetAt）を Freezed で定義
  - adStatusProvider で API からステータスを取得・キャッシュ
  - 広告使用後のステータス更新メソッドを実装
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 4. 広告 UI ウィジェットの実装
- [x] 4.1 (P) バナー広告ウィジェットを作成
  - AdMob バナー広告をロード・表示するウィジェットを実装
  - 読み込み中は固定高さのプレースホルダーを表示
  - 読み込み失敗時はウィジェットを非表示（高さ0）に
  - _Requirements: 1.1, 1.2, 1.3_

- [x] 4.2 (P) リワード広告ボタンウィジェットを作成
  - 残り回数と広告ロード状態を表示するボタンを実装
  - 残り回数0でボタン無効化、次のリセット時刻を表示
  - 広告ロード中はローディングインジケーターを表示
  - _Requirements: 2.1, 2.5, 3.2, 3.4, 3.5_

- [x] 4.3 リワード広告視聴完了時の通知処理を実装
  - 視聴完了後に API を呼び出して履歴をクリア
  - クリア件数を SnackBar で通知
  - 履歴がない場合は「クリアする履歴がありません」メッセージを表示
  - _Requirements: 2.2, 4.3, 4.4_

- [x] 5. ホーム画面への統合
- [x] 5.1 FollowingTab にバナー広告を配置
  - GridView の下部に BannerAdWidget を配置
  - コンテンツ視聴体験を妨げない位置に調整
  - 広告とコンテンツの間隔を適切に設定
  - _Requirements: 1.1, 1.4_

- [x] 5.2 ホーム画面にリワード広告ボタンを配置
  - RewardAdButton をホーム画面の適切な位置に配置
  - ボタンタップでリワード広告フローを開始
  - 状態更新後に UI を自動リフレッシュ
  - _Requirements: 2.1, 3.4_

- [x] 6. 動作検証
- [x] 6.1 バナー広告の表示検証
  - エミュレータ/シミュレータでテスト広告が表示されることを確認
  - 読み込み失敗時の非表示動作を確認
  - レイアウトのずれがないことを確認
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [x] 6.2 リワード広告フローの検証
  - リワード広告視聴完了で履歴がクリアされることを確認
  - 途中離脱時にクリアされないことを確認
  - 使用回数制限と午前5時リセットの動作を確認
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 4.1, 4.2, 4.3, 4.4_
