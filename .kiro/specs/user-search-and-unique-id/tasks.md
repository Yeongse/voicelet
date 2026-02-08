# Implementation Plan

## Task 1: データベーススキーマにusernameフィールドを追加
- [x] 1.1 Userモデルにusernameフィールドを追加するマイグレーションを作成
  - Prismaスキーマに`username`フィールドを追加（nullable、unique制約付き）
  - 30文字以下のVARCHAR型で定義
  - case-insensitiveなユニークインデックスを追加
  - マイグレーションを実行してスキーマを適用
  - _Requirements: 2.1, 2.2_

## Task 2: バックエンドAPIの実装

- [x] 2.1 username使用可否チェックAPIを実装
  - 新規`/api/usernames`コントローラーを作成
  - `GET /api/usernames/check`エンドポイントを実装
  - username形式のバリデーション（3-30文字、半角英数字・アンダースコア・ピリオドのみ）
  - データベースで重複チェックを行い、使用可否を返却
  - Zodスキーマでリクエスト・レスポンスを定義
  - _Requirements: 2.3, 2.5, 2.6_

- [x] 2.2 (P) プロフィールAPIにusernameフィールドを追加
  - プロフィール登録（POST）でusername必須化
  - プロフィール更新（PATCH）でusername変更を許可
  - @自動除去のtransformを追加
  - 一意性違反時は409エラーを返却
  - レスポンススキーマにusernameを追加
  - _Requirements: 2.5, 2.6, 2.7, 2.9, 3.2, 3.4_

- [x] 2.3 (P) ユーザー検索APIを実装
  - 新規`/api/search`コントローラーを作成
  - `GET /api/search/users`エンドポイントを実装
  - 表示名とusernameに対する部分一致検索（ILIKE）
  - 2文字以上のクエリを必須とするバリデーション
  - 鍵アカウントも検索結果に含める
  - 既存のページネーションユーティリティを使用
  - _Requirements: 1.2, 1.7, 4.5_

- [x] 2.4 (P) おすすめフィードAPIから鍵アカウントを除外
  - DiscoverControllerのクエリに`isPrivate: false`条件を追加
  - おすすめユーザーリストからも鍵アカウントを除外
  - 既存のテストを更新して鍵アカウント除外を検証
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

## Task 3: モバイルクライアントのモデルとプロバイダー実装

- [x] 3.1 検索機能のモデルとAPIサービスを作成
  - 新規`search`フィーチャーディレクトリを作成
  - SearchUserモデルをFreezedで定義（id, username, name, avatarUrl, isPrivate）
  - 検索APIを呼び出すサービスクラスを実装
  - ページネーション対応のレスポンスモデルを作成
  - _Requirements: 1.2, 1.3_

- [x] 3.2 検索用Riverpodプロバイダーを実装
  - クエリ文字列を受け取る検索プロバイダーを作成
  - 2文字未満の場合は空結果を返す
  - debounce処理でAPI呼び出しを最適化
  - ローディング状態とエラー状態を管理
  - _Requirements: 1.2, 1.6_

- [x] 3.3 (P) Profileモデルにusernameフィールドを追加
  - 既存のProfileモデルにusernameフィールドを追加
  - プロフィールAPIサービスのレスポンス処理を更新
  - コード生成（build_runner）を実行
  - _Requirements: 2.1, 2.8_

- [x] 3.4 (P) username使用可否チェックプロバイダーを実装
  - usernameチェックAPIを呼び出すプロバイダーを作成
  - debounce処理で入力中の連続呼び出しを防止
  - 使用可否の状態を管理（available/unavailable/checking）
  - _Requirements: 2.3_

## Task 4: モバイルクライアントのUI実装

- [x] 4.1 検索画面を実装
  - 検索入力フィールドを持つSearchPageを作成
  - テキスト入力時に検索プロバイダーを呼び出し
  - 検索結果をリスト表示（アバター、表示名、username）
  - ローディングインジケーターを表示
  - 0件時のメッセージを表示
  - _Requirements: 1.1, 1.3, 1.5, 1.6_

- [x] 4.2 検索結果からプロフィール画面への遷移を実装
  - 検索結果のユーザーをタップで選択可能に
  - go_routerでユーザープロフィール画面に遷移
  - ルーティング設定に`/search`を追加
  - _Requirements: 1.4_

- [x] 4.3 ホーム画面に検索アイコンを追加
  - ヘッダーに検索アイコンボタンを配置
  - タップで検索画面に遷移
  - _Requirements: 1.1_

- [x] 4.4 (P) プロフィール編集画面にusernameフィールドを追加
  - username入力フィールドを追加
  - 現在のusernameを初期値として表示
  - 入力時にリアルタイムで使用可否をチェック
  - 使用可能時は緑チェック、使用不可時はエラーメッセージを表示
  - @入力時は自動的に除去
  - _Requirements: 2.3, 2.4, 2.7, 3.1, 3.3_

- [x] 4.5 (P) プロフィール画面にusernameを表示
  - 表示名の下に@username形式で表示
  - usernameタップでクリップボードにコピー
  - 自分のプロフィールでは目立つ位置に表示
  - _Requirements: 2.8, 5.1, 5.3, 5.4_

- [x] 4.6 (P) ユーザーカード（リスト表示）にusernameを追加
  - UserListTileに表示名とusernameの両方を表示
  - 検索結果カードにも同様に表示
  - _Requirements: 5.2_

## Task 5: 統合とテスト

- [x] 5.1 バックエンドAPIの統合テスト
  - ユーザー検索APIのテスト（部分一致、ページネーション）
  - username重複チェックAPIのテスト
  - プロフィール更新でのusername一意性テスト
  - おすすめフィードの鍵アカウント除外テスト
  - _Requirements: 1.2, 1.7, 2.2, 2.3, 4.1, 4.5_

- [x] 5.2 新規ユーザー登録フローの確認
  - オンボーディング画面でのusername設定を確認
  - username未設定での登録が拒否されることを確認
  - _Requirements: 2.9_

- [x] 5.3 エンドツーエンドの動作確認
  - 検索画面表示・入力・結果表示の動作確認
  - 検索結果からプロフィール遷移の確認
  - username編集・リアルタイムチェック・保存の確認
  - _Requirements: 1.1, 1.3, 1.4, 3.1, 3.2, 3.3_
