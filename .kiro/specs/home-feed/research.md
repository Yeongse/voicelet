# Research & Design Decisions

## Summary
- **Feature**: `home-feed`
- **Discovery Scope**: New Feature（既存コードベースへの拡張）
- **Key Findings**:
  - Prismaスキーマに`Follow`モデルが存在しない → 新規追加が必要
  - 既存の`AppTheme`に「夜のささやき」デザインシステムが実装済み
  - Riverpodのパターンは`StateNotifier`と`FutureProvider`を併用 → AsyncNotifierへの移行検討

## Research Log

### 既存データベーススキーマ分析
- **Context**: ホーム画面実装に必要なデータ構造の確認
- **Sources Consulted**: `backend/prisma/schema.prisma`
- **Findings**:
  - `User`モデル: id, email, name, createdAt, updatedAt
  - `Whisper`モデル: id, userId, bucketName, fileName, duration, createdAt, expiresAt
  - ユーザー間のフォロー関係を表す`Follow`モデルが存在しない
  - ユーザーアバターを格納するフィールドが存在しない
- **Implications**:
  - `Follow`モデルの追加が必須（followerId, followingId, createdAt）
  - `User`モデルにavatarUrl、displayNameフィールドの追加を検討
  - Whisperの視聴履歴を管理する`WhisperView`モデルが必要（ストーリー未視聴リング表示用）

### 既存Flutter Feature構造
- **Context**: プロジェクトのアーキテクチャパターン理解
- **Sources Consulted**: `mobile-client/lib/features/`配下のコード
- **Findings**:
  - Feature-firstアーキテクチャ: `models/`, `pages/`, `providers/`, `services/`, `widgets/`
  - モデルはFreezedを使用したイミュータブル設計
  - Providerパターン: `FutureProvider`（データ取得）、`StateNotifierProvider`（状態管理）
  - go_routerによるナビゲーション
  - `home_data_provider.dart`が存在するがモックデータのみ
- **Implications**:
  - 既存パターンに従って`home`featureを拡張
  - 新規モデル（`Story`, `FeedItem`, `DiscoverItem`）をFreezedで定義
  - 無限スクロールにはAsyncNotifierパターンを採用

