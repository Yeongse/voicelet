# Requirements Document

## Introduction
他人の投稿を視聴する際に3つの制約を付与する機能。これにより、投稿の有効期限管理、視聴行為の不可逆性、視聴履歴による再視聴制限を実現する。Voiceletの音声コンテンツの希少性と一期一会の体験価値を高める。

## Requirements

### Requirement 1: 有効期限による投稿フィルタリング
**Objective:** As a ユーザー, I want 有効期限が切れた投稿を見えなくしてほしい, so that 有効な投稿のみを視聴できる

#### Acceptance Criteria
1. When ユーザーが他人の投稿一覧を取得した時, the 投稿取得API shall expiresAtが現在時刻より未来の投稿のみを返却する
2. When expiresAtが現在時刻を過ぎている投稿が存在する時, the 投稿取得API shall その投稿を一覧から除外する
3. The 投稿取得API shall 投稿のフィルタリングをサーバーサイドで実行する

### Requirement 2: 再生制御と視聴記録の即時永続化
**Objective:** As a ユーザー, I want 再生を開始したら途中で止められず、その瞬間に視聴が記録されてほしい, so that 投稿を真剣に視聴する意思決定ができる

#### Acceptance Criteria
1. When ユーザーが投稿の再生を開始した時, the モバイルクライアント shall 再生を一時停止・停止できないようにする
2. When ユーザーが投稿の再生を開始した時, the モバイルクライアント shall 即座に視聴記録APIを呼び出す
3. When 視聴記録APIが呼び出された時, the 視聴記録API shall ユーザーIDと投稿IDの組み合わせをデータベースに永続化する
4. If 視聴記録APIの呼び出しが失敗した時, the モバイルクライアント shall 再生を中断してエラーを表示する
5. While 音声が再生中の時, the モバイルクライアント shall シークバー操作を無効化する

### Requirement 3: 視聴済み投稿の再視聴制限
**Objective:** As a ユーザー, I want 一度視聴した投稿を再度視聴できないようにしてほしい, so that 投稿の一回性・希少性が担保される

#### Acceptance Criteria
1. When ユーザーが他人の投稿一覧を取得した時, the 投稿取得API shall 視聴記録が存在する投稿を一覧から除外する
2. The 視聴記録 shall ユーザーがログアウト・再インストールしても保持される（サーバー側永続化）
3. When 視聴記録が存在する投稿の再生が試行された時, the モバイルクライアント shall 再生を開始せずに視聴済みである旨を表示する

### Requirement 4: 視聴記録データモデル
**Objective:** As a システム, I want 視聴記録を適切に管理したい, so that 視聴制約が正しく機能する

#### Acceptance Criteria
1. The 視聴記録 shall ユーザーID、投稿ID、視聴日時を含む
2. The 視聴記録 shall ユーザーIDと投稿IDの組み合わせで一意である
3. When 同一ユーザーが同一投稿を再度視聴記録しようとした時, the 視聴記録API shall 重複を許可せずエラーを返却する
