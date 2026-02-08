import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../home/providers/home_providers.dart';
import '../providers/ad_provider.dart';

/// リワード広告ボタンウィジェット
///
/// - 残り回数を表示
/// - 読み込み中はローディング表示
/// - 残り回数0で無効化
/// - 視聴完了後にクリア件数を通知
class RewardAdButton extends ConsumerStatefulWidget {
  /// 完了時のコールバック（クリア件数を通知）
  final void Function(int clearedCount)? onCompleted;

  const RewardAdButton({
    super.key,
    this.onCompleted,
  });

  @override
  ConsumerState<RewardAdButton> createState() => _RewardAdButtonState();
}

class _RewardAdButtonState extends ConsumerState<RewardAdButton> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // 初回ステータス取得
    Future.microtask(() {
      ref.read(rewardAdStatusProvider.notifier).fetchStatus();
    });
  }

  Future<void> _handleTap() async {
    if (_isProcessing) return;

    final adService = ref.read(adServiceProvider);
    final statusNotifier = ref.read(rewardAdStatusProvider.notifier);

    // 広告がロードされていなければプリロードを待つ
    if (!adService.isRewardedAdReady) {
      setState(() => _isProcessing = true);
      await adService.preloadRewardedAd();

      // ロード失敗の場合
      if (!adService.isRewardedAdReady) {
        setState(() => _isProcessing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('広告の読み込みに失敗しました'),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }

    setState(() => _isProcessing = true);

    try {
      // 広告を表示
      final earnedReward = await adService.showRewardedAd();

      if (!earnedReward) {
        // 途中離脱または失敗
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('広告の視聴が完了しませんでした'),
              backgroundColor: AppTheme.textSecondary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // 視聴完了 → APIを呼び出して履歴をクリア
      final response = await statusNotifier.useReward();

      if (response != null && mounted) {
        // ローカルの視聴状態をクリア
        ref.read(viewedStoryIdsProvider.notifier).state = {};
        ref.read(viewedUserIdsProvider.notifier).state = {};

        // サーバーからストーリーリストを再取得
        ref.invalidate(storiesProvider);
        ref.invalidate(discoverProvider);

        widget.onCompleted?.call(response.clearedCount);
        _showCompletionDialog(response.clearedCount);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('エラーが発生しました'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showCompletionDialog(int clearedCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppTheme.success,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              '視聴履歴をクリア',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          clearedCount > 0
              ? '$clearedCount件の視聴履歴をクリアしました。\nもう一度投稿を視聴できます！'
              : 'クリアする視聴履歴がありませんでした。',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(
                color: AppTheme.accentPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(rewardAdStatusProvider);

    return statusAsync.when(
      data: (status) {
        final isDisabled = status.remainingCount <= 0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled || _isProcessing ? null : _handleTap,
            borderRadius: BorderRadius.circular(12),
            child: Opacity(
              opacity: isDisabled ? 0.5 : 1.0,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: isDisabled
                            ? null
                            : LinearGradient(
                                colors: [
                                  AppTheme.accentPrimary,
                                  AppTheme.accentSecondary,
                                ],
                              ),
                        color: isDisabled ? AppTheme.bgTertiary : null,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _isProcessing
                          ? Padding(
                              padding: const EdgeInsets.all(8),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              Icons.play_circle_filled_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '視聴履歴をクリア',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isDisabled
                                ? '本日の利用上限に達しました'
                                : '広告を見て履歴をリセット',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 残り回数バッジ
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDisabled
                            ? AppTheme.bgTertiary
                            : AppTheme.accentPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '残り${status.remainingCount}回',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDisabled
                              ? AppTheme.textTertiary
                              : AppTheme.accentPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.bgTertiary,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppTheme.bgTertiary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 140,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppTheme.bgTertiary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      error: (_, __) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(rewardAdStatusProvider.notifier).fetchStatus();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.refresh_rounded,
                    color: AppTheme.error,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    '読み込みに失敗しました（タップで再試行）',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
