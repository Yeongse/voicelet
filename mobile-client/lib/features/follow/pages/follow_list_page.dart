import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dialogs.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/follow_models.dart';
import '../providers/follow_provider.dart';
import '../widgets/follow_button.dart';

enum FollowListType { following, followers }

class FollowListPage extends ConsumerStatefulWidget {
  final String userId;
  final FollowListType initialType;

  const FollowListPage({
    super.key,
    required this.userId,
    this.initialType = FollowListType.following,
  });

  @override
  ConsumerState<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends ConsumerState<FollowListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialType == FollowListType.following ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final isOwnProfile = currentUserId == widget.userId;

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSecondary,
        foregroundColor: AppTheme.textPrimary,
        title: const Text('フォロー'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentPrimary,
          labelColor: AppTheme.accentPrimary,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'フォロー中'),
            Tab(text: 'フォロワー'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FollowingList(
            userId: widget.userId,
            currentUserId: currentUserId,
            isOwnProfile: isOwnProfile,
          ),
          _FollowersList(
            userId: widget.userId,
            currentUserId: currentUserId,
            isOwnProfile: isOwnProfile,
          ),
        ],
      ),
    );
  }
}

/// フォロー中リスト
class _FollowingList extends ConsumerWidget {
  final String userId;
  final String? currentUserId;
  final bool isOwnProfile;

  const _FollowingList({
    required this.userId,
    required this.currentUserId,
    required this.isOwnProfile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(followingListProvider((userId: userId, page: 1)));

    return asyncValue.when(
      data: (response) => _buildList(context, ref, response),
      loading: () => Center(
        child: CircularProgressIndicator(color: AppTheme.accentPrimary),
      ),
      error: (error, _) => _buildError(context, ref, error),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, UserListResponse response) {
    if (response.data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppTheme.textTertiary),
            const SizedBox(height: 16),
            Text(
              'フォロー中のユーザーがいません',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(followingListProvider((userId: userId, page: 1)));
      },
      child: ListView.builder(
        itemCount: response.data.length,
        itemBuilder: (context, index) {
          final user = response.data[index];
          return _UserListItem(
            user: user,
            currentUserId: currentUserId,
            onTap: () => context.push('/users/${user.id}'),
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    if (error.toString().contains('403')) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: AppTheme.textTertiary),
            const SizedBox(height: 16),
            Text(
              'このユーザーのフォロー一覧は非公開です',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppTheme.error),
          const SizedBox(height: 16),
          Text('エラーが発生しました', style: TextStyle(color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(followingListProvider((userId: userId, page: 1)));
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
}

/// フォロワーリスト
class _FollowersList extends ConsumerWidget {
  final String userId;
  final String? currentUserId;
  final bool isOwnProfile;

  const _FollowersList({
    required this.userId,
    required this.currentUserId,
    required this.isOwnProfile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(followersListProvider((userId: userId, page: 1)));

    return asyncValue.when(
      data: (response) => _buildList(context, ref, response),
      loading: () => Center(
        child: CircularProgressIndicator(color: AppTheme.accentPrimary),
      ),
      error: (error, _) => _buildError(context, ref, error),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, UserListResponse response) {
    if (response.data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppTheme.textTertiary),
            const SizedBox(height: 16),
            Text(
              'フォロワーがいません',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(followersListProvider((userId: userId, page: 1)));
      },
      child: ListView.builder(
        itemCount: response.data.length,
        itemBuilder: (context, index) {
          final user = response.data[index];

          // 自分のフォロワーリストの場合は削除ボタンを表示
          if (isOwnProfile) {
            return _FollowerListItemWithRemove(
              user: user,
              listOwnerId: userId,
              onTap: () => context.push('/users/${user.id}'),
            );
          }

          // 他人のフォロワーリストの場合はフォローボタンを表示
          return _UserListItem(
            user: user,
            currentUserId: currentUserId,
            onTap: () => context.push('/users/${user.id}'),
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    if (error.toString().contains('403')) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: AppTheme.textTertiary),
            const SizedBox(height: 16),
            Text(
              'このユーザーのフォロワー一覧は非公開です',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppTheme.error),
          const SizedBox(height: 16),
          Text('エラーが発生しました', style: TextStyle(color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(followersListProvider((userId: userId, page: 1)));
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
}

/// 通常のユーザーリストアイテム（フォローボタン付き）
class _UserListItem extends StatelessWidget {
  final UserWithFollowStatus user;
  final String? currentUserId;
  final VoidCallback? onTap;

  const _UserListItem({
    required this.user,
    required this.currentUserId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 自分自身の場合はボタンを表示しない
    final isMe = user.id == currentUserId;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: AppTheme.bgTertiary,
        backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
        child: user.avatarUrl == null
            ? Icon(Icons.person, color: AppTheme.textTertiary)
            : null,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              user.name ?? '名前未設定',
              style: TextStyle(color: AppTheme.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (user.isPrivate) ...[
            const SizedBox(width: 4),
            Icon(Icons.lock, size: 16, color: AppTheme.textTertiary),
          ],
        ],
      ),
      subtitle: user.username != null
          ? Text(
              '@${user.username}',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: isMe
          ? null
          : FollowButton(
              userId: user.id,
              initialStatus: user.followStatus,
              isPrivate: user.isPrivate,
              compact: true,
            ),
    );
  }
}

/// フォロワー削除ボタン付きリストアイテム（自分のフォロワーリスト用）
class _FollowerListItemWithRemove extends ConsumerWidget {
  final UserWithFollowStatus user;
  final String listOwnerId;
  final VoidCallback? onTap;

  const _FollowerListItemWithRemove({
    required this.user,
    required this.listOwnerId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: AppTheme.bgTertiary,
        backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
        child: user.avatarUrl == null
            ? Icon(Icons.person, color: AppTheme.textTertiary)
            : null,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              user.name ?? '名前未設定',
              style: TextStyle(color: AppTheme.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (user.isPrivate) ...[
            const SizedBox(width: 4),
            Icon(Icons.lock, size: 16, color: AppTheme.textTertiary),
          ],
        ],
      ),
      subtitle: user.username != null
          ? Text(
              '@${user.username}',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: IconButton(
        icon: Icon(Icons.close, color: AppTheme.textSecondary),
        onPressed: () => _showRemoveDialog(context, ref),
      ),
    );
  }

  Future<void> _showRemoveDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDestructiveConfirmDialog(
      context: context,
      message: '${user.name ?? 'このユーザー'}をフォロワーから削除しますか？',
      destructiveText: 'フォロワーを削除',
    );

    if (confirmed && context.mounted) {
      try {
        final service = ref.read(followApiServiceProvider);
        await service.removeFollower(user.id);
        ref.invalidate(followersListProvider((userId: listOwnerId, page: 1)));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'フォロワーを削除しました',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              backgroundColor: AppTheme.bgElevated,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '削除に失敗しました: $e',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              backgroundColor: AppTheme.bgElevated,
            ),
          );
        }
      }
    }
  }
}