### デザインシステム
- **Context**: UIデザイン要件への対応
- **Sources Consulted**: `mobile-client/lib/core/theme/app_theme.dart`
- **Findings**:
  - 「夜のささやき」テーマが完全実装済み
  - ベースカラー: bgPrimary(#1A1625), bgSecondary(#241F31)
  - アクセントカラー: accentPrimary(#7ECFB3)
  - アニメーション: durationFast(150ms), durationNormal(250ms), durationSlow(400ms)
  - グラデーション、シャドウ、グローが定義済み
- **Implications**:
  - ストーリーリングにはgradientAccentを使用
  - カードUIにはbgElevatedとshadowSmを活用
  - 既存のスペーシング定数を遵守

### Flutter無限スクロール実装
- **Context**: フィードの無限スクロール実装方法
- **Sources Consulted**:
  - [Flutter Pagination with Riverpod](https://codewithandrea.com/articles/flutter-riverpod-pagination/)
  - [Riverpod Pagination Guide](https://dinkomarinac.dev/riverpod-pagination-the-ultimate-guide-for-flutter-developers)
- **Findings**:
  - AsyncNotifierを使用した状態管理が推奨
  - ScrollControllerまたはNotificationListenerでスクロール検知
  - CancelTokenによるリクエストキャンセル対応
  - keep-aliveでページキャッシュ管理
- **Implications**:
  - `FeedNotifier`をAsyncNotifierとして実装
  - 各ページのエラー状態とリトライをサポート
  - Pull-to-refreshとの統合

### ストーリーUI実装
- **Context**: Instagramライクなストーリー表示の実装
- **Sources Consulted**:
  - [flutter_instagram_stories](https://pub.dev/packages/flutter_instagram_stories)
  - [stories_for_flutter](https://github.com/steevjames/stories-for-flutter)
- **Findings**:
  - 既存パッケージはFirebase依存や外部依存が多い
  - 音声特化のため、独自実装が適切
  - 横スクロールのアバターリスト + 全画面視聴ビュー
  - ジェスチャー: タップで一時停止、左右スワイプで前後移動
- **Implications**:
  - 独自のStoryViewコンポーネントを実装
  - audio_waveformsパッケージを活用した波形表示
  - プログレスバーはアニメーション付きのカスタムWidget

## Architecture Pattern Evaluation

| Option | Description | Strengths | Risks / Limitations | Notes |
|--------|-------------|-----------|---------------------|-------|
| Feature-first拡張 | 既存homeディレクトリを拡張 | 一貫性維持、学習コスト低 | 単一featureが大きくなる | 採用 |
| 新規feature分割 | stories, feed, discoverを分離 | 関心分離が明確 | 依存関係複雑化 | 不採用 |

## Design Decisions

### Decision: フォローモデルのデータ構造
- **Context**: ストーリーとフィードの表示にフォロー関係が必要
- **Alternatives Considered**:
  1. 単純なFollow（followerId, followingId） — シンプルだが拡張性低
  2. FollowWithMetadata（createdAt, notificationEnabled等） — 将来の拡張に対応
- **Selected Approach**: Option 2 — createdAtを含むFollowモデル
- **Rationale**: 通知設定やフォロー日時でのソートが将来必要になる可能性
- **Trade-offs**: テーブルサイズ微増、実装複雑性は軽微
- **Follow-up**: 通知機能実装時にnotificationEnabledカラム追加

### Decision: ストーリー表示のバックエンドAPI設計
- **Context**: ストーリー（フォロー中ユーザーの最新投稿）取得方法
- **Alternatives Considered**:
  1. `/api/stories` — 専用エンドポイント、フォロー中ユーザーの最新Whisperを返す
  2. `/api/whispers?feed=stories` — 既存エンドポイントをクエリパラメータで拡張
- **Selected Approach**: Option 1 — 専用エンドポイント
- **Rationale**: レスポンス構造が異なる（ユーザーごとにグループ化）、パフォーマンス最適化が容易
- **Trade-offs**: APIエンドポイント増加
- **Follow-up**: レスポンスに視聴済みフラグを含めるか検討

### Decision: 発見欄のコンテンツ選定ロジック
- **Context**: フォロー外ユーザーの投稿をどう選定するか
- **Alternatives Considered**:
  1. 単純な新着順
  2. 人気順（視聴数ベース）
  3. 推薦アルゴリズム
- **Selected Approach**: Option 1 — 新着順（初期実装）
- **Rationale**: MVP段階では複雑な推薦ロジックは不要、将来的な拡張ポイント
- **Trade-offs**: パーソナライズされていないが、シンプルで予測可能
- **Follow-up**: 視聴数カウント機能追加後にOption 2への移行を検討

### Decision: シードデータ構造
- **Context**: 開発時のホーム画面確認用にダミーデータが必要
- **Alternatives Considered**:
  1. 固定ユーザー + 固定投稿
  2. ランダム生成
- **Selected Approach**: Option 1 — 固定パターンで再現性を確保
- **Rationale**: テスト時の再現性、UIレビューの一貫性
- **Trade-offs**: エッジケース（大量データ等）の確認には別途対応必要
- **Follow-up**: シードスクリプトにオプションフラグでデータ量変更可能に

## Risks & Mitigations
- **音声ファイルの遅延読み込み**: 事前キャッシュ戦略とプログレッシブ読み込み
- **大量フォロワーのパフォーマンス**: ストーリー取得にページネーション適用、N+1クエリ回避
- **オフライン対応**: 初期実装ではオンライン必須、将来的にキャッシュ層追加

## References
- [Flutter Pagination with Riverpod](https://codewithandrea.com/articles/flutter-riverpod-pagination/)
- [Riverpod Pagination Guide](https://dinkomarinac.dev/riverpod-pagination-the-ultimate-guide-for-flutter-developers)
- [flutter_instagram_stories](https://pub.dev/packages/flutter_instagram_stories)
- [stories_for_flutter](https://github.com/steevjames/stories-for-flutter)
