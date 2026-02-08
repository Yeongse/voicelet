# Requirements Document

## Introduction
本仕様は、Voiceletアプリケーションへの広告機能（AdMob）の導入を定義する。他のユーザーの投稿を閲覧する画面へのバナー広告と、視聴履歴をリセットできるリワード広告の2種類を実装する。リワード広告は1日3回までの制限があり、午前5時（JST）にリセットされる。

## Requirements

### Requirement 1: バナー広告表示
**Objective:** ユーザーとして、投稿閲覧画面でバナー広告を見ることで、アプリを無料で利用し続けられる

#### Acceptance Criteria
1. When ユーザーが他のユーザーの投稿を閲覧する画面を開く, the Voicelet App shall 画面下部にAdMobバナー広告を表示する
2. While バナー広告が読み込み中, the Voicelet App shall 広告領域のサイズを維持してレイアウトのずれを防止する
3. If バナー広告の読み込みに失敗した場合, the Voicelet App shall 広告領域を非表示にしてコンテンツ領域を拡大する
4. The Voicelet App shall バナー広告がコンテンツの視聴体験を妨げない位置に配置する

### Requirement 2: リワード広告表示
**Objective:** ユーザーとして、リワード広告を視聴することで、その日の視聴履歴をクリアして投稿を再視聴できる

#### Acceptance Criteria
1. When ユーザーがリワード広告視聴ボタンをタップする, the Voicelet App shall AdMobリワード広告をフルスクリーンで表示する
2. When ユーザーがリワード広告を最後まで視聴完了する, the Voicelet App shall その日に視聴したすべての投稿の視聴履歴をクリアする
3. If リワード広告の読み込みに失敗した場合, the Voicelet App shall エラーメッセージを表示して再試行を促す
4. If ユーザーがリワード広告を途中でスキップまたは閉じた場合, the Voicelet App shall 視聴履歴のクリアを実行しない
5. While リワード広告が読み込み中, the Voicelet App shall ローディングインジケーターを表示する

### Requirement 3: リワード広告の使用回数制限
**Objective:** サービス運営者として、リワード広告の使用回数を1日3回に制限することで、広告収益と視聴履歴機能のバランスを維持する

#### Acceptance Criteria
1. The Voicelet App shall リワード広告の使用回数を1日あたり3回までに制限する
2. When ユーザーが本日3回目のリワード広告視聴を完了する, the Voicelet App shall リワード広告視聴ボタンを無効化して残り回数0を表示する
3. When 午前5時（JST）を過ぎた後にユーザーがアプリを使用する, the Voicelet App shall リワード広告の使用回数をリセットして3回に戻す
4. The Voicelet App shall リワード広告の残り使用可能回数をユーザーに表示する
5. While リワード広告の残り回数が0回, the Voicelet App shall リワード広告視聴ボタンを無効状態で表示し、次のリセット時刻を表示する

### Requirement 4: 視聴履歴クリアの対象範囲
**Objective:** ユーザーとして、その日に視聴した投稿のみをクリア対象とすることで、意図しない過去の視聴履歴が消えることを防ぐ

#### Acceptance Criteria
1. When リワード広告視聴が完了する, the Backend Server shall 当日（午前5時以降）に視聴した投稿の視聴履歴のみを削除する
2. The Backend Server shall 前日以前の視聴履歴はクリア対象に含めない
3. When 視聴履歴がクリアされる, the Voicelet App shall クリアされた件数をユーザーに通知する
4. If 当日の視聴履歴が存在しない場合, the Voicelet App shall クリアする履歴がない旨をユーザーに表示する

### Requirement 5: AdMob SDK統合
**Objective:** 開発者として、AdMob SDKを適切に統合することで、広告の配信と収益化を実現する

#### Acceptance Criteria
1. The Voicelet App shall Google Mobile Ads SDK（AdMob）を使用して広告を表示する
2. The Voicelet App shall 本番環境では本番用広告ユニットIDを、開発環境ではテスト用広告IDを使用する
3. The Voicelet App shall アプリ起動時にAdMob SDKを初期化する
4. The Voicelet App shall GDPRおよびATT（App Tracking Transparency）の同意管理に対応する
