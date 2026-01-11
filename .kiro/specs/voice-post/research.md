# Research & Design Decisions

## Summary
- **Feature**: `voice-post`
- **Discovery Scope**: New Feature（音声録音・投稿機能の新規実装）
- **Key Findings**:
  - Flutter音声録音には `record` パッケージが最も推奨（幅広いプラットフォームサポート）
  - 波形表示は `audio_waveforms` が軽量で要件に適合
  - ファイルアップロードは署名付きURL方式を採用（Fastifyはファイル本体を受け取らない）
  - クラウドストレージはGoogle Cloud Storageを使用、環境変数でバケット名を指定

## Research Log

### Flutter音声録音ライブラリ選定
- **Context**: 30秒音声録音機能の実装に最適なライブラリを調査（iOS専用）
- **Sources Consulted**:
  - [Flutter Gems - Audio](https://fluttergems.dev/audio/)
  - [record | pub.dev](https://pub.dev/packages/record)
  - [flutter_sound | pub.dev](https://pub.dev/packages/flutter_sound)
- **Findings**:
  - `record`: iOSではAVFoundationを使用、シンプルなAPI
  - `flutter_sound`: ストリーミング機能が強力だが、次期バージョン（Taudio 10.0）はまだAlpha
  - `record`は高精度収音を優先する要件に適合
- **Implications**: `record`パッケージを採用。iOS専用でシンプルなAPIで収音品質にリソースを集中可能

### 波形表示ライブラリ選定
- **Context**: 簡易的な波形インジケーター表示のための軽量ライブラリを調査
- **Sources Consulted**:
  - [audio_waveforms | Flutter Gems](https://fluttergems.dev/packages/audio_waveforms/)
  - [waveform_flutter | pub.dev](https://pub.dev/packages/waveform_flutter)
- **Findings**:
  - `audio_waveforms`: 録音中・再生中の波形生成をサポート、カスタマイズ性が高い
  - `waveform_flutter`: シンプルなアニメーション波形、Voice UI向け
  - 要件では「厳密な波形は不要、大まかな視覚フィードバック」のため軽量実装が適切
- **Implications**: `audio_waveforms`を採用。録音/再生両対応で、パフォーマンスを優先した実装が可能

### 署名付きURLによるファイルアップロード
- **Context**: Fastifyでファイル本体を受け取らず、署名付きURLを返すAPI設計を調査
- **Sources Consulted**:
  - [Google Cloud Storage Signed URLs](https://cloud.google.com/storage/docs/access-control/signed-urls)
  - [@google-cloud/storage - Node.js Client](https://googleapis.dev/nodejs/storage/latest/File.html)
- **Findings**:
  - GCS: `@google-cloud/storage`パッケージで`file.getSignedUrl()`を使用
  - 署名付きURLは一時的なアクセス権を付与、クレデンシャルをクライアントに露出しない
  - デフォルト有効期限は15分、カスタマイズ可能
  - サービスアカウントキー（GOOGLE_APPLICATION_CREDENTIALS）で認証
- **Implications**:
  - Fastifyは署名付きURL発行APIのみを実装
  - Mobileがストレージに直接アップロード
  - 環境変数でバケット名を指定（GCS_BUCKET_NAME）

### ローカルストレージ（Mobile）
- **Context**: 録音データの一時保存場所を調査（iOS専用）
- **Findings**:
  - iOSは`NSTemporaryDirectory`を使用
  - `path_provider`パッケージで一時ディレクトリを取得
  - 投稿成功後にローカルファイルを削除するクリーンアップが必要
- **Implications**: `path_provider`で一時ディレクトリを取得し、録音ファイルを保存

### ファイル名生成戦略
- **Context**: ユニークなファイル名の生成方法を検討
- **Findings**:
  - ユーザー名 + タイムスタンプでユニーク性を確保
  - 形式例: `{userId}_{timestamp}.m4a`
  - Mobileでファイル名を生成し、APIリクエストに含める
- **Implications**: ファイル名はMobile側で生成、署名付きURL発行時にそのファイル名を使用

## Architecture Pattern Evaluation

| Option | Description | Strengths | Risks / Limitations | Notes |
|--------|-------------|-----------|---------------------|-------|
| Feature-first | 機能単位でディレクトリを分離 | 既存パターンと一致、独立性が高い | - | 既存mobile-clientの構造に準拠 |
| Controller-Service-Model | バックエンドのレイヤード構成 | 既存パターンと一致、責務分離が明確 | - | 既存backendの構造に準拠 |
| 署名付きURL方式 | Backendはメタデータのみ、ファイルは直接Storage | サーバー負荷軽減、スケーラブル | クラウドストレージ依存 | 採用決定 |

## Design Decisions

### Decision: 署名付きURL方式の採用
- **Context**: ファイルアップロードのアーキテクチャを決定
- **Alternatives Considered**:
  1. Fastifyでマルチパートファイル受信 — サーバー負荷が高い、ディスク管理が必要
  2. 署名付きURL方式 — サーバーはURL発行のみ、ファイルはクラウドストレージへ直接
- **Selected Approach**: 署名付きURL方式を採用
- **Rationale**: サーバー負荷軽減、スケーラビリティ向上、クラウドストレージの耐久性活用
- **Trade-offs**: クラウドストレージへの依存、ローカル開発時の設定が必要
- **Follow-up**: 開発用にGCSエミュレーターまたはテスト用バケットを使用

### Decision: 音声録音ライブラリ
- **Context**: 高精度な音声収音を優先しつつ、簡易波形表示を実現する
- **Alternatives Considered**:
  1. `record` — シンプルなAPI、幅広いプラットフォーム対応
  2. `flutter_sound` — ストリーミング機能が強力だが複雑
- **Selected Approach**: `record`パッケージを採用
- **Rationale**: シンプルなAPIで開発効率が高く、収音品質にリソースを集中可能
- **Trade-offs**: ストリーミング機能は制限されるが、30秒録音には十分
- **Follow-up**: iOS/Androidでの実機テストで収音品質を検証

### Decision: 音声ファイル形式
- **Context**: 音声ファイルの形式とエンコーディングを決定
- **Alternatives Considered**:
  1. AAC — iOS/Androidで標準サポート、良好な圧縮率
  2. MP3 — 広く普及しているが、エンコーダーライセンスの考慮が必要
  3. WAV — 非圧縮で高品質だが、ファイルサイズが大きい
- **Selected Approach**: AAC（.m4a）を採用
- **Rationale**: モバイルで標準サポートされ、30秒の音声で妥当なファイルサイズ
- **Trade-offs**: ブラウザ対応は将来課題
- **Follow-up**: ファイルサイズとビットレートの最適値を実装時に調整

### Decision: デモユーザーの実装方法
- **Context**: 開発時にダミーユーザーとして認証済み状態で動作させる
- **Alternatives Considered**:
  1. Seedデータでユーザーを事前登録 + アプリ起動時にハードコード
  2. 環境変数でデモモードを切り替え
- **Selected Approach**: Seedデータ + アプリ内ハードコード
- **Rationale**: 開発環境でシンプルに動作確認が可能
- **Trade-offs**: 本番環境では認証フローが必要（将来の拡張課題）
- **Follow-up**: デモユーザーIDをPrisma seedで登録

## Risks & Mitigations
- **マイク権限拒否** — エラーメッセージ表示と設定画面への誘導UIを実装
- **ストレージ容量不足** — 保存前に容量チェックを行い、エラーハンドリング
- **アップロード失敗** — リトライオプションと進捗表示を実装
- **大きなファイルサイズ** — AAC圧縮とビットレート調整で対応
- **署名付きURL有効期限切れ** — アップロード前にURLを取得し、15分以内に完了

## References
- [record | pub.dev](https://pub.dev/packages/record) — Flutter音声録音ライブラリ
- [audio_waveforms | pub.dev](https://pub.dev/packages/audio_waveforms) — 波形表示ライブラリ
- [@google-cloud/storage](https://googleapis.dev/nodejs/storage/latest/File.html) — GCS署名付きURL生成
- [Google Cloud Storage Signed URLs](https://cloud.google.com/storage/docs/access-control/signed-urls) — 署名付きURLドキュメント
- [path_provider | pub.dev](https://pub.dev/packages/path_provider) — Flutterパス取得ライブラリ
