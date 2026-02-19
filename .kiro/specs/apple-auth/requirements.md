# Requirements Document

## Introduction
VoiceletアプリにSign in with Appleを実装し、iOSユーザーがApple IDを使用して安全かつ迅速に認証できるようにする。これにより、ユーザー登録の障壁を下げ、Appleのプライバシー保護機能を活用したセキュアな認証体験を提供する。

## Requirements

### Requirement 1: Apple認証フロー（iOS）
**Objective:** As a iOSユーザー, I want Apple IDでVoiceletにサインインしたい, so that 新たにパスワードを作成せずに素早くアカウント作成・ログインできる

#### Acceptance Criteria
1. When ユーザーが「Sign in with Apple」ボタンをタップした時, the 認証システム shall Apple認証フローを開始し、システムの認証ダイアログを表示する
2. When ユーザーがApple認証を完了した時, the モバイルアプリ shall Apple Identity Tokenをバックエンドに送信する
3. When ユーザーがApple認証をキャンセルした時, the モバイルアプリ shall ログイン画面に戻り、エラーメッセージを表示しない
4. The 「Sign in with Apple」ボタン shall Appleのヒューマンインターフェースガイドラインに準拠したデザインである

### Requirement 2: バックエンドトークン検証
**Objective:** As a システム管理者, I want Apple Identity Tokenを安全に検証したい, so that 不正なトークンによるアカウント作成を防止できる

#### Acceptance Criteria
1. When バックエンドがApple Identity Tokenを受信した時, the 認証サービス shall Appleの公開鍵を使用してトークンの署名を検証する
2. When トークン検証が成功した時, the 認証サービス shall トークンからユーザー識別子（sub）、メールアドレス、名前を抽出する
3. If トークンの署名が無効な場合, then the 認証サービス shall 401 Unauthorizedエラーを返す
4. If トークンが期限切れの場合, then the 認証サービス shall 401 Unauthorizedエラーを返す
5. The 認証サービス shall Appleの公開鍵をキャッシュし、パフォーマンスを最適化する

### Requirement 3: アカウント作成・連携
**Objective:** As a 新規ユーザー, I want Apple認証で初めてログインした際に自動でアカウントを作成したい, so that 追加の登録手続きなしにアプリを利用開始できる

#### Acceptance Criteria
1. When 新規ユーザーがApple認証を完了した時, the 認証サービス shall Apple User ID（sub）に紐づく新規アカウントを作成する
2. When Appleからメールアドレスが提供された時, the 認証サービス shall そのメールアドレスをユーザーアカウントに保存する
3. When Appleがメールアドレスを非公開設定（Private Email Relay）で提供した時, the 認証サービス shall そのリレーアドレスを正常に保存・使用する
4. When 既存のApple User IDでログインした時, the 認証サービス shall 新規アカウントを作成せず、既存アカウントで認証する
5. If 同じメールアドレスで別の認証方法のアカウントが存在する場合, then the 認証サービス shall アカウントの重複を防ぎ、適切なエラーメッセージを返す

### Requirement 4: セッション管理
**Objective:** As a 認証済みユーザー, I want ログイン状態が適切に維持されたい, so that 毎回認証し直す必要がない

#### Acceptance Criteria
1. When Apple認証が成功した時, the 認証サービス shall JWTアクセストークンとリフレッシュトークンを発行する
2. The アクセストークン shall 有効期限を持ち、期限切れ後は再認証またはリフレッシュが必要である
3. When ユーザーがログアウトした時, the 認証サービス shall リフレッシュトークンを無効化する
4. The モバイルアプリ shall トークンを安全なストレージ（Keychain）に保存する

### Requirement 5: エラーハンドリングとUX
**Objective:** As a ユーザー, I want 認証エラー時に分かりやすいフィードバックを受けたい, so that 問題を理解し、適切な対処ができる

#### Acceptance Criteria
1. If ネットワークエラーが発生した場合, then the モバイルアプリ shall 「ネットワーク接続を確認してください」というメッセージを表示する
2. If サーバーエラーが発生した場合, then the モバイルアプリ shall 「しばらく時間をおいて再度お試しください」というメッセージを表示する
3. If Apple認証サービスが利用不可の場合, then the モバイルアプリ shall ユーザーに代替の認証方法を案内する
4. While 認証処理中, the モバイルアプリ shall ローディングインジケーターを表示し、重複タップを防止する

### Requirement 6: Apple認証情報の取り消し対応
**Objective:** As a ユーザー, I want Apple設定からVoiceletとの連携を解除できるようにしたい, so that プライバシー管理の主導権を保持できる

#### Acceptance Criteria
1. When ユーザーがApple設定からVoiceletの認証を取り消した時, the 認証サービス shall Appleからのサーバー間通知を受信する
2. When 認証取り消し通知を受信した時, the 認証サービス shall 該当ユーザーの認証セッションを無効化する
3. The 認証サービス shall Apple Server-to-Server Notification用のエンドポイントを提供する
