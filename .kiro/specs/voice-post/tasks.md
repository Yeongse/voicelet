# Implementation Tasks: voice-post

## Overview

本ドキュメントは、voice-post機能（Phase 1: ローカル完結）の実装タスクを定義します。各タスクはTDD（テスト駆動開発）アプローチに従い、テスト作成→実装→リファクタリングの順で進めます。

**スコープ**: Phase 1はモバイルアプリ内で完結する録音・プレビュー機能のみ。クラウドアップロード・DB永続化はPhase 2で実装。

## Task Groups

### Group 1: 依存関係・セットアップ

#### Task 1.1: 依存関係追加とコード生成
- [ ] 完了

**Requirements**: -
**Design Reference**: Technology Stack

**Description**:
必要なパッケージを追加し、コード生成を実行する。

**Acceptance Criteria**:
- pubspec.yamlに必要なパッケージが追加されている
- build_runnerでコード生成が正常に完了する
- iOS Info.plistにマイク権限が設定されている

**Steps**:
1. pubspec.yamlに追加: record, audio_waveforms, path_provider
2. iOS Info.plist: NSMicrophoneUsageDescription追加
3. `flutter pub get`
4. `flutter pub run build_runner build`

---

### Group 2: Mobile Core Services実装

#### Task 2.1: StorageService実装
- [ ] 完了

**Requirements**: 3.1, 3.2, 3.3
**Design Reference**: StorageService

**Description**:
録音ファイルのローカル保存・削除を管理するサービスを実装する。

**Acceptance Criteria**:
- ユニークなファイル名を生成できる（`{userId}_{timestamp}.m4a`形式）
- 一時ディレクトリにファイルパスを生成できる
- ファイルの存在確認ができる
- ファイルを削除できる
- ストレージ容量を確認できる

**Steps**:
1. `mobile-client/lib/features/recording/services/storage_service.dart`を作成
2. path_providerを使用したパス取得ロジック
3. ファイル名生成ロジック（userId + timestamp）
4. ファイル操作メソッド実装
5. StorageException定義

---

#### Task 2.2: RecordingService実装
- [ ] 完了

**Requirements**: 1.1, 1.4, 1.5, 1.7
**Design Reference**: RecordingService

**Description**:
音声録音の開始・停止・設定を管理するサービスを実装する。

**Acceptance Criteria**:
- マイク権限を要求し録音を開始できる
- 30秒で自動停止する
- 手動で停止できる
- 音量レベルストリームを提供する
- 経過時間ストリームを提供する
- AAC形式で高品質エンコーディング
- iOS専用（AVFoundationベース）

**Steps**:
1. `mobile-client/lib/features/recording/services/recording_service.dart`を作成
2. RecordingState enum定義
3. RecordingResult model定義
4. startRecording, stopRecordingメソッド実装
5. amplitudeStream, durationStream実装
6. 30秒自動停止ロジック
7. PermissionDeniedException定義

---

### Group 3: Mobile Providers実装

#### Task 3.1: AuthProvider実装
- [ ] 完了

**Requirements**: 4.1
**Design Reference**: AuthProvider

**Description**:
デモユーザーの認証状態を管理するProviderを実装する。

**Acceptance Criteria**:
- 開発時にデモユーザーIDを提供する
- AuthState（authenticated/unauthenticated）を管理する
- demoUserIdは`demo-user-001`

**Steps**:
1. `mobile-client/lib/features/auth/providers/auth_provider.dart`を作成
2. AuthStateをFreezedで定義
3. AuthNotifierを@riverpodで実装
4. build_runnerでコード生成

---

### Group 4: Mobile UI Components実装

#### Task 4.1: WaveformComponent実装
- [ ] 完了

**Requirements**: 5.1, 5.2, 5.3, 5.4
**Design Reference**: WaveformComponent

**Description**:
録音中・再生中の簡易波形を表示するコンポーネントを実装する。

**Acceptance Criteria**:
- 録音中に音量レベルインジケーターを表示
- 再生中に波形と再生位置を表示
- 軽量実装でパフォーマンス優先
- 設定可能な色とサイズ

**Steps**:
1. `mobile-client/lib/features/recording/widgets/waveform_component.dart`を作成
2. WaveformConfig定義
3. 録音中用インジケーターWidget
4. 再生中用波形Widget

---

#### Task 4.2: RecordingPage実装
- [ ] 完了

**Requirements**: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6
**Design Reference**: RecordingPage

**Description**:
録音画面の表示と操作を実装する。

**Acceptance Criteria**:
- 録音ボタンをタップで録音開始
- 録音中に波形インジケーターを表示
- 経過時間を表示
- 30秒で自動停止
- 停止ボタンで手動停止→プレビューへ遷移
- マイク権限拒否時にエラー表示

**Steps**:
1. `mobile-client/lib/features/recording/screens/recording_page.dart`を作成
2. RecordingServiceとの連携
3. WaveformComponentの使用
4. 経過時間表示UI
5. 録音開始/停止ボタン
6. マイク権限エラーハンドリング
7. go_routerでナビゲーション設定

---

#### Task 4.3: PreviewPage実装
- [ ] 完了

**Requirements**: 2.1, 2.2, 2.3, 2.4, 2.5
**Design Reference**: PreviewPage

**Description**:
プレビュー画面の表示と操作を実装する。

**Acceptance Criteria**:
- 録音された音声の波形を表示
- 再生ボタンで音声再生
- 再生位置を表示
- 再録音ボタンで録音画面に戻る
- 音声の長さを表示

**Steps**:
1. `mobile-client/lib/features/recording/screens/preview_page.dart`を作成
2. 音声再生機能（audio_waveforms or audioplayers）
3. WaveformComponentの使用
4. 再録音ナビゲーション
5. 音声長さ表示

---

### Group 5: ルーティング・統合

#### Task 5.1: go_routerルート設定
- [ ] 完了

**Requirements**: 1.5, 2.4
**Design Reference**: System Flows

**Description**:
録音→プレビューの画面遷移を設定する。

**Acceptance Criteria**:
- `/recording`で録音画面
- `/preview`でプレビュー画面（filePathパラメータ）
- 再録音時の戻りナビゲーション

**Steps**:
1. `mobile-client/lib/core/router/app_router.dart`を更新
2. RecordingPageルート追加
3. PreviewPageルート追加（Extra経由でfilePathを渡す）

---

## Dependency Graph

```
Task 1.1 (Dependencies)
    ├── Task 2.1 (StorageService)
    │    └── Task 2.2 (RecordingService)
    ├── Task 3.1 (AuthProvider)
    └── Task 4.1 (WaveformComponent)
         ├── Task 4.2 (RecordingPage)
         └── Task 4.3 (PreviewPage)
              └── Task 5.1 (Router)
```

## Implementation Order

1. **Phase 1-1: セットアップ**
   - Task 1.1: 依存関係追加

2. **Phase 1-2: Core Services**
   - Task 2.1: StorageService
   - Task 2.2: RecordingService

3. **Phase 1-3: Providers**
   - Task 3.1: AuthProvider

4. **Phase 1-4: UI Components**
   - Task 4.1: WaveformComponent
   - Task 4.2: RecordingPage
   - Task 4.3: PreviewPage

5. **Phase 1-5: 統合**
   - Task 5.1: go_routerルート設定

---

## Phase 2 Tasks（将来実装）

Phase 2では以下のタスクを追加予定：

### Backend
- Prisma Whisperモデル追加
- デモユーザーシードデータ作成
- SignedUrlController実装
- WhisperController実装

### Mobile
- UploadService実装
- WhisperProvider実装
- PreviewPageに投稿機能追加
