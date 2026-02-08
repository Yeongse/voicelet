# Research & Design Decisions: qr-code-follow

## Summary
- **Feature**: `qr-code-follow`
- **Discovery Scope**: Extension（既存プロフィール機能の拡張）
- **Key Findings**:
  - `mobile_scanner` v7.1.4 はカメラ権限を自動で処理し、`MobileScanner`ウィジェットで簡潔に実装可能
  - `qr_flutter` v4.1.0 はオフラインでQR生成可能、カスタマイズも豊富
  - 既存の`/users/:userId`ルートと`userProfileProvider`を再利用可能

## Research Log

### QRコードスキャナーライブラリ選定
- **Context**: QRコードスキャン機能の実装に必要なライブラリを調査
- **Sources Consulted**:
  - [mobile_scanner | pub.dev](https://pub.dev/packages/mobile_scanner)
  - [Flutter QR Code Libraries](https://fluttergems.dev/qr-code-bar-code/)
- **Findings**:
  - `mobile_scanner` v7.1.4 が最新、積極的にメンテナンス
  - Android: CameraX + ML Kit、iOS: AVFoundation + Apple Vision
  - Web/macOS対応あり、Linux/Windows非対応
  - シンプルなAPI: `MobileScanner(onDetect: (result) {})`
  - カメラ権限はプラットフォーム設定で対応（iOS: `Info.plist`）
- **Implications**:
  - 最小限のコードでスキャン機能を実装可能
  - iOS `Info.plist`にカメラ使用理由の追加が必要

### QRコード生成ライブラリ選定
- **Context**: ユーザーIDを埋め込んだQRコード生成
- **Sources Consulted**:
  - [qr_flutter | pub.dev](https://pub.dev/packages/qr_flutter)
- **Findings**:
  - `qr_flutter` v4.1.0、ネットワーク不要でローカル生成
  - `QrImageView`ウィジェットでシンプルに表示
  - カスタマイズ豊富（色、サイズ、埋め込み画像）
  - QRバージョン1-40対応、エラー訂正レベル設定可能
- **Implications**:
  - オフライン要件（1.4）を満たす
  - UIカスタマイズでブランドに合わせたデザイン可能

### QRコードデータ形式
- **Context**: QRコードに埋め込むデータ形式の決定
- **Sources Consulted**: 内部設計検討
- **Findings**:
  - 選択肢: (A) userId単体、(B) JSON形式、(C) Deep Link URL
  - Deep Link URLはアプリ外からの遷移に有用だが、現時点では不要
  - JSON形式は将来拡張性があるが、パース処理が必要
  - userId単体が最もシンプルで十分
- **Implications**:
  - 初期実装はuserIdをプレーンテキストで埋め込み
  - プレフィックス`voicelet://user/`を追加して識別性を確保

### 既存コードパターン分析
- **Context**: 権限処理、ルーティング、プロバイダーの既存パターン確認
- **Sources Consulted**:
  - `recording_service.dart` - 権限処理パターン
  - `main.dart` - ルーティング定義
  - `user_detail_page.dart` - プロフィール遷移パターン
- **Findings**:
  - `PermissionDeniedException`パターンが録音機能で確立済み
  - `context.push('/users/$userId')`でプロフィール遷移
  - `userProfileProvider`でユーザー存在確認可能
- **Implications**:
  - 既存パターンを踏襲し、一貫性を維持
  - 新規APIエンドポイント不要

## Architecture Pattern Evaluation

| Option | Description | Strengths | Risks / Limitations | Notes |
|--------|-------------|-----------|---------------------|-------|
| Hybrid | 既存パターン踏襲 + 独立feature | 関心分離明確、テスト容易 | 新規ファイル追加 | **採用** |
| Extension Only | profile_page.dartに直接追加 | 最小変更 | 複雑化、責務混在 | 不採用 |
| Full New Feature | 完全独立モジュール | 完全分離 | 過剰設計 | 不採用 |

## Design Decisions

### Decision: QRコードデータ形式
- **Context**: QRコードに埋め込むデータの形式を決定
- **Alternatives Considered**:
  1. userId単体（例: `abc123-def456`）
  2. JSON形式（例: `{"userId": "abc123", "version": 1}`）
  3. Deep Link URL（例: `https://voicelet.app/u/abc123`）
- **Selected Approach**: カスタムURL形式 `voicelet://user/{userId}`
- **Rationale**:
  - 識別性が高く、無効QRとの区別が容易
  - パース処理がシンプル
  - 将来的なDeep Link対応への拡張が容易
- **Trade-offs**:
  - Deep Linkとしての直接動作はしない
  - アプリ内でのみ有効
- **Follow-up**: Deep Link対応が必要になった場合は形式を拡張

### Decision: Feature構成
- **Context**: QRコード機能のディレクトリ構成
- **Selected Approach**:
  ```
  features/qr_code/
  ├── pages/qr_code_page.dart
  └── widgets/
      ├── qr_display_tab.dart
      └── qr_scanner_tab.dart
  ```
- **Rationale**:
  - Feature-firstパターンに準拠
  - サービス層は不要（ライブラリが処理を担当）
  - ウィジェット分離でテスト容易性確保
- **Trade-offs**:
  - プロバイダーは不要（ステートレスなUI）
  - `currentUserIdProvider`と`userProfileProvider`を再利用

## Risks & Mitigations
- **カメラ権限拒否** → 設定画面への誘導メッセージを表示
- **無効QRコード** → プレフィックス検証で早期エラー表示
- **ユーザー不在** → `userProfileProvider`のエラーハンドリングで対応
- **オフライン時のスキャン** → スキャン可能だが遷移前にネットワーク確認

## References
- [mobile_scanner v7.1.4 | pub.dev](https://pub.dev/packages/mobile_scanner) — QRスキャン実装
- [qr_flutter v4.1.0 | pub.dev](https://pub.dev/packages/qr_flutter) — QR生成実装
- [Flutter Camera Permission](https://pub.dev/packages/permission_handler) — 権限処理（参考）
