# Requirements Document

## Introduction
本ドキュメントは、VoiceletアプリケーションにおけるユーザープロフィールのCRUD機能に関する要件を定義する。Supabase Authによる認証基盤の上で、ユーザーの初期登録、プロフィール情報の管理、およびCloud Storageを利用したアバター画像の署名付きURLによるアップロード・ダウンロード機能を実現する。

## Requirements

### Requirement 1: ユーザー認証（Supabase Auth連携）
**Objective:** As a ユーザー, I want Supabase Authを使ってアカウントを作成・ログインしたい, so that 安全にアプリを利用できる

#### Acceptance Criteria
1. When ユーザーがメールアドレスとパスワードで新規登録を行う, the Profile Service shall Supabase Authにユーザーを作成し、アプリ内にプロフィールレコードを自動生成する
2. When ユーザーがログインに成功する, the Profile Service shall JWTトークンを発行し、認証済みセッションを開始する
3. When ユーザーがログアウトを要求する, the Profile Service shall セッションを無効化し、トークンを破棄する
4. If 無効な認証情報が入力された場合, then the Profile Service shall エラーメッセージを表示し、ログインを拒否する
5. If 既に登録済みのメールアドレスで新規登録を試みた場合, then the Profile Service shall 重複エラーを返す

### Requirement 2: プロフィール作成（Create）
**Objective:** As a 認証済みユーザー, I want 初回ログイン時にプロフィールを作成したい, so that 他のユーザーに自分を識別してもらえる

#### Acceptance Criteria
1. When ユーザーがSupabase Authで初回認証に成功する, the Profile Service shall ユーザーIDに紐づく空のプロフィールレコードを自動作成する
2. When ユーザーがプロフィール情報（表示名、自己紹介、生年月）を入力して保存する, the Profile Service shall データベースにプロフィール情報を保存する
3. The Profile Service shall プロフィール作成時に、ユーザーIDの一意性を検証する
4. The Profile Service shall 生年月を年と月の形式（YYYY-MM）で保存する
5. If プロフィール作成が失敗した場合, then the Profile Service shall エラー内容をユーザーに通知し、再試行を促す

### Requirement 3: プロフィール参照（Read）
**Objective:** As a ユーザー, I want 自分や他のユーザーのプロフィールを閲覧したい, so that ユーザー情報を確認できる

#### Acceptance Criteria
1. When ユーザーが自分のプロフィール画面を開く, the Profile Service shall 現在ログイン中のユーザーのプロフィール情報を表示する
2. When ユーザーが他のユーザーのプロフィールを閲覧する, the Profile Service shall 対象ユーザーの公開プロフィール情報を表示する
3. The Profile Service shall プロフィール情報に表示名、自己紹介、アバター画像、年齢を含める
4. When プロフィールを表示する, the Profile Service shall 生年月から現在の年齢を計算して返す
5. The Mobile Client shall プロフィール参照画面では生年月ではなく計算された年齢を表示する
6. If 指定されたユーザーのプロフィールが存在しない場合, then the Profile Service shall 404エラーを返す

### Requirement 4: プロフィール更新（Update）
**Objective:** As a 認証済みユーザー, I want プロフィール情報を編集・更新したい, so that 最新の情報を反映できる

#### Acceptance Criteria
1. When ユーザーがプロフィール編集画面で情報を変更して保存する, the Profile Service shall 変更内容をデータベースに反映する
2. While ユーザーがプロフィール編集中, the Profile Service shall 現在の値をフォームに表示する
3. The Mobile Client shall プロフィール編集画面では生年月を直接入力できるフォームを表示する
4. The Profile Service shall 自分以外のプロフィールの編集を禁止する
5. If 不正なデータが送信された場合, then the Profile Service shall バリデーションエラーを返す

### Requirement 5: プロフィール削除（Delete）
**Objective:** As a 認証済みユーザー, I want アカウントを削除したい, so that サービスの利用を完全に停止できる

#### Acceptance Criteria
1. When ユーザーがアカウント削除を要求する, the Profile Service shall 確認ダイアログを表示する
2. When ユーザーが削除を確定する, the Profile Service shall プロフィールレコードおよびSupabase Authアカウントを削除する
3. When アカウント削除が完了する, the Profile Service shall 関連するアバター画像をCloud Storageから削除する
4. The Profile Service shall 自分以外のアカウントの削除を禁止する

### Requirement 6: アバター画像アップロード
**Objective:** As a 認証済みユーザー, I want プロフィール画像をアップロードしたい, so that 自分のアイデンティティを視覚的に表現できる

#### Acceptance Criteria
1. When ユーザーがアバター画像をアップロードする, the Profile Service shall Cloud Storage用の署名付きアップロードURLを生成する
2. When 署名付きURLが生成される, the Mobile Client shall そのURLを使用してCloud Storageに直接画像をアップロードする
3. When アップロードが完了する, the Profile Service shall 画像のパスをプロフィールレコードに保存する
4. The Profile Service shall アップロード可能なファイル形式をJPEG、PNG、WebPに制限する
5. The Profile Service shall アップロード可能なファイルサイズを5MB以下に制限する
6. If ファイル形式またはサイズが制限を超える場合, then the Profile Service shall エラーを返しアップロードを拒否する

### Requirement 7: アバター画像ダウンロード（表示）
**Objective:** As a ユーザー, I want プロフィールのアバター画像を表示したい, so that ユーザーを視覚的に識別できる

#### Acceptance Criteria
1. When プロフィール画面を表示する, the Profile Service shall アバター画像の署名付きダウンロードURLを生成する
2. When 署名付きダウンロードURLが取得できる, the Mobile Client shall そのURLを使用してCloud Storageから画像を取得・表示する
3. The Profile Service shall 署名付きURLに適切な有効期限（1時間以内）を設定する
4. If アバター画像が設定されていない場合, the Mobile Client shall デフォルトのプレースホルダー画像を表示する
5. If 署名付きURLが期限切れの場合, the Profile Service shall 新しい署名付きURLを再生成する

### Requirement 8: セキュリティ要件
**Objective:** As a システム管理者, I want プロフィール機能が安全に動作することを保証したい, so that ユーザーデータを保護できる

#### Acceptance Criteria
1. The Profile Service shall すべてのAPIエンドポイントでJWT認証を検証する
2. The Profile Service shall 自分以外のプロフィールへの書き込み操作を拒否する
3. The Profile Service shall 署名付きURLを特定ユーザーのファイルのみにアクセス可能なように生成する
4. The Profile Service shall すべての入力データに対してバリデーションを実行する
5. The Profile Service shall SQLインジェクション、XSSなどの攻撃を防止する

### Requirement 9: 生年月と年齢計算
**Objective:** As a ユーザー, I want 生年月を登録して年齢として表示したい, so that 個人情報を最小限に抑えつつ年齢を公開できる

#### Acceptance Criteria
1. The Profile Service shall 生年月をYYYY-MM形式でデータベースに保存する
2. When プロフィール情報をAPIから返却する, the Profile Service shall 生年月から現在日時を基に年齢を計算して含める
3. The Profile Service shall 年齢計算において、現在の月が生年月より前の場合は1歳引いた値を返す
4. The Mobile Client shall プロフィール編集画面でのみ生年月入力フィールド（年・月セレクター）を表示する
5. The Mobile Client shall プロフィール表示画面では生年月を表示せず、計算された年齢のみを表示する
6. If 生年月が未設定の場合, the Profile Service shall 年齢をnullとして返す
