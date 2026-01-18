# Requirements Document

## Introduction
本ドキュメントは、Voiceletアプリにおける「自分のストーリー閲覧機能」の要件を定義する。ユーザーが投稿した音声ストーリーを自身で閲覧・管理できる機能を実装し、Instagramストーリーのような体験を提供する。

## Requirements

### Requirement 1: 自分のストーリー一覧表示
**Objective:** As a ユーザー, I want ホーム画面で自分が投稿したストーリーを横並びで確認できる, so that 自分の投稿状況を一目で把握できる

#### Acceptance Criteria
1. When ユーザーがホーム画面を開く, the Voicelet App shall 自分が投稿したストーリーをサムネイル形式で横並びに表示する
2. The Voicelet App shall ストーリーを投稿日時の新しい順に左から右へ並べる
3. When ストーリーが複数存在する, the Voicelet App shall 横スクロールで全てのストーリーにアクセスできるようにする
4. If 自分のストーリーが存在しない, then the Voicelet App shall 空の状態を適切に表示する

### Requirement 2: ストーリー再生機能
**Objective:** As a ユーザー, I want 自分のストーリーを自由にシークして何度でも再生できる, so that 投稿した内容を好きなタイミングで確認できる

#### Acceptance Criteria
1. When ユーザーがストーリーサムネイルをタップする, the Voicelet App shall ストーリー再生画面を全画面で表示する
2. The Voicelet App shall 音声の再生位置を示すシークバーを表示する
3. When ユーザーがシークバーをドラッグする, the Voicelet App shall 再生位置をドラッグした位置に移動させる
4. When ユーザーがシークバー上の任意の位置をタップする, the Voicelet App shall 再生位置をタップした位置に移動させる
5. When 音声再生が終了する, the Voicelet App shall ユーザーが再度再生ボタンを押せる状態で停止する
6. While 音声が再生中, the Voicelet App shall 再生の一時停止と再開を可能にする

### Requirement 3: ストーリー間ナビゲーション
**Objective:** As a ユーザー, I want 再生中に次の自分のストーリーに移動できる, so that 複数のストーリーを連続して確認できる

#### Acceptance Criteria
1. When ユーザーが再生画面の右側エリアをタップする, the Voicelet App shall 次のストーリーの再生を開始する
2. When ユーザーが再生画面の左側エリアをタップする, the Voicelet App shall 前のストーリーの再生を開始する
3. If 最後のストーリー再生中に右側エリアをタップする, then the Voicelet App shall 再生画面を閉じてホーム画面に戻る
4. If 最初のストーリー再生中に左側エリアをタップする, then the Voicelet App shall 現在のストーリーを最初から再生する
5. The Voicelet App shall 現在の再生位置を示すプログレスインジケーターを画面上部に表示する

### Requirement 4: 閲覧者一覧表示
**Objective:** As a ユーザー, I want 自分のストーリーを閲覧した人を確認できる, so that 誰が自分の投稿に興味を持っているか把握できる

#### Acceptance Criteria
1. When ユーザーがストーリー再生画面で上にスワイプする, the Voicelet App shall 閲覧者一覧をボトムシートで表示する
2. The Voicelet App shall 閲覧者のアバター画像とユーザー名を一覧で表示する
3. The Voicelet App shall 閲覧者を閲覧日時の新しい順に並べる
4. The Voicelet App shall 閲覧者の総数を表示する
5. If 閲覧者が存在しない, then the Voicelet App shall 「まだ閲覧者がいません」というメッセージを表示する
6. When 閲覧者のユーザー名またはアバターをタップする, the Voicelet App shall そのユーザーのプロフィール画面に遷移する

### Requirement 5: ストーリー削除機能
**Objective:** As a ユーザー, I want 自分のストーリーを削除できる, so that 不要になった投稿を管理できる

#### Acceptance Criteria
1. When ユーザーがストーリー再生画面でメニューボタンをタップする, the Voicelet App shall 削除オプションを含むメニューを表示する
2. When ユーザーが削除オプションを選択する, the Voicelet App shall 削除確認ダイアログを表示する
3. When ユーザーが削除を確認する, the Voicelet App shall ストーリーをサーバーから削除する
4. When ストーリーの削除が完了する, the Voicelet App shall 再生画面を閉じてホーム画面に戻り、一覧を更新する
5. If ストーリーの削除に失敗する, then the Voicelet App shall エラーメッセージを表示し、ストーリーを保持する
6. While 削除処理中, the Voicelet App shall ローディングインジケーターを表示し、他の操作を無効化する

### Requirement 6: 閲覧記録のバックエンド処理
**Objective:** As a システム, I want ストーリーの閲覧記録を保存できる, so that 閲覧者一覧を正確に表示できる

#### Acceptance Criteria
1. When 他のユーザーがストーリーを再生開始する, the Backend API shall 閲覧記録をデータベースに保存する
2. The Backend API shall 閲覧者ID、ストーリーID、閲覧日時を記録する
3. If 同一ユーザーが同一ストーリーを再度閲覧する, then the Backend API shall 閲覧日時のみを更新し、重複レコードを作成しない
4. When 閲覧者一覧のAPIが呼び出される, the Backend API shall 閲覧日時の降順で閲覧者情報を返却する
5. When ストーリーが削除される, the Backend API shall 関連する閲覧記録も削除する
