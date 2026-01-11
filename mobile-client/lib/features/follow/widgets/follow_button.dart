import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
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
  String? _requestId;

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
    final statusMap = ref.watch(userFollowStatusProvider);
    return statusMap[widget.userId] ?? widget.initialStatus;
  }

  Future<void> _onPressed() async {
    if (_isLoading) return;

    // フォロー中の場合は確認ダイアログを表示
    if (_status == FollowStatus.following) {
      final confirmed = await _showUnfollowConfirmDialog();
      if (confirmed != true) return;
    }

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(userFollowStatusProvider.notifier);

      switch (_status) {
        case FollowStatus.none:
          await notifier.follow(widget.userId);
          break;
        case FollowStatus.following:
          await notifier.unfollow(widget.userId);
          break;
        case FollowStatus.requested:
          if (_requestId != null) {
            await notifier.cancelRequest(widget.userId, _requestId!);
          }
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool?> _showUnfollowConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'フォロー解除',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'フォローを解除しますか？',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'キャンセル',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '解除',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final buttonText = _getButtonText();

    if (widget.compact) {
      return SizedBox(
        height: 32,
        child: OutlinedButton(
          onPressed: _isLoading ? null : _onPressed,
          style: buttonStyle.copyWith(
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _getTextColor(),
                  ),
                )
              : Text(buttonText, style: TextStyle(fontSize: 12)),
        ),
      );
    }

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

  Color _getTextColor() {
    switch (_status) {
      case FollowStatus.none:
        return Colors.white;
      case FollowStatus.following:
      case FollowStatus.requested:
        return AppTheme.textSecondary;
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
