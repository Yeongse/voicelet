# Research & Design Decisions

## Summary
- **Feature**: post-viewing-constraints
- **Discovery Scope**: Extension（既存システムの機能拡張）
- **Key Findings**:
  - WhisperViewモデルと視聴記録APIは既に実装済み（userId × whisperIdの一意制約あり）
  - expiresAtによるフィルタリングはdiscover/stories APIで部分的に実装済み
  - 視聴済み投稿の除外ロジックは未実装（現在はisViewedフラグを返すのみ）
  - モバイルクライアントは一時停止・シーク機能を持っており、制限が必要

## Research Log

### 既存の視聴記録システム
- **Context**: 視聴記録APIの現状を把握
- **Sources Consulted**: `backend/src/controller/whisper-views/controller.ts`, `backend/prisma/schema.prisma`
- **Findings**:
  - `POST /api/whisper-views` で視聴記録を作成済み
  - 重複登録時は409を返す仕様が既に実装されている
  - WhisperViewモデル: userId, whisperId, viewedAtを持ち、複合ユニーク制約あり
- **Implications**: 視聴記録API自体は要件を満たしている。クライアント側の呼び出しタイミングの調整が必要

### 有効期限フィルタリングの現状
- **Context**: expiresAtフィルタリングの実装状況
- **Sources Consulted**: `backend/src/controller/discover/controller.ts`, `backend/src/controller/stories/controller.ts`
- **Findings**:
  - discover API: `expiresAt: { gt: now }` でフィルタリング済み
  - stories API: `expiresAt: { gt: new Date() }` でフィルタリング済み
  - 両APIともサーバーサイドでフィルタリングを実行
- **Implications**: 要件1.1〜1.3は既に満たされている可能性が高い

### 視聴済み投稿の除外
- **Context**: 視聴済み投稿を一覧から除外するロジック
- **Sources Consulted**: `backend/src/controller/discover/controller.ts`, `backend/src/controller/stories/controller.ts`
- **Findings**:
  - 現在は `views: { where: { userId }, select: { id: true } }` で視聴情報を取得
  - `isViewed: w.views.length > 0` としてフラグを返しているが、一覧から除外していない
  - Prismaの `NOT` + `some` 条件で除外可能
- **Implications**: 視聴済み除外は新規実装が必要。Prismaクエリの拡張で対応可能

### モバイルクライアントの再生制御
- **Context**: 再生の一時停止・シーク制限の実装方法
- **Sources Consulted**: `mobile-client/lib/features/home/pages/story_viewer_page.dart`
- **Findings**:
  - `_togglePlayPause()` メソッドで一時停止が可能な状態
  - GestureDetectorで画面タップ時の操作を制御
  - AudioPlayerの `pause()` と `resume()` を使用
  - プログレスバーは表示のみでシーク操作は未実装
- **Implications**: 再生開始後の一時停止機能を無効化する必要あり。視聴記録APIの呼び出しを再生開始直後に移動

## Architecture Pattern Evaluation

| Option | Description | Strengths | Risks / Limitations | Notes |
|--------|-------------|-----------|---------------------|-------|
| APIレイヤー拡張 | 既存APIのクエリ条件を拡張 | 最小限の変更、既存パターンに準拠 | なし | 採用：既存実装との整合性が高い |
| 新規エンドポイント | 制約付き投稿取得専用API | 関心の分離 | 重複実装、メンテナンスコスト増 | 不採用 |

## Design Decisions

### Decision: 視聴済み除外のクエリ戦略
- **Context**: 視聴済み投稿をAPI応答から除外する方法
- **Alternatives Considered**:
  1. クライアント側フィルタリング — レスポンス後にクライアントで除外
  2. サーバー側クエリ条件 — Prismaクエリで `NOT: { views: { some: { userId } } }` 条件を追加
- **Selected Approach**: サーバー側クエリ条件
- **Rationale**: 帯域幅の節約、セキュリティ（視聴済みデータの漏洩防止）、既存パターンとの整合性
- **Trade-offs**: クエリの複雑化（軽微）
- **Follow-up**: パフォーマンステストで大量データ時の応答時間を確認

### Decision: 再生制御の実装方針
- **Context**: 再生開始後の一時停止・停止を禁止する方法
- **Alternatives Considered**:
  1. UI非表示 — 一時停止ボタン/操作領域を非表示
  2. 操作無視 — 操作を受け付けない（ボタンは表示）
- **Selected Approach**: 操作無視（タップハンドラの条件分岐）
- **Rationale**: UIの一貫性維持、実装のシンプルさ
- **Trade-offs**: ユーザーが混乱する可能性（フィードバック表示で対応）
- **Follow-up**: 再生中の操作不可を示すUI表示を検討

### Decision: 視聴記録の即時送信
- **Context**: 視聴記録APIの呼び出しタイミング
- **Alternatives Considered**:
  1. 再生開始時 — 音声ロード直後に即座に送信
  2. 再生完了時 — 音声が最後まで再生された後に送信
- **Selected Approach**: 再生開始時
- **Rationale**: 要件「再生した瞬間に視聴が記録される」を満たす。ネットワーク障害時も再生前にエラー検知可能
- **Trade-offs**: 途中で失敗した場合も視聴済みとなる（意図された仕様）
- **Follow-up**: API失敗時は再生を中断しエラー表示

## Risks & Mitigations
- 視聴記録API失敗時のUX劣化 — 再生中断とエラーダイアログで対応、リトライ不可
- 既存ユーザーの視聴履歴データ整合性 — 既存データは保持、新規視聴から制約適用

## References
- [Prisma Filtering](https://www.prisma.io/docs/orm/prisma-client/queries/filtering-and-sorting) — NOT条件の使用方法
- [Flutter AudioPlayers](https://pub.dev/packages/audioplayers) — 再生制御API
