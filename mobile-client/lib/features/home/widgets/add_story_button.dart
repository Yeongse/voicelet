import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// 新規投稿ボタン（＋ボタン）
class AddStoryButton extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;

  const AddStoryButton({
    super.key,
    this.size = 64,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
              color: AppTheme.bgTertiary,
              border: Border.all(
                color: AppTheme.accentPrimary.withValues(alpha: 0.5),
                width: 2,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            ),
            child: Center(
              child: Container(
                width: size * 0.4,
                height: size * 0.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.gradientAccent,
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: AppTheme.textInverse,
                  size: size * 0.28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: size + 8,
            child: Text(
              '投稿する',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
