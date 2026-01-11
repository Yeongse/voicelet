import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/models/profile.dart';
import '../../follow/models/follow_models.dart';
import '../../follow/widgets/follow_button.dart';
import '../../profile/services/profile_api_service.dart';

/// 他ユーザーのプロフィール取得プロバイダー
final userProfileProvider = FutureProvider.family<Profile, String>((ref, userId) async {
  final service = ProfileApiService();
  return service.getUserProfile(userId);
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

    return RefreshIndicator(
      onRefresh: () async {
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
                  // アバター
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.bgTertiary,
                    backgroundImage: profile.avatarUrl != null
                        ? NetworkImage(profile.avatarUrl!)
                        : null,
                    child: profile.avatarUrl == null
                        ? Icon(
                            Icons.person,
                            size: 50,
                            color: AppTheme.textTertiary,
                          )
                        : null,
                  ),
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
                        count: profile.followingCount,
                        label: 'フォロー中',
                        onTap: () => context.push(
                          '/users/${widget.userId}/follow-list',
                          extra: {'initialType': 'following'},
                        ),
                      ),
                      const SizedBox(width: 32),
                      _buildStatItem(
                        count: profile.followersCount,
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
