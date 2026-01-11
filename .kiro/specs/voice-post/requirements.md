# Requirements Document

## Introduction
本ドキュメントは、Voiceletアプリケーションにおける音声投稿機能の要件を定義します。ユーザーが30秒以内の音声を録音し、プレビューして投稿するまでの一連のフローを実現します。開発時はシステムに事前登録されたデモユーザー（ダミーユーザー）として認証済みの状態で動作確認を行います。

**実装フェーズ**:
- **Phase 1（本スコープ）**: ローカルで完結する録音・プレビュー・ローカル保存機能
- **Phase 2（将来）**: クラウドストレージへのアップロード・DB永続化

## Requirements

### Requirement 1: 音声録音
**Objective:** As a ユーザー, I want 30秒以内の音声を録音できる機能, so that 自分の声を投稿コンテンツとして作成できる

#### Acceptance Criteria
1. When ユーザーが録音ボタンをタップする, the Recording UI shall マイクへのアクセスを要求し、録音を開始する
2. While 録音中, the Recording UI shall 簡易的な波形インジケーターを表示する（高精度な波形描画は不要）
3. While 録音中, the Recording UI shall 経過時間を表示する
4. When 録音時間が30秒に達する, the Recording UI shall 自動的に録音を停止する
5. When ユーザーが録音停止ボタンをタップする, the Recording UI shall 録音を停止し、プレビュー画面に遷移する
6. If マイクへのアクセスが拒否された場合, then the Recording UI shall エラーメッセージを表示し、設定への誘導を行う
7. The Recording Service shall 高精度な音声収音を優先する（波形表示よりも収音品質にリソースを割り当てる）

### Requirement 2: 音声プレビュー
**Objective:** As a ユーザー, I want 録音した音声をプレビューできる機能, so that 投稿前に内容を確認・再録音できる

#### Acceptance Criteria
1. When 録音が完了する, the Preview UI shall 録音された音声の簡易波形を表示する（大まかな形状で可）
2. When ユーザーが再生ボタンをタップする, the Preview UI shall 録音された音声を再生する
3. While 音声再生中, the Preview UI shall 再生位置を表示する
4. When ユーザーが再録音ボタンをタップする, the Preview UI shall 現在の録音を破棄し、録音画面に戻る
5. The Preview UI shall 録音された音声の長さを表示する

### Requirement 3: ローカルストレージ保存
**Objective:** As a ユーザー, I want 録音した音声をローカルに保存できる機能, so that 投稿処理中やオフライン時にもデータが失われない

#### Acceptance Criteria
1. When 録音が完了する, the Storage Service shall 音声データをローカルストレージに保存する
2. If ローカルストレージの容量が不足している場合, then the Storage Service shall エラーメッセージを表示する
3. The Storage Service shall 保存された音声データに一意の識別子を付与する

### Requirement 4: デモユーザー（開発用ダミーユーザー）
**Objective:** As a 開発者, I want 事前登録されたダミーユーザーとして認証済みの状態で開発できる機能, so that ユーザー登録や認証フローを省略して機能開発に集中できる

#### Acceptance Criteria
1. The Mobile App shall 開発時にデモユーザーとして認証済みの状態で起動する
2. The Demo User shall 音声録音・プレビューの全機能を利用できる

### Requirement 5: 波形表示
**Objective:** As a ユーザー, I want 録音中および再生中に波形を視覚的に確認できる機能, so that 音声の状態を直感的に把握できる

#### Acceptance Criteria
1. While 録音中, the Waveform Component shall 簡易的な音量インジケーターを表示する（厳密な波形ではなく大まかな視覚フィードバック）
2. When 録音が完了する, the Waveform Component shall 録音全体の概要波形を表示する
3. While 再生中, the Waveform Component shall 現在の再生位置を視覚的に示す
4. The Waveform Component shall パフォーマンスを優先し、収音処理を妨げない軽量な実装とする

---

## Phase 2 Requirements（将来実装）

### Requirement P2-1: 音声投稿（クラウドアップロード）
**Objective:** As a ユーザー, I want 録音した音声を投稿できる機能, so that 他のユーザーと音声コンテンツを共有できる

#### Acceptance Criteria
1. When ユーザーが投稿ボタンをタップする, the Whisper Service shall 音声データをクラウドストレージにアップロードする
2. When 音声アップロードが成功する, the Whisper Service shall データベースに投稿レコードを作成する
3. While 投稿処理中, the Post UI shall 進捗状況を表示する
4. When 投稿が成功する, the Post UI shall 成功メッセージを表示し、投稿一覧画面に遷移する
5. If 投稿が失敗した場合, then the Post UI shall エラーメッセージを表示し、再試行オプションを提供する
6. The Whisper Record shall 投稿したユーザーのIDと関連付けられる
7. When 投稿が成功する, the Storage Service shall ローカルストレージから該当の音声データを削除する

### Requirement P2-2: デモユーザーDB登録
**Objective:** As a 開発者, I want DBにデモユーザーが登録された状態で開発できる機能

#### Acceptance Criteria
1. The System shall データベースに事前登録されたデモユーザー（ダミーユーザー）を持つ
2. The Whisper Service shall デモユーザーによる投稿を通常ユーザーと同様に処理する
