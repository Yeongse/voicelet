import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../models/home_models.dart';
import '../providers/home_providers.dart';
import 'story_avatar.dart';

/// フォロー中タブ（ユーザーアバターのグリッド表示）
class FollowingTab extends ConsumerWidget {
  final void Function(UserStory story)? onStoryTap;

  const FollowingTab({
    super.key,
    this.onStoryTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(storiesProvider);
    final viewedUserIds = ref.watch(viewedUserIdsProvider);
    final viewedStoryIds = ref.watch(viewedStoryIdsProvider);

    return storiesAsync.when(
      data: (stories) => _buildContent(stories, viewedUserIds, viewedStoryIds),
      loading: () => _buildLoading(),
      error: (error, _) => _buildError(error),
    );
  }

  Widget _buildContent(
    List<UserStory> stories,
    Set<String> viewedUserIds,
    Set<String> viewedStoryIds,
  ) {
    if (stories.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: stories.length,
      itemBuilder: (context, index) {
        final story = stories[index];
        // ユーザーが全投稿視聴済みとしてマークされているか確認
        final isFullyViewedInSession = viewedUserIds.contains(story.user.id);
        // 個別のストーリー視聴状態も考慮して未視聴があるか確認
        // (サーバーからのisViewedフラグ + セッション中に視聴したストーリー)
        final hasUnviewedStories = story.stories.any((s) =>
            !s.isViewed && !viewedStoryIds.contains(s.id));
        final hasUnviewed = hasUnviewedStories && !isFullyViewedInSession;
        return StoryAvatar(
          avatarUrl: story.user.avatarUrl,
          name: story.user.name,
          hasUnviewed: hasUnviewed,
          size: 64,
          onTap: () => onStoryTap?.call(story),
        );
      },
    );
  }

  Widget _buildLoading() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: 8,
      itemBuilder: (context, index) => _buildShimmerItem(),
    );
  }

  Widget _buildShimmerItem() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.bgTertiary.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 48,
          height: 12,
          decoration: BoxDecoration(
            color: AppTheme.bgTertiary.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 64,
            color: AppTheme.textPrimary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'フォロー中のユーザーの投稿がありません',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'おすすめタブからユーザーをフォローしてみましょう',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textPrimary.withValues(alpha: 0.7),
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
    );
  }
}
