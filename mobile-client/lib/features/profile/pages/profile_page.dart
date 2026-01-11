import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/models/profile.dart';
import '../../auth/providers/auth_provider.dart';
import '../../follow/models/follow_models.dart';
import '../../follow/providers/follow_provider.dart';
import '../../follow/widgets/user_list_tile.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  final String? userId;

  const ProfilePage({super.key, this.userId});

  bool get isMyProfile => userId == null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = isMyProfile
        ? ref.watch(myProfileProvider)
        : ref.watch(userProfileProvider(userId!));

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSecondary,
        foregroundColor: AppTheme.textPrimary,
        title: Text(isMyProfile ? 'マイプロフィール' : 'プロフィール'),
        actions: isMyProfile
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    context.push('/profile/edit');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppTheme.bgSecondary,
                        title: Text(
                          'ログアウト',
                          style: TextStyle(color: AppTheme.textPrimary),
                        ),
                        content: Text(
                          'ログアウトしますか？',
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
                              'ログアウト',
                              style: TextStyle(color: AppTheme.error),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      // 先に画面遷移してからサインアウトを実行
                      context.go('/login');
                      ref.read(authProvider.notifier).signOut();
                    }
                  },
                ),
              ]
            : null,
      ),
      body: profileAsync.when(
        data: (profile) => _ProfileContent(profile: profile, isMyProfile: isMyProfile),
        loading: () => Center(
          child: CircularProgressIndicator(color: AppTheme.accentPrimary),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppTheme.error),
              const SizedBox(height: 16),
              Text(
                'エラーが発生しました',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                '$error',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (isMyProfile) {
                    ref.invalidate(myProfileProvider);
                  } else {
                    ref.invalidate(userProfileProvider(userId!));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPrimary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  final Profile profile;
  final bool isMyProfile;

  const _ProfileContent({
    required this.profile,
    required this.isMyProfile,
  });

  void _showFollowListBottomSheet(
    BuildContext context,
    WidgetRef ref,
    bool isFollowing,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _FollowListBottomSheet(
          userId: profile.id,
          isFollowing: isFollowing,
          isMyProfile: isMyProfile,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          // アバター
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.gradientAccent,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentPrimary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.bgSecondary,
              ),
              child: ClipOval(
                child: profile.avatarUrl != null
                    ? Image.network(
                        profile.avatarUrl!,
                        fit: BoxFit.cover,
                        width: 114,
                        height: 114,
                        errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.accentPrimary,
                            ),
                          );
                        },
                      )
                    : _buildDefaultAvatar(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 表示名と鍵アイコン
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (profile.isPrivate)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.lock,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                ),
              Flexible(
                child: Text(
                  profile.name ?? '名前未設定',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 年齢
          if (profile.age != null)
            Text(
              '${profile.age}歳',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          const SizedBox(height: 16),

          // フォロー数・フォロワー数
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFollowCountTile(
                context: context,
                ref: ref,
                label: 'フォロー',
                count: profile.followingCount,
                onTap: () => _showFollowListBottomSheet(context, ref, true),
              ),
              const SizedBox(width: 32),
              _buildFollowCountTile(
                context: context,
                ref: ref,
                label: 'フォロワー',
                count: profile.followersCount,
                onTap: () => _showFollowListBottomSheet(context, ref, false),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 自己紹介
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.bgSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.textTertiary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '自己紹介',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile.bio!,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // メールアドレス（自分のプロフィールのみ）
          if (isMyProfile) ...[
            const SizedBox(height: 24),
            _buildInfoTile(
              icon: Icons.email_outlined,
              label: 'メールアドレス',
              value: profile.email,
            ),
          ],

          // 生年月（自分のプロフィールのみ）
          if (isMyProfile && profile.birthMonth != null) ...[
            const SizedBox(height: 8),
            _buildInfoTile(
              icon: Icons.cake_outlined,
              label: '生年月',
              value: profile.birthMonth!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFollowCountTile({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            '$count',
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
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 114,
      height: 114,
      color: AppTheme.bgTertiary,
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: 60,
          color: AppTheme.textTertiary,
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.textTertiary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.textSecondary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// フォロー/フォロワー一覧のボトムシート
class _FollowListBottomSheet extends ConsumerStatefulWidget {
  final String userId;
  final bool isFollowing;
  final bool isMyProfile;
  final ScrollController scrollController;

  const _FollowListBottomSheet({
    required this.userId,
    required this.isFollowing,
    required this.isMyProfile,
    required this.scrollController,
  });

  @override
  ConsumerState<_FollowListBottomSheet> createState() => _FollowListBottomSheetState();
}

class _FollowListBottomSheetState extends ConsumerState<_FollowListBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.isFollowing ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showRemoveFollowerDialog(UserWithFollowStatus user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgSecondary,
        title: Text('フォロワー削除', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          '${user.name ?? 'このユーザー'}をフォロワーから削除しますか？',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('キャンセル', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('削除', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final service = ref.read(followApiServiceProvider);
        await service.removeFollower(user.id);
        ref.invalidate(followersListProvider((userId: widget.userId, page: 1)));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('フォロワーを削除しました')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('削除に失敗しました: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ハンドル
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.textTertiary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),
        // タブバー
        TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentPrimary,
          labelColor: AppTheme.accentPrimary,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'フォロー中'),
            Tab(text: 'フォロワー'),
          ],
        ),
        // タブビュー
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildFollowingList(),
              _buildFollowersList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFollowingList() {
    final asyncValue = ref.watch(followingListProvider((userId: widget.userId, page: 1)));

    return asyncValue.when(
      data: (response) {
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
            ref.invalidate(followingListProvider((userId: widget.userId, page: 1)));
          },
          child: ListView.builder(
            controller: widget.scrollController,
            itemCount: response.data.length,
            itemBuilder: (context, index) {
              final user = response.data[index];
              return UserListTile(
                user: user,
                onTap: () {
                  Navigator.pop(context);
                  context.push('/users/${user.id}');
                },
              );
            },
          ),
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(color: AppTheme.accentPrimary),
      ),
      error: (error, _) => _buildErrorWidget(error, true),
    );
  }

  Widget _buildFollowersList() {
    final asyncValue = ref.watch(followersListProvider((userId: widget.userId, page: 1)));

    return asyncValue.when(
      data: (response) {
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
            ref.invalidate(followersListProvider((userId: widget.userId, page: 1)));
          },
          child: ListView.builder(
            controller: widget.scrollController,
            itemCount: response.data.length,
            itemBuilder: (context, index) {
              final user = response.data[index];
              return UserListTile(
                user: user,
                onTap: () {
                  Navigator.pop(context);
                  context.push('/users/${user.id}');
                },
                showRemoveButton: widget.isMyProfile,
                onRemove: widget.isMyProfile ? () => _showRemoveFollowerDialog(user) : null,
              );
            },
          ),
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(color: AppTheme.accentPrimary),
      ),
      error: (error, _) => _buildErrorWidget(error, false),
    );
  }

  Widget _buildErrorWidget(Object error, bool isFollowing) {
    if (error.toString().contains('403')) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: AppTheme.textTertiary),
            const SizedBox(height: 16),
            Text(
              isFollowing
                  ? 'このユーザーのフォロー一覧は非公開です'
                  : 'このユーザーのフォロワー一覧は非公開です',
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
              if (isFollowing) {
                ref.invalidate(followingListProvider((userId: widget.userId, page: 1)));
              } else {
                ref.invalidate(followersListProvider((userId: widget.userId, page: 1)));
              }
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
