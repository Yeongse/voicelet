import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/home_models.dart';

/// おすすめユーザーカード
class DiscoverCard extends StatelessWidget {
  final DiscoverUser user;
  final bool isFollowing;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onFollowTap;

  const DiscoverCard({
    super.key,
    required this.user,
    this.isFollowing = false,
    this.onAvatarTap,
    this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.bgTertiary.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          // アバター（タップでストーリー再生）
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.gradientAccent,
              ),
              padding: const EdgeInsets.all(2.5),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.bgPrimary,
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: user.avatarUrl != null
                      ? Image.network(
                          user.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                        )
                      : _buildDefaultAvatar(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ユーザー情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.graphic_eq_rounded,
                      size: 14,
                      color: AppTheme.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${user.whisperCount}件の投稿',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // フォローボタン
          _FollowButton(
            isFollowing: isFollowing,
            onTap: onFollowTap,
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppTheme.bgTertiary,
      child: Center(
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback? onTap;

  const _FollowButton({
    required this.isFollowing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isFollowing ? null : AppTheme.gradientAccent,
          color: isFollowing ? AppTheme.bgTertiary : null,
          borderRadius: BorderRadius.circular(20),
          border: isFollowing
              ? Border.all(color: AppTheme.textTertiary.withValues(alpha: 0.3))
              : null,
        ),
        child: Text(
          isFollowing ? 'フォロー中' : 'フォロー',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isFollowing ? AppTheme.textSecondary : AppTheme.textInverse,
          ),
        ),
      ),
    );
  }
}
