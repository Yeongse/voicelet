# Gap Analysis: account-hard-delete

## 1. 現状調査

### 1.1 既存アセット

#### Backend API
| ファイル | 機能 | 備考 |
|---------|------|------|
| `backend/src/controller/profiles/me/controller.ts:288-323` | `DELETE /api/profiles/me` | **既存** - TODOコメント付きでDB削除のみ実装済み |
| `backend/src/services/storage.ts:82-89` | `deleteWhisperFile(fileName)` | Whisper音声ファイル削除 |
| `backend/src/services/storage.ts:182-189` | `deleteAvatarFiles(userId)` | **既存** - ユーザーのアバター一括削除 |
| `backend/src/lib/auth.ts` | Supabase認証 | service_role_keyでクライアント初期化済み |

#### Prisma スキーマ
- 全ての関連テーブルに `onDelete: Cascade` が設定済み
- `prisma.user.delete()` 実行時に以下が自動削除:
  - `whispers`, `follows`, `follow_requests`, `whisper_views`, `reward_ad_usages`, `legal_consents`

#### Mobile Client
| ファイル | 機能 | 備考 |
|---------|------|------|
| `mobile-client/lib/features/home/widgets/profile_drawer.dart:204-210` | 設定メニュー | TODOプレースホルダー |
| `mobile-client/lib/features/auth/providers/auth_provider.dart:273-292` | `signOut()` | ローカル状態クリアのパターン参考 |
| `mobile-client/lib/core/utils/dialogs.dart` | `showDestructiveConfirmDialog()` | 確認ダイアログ既存 |

### 1.2 アーキテクチャパターン

- **Controller-Service-Model**: バックエンドは機能ごとにcontroller配下にルート配置
- **トランザクション**: `prisma.$transaction()` でアトミック操作（`profiles/me/controller.ts:70-96`参考）
- **認証**: `preHandler: [authenticate]` でJWT検証
- **ロギング**: `fastify.log.error()`, `fastify.log.warn()` パターン
- **エラーハンドリング**: Zodスキーマで定義した`errorResponseSchema`を返却

---

## 2. 要件実現性分析

### 2.1 技術ニーズ一覧

| 要件 | 必要な技術 | 現状 |
|------|-----------|------|
| Req 1: API認可 | JWT検証 + 自己削除のみ許可 | **既存** - `authenticate` フック |
| Req 2: DB物理削除 | Prisma cascade delete | **既存** - スキーマ設定済み |
| Req 3: Cloud Storage削除 | GCS client | **部分的** - avatar削除あり、whisper一括削除なし |
| Req 4: Supabase Auth削除 | Admin API | **Missing** - `admin.deleteUser`未実装 |
| Req 5: Mobile UI | Flutter/Riverpod | **Missing** - 設定画面・削除フロー未実装 |
| Req 6: ロギング | pino-pretty | **既存** - パターン確立済み |

### 2.2 ギャップ詳細

#### Missing: Supabase Auth ユーザー削除
- **現状**: `backend/src/lib/auth.ts` にSupabaseクライアント存在するが認証検証のみ
- **必要**: `supabase.auth.admin.deleteUser(userId)` の実装
- **リサーチ必要**: Admin APIの権限確認（service_role_keyで可能か）

#### Missing: Whisper音声ファイル一括削除
- **現状**: `deleteWhisperFile(fileName)` は単一ファイル削除
- **必要**: ユーザーの全Whisperファイルを事前取得→削除
- **実装方針**: DB削除前にwhispersを取得し、各ファイルを削除

#### Missing: 設定画面（Mobile）
- **現状**: profile_drawerに「設定」メニューあるがTODO
- **必要**: 設定画面作成、アカウント削除セクション追加

#### Missing: 削除確認UI（Mobile）
- **現状**: `showDestructiveConfirmDialog()` 存在
- **必要**: 多段確認（説明→キーワード入力→実行）

### 2.3 制約事項

- **Cloud Storageファイル削除順序**: DB削除前にファイルパス情報が必要
- **Supabase Auth削除順序**: DB削除後が望ましい（ロールバック時の整合性）
- **トランザクション境界**: Cloud Storage/Supabase AuthはPrismaトランザクション外

---

## 3. 実装アプローチオプション

### Option A: 既存エンドポイント拡張

**対象**: `backend/src/controller/profiles/me/controller.ts` の `DELETE /api/profiles/me`

**変更内容**:
1. TODOコメント部分を実装
2. 削除処理順序: Whisperファイル取得 → Storage削除 → DB削除 → Supabase Auth削除
3. エラーハンドリング追加

**トレードオフ**:
- ✅ 既存APIパスを維持（後方互換性）
- ✅ 変更ファイル数最小
- ❌ controller.tsが肥大化する可能性

### Option B: 専用サービス層作成

**対象**: 新規 `backend/src/services/account-deletion.ts`

**変更内容**:
1. `AccountDeletionService` クラス作成
2. 削除ロジックをサービスに分離
3. controllerはサービス呼び出しのみ

**トレードオフ**:
- ✅ 責務分離が明確
- ✅ テスト容易性向上
- ❌ ファイル数増加
- ❌ 現状のコードベースにserviceパターンが少ない

### Option C: ハイブリッドアプローチ（推奨）

**変更内容**:
1. `auth.ts` にSupabase Auth削除関数追加（既存パターンに沿う）
2. `storage.ts` にWhisper一括削除関数追加（既存パターンに沿う）
3. `profiles/me/controller.ts` でこれらを呼び出し

**トレードオフ**:
- ✅ 既存パターンに沿った最小限の拡張
- ✅ 各モジュールの責務を維持
- ✅ 再利用可能な関数を追加
- ❌ 複数ファイルへの変更

---

## 4. 実装見積もり

### 工数: M（3-5日）

**内訳**:
- Backend API拡張: 1日
  - auth.ts: Supabase Admin API追加
  - storage.ts: Whisper一括削除追加
  - controller.ts: 統合・エラーハンドリング
- Mobile設定画面: 1.5日
  - 設定画面作成
  - アカウント削除フロー実装
- テスト・調整: 1日
- 全体統合・動作確認: 0.5日

### リスク: Medium

**理由**:
- Supabase Admin APIは既知の技術だが、このプロジェクトでは未使用
- Cloud Storage一括削除のパフォーマンス（多数ファイル時）
- 削除処理の部分失敗時のリカバリー戦略

---

## 5. 設計フェーズへの推奨事項

### 推奨アプローチ: Option C（ハイブリッド）

### 設計フェーズで決定すべき事項

1. **削除処理の部分失敗ポリシー**
   - Cloud Storage削除失敗時: 続行 or 中断？
   - Supabase Auth削除失敗時: ログのみ or リトライ？

2. **確認UIフロー詳細**
   - キーワード入力: 「削除」固定 or ユーザー名入力？
   - 削除前の情報表示内容

3. **同時リクエスト制御**
   - 削除処理中の他APIブロック方法（楽観的ロック or 分散ロック？）

### リサーチ項目

- [ ] Supabase Admin API `deleteUser` の権限要件確認
- [ ] GCS prefix削除のパフォーマンス特性（大量ファイル時）

