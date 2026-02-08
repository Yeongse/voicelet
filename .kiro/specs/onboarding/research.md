# Research & Design Decisions: Onboarding Feature

---
**Purpose**: オンボーディング機能のディスカバリー調査結果と設計決定の根拠を記録する。
---

## Summary
- **Feature**: `onboarding`
- **Discovery Scope**: Extension（既存アプリへの機能拡張）
- **Key Findings**:
  - `tutorial_coach_mark` v1.3.3 が Flutter 3.10+ 対応、GPL ライセンス要件なし（MIT）
  - `shared_preferences` v2.5.4 が推奨 API（SharedPreferencesAsync）を提供
  - 既存の `OnboardingPage` はプロフィール入力用のため、命名衝突を回避する必要あり

## Research Log

### パッケージ選定: tutorial_coach_mark vs onboarding_overlay

- **Context**: ギャップ分析で `onboarding_overlay` を候補としたが、実績と機能性を再評価
- **Sources Consulted**:
  - [pub.dev/tutorial_coach_mark](https://pub.dev/packages/tutorial_coach_mark)
  - [pub.dev/onboarding_overlay](https://pub.dev/packages/onboarding_overlay)
- **Findings**:
  - `tutorial_coach_mark`: 1.54k likes, 102k downloads, MIT ライセンス、GlobalKey ベース
  - `onboarding_overlay`: FocusNode ベース、カスタマイズ性高いがダウンロード数少ない
  - 両パッケージとも Flutter 3.10+ 対応
- **Implications**: `tutorial_coach_mark` を採用。実績が豊富でコミュニティサポートが充実

### 状態永続化: shared_preferences

- **Context**: オンボーディング完了状態をローカルに保存する必要
- **Sources Consulted**: [pub.dev/shared_preferences](https://pub.dev/packages/shared_preferences)
- **Findings**:
  - v2.5.4 が最新、Flutter 公式メンテナンス
  - 推奨 API: `SharedPreferencesAsync` または `SharedPreferencesWithCache`
  - Boolean 値の保存: `setBool('key', true)` / `getBool('key')`
- **Implications**: `SharedPreferencesAsync` を使用してモダンな非同期パターンに準拠

### 既存コードとの統合ポイント

- **Context**: 既存の画面構造への影響を最小化
- **Sources Consulted**: gap-analysis.md、既存コードベース
- **Findings**:
  - `home_page.dart`: ヘッダー右側に復習ボタン配置可能（検索・プロフィール横）
  - `recording_page.dart`: AppBar 左側に閉じるボタンがあるため、右側に配置
  - `splash_page.dart`: 初期化フローでオンボーディング状態を確認する必要なし（各画面で判定）
- **Implications**: 各画面単位でオンボーディング表示を判定、画面遷移時に Splash を経由しないため

## Architecture Pattern Evaluation

| Option | Description | Strengths | Risks / Limitations | Notes |
|--------|-------------|-----------|---------------------|-------|
| Feature Module | `features/tutorial/` を新規作成 | Feature-first パターン準拠、分離された責務 | ファイル数増加 | 既存パターンに合致 |
| Core Utility | `core/tutorial/` に配置 | 横断的な機能として統一 | 機能固有のロジックが core に混在 | 不採用 |

**Selected**: Feature Module（`features/tutorial/`）

## Design Decisions

### Decision: パッケージ選定

- **Context**: オンボーディング UI を効率的に実装するためのパッケージが必要
- **Alternatives Considered**:
  1. `tutorial_coach_mark` — 実績豊富、GlobalKey ベース
  2. `onboarding_overlay` — カスタマイズ性高い、FocusNode ベース
  3. フルカスタム実装 — 完全な自由度、開発工数大
- **Selected Approach**: `tutorial_coach_mark` v1.3.3
- **Rationale**: 102k ダウンロードの実績、MIT ライセンス、十分なカスタマイズ性
- **Trade-offs**: パッケージ依存は発生するが、開発工数削減のメリットが大きい
- **Follow-up**: パッケージ更新時の互換性確認を CI に組み込む検討

### Decision: 状態永続化方式

- **Context**: オンボーディング完了フラグの永続化
- **Alternatives Considered**:
  1. `shared_preferences` — シンプル、Flutter 公式
  2. `Hive` — 高速、型安全
  3. サーバーサイド保存 — クロスデバイス同期可能
- **Selected Approach**: `shared_preferences` v2.5.4
- **Rationale**: 単純なブール値の保存には十分、追加学習コストなし
- **Trade-offs**: デバイス間同期なし（今回は要件外）
- **Follow-up**: なし

### Decision: 命名規則

- **Context**: 既存の `OnboardingPage`（プロフィール入力）との衝突回避
- **Alternatives Considered**:
  1. `TutorialOverlay` 系 — パッケージ名に近い
  2. `AppGuide` 系 — 一般的な表現
  3. `Onboarding` 系 — 既存と衝突
- **Selected Approach**: `Tutorial` プレフィックスを使用
- **Rationale**: パッケージ名 `tutorial_coach_mark` との一貫性、既存との明確な区別
- **Trade-offs**: なし
- **Follow-up**: なし

## Risks & Mitigations

- **GlobalKey 管理の複雑化** — 各画面で定義する GlobalKey が増加する。対策: Provider で一元管理
- **パッケージ非互換** — Flutter メジャーアップデート時の互換性。対策: バージョン固定、CI での検証
- **既存 UI への影響** — ホーム画面・録音画面の変更。対策: 変更を最小限に、復習ボタンのみ追加

## References

- [tutorial_coach_mark | pub.dev](https://pub.dev/packages/tutorial_coach_mark) — オンボーディング UI パッケージ
- [shared_preferences | pub.dev](https://pub.dev/packages/shared_preferences) — ローカルストレージ
- [Flutter GlobalKey Documentation](https://api.flutter.dev/flutter/widgets/GlobalKey-class.html) — ウィジェット参照の仕組み
