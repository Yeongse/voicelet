import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

/// 新規投稿ボタン（＋ボタン）
/// 背景に自分のアバター画像を表示
class AddStoryButton extends ConsumerWidget {
  final double size;
  final VoidCallback? onTap;

  const AddStoryButton({
    super.key,
    this.size = 64,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 認証状態からプロフィールを取得
    final authState = ref.watch(authProvider);
    String? avatarUrl;
    if (authState is AuthStateAuthenticated) {
      avatarUrl = authState.profile.avatarUrl;
    }

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
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 背景：アバター画像または人物アイコン
                  if (avatarUrl != null)
                    Image.network(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                    )
                  else
                    _buildDefaultAvatar(),
                  // 薄い暗いオーバーレイ
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                  // 中央の＋ボタン
                  Center(
                    child: Container(
                      width: size * 0.4,
                      height: size * 0.4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.gradientAccent,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentPrimary.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: AppTheme.textInverse,
                        size: size * 0.28,
                      ),
                    ),
                  ),
                ],
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

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppTheme.bgSecondary,
      child: Center(
        child: Icon(
          Icons.person_rounded,
          color: AppTheme.textTertiary,
          size: size * 0.5,
        ),
      ),
    );
  }
}
