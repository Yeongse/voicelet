# Research & Design Decisions

## Summary
- **Feature**: `my-stories-viewer`
- **Discovery Scope**: Extension（既存システムへの機能拡張）
- **Key Findings**:
  - 既存のStoryViewerPageは他ユーザーのストーリー再生専用で、シークバー機能がない
  - WhisperViewモデルは既に閲覧履歴を記録しており、閲覧者一覧取得APIの追加のみで対応可能
  - MyStorySectionは既に自分のWhisper一覧を横並びで表示しているため、拡張が容易

## Research Log

### 既存ストーリー再生機能の分析
- **Context**: 自分のストーリー閲覧機能が他ユーザー向けと同じUIで良いか確認
- **Sources Consulted**: `mobile-client/lib/features/home/pages/story_viewer_page.dart`
- **Findings**:
  - 現在のStoryViewerPageは視聴記録APIを必ず呼び出す設計（自分の投稿では不要）
  - シークバー機能がなく、再生位置の変更不可
  - 一時停止は無効化されている（要件2.6と異なる）
  - 左右タップでのナビゲーションは既に実装済み
- **Implications**: 自分のストーリー用に新規ページ（MyStoryViewerPage）を作成する必要がある

### 閲覧履歴のデータモデル確認
- **Context**: 閲覧者一覧機能に必要なデータ構造の確認
- **Sources Consulted**: `backend/prisma/schema.prisma`, `backend/src/controller/whisper-views/controller.ts`
- **Findings**:
  - WhisperViewモデルは`userId`, `whisperId`, `viewedAt`を保持
  - `@@unique([userId, whisperId])`で重複防止済み
  - Whisper削除時に`onDelete: Cascade`で閲覧履歴も自動削除
  - 現在のAPIは視聴記録のPOSTのみで、閲覧者一覧取得APIがない
- **Implications**: 閲覧者一覧取得API（GET /api/whispers/:whisperId/viewers）の追加が必要

### 自分のストーリー一覧表示の現状
- **Context**: 既存のMyStorySectionの拡張可能性確認
- **Sources Consulted**: `mobile-client/lib/features/home/widgets/my_story_section.dart`, `mobile-client/lib/features/home/providers/home_providers.dart`
- **Findings**:
  - MyStorySectionは`myWhispersProvider`経由で自分のWhisper一覧を取得
  - 既に横並びで表示、横スクロール対応済み
  - `onWhisperTap`コールバックで選択時の処理をカスタマイズ可能
  - MyWhisperモデルにはviewCount等の閲覧情報がない
- **Implications**: 閲覧数表示のためにMyWhisperモデルの拡張またはAPIレスポンスの拡張が必要

### Flutterオーディオプレーヤーのシーク機能
- **Context**: シークバー実装のためのaudioplayersパッケージの機能確認
- **Sources Consulted**: 既存コード、audioplayersパッケージドキュメント
- **Findings**:
  - `AudioPlayer.seek(Duration position)`メソッドでシーク可能
  - `onPositionChanged`ストリームで現在位置を取得可能
  - `onDurationChanged`で総再生時間を取得可能
  - Sliderウィジェットと組み合わせてシークバーUI実装可能
- **Implications**: 既存のaudioplayersパッケージで要件を満たせる

## Architecture Pattern Evaluation

| Option | Description | Strengths | Risks / Limitations | Notes |
|--------|-------------|-----------|---------------------|-------|
| 既存StoryViewerPageの拡張 | パラメータで自分/他者を切り替え | コード重複削減 | 責務が混在、複雑化 | 非推奨 |
| 新規MyStoryViewerPage作成 | 自分のストーリー専用ページ | 責務分離、要件特化 | 一部コード重複 | 採用 |

## Design Decisions

### Decision: 自分のストーリー専用ビューアーページの新規作成
- **Context**: 自分のストーリー閲覧は他ユーザーのストーリー閲覧と異なる要件（シークバー、閲覧者確認、削除機能）がある
- **Alternatives Considered**:
  1. 既存StoryViewerPageにモード切り替えパラメータを追加
  2. 新規MyStoryViewerPageを作成
- **Selected Approach**: 新規MyStoryViewerPageを作成
- **Rationale**:
  - 責務の分離（Single Responsibility）
  - 他ユーザーのストーリー視聴ロジック（視聴記録API呼び出し等）を混在させない
  - 将来の機能拡張が容易
- **Trade-offs**: UI部品の一部重複が発生するが、保守性向上のメリットが上回る
- **Follow-up**: 共通UI部品（プログレスバー、ヘッダー）は抽出を検討

### Decision: 閲覧者一覧APIの新規エンドポイント追加
- **Context**: 現在のAPIには閲覧者一覧取得機能がない
- **Alternatives Considered**:
  1. GET /api/whispers/:whisperId/viewers - リソース階層型
  2. GET /api/whisper-views?whisperId=xxx - クエリパラメータ型
- **Selected Approach**: GET /api/whispers/:whisperId/viewers
- **Rationale**: RESTful設計でWhisperのサブリソースとして表現
- **Trade-offs**: 既存controller/whisper-viewsとは別の場所に配置
- **Follow-up**: オーナー検証（自分のWhisperのみ閲覧者確認可能）が必要

### Decision: 閲覧日時更新によるUpsert方式
- **Context**: 同一ユーザーが同一ストーリーを再度閲覧した場合の処理
- **Alternatives Considered**:
  1. 現状維持（409エラーを返す）
  2. Upsertで閲覧日時を更新
- **Selected Approach**: Upsertで閲覧日時を更新（要件6.3）
- **Rationale**: 最新の閲覧日時を保持することで、閲覧者一覧の並び順が正確になる
- **Trade-offs**: 既存APIの動作変更が必要
- **Follow-up**: 既存クライアントへの影響確認

## Risks & Mitigations
- **Risk 1**: 閲覧者一覧が大量になった場合のパフォーマンス → ページネーション実装
- **Risk 2**: 削除確認なしでの誤削除 → 確認ダイアログ必須化
- **Risk 3**: 音声シーク中のUI不整合 → debounceでシーク操作を制御

## References
- [audioplayers package](https://pub.dev/packages/audioplayers) — Flutter音声再生ライブラリ
- [Prisma upsert](https://www.prisma.io/docs/reference/api-reference/prisma-client-reference#upsert) — 閲覧履歴のupsert実装
