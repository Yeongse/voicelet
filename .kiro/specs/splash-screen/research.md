# Research & Design Decisions

## Summary
- **Feature**: `splash-screen`
- **Discovery Scope**: New Feature（新規スプラッシュ画面の実装）
- **Key Findings**:
  - 既存のAppThemeに「夜のささやき」デザインシステムが定義済み（グラデーション、アニメーション定数含む）
  - go_routerによるルーティングが構成済み、initialLocationの変更でスプラッシュ画面を起点に設定可能
  - RiverpodでAPIデータ取得の状態管理パターンが確立済み

## Research Log

### Flutter スプラッシュ画面実装パターン
- **Context**: アプリ起動時のローディング画面の最適な実装方法を調査
- **Sources Consulted**: Flutter公式ドキュメント、go_router redirect機能
- **Findings**:
  - Flutterネイティブのスプラッシュ（flutter_native_splash）はOSレベルで表示されるが、カスタムアニメーションには不向き
  - アプリ内スプラッシュページとして実装し、データロード完了後にルーティングで遷移するパターンが柔軟
  - go_routerのredirect機能を使用すると、条件付きナビゲーションが可能
- **Implications**: アプリ内スプラッシュページとして実装し、Riverpodで初期データロード状態を管理する方針が最適

### 既存テーマシステムの活用
- **Context**: 「おしゃれな画面」の実現にあたり、既存デザインシステムとの整合性確認
- **Sources Consulted**: `app_theme.dart`
- **Findings**:
  - `gradientBgMain`: 背景グラデーション（bgPrimary → bgSecondary → bgPrimary）
  - `glowAccent`: アクセントカラーのグロー効果
  - アニメーション定数: `durationSlow`（400ms）、`curveDefault`（easeOutCubic）
  - パーティクルカラー（warm/cool/pink）が定義済みで、既存の`ParticleBackground`ウィジェットを参考にできる
- **Implications**: 新規カラー定義は不要。既存のAppTheme定数を活用してブランド一貫性を維持

### 最低表示時間とデータロードの並行処理
- **Context**: 要件2.3「最低1.5秒間の表示」とデータロード完了の両方を満たす必要
- **Sources Consulted**: Dart Future.wait, Future.delayed
- **Findings**:
  - `Future.wait([dataLoadFuture, Future.delayed(minDisplayDuration)])`で両条件を満たせる
  - タイムアウト（10秒）は`Future.timeout`で実装可能
- **Implications**: SplashProviderで最低表示時間とデータロードを並行管理

## Architecture Pattern Evaluation

| Option | Description | Strengths | Risks / Limitations | Notes |
|--------|-------------|-----------|---------------------|-------|
| ルートガード方式 | go_routerのredirectでスプラッシュ→ホーム遷移を制御 | ルーティングロジックが集約、ディープリンク対応 | redirect内でasyncが複雑になる可能性 | 採用：シンプルかつ拡張性あり |
| 状態監視方式 | ConsumerWidgetでProvider状態を監視して遷移 | UI側で完結、直感的 | ルーティングロジックが分散 | 不採用 |

## Design Decisions

### Decision: アプリ内スプラッシュページとして実装
- **Context**: OSネイティブスプラッシュ vs アプリ内カスタム画面
- **Alternatives Considered**:
  1. flutter_native_splash — OS起動時に表示、カスタマイズ制限あり
  2. アプリ内SplashPage — 完全なカスタムアニメーション可能
- **Selected Approach**: アプリ内SplashPageとして実装
- **Rationale**: アニメーション要件（フェードイン、スケール、グロー効果）を実現するにはアプリ内実装が必須
- **Trade-offs**: 初期ロード時に一瞬白画面が見える可能性（flutter_native_splashと併用で対応可能）
- **Follow-up**: 将来的にネイティブスプラッシュとの連携を検討

### Decision: Riverpod FutureProviderによる初期データ管理
- **Context**: スプラッシュ画面での初期データロード状態管理
- **Alternatives Considered**:
  1. StatefulWidget内でFutureBuilder使用
  2. Riverpod FutureProviderで状態管理
- **Selected Approach**: Riverpod FutureProviderを使用
- **Rationale**: 既存プロジェクトがRiverpodを採用しており、パターン一貫性を維持。ホーム画面でもキャッシュされたデータを即座に利用可能
- **Trade-offs**: Providerの追加によるコード量増加
- **Follow-up**: なし

### Decision: go_router initialLocation変更によるスプラッシュ起点化
- **Context**: アプリ起動時のエントリーポイント設定
- **Alternatives Considered**:
  1. initialLocationを`/splash`に変更
  2. redirectで条件分岐
- **Selected Approach**: initialLocationを`/splash`に変更し、データロード完了後に`context.go('/home')`で遷移
- **Rationale**: 最もシンプルで明確な実装
- **Trade-offs**: ディープリンク対応には追加のguardロジックが必要
- **Follow-up**: 将来のディープリンク要件で再検討

## Risks & Mitigations
- **Risk 1**: ネットワーク遅延によるスプラッシュ長時間表示 — タイムアウト（10秒）後に強制遷移、オフライン状態をホーム画面で表示
- **Risk 2**: アニメーション過多によるパフォーマンス低下 — 既存のAppTheme.durationSlow（400ms）を基準にシンプルなアニメーションに留める
- **Risk 3**: ダークモード/ライトモード未対応 — 既存AppThemeはダークモードのみ。要件4.3への対応は将来フェーズに延期（現時点ではダークモードのみ）

## References
- [go_router公式ドキュメント](https://pub.dev/packages/go_router) — redirectとguard機能
- [Riverpod公式ドキュメント](https://riverpod.dev/) — FutureProviderパターン
- Voicelet既存実装: `app_theme.dart`, `particle_background.dart`
