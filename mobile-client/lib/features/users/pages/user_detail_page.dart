import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../ads/providers/ad_provider.dart';
import '../../auth/models/profile.dart';
import '../../auth/providers/auth_provider.dart';
import '../../follow/models/follow_models.dart';
import '../../follow/providers/follow_provider.dart';
import '../../follow/widgets/follow_button.dart';
import '../../home/models/home_models.dart';
import '../../home/pages/story_viewer_page.dart';
import '../../home/providers/home_providers.dart';
import '../../home/services/home_api_service.dart';
import '../../profile/services/profile_api_service.dart';

/// 他ユーザーのプロフィール取得プロバイダー
final userProfileProvider = FutureProvider.family<Profile, String>((ref, userId) async {
  final service = ProfileApiService();
  return service.getUserProfile(userId);
});

/// ユーザーのストーリー取得プロバイダー
final userStoriesProvider = FutureProvider.autoDispose
    .family<DiscoverStoriesResponse, ({String userId, String currentUserId})>((ref, params) async {
  final service = HomeApiService();
  return service.getDiscoverUserStories(
    userId: params.currentUserId,
    targetUserId: params.userId,
  );
});

class UserDetailPage extends ConsumerStatefulWidget {
  final String userId;

  const UserDetailPage({super.key, required this.userId});

  @override
  ConsumerState<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends ConsumerState<UserDetailPage> {
  @override
  void initState() {
    super.initState();
    // 画面表示時に最新データを取得
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(userProfileProvider(widget.userId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider(widget.userId));

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSecondary,
        foregroundColor: AppTheme.textPrimary,
        title: const Text('プロフィール'),
        elevation: 0,
      ),
      body: profileAsync.when(
        data: (profile) => _buildProfileContent(profile),
        loading: () => Center(
          child: CircularProgressIndicator(color: AppTheme.accentPrimary),
        ),
        error: (error, _) => _buildError(error),
      ),
    );
  }

