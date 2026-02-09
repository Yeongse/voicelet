import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/account_deletion_provider.dart';

/// アカウント削除確認ダイアログ
class DeleteAccountDialog extends ConsumerStatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  ConsumerState<DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  final _textController = TextEditingController();
  bool _isConfirmEnabled = false;

  static const _confirmKeyword = '削除';

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    // ダイアログを開いた時に状態をリセット
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(accountDeletionProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final isEnabled = _textController.text.trim() == _confirmKeyword;
    if (isEnabled != _isConfirmEnabled) {
      setState(() {
        _isConfirmEnabled = isEnabled;
      });
    }
  }

  Future<void> _handleDelete() async {
    if (!_isConfirmEnabled) return;

    await ref.read(accountDeletionProvider.notifier).deleteAccount();
  }

  @override
  Widget build(BuildContext context) {
    final deletionState = ref.watch(accountDeletionProvider);

    // 削除成功時はトップ画面へ強制遷移
    ref.listen<AccountDeletionState>(accountDeletionProvider, (previous, next) {
      if (next is AccountDeletionSuccess) {
        // すべてのオーバーレイ（モーダル、ダイアログ）を閉じてからトップ画面へ遷移
        // rootNavigator: true でルートナビゲーターを取得し、すべてのルートをpop
        Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
        // go()でナビゲーションスタックを完全に置き換え
        if (context.mounted) {
          context.go('/');
        }
      }
    });

    final isLoading = deletionState is AccountDeletionLoading;
    final errorMessage =
        deletionState is AccountDeletionError ? deletionState.message : null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ハンドルバー
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textTertiary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // タイトル
              Row(
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_triangle_fill,
                    color: AppTheme.error,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'アカウントを削除',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 警告メッセージ
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.error.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'この操作は取り消せません',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '以下のデータがすべて完全に削除されます：',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildBulletPoint('プロフィール情報'),
                    _buildBulletPoint('投稿したストーリー'),
                    _buildBulletPoint('フォロー・フォロワー情報'),
                    _buildBulletPoint('視聴履歴'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 確認入力
              Text(
                '削除を確認するには「$_confirmKeyword」と入力してください',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              CupertinoTextField(
                controller: _textController,
                enabled: !isLoading,
                placeholder: _confirmKeyword,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bgTertiary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isConfirmEnabled
                        ? AppTheme.error
                        : AppTheme.textTertiary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
                placeholderStyle: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textTertiary,
                ),
              ),

              // エラーメッセージ
              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // ボタン
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      color: AppTheme.bgTertiary,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: isLoading ? null : () => Navigator.pop(context),
                      child: Text(
                        'キャンセル',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      color: _isConfirmEnabled && !isLoading
                          ? AppTheme.error
                          : AppTheme.error.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      onPressed:
                          _isConfirmEnabled && !isLoading ? _handleDelete : null,
                      child: isLoading
                          ? const CupertinoActivityIndicator(color: Colors.white)
                          : const Text(
                              '削除する',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
