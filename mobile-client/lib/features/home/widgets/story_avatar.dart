import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// ストーリーアバターウィジェット
/// 未視聴時はグラデーションボーダー、視聴済みはグレーボーダー
class StoryAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final bool hasUnviewed;
  final double size;
  final VoidCallback? onTap;

  const StoryAvatar({
    super.key,
    this.avatarUrl,
    required this.name,
    required this.hasUnviewed,
    this.size = 64,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderWidth = size * 0.05;
    final innerPadding = size * 0.04;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: hasUnviewed ? AppTheme.gradientAccent : null,
              border: hasUnviewed
                  ? null
                  : Border.all(
                      color: AppTheme.textTertiary.withValues(alpha: 0.5),
                      width: borderWidth,
                    ),
            ),
            padding: EdgeInsets.all(borderWidth),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.bgPrimary,
              ),
              padding: EdgeInsets.all(innerPadding),
              child: ClipOval(
                child: avatarUrl != null
                    ? Image.network(
                        avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                      )
                    : _buildDefaultAvatar(),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: size + 8,
            child: Text(
              name,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textPrimary.withValues(alpha: 0.85),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
