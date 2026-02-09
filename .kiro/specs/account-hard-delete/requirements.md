# Requirements Document

## Introduction

ユーザーがアカウントを完全に削除できる機能を実装する。削除はすべての関連データ（データベースレコード、Cloud Storage上のファイル、認証プロバイダーの情報）を物理的に削除し、GDPR「忘れられる権利」などのプライバシー規制に準拠する。

## Requirements

### Requirement 1: アカウント削除リクエスト

**Objective:** ユーザーとして、自分のアカウントを完全に削除できるようにしたい。これにより、サービスから自分のデータを完全に消去できる。

#### Acceptance Criteria

1. When ユーザーがアカウント削除APIを呼び出す, the Backend API shall 認証済みユーザー自身のアカウントのみ削除を許可する
2. When アカウント削除リクエストを受信する, the Backend API shall 削除確認のため現在のパスワードまたは再認証を要求する（将来の拡張）
3. The Backend API shall アカウント削除処理を単一トランザクション内で実行し、部分的な削除状態を防ぐ

### Requirement 2: データベースレコードの物理削除

**Objective:** システムとして、ユーザーに関連する全てのデータベースレコードを物理削除したい。これにより、ユーザーデータが完全にシステムから消去される。

#### Acceptance Criteria

1. When アカウント削除が実行される, the Backend API shall usersテーブルから該当ユーザーレコードを物理削除する
2. When アカウント削除が実行される, the Backend API shall whispersテーブルから該当ユーザーの投稿を全て物理削除する
3. When アカウント削除が実行される, the Backend API shall followsテーブルから該当ユーザーのフォロー関係（フォロー・被フォロー両方）を全て物理削除する
4. When アカウント削除が実行される, the Backend API shall follow_requestsテーブルから該当ユーザーのフォローリクエスト（送信・受信両方）を全て物理削除する
5. When アカウント削除が実行される, the Backend API shall whisper_viewsテーブルから該当ユーザーの視聴履歴を全て物理削除する
6. When アカウント削除が実行される, the Backend API shall reward_ad_usagesテーブルから該当ユーザーの広告利用履歴を物理削除する
7. When アカウント削除が実行される, the Backend API shall legal_consentsテーブルから該当ユーザーの同意履歴を全て物理削除する

### Requirement 3: Cloud Storageファイルの削除

**Objective:** システムとして、ユーザーがアップロードした全てのファイルをCloud Storageから削除したい。これにより、ストレージ上にユーザーデータが残存しない。

#### Acceptance Criteria

1. When アカウント削除が実行される, the Backend API shall 該当ユーザーの全Whisper音声ファイルをCloud Storageから削除する
2. When アカウント削除が実行される, the Backend API shall 該当ユーザーのアバター画像をCloud Storageから削除する
3. If Cloud Storageファイルの削除に失敗する, the Backend API shall エラーをログに記録し、削除処理を継続する（ベストエフォート）
4. The Backend API shall Cloud Storageファイルの削除をデータベース削除の前に実行する（ファイルパス情報が必要なため）

### Requirement 4: 認証プロバイダー（Supabase Auth）からの削除

**Objective:** システムとして、認証プロバイダーからユーザーの認証情報を削除したい。これにより、削除されたアカウントでのログインを不可能にする。

#### Acceptance Criteria

1. When アカウント削除が実行される, the Backend API shall Supabase Authから該当ユーザーを削除する
2. If Supabase Authからの削除に失敗する, the Backend API shall エラーをログに記録するが、データベース削除は実行する
3. The Backend API shall Supabase Auth削除をデータベース削除の後に実行する（ロールバック時の整合性確保）

### Requirement 5: モバイルクライアントUI

**Objective:** ユーザーとして、アプリ内からアカウント削除を実行できるようにしたい。これにより、簡単にサービスから退会できる。

#### Acceptance Criteria

1. When ユーザーが設定画面を開く, the Mobile App shall アカウント削除オプションを表示する
2. When ユーザーがアカウント削除を選択する, the Mobile App shall 削除の影響（全データの永久削除、復元不可）を明確に説明する確認ダイアログを表示する
3. When ユーザーが確認ダイアログで削除を確定する, the Mobile App shall 最終確認として「削除」などのキーワード入力を求める
4. When アカウント削除が成功する, the Mobile App shall ローカルデータをクリアし、ログイン画面に遷移する
5. If アカウント削除が失敗する, the Mobile App shall エラーメッセージを表示し、再試行を促す

### Requirement 6: エラーハンドリングとロギング

**Objective:** システムとして、削除処理の失敗を適切に処理し、監査証跡を残したい。これにより、問題発生時のデバッグと法的要件への対応が可能になる。

#### Acceptance Criteria

1. The Backend API shall アカウント削除の開始・完了・失敗をログに記録する（ユーザーID、タイムスタンプ、結果）
2. If データベーストランザクションが失敗する, the Backend API shall 全ての変更をロールバックし、エラーを返す
3. The Backend API shall 削除処理中に発生した部分的な失敗（Cloud Storage、Supabase Auth）を詳細にログ記録する
4. While 削除処理が実行中, the Backend API shall 該当ユーザーの他のAPI呼び出しをブロックする（競合防止）

