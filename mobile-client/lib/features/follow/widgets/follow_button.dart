import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dialogs.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/follow_models.dart';
import '../providers/follow_provider.dart';

class FollowButton extends ConsumerStatefulWidget {
  final String userId;
  final FollowStatus initialStatus;
  final bool isPrivate;
  final bool compact;

  const FollowButton({
    super.key,
    required this.userId,
    required this.initialStatus,
    this.isPrivate = false,
    this.compact = false,
  });

  @override
  ConsumerState<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends ConsumerState<FollowButton> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 初期状態を設定
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userFollowStatusProvider.notifier).setStatus(
            widget.userId,
            widget.initialStatus,
          );
    });
  }

  FollowStatus get _status {
    final stateMap = ref.watch(userFollowStatusProvider);
    return stateMap[widget.userId]?.status ?? widget.initialStatus;
  }

  Future<void> _onPressed() async {
    if (_isLoading) return;

    // フォロー中の場合は確認ダイアログを表示
    if (_status == FollowStatus.following) {
      final confirmed = await _showUnfollowConfirmDialog();
      if (confirmed != true) return;
    }

    // リクエスト取消の場合も確認ダイアログを表示
    if (_status == FollowStatus.requested) {
      final confirmed = await _showCancelRequestConfirmDialog();
      if (confirmed != true) return;
    }

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(userFollowStatusProvider.notifier);

      final currentUserId = ref.read(currentUserIdProvider);

      switch (_status) {
        case FollowStatus.none:
          await notifier.follow(widget.userId);
          break;
        case FollowStatus.following:
          await notifier.unfollow(widget.userId, currentUserId: currentUserId);
          break;
        case FollowStatus.requested:
          await notifier.cancelRequest(widget.userId);
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '操作に失敗しました: $e',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            backgroundColor: AppTheme.bgElevated,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _showUnfollowConfirmDialog() {
    return showDestructiveConfirmDialog(
      context: context,
      message: 'フォローを解除しますか？',
      destructiveText: 'フォロー解除',
    );
  }

  Future<bool> _showCancelRequestConfirmDialog() {
    return showDestructiveConfirmDialog(
      context: context,
      message: 'フォローリクエストを取り消しますか？',
      destructiveText: 'リクエスト取消',
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonText = _getButtonText();

    if (widget.compact) {
      // コンパクトモード: 状態に応じて異なるボタンスタイル
      if (_status == FollowStatus.none) {
        // 未フォロー: 塗りつぶしボタン（目立つように）
        return SizedBox(
          height: 32,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(buttonText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        );
      } else {
        // フォロー中/リクエスト済み: アウトラインボタン
        return SizedBox(
          height: 32,
          child: OutlinedButton(
            onPressed: _isLoading ? null : _onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              side: BorderSide(color: AppTheme.textTertiary.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.textSecondary,
                    ),
                  )
                : Text(buttonText, style: const TextStyle(fontSize: 12)),
          ),
        );
      }
    }

    final buttonStyle = _getButtonStyle();

    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onPressed,
        style: buttonStyle,
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(buttonText),
      ),
    );
  }

  String _getButtonText() {
    switch (_status) {
      case FollowStatus.none:
        return widget.isPrivate ? 'リクエスト' : 'フォロー';
      case FollowStatus.following:
        return 'フォロー中';
      case FollowStatus.requested:
        return 'リクエスト済み';
    }
  }

  ButtonStyle _getButtonStyle() {
    switch (_status) {
      case FollowStatus.none:
        return ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case FollowStatus.following:
      case FollowStatus.requested:
        return OutlinedButton.styleFrom(
          foregroundColor: AppTheme.textSecondary,
          side: BorderSide(color: AppTheme.textTertiary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
    }
  }
}