  Widget _buildProfileContent(Profile profile) {
    // フォロー状態をFollowStatusに変換
    final followStatus = _parseFollowStatus(profile.followStatus);

    // 楽観的更新のデルタを取得
    final countDelta = ref.watch(followCountDeltaProvider);
    final delta = countDelta[widget.userId];
    final adjustedFollowersCount = profile.followersCount + (delta?.followersDelta ?? 0);
    final adjustedFollowingCount = profile.followingCount + (delta?.followingDelta ?? 0);

    return RefreshIndicator(
      onRefresh: () async {
        // リフレッシュ時はデルタをリセット
        final current = ref.read(followCountDeltaProvider);
        final newState = Map<String, ({int followingDelta, int followersDelta})>.from(current);
        newState.remove(widget.userId);
        ref.read(followCountDeltaProvider.notifier).state = newState;
        ref.invalidate(userProfileProvider(widget.userId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // ヘッダー部分
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.bgSecondary,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // アバター（タップでストーリー再生）
                  _buildTappableAvatar(profile),
                  const SizedBox(height: 16),

                  // 名前
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        profile.name ?? '名前未設定',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (profile.isPrivate) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.lock,
                          size: 18,
                          color: AppTheme.textTertiary,
                        ),
                      ],
                    ],
                  ),

                  // ユーザー名
                  if (profile.username != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '@${profile.username}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],

                  // ID
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${profile.id}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Bio
                  if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                    Text(
                      profile.bio!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // フォロー/フォロワー数
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatItem(
                        count: adjustedFollowingCount,
                        label: 'フォロー中',
                        onTap: () => context.push(
                          '/users/${widget.userId}/follow-list',
                          extra: {'initialType': 'following'},
                        ),
                      ),
                      const SizedBox(width: 32),
                      _buildStatItem(
                        count: adjustedFollowersCount,
                        label: 'フォロワー',
                        onTap: () => context.push(
                          '/users/${widget.userId}/follow-list',
                          extra: {'initialType': 'followers'},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // フォローボタン（自分のプロフィールでない場合のみ表示）
                  if (!profile.isOwnProfile)
                    SizedBox(
                      width: 200,
                      child: FollowButton(
                        userId: widget.userId,
                        initialStatus: followStatus,
                        isPrivate: profile.isPrivate,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTappableAvatar(Profile profile) {
    final currentUserId = ref.watch(currentUserIdProvider);
    if (currentUserId == null) {
      return _buildAvatarWithBorder(profile, hasStories: false, hasUnviewed: false);
    }

    final storiesAsync = ref.watch(
      userStoriesProvider((userId: widget.userId, currentUserId: currentUserId)),
    );

    return storiesAsync.when(
      data: (response) {
        final hasStories = response.stories.isNotEmpty;
        final hasUnviewed = response.hasUnviewed;
        return GestureDetector(
          // 視聴済みでも遷移し、視聴画面で広告視聴による再生を提供
          onTap: hasStories ? () => _playStory(response, profile, 0) : null,
          child: _buildAvatarWithBorder(profile, hasStories: hasStories, hasUnviewed: hasUnviewed),
        );
      },
      loading: () => _buildAvatarWithBorder(profile, hasStories: false, hasUnviewed: false),
      error: (e, s) => _buildAvatarWithBorder(profile, hasStories: false, hasUnviewed: false),
    );
  }

  Widget _buildAvatarWithBorder(Profile profile, {required bool hasStories, required bool hasUnviewed}) {
    return Container(
      width: 108,
      height: 108,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasStories && hasUnviewed ? AppTheme.gradientAccent : null,
        border: !hasStories || !hasUnviewed
            ? Border.all(
                color: hasStories
                    ? AppTheme.textTertiary.withValues(alpha: 0.5)
                    : AppTheme.bgTertiary,
                width: 3,
              )
            : null,
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.bgSecondary,
        ),
        padding: const EdgeInsets.all(2),
        child: CircleAvatar(
          radius: 46,
          backgroundColor: AppTheme.bgTertiary,
          backgroundImage: profile.avatarUrl != null
              ? NetworkImage(profile.avatarUrl!)
              : null,
          child: profile.avatarUrl == null
              ? Icon(
                  Icons.person,
                  size: 46,
                  color: AppTheme.textTertiary,
                )
              : null,
        ),
      ),
    );
  }

  Future<void> _playStory(DiscoverStoriesResponse response, Profile profile, int startIndex) async {
    final viewedUserIds = ref.read(viewedUserIdsProvider);
    final viewedStoryIds = ref.read(viewedStoryIdsProvider);

    // このユーザーの全投稿が視聴済みかチェック
    final isFullyViewedInSession = viewedUserIds.contains(widget.userId);
    final allStoriesViewed = response.stories.every(
      (s) => s.isViewed || viewedStoryIds.contains(s.id),
    );

    if (isFullyViewedInSession || allStoriesViewed) {
      _showAlreadyViewedToast();
      return;
    }

    // UserStoryオブジェクトを作成
    final userStory = UserStory(
      user: StoryUser(
        id: widget.userId,
        name: profile.name ?? '名前未設定',
        avatarUrl: profile.avatarUrl,
      ),
      stories: response.stories,
      hasUnviewed: response.hasUnviewed,
    );

    final currentUserId = ref.read(currentUserIdProvider);

    // StoryViewerPageに遷移
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            StoryViewerPage(story: userStory),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );

    // ストーリービューワーから戻ったらデータを更新
    if (currentUserId != null && mounted) {
      ref.invalidate(userStoriesProvider((userId: widget.userId, currentUserId: currentUserId)));
    }
  }

  void _showAlreadyViewedToast() {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final statusAsync = ref.watch(rewardAdStatusProvider);

          return statusAsync.when(
            data: (status) {
              final remainingCount = status.remainingCount;
              return CupertinoAlertDialog(
                title: const Text('視聴済み'),
                content: Text(
                  remainingCount > 0
                      ? 'このユーザーの投稿はすべて視聴済みです。\n\n動画広告を視聴して、視聴回数を回復しますか？\n（本日残り$remainingCount回）'
                      : 'このユーザーの投稿はすべて視聴済みです。\n\n本日の広告視聴上限に達しました。\n（朝5時(JST)に回復します）',
                ),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('閉じる'),
                  ),
                  if (remainingCount > 0)
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        _handleWatchAd();
                      },
                      child: const Text('広告を見る'),
                    ),
                ],
              );
            },
            loading: () => CupertinoAlertDialog(
              title: const Text('視聴済み'),
              content: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoActivityIndicator(),
                  SizedBox(width: 16),
                  Text('読み込み中...'),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('閉じる'),
                ),
              ],
            ),
            error: (_, _) => CupertinoAlertDialog(
              title: const Text('視聴済み'),
              content: const Text('このユーザーの投稿はすべて視聴済みです。'),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('閉じる'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleWatchAd() async {
    final adService = ref.read(adServiceProvider);
    final statusNotifier = ref.read(rewardAdStatusProvider.notifier);

    // ローディングダイアログを表示
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('広告を読み込み中...'),
          ],
        ),
      ),
    );

    // 広告がロードされていなければプリロードを待つ
    if (!adService.isRewardedAdReady) {
      await adService.preloadRewardedAd();

      if (!adService.isRewardedAdReady) {
        if (mounted) {
          Navigator.of(context).pop(); // ローディングダイアログを閉じる
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('広告の読み込みに失敗しました'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
        return;
      }
    }

    if (mounted) {
      Navigator.of(context).pop(); // ローディングダイアログを閉じる
    }

    final currentUserId = ref.read(currentUserIdProvider);

    try {
      // 広告を表示
      final earnedReward = await adService.showRewardedAd();

      if (!earnedReward) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('広告の視聴が完了しませんでした')),
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

        // ストーリーリストを更新
        if (currentUserId != null) {
          ref.invalidate(userStoriesProvider((userId: widget.userId, currentUserId: currentUserId)));
        }

        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('視聴履歴をクリア'),
            content: Text('${response.clearedCount}件の視聴履歴をクリアしました。\nもう一度投稿を視聴できます！'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('エラーが発生しました'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Widget _buildStatItem({
    required int count,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppTheme.error),
          const SizedBox(height: 16),
          Text(
            'プロフィールを読み込めませんでした',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(userProfileProvider(widget.userId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPrimary,
              foregroundColor: Colors.white,
            ),
            child: const Text('再試行'),
          ),
        ],
      ),
    );
  }

  FollowStatus _parseFollowStatus(String status) {
    switch (status) {
      case 'following':
        return FollowStatus.following;
      case 'requested':
        return FollowStatus.requested;
      default:
        return FollowStatus.none;
    }
  }
}
