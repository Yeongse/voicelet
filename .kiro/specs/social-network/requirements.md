# Requirements Document

## Introduction
本ドキュメントはVoiceletにおけるソーシャルネットワーク機能（フォロー・フォロワー・鍵垢・フォローリクエスト）の要件を定義する。通知機能は本スコープに含まない。

## Requirements

### Requirement 1: フォロー機能
**Objective:** As a ユーザー, I want 他のユーザーをフォローする, so that そのユーザーの投稿をフィードで閲覧できる

#### Acceptance Criteria
1. When ユーザーがフォローボタンをタップした, the Follow Service shall 対象ユーザーへのフォロー関係を作成する
2. When フォローが成功した, the Mobile App shall フォローボタンをフォロー済み状態に更新する
3. When 既にフォロー済みのユーザーに対してフォロー解除ボタンをタップした, the Follow Service shall フォロー関係を削除する
4. The Follow Service shall 自分自身へのフォローを拒否する
5. If フォロー作成に失敗した, the Mobile App shall エラーメッセージを表示する

### Requirement 2: フォロワー・フォロー一覧表示
**Objective:** As a ユーザー, I want 自分や他のユーザーのフォロー・フォロワー一覧を閲覧する, so that ソーシャルグラフを把握できる

#### Acceptance Criteria
1. When ユーザープロフィールのフォロー数をタップした, the Mobile App shall フォロー中のユーザー一覧を表示する
2. When ユーザープロフィールのフォロワー数をタップした, the Mobile App shall フォロワーのユーザー一覧を表示する
3. The Follow API shall フォロー・フォロワー一覧をページネーション付きで返却する
4. While 鍵垢ユーザーのプロフィールを閲覧している and フォロワーではない, the Mobile App shall フォロー・フォロワー一覧を非表示にする

### Requirement 3: 鍵垢（非公開アカウント）
**Objective:** As a ユーザー, I want アカウントを非公開に設定する, so that 承認したフォロワーのみに投稿を公開できる

#### Acceptance Criteria
1. When ユーザーがアカウント設定で非公開をオンにした, the User Service shall アカウントを鍵垢状態に更新する
2. When 鍵垢ユーザーがフォローリクエストを受けた, the Follow Service shall 即座にフォロー関係を作成せずリクエストとして保留する
3. While アカウントが非公開である, the User API shall 非フォロワーへの投稿一覧を空で返却する
4. When 非公開を解除した, the User Service shall アカウントを公開状態に更新する
5. The Mobile App shall 鍵垢ユーザーのプロフィールに鍵アイコンを表示する

### Requirement 4: フォローリクエスト送信
**Objective:** As a ユーザー, I want 鍵垢ユーザーにフォローリクエストを送信する, so that 承認されればそのユーザーをフォローできる

#### Acceptance Criteria
1. When 鍵垢ユーザーへのフォローボタンをタップした, the Follow Service shall フォローリクエストを作成する
2. When フォローリクエストが送信された, the Mobile App shall ボタンをリクエスト送信済み状態に更新する
3. When リクエスト送信済みのボタンをタップした, the Follow Service shall フォローリクエストを取り消す
4. The Follow Service shall 同一ユーザーへの重複リクエストを拒否する
5. If フォローリクエスト作成に失敗した, the Mobile App shall エラーメッセージを表示する

### Requirement 5: フォローリクエスト管理
**Objective:** As a 鍵垢ユーザー, I want 受信したフォローリクエストを管理する, so that フォロワーを選択的に承認できる

#### Acceptance Criteria
1. When フォローリクエスト一覧画面を開いた, the Follow API shall 保留中のフォローリクエスト一覧を返却する
2. When フォローリクエストを承認した, the Follow Service shall リクエストを削除しフォロー関係を作成する
3. When フォローリクエストを拒否した, the Follow Service shall リクエストを削除する
4. The Mobile App shall 各リクエストに対して承認・拒否ボタンを表示する
5. While 保留中のフォローリクエストが存在する, the Mobile App shall リクエスト一覧へのバッジを表示する

### Requirement 6: フォロワー削除
**Objective:** As a ユーザー, I want 特定のフォロワーを削除する, so that 望まないフォロワーからの閲覧を防げる

#### Acceptance Criteria
1. When フォロワー削除ボタンをタップした, the Follow Service shall 対象ユーザーからのフォロー関係を削除する
2. When フォロワー削除が成功した, the Mobile App shall 確認メッセージを表示し一覧を更新する
3. The Mobile App shall フォロワー削除前に確認ダイアログを表示する
4. If フォロワー削除に失敗した, the Mobile App shall エラーメッセージを表示する
