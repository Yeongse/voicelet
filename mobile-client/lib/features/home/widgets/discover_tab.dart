import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shimmer.dart';
import '../models/home_models.dart';
import '../providers/home_providers.dart';
import 'discover_card.dart';

/// フォロー状態を管理するプロバイダー
final followingStateProvider =
    StateProvider.autoDispose<Set<String>>((ref) => {});

/// おすすめタブ（ユーザーカードのリスト）
class DiscoverTab extends ConsumerWidget {
  final void Function(DiscoverUser user)? onUserStoryTap;
  final void Function(DiscoverUser user)? onFollowTap;
  final void Function(DiscoverUser user)? onUserProfileTap;

  const DiscoverTab({
    super.key,
    this.onUserStoryTap,
    this.onFollowTap,
    this.onUserProfileTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discoverAsync = ref.watch(discoverProvider);
    final followingSet = ref.watch(followingStateProvider);

    return RefreshIndicator(
      color: AppTheme.accentPrimary,
      backgroundColor: AppTheme.bgSecondary,
      onRefresh: () async {
        ref.invalidate(discoverProvider);
        await ref.read(discoverProvider.future);
      },
      child: discoverAsync.when(
        data: (users) => _buildContent(users, followingSet, ref),
        loading: () => _buildLoading(),
        error: (error, _) => _buildError(error),
      ),
    );
  }

  Widget _buildContent(
    List<DiscoverUser> users,
    Set<String> followingSet,
    WidgetRef ref,
  ) {
    if (users.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isFollowing = followingSet.contains(user.id);
        // サーバーからのhasUnviewedのみで判定
        // ※ viewedUserIdsは使わない（新規投稿追加時にサーバーデータと矛盾するため）
        // ビューワーから戻った時にdiscoverProviderを再取得するので最新状態が反映される
        final isViewed = !user.hasUnviewed;

        final hasStory = user.whisperCount > 0;

        return DiscoverCard(
          user: user,
          isFollowing: isFollowing,
          isViewed: isViewed,
          hasStory: hasStory,
          onAvatarTap: () => onUserStoryTap?.call(user),
          onCardTap: () => onUserProfileTap?.call(user),
          onFollowTap: () {
            // 楽観的更新
            if (isFollowing) {
              ref.read(followingStateProvider.notifier).update(
                    (state) => {...state}..remove(user.id),
                  );
            } else {
              ref.read(followingStateProvider.notifier).update(
                    (state) => {...state, user.id},
                  );
            }
            onFollowTap?.call(user);
          },
        );
      },
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 5,
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: const Row(
        children: [
          ShimmerCircle(size: 56),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 100, height: 14),
                SizedBox(height: 8),
                ShimmerBox(width: 60, height: 12),
              ],
            ),
          ),
          ShimmerBox(width: 80, height: 32, borderRadius: 16),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.explore_outlined,
                  size: 64,
                  color: AppTheme.textTertiary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'おすすめのユーザーが見つかりません',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(Object error) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppTheme.error.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 12),
                Text(
                  '読み込みに失敗しました',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
