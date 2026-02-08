# Requirements Document

## Introduction

本ドキュメントは、VoiceletアプリにおけるQRコードを使ったフォロー機能の要件を定義する。ユーザーは自分のプロフィールに紐づいたQRコードを表示し、他のユーザーがそれをスキャンすることで対象ユーザーのプロフィール画面に遷移できる。プロフィール画面からは既存のフォロー/フォローリクエスト機能を利用する。対面でのユーザー交換を簡単かつ迅速に行えるようにすることが目的である。

## Requirements

### Requirement 1: QRコード生成・表示

**Objective:** As a ユーザー, I want 自分のプロフィールに紐づいたQRコードを表示したい, so that 他のユーザーが簡単に自分のプロフィールにアクセスできる

#### Acceptance Criteria
1. When ユーザーがQRコード表示画面を開く, the モバイルアプリ shall ユーザー固有のQRコードを画面中央に表示する
2. The QRコード shall ユーザーを一意に識別できる情報（userId）を含む
3. When QRコード表示画面が表示される, the モバイルアプリ shall ユーザーのプロフィール情報（アバター、名前、ユーザー名）をQRコードと共に表示する
4. The QRコード shall オフライン状態でも表示可能である

### Requirement 2: QRコードスキャン

**Objective:** As a ユーザー, I want 他のユーザーのQRコードをスキャンしたい, so that 素早くそのユーザーのプロフィールにアクセスできる

#### Acceptance Criteria
1. When ユーザーがQRスキャン画面を開く, the モバイルアプリ shall カメラを起動しQRコードスキャンモードを開始する
2. When 有効なVoiceletユーザーのQRコードをスキャンする, the モバイルアプリ shall スキャンしたユーザーのプロフィール画面に遷移する
3. If カメラへのアクセス権限がない場合, the モバイルアプリ shall 権限リクエストダイアログを表示する
4. If 無効なQRコードをスキャンした場合, the モバイルアプリ shall エラーメッセージを表示し再スキャンを促す
5. If 存在しないユーザーのQRコードをスキャンした場合, the モバイルアプリ shall 「ユーザーが見つかりません」というメッセージを表示する
6. If 自分自身のQRコードをスキャンした場合, the モバイルアプリ shall 自分のプロフィール画面に遷移する

### Requirement 3: UI/UXとナビゲーション

**Objective:** As a ユーザー, I want QRコード機能に簡単にアクセスしたい, so that 必要なときにすぐ使える

#### Acceptance Criteria
1. The モバイルアプリ shall プロフィール画面からQRコード機能へのエントリーポイントを提供する
2. When QRコード画面を開く, the モバイルアプリ shall 「自分のQRコード表示」と「スキャン」の切り替えタブを表示する
3. The QRコード画面 shall 戻るボタンで前の画面に戻れる

### Requirement 4: エラーハンドリングとオフライン対応

**Objective:** As a ユーザー, I want エラー発生時に適切なフィードバックを受けたい, so that 何が起きたか理解し対処できる

#### Acceptance Criteria
1. If ネットワークエラーが発生した場合, the モバイルアプリ shall ネットワーク接続を確認するようメッセージを表示する
2. While オフライン状態の場合, the モバイルアプリ shall 自分のQRコード表示は可能だがスキャン後のプロフィール遷移は利用不可であることを示す
