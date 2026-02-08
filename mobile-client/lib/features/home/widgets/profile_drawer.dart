import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dialogs.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/profile.dart';
import '../../follow/providers/follow_provider.dart';

/// プロフィールドロワー（右からスライドで表示）
class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    Profile? profile;
    if (authState is AuthStateAuthenticated) {
      profile = authState.profile;
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        bottomLeft: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.bgSecondary.withValues(alpha: 0.95),
                AppTheme.bgPrimary.withValues(alpha: 0.9),
              ],
            ),
            border: Border(
              left: BorderSide(
                color: AppTheme.accentPrimary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                // プロフィールセクション
                _buildProfileSection(context, profile),
                const SizedBox(height: 32),
                // メニュー
                Expanded(
                  child: _buildMenuList(context, ref),
                ),
                // フッター
                _buildFooter(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, Profile? profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // アバター
          Container(
            width: 80,
            height: 80,
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
                child: profile?.avatarUrl != null
                    ? Image.network(
                        profile!.avatarUrl!,
                        fit: BoxFit.cover,
                        width: 74,
                        height: 74,
                        errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 74,
                            height: 74,
                            color: AppTheme.bgTertiary,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.accentPrimary,
                              ),
                            ),
                          );
                        },
                      )
                    : _buildDefaultAvatar(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 表示名
          Text(
            profile?.name ?? '名前未設定',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // 年齢
          if (profile?.age != null)
            Text(
              '${profile!.age}歳',
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
      color: AppTheme.bgTertiary,
      child: Center(
        child: Icon(
          Icons.person_rounded,
          color: AppTheme.textTertiary,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildMenuList(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _MenuTile(
          icon: Icons.person_outline_rounded,
          label: 'マイプロフィール',
          onTap: () {
            Navigator.of(context).pop();
            context.push('/profile');
          },
        ),
        _FollowRequestMenuTile(
          onTap: () {
            Navigator.of(context).pop();
            context.push('/follow-requests');
          },
        ),
        _MenuTile(
          icon: Icons.qr_code_rounded,
          label: 'QRコード',
          onTap: () {
            Navigator.of(context).pop();
            context.push('/qr-code');
          },
        ),
        const SizedBox(height: 16),
        Divider(
          color: AppTheme.textTertiary.withValues(alpha: 0.2),
          height: 1,
        ),
        const SizedBox(height: 16),
        _MenuTile(
          icon: Icons.settings_outlined,
          label: '設定',
          onTap: () {
            // TODO: 設定画面への遷移
            Navigator.of(context).pop();
          },
        ),
        _MenuTile(
          icon: Icons.help_outline_rounded,
          label: 'ヘルプ',
          onTap: () {
            // TODO: ヘルプ画面への遷移
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showDestructiveConfirmDialog(
                  context: context,
                  message: 'ログアウトしますか？',
                  destructiveText: 'ログアウト',
                );

                if (confirm && context.mounted) {
                  // signOutの完了を待ってから画面遷移
                  await ref.read(authProvider.notifier).signOut();
                  if (context.mounted) {
                    // ドロワーを閉じてからトップ画面に遷移
                    Navigator.of(context).pop();
                    context.go('/');
                  }
                }
              },
              icon: Icon(
                Icons.logout_rounded,
                size: 18,
                color: AppTheme.textSecondary,
              ),
              label: Text(
                'ログアウト',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(
                  color: AppTheme.textTertiary.withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// フォローリクエストメニュータイル（バッジ付き）
class _FollowRequestMenuTile extends ConsumerWidget {
  final VoidCallback onTap;

  const _FollowRequestMenuTile({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(followRequestCountProvider);
    final count = countAsync.valueOrNull ?? 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                Icons.person_add_outlined,
                color: AppTheme.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'フォローリクエスト',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              if (count > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// メニュータイル
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppTheme.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ヘッダーに表示するプロフィールアバターボタン
class ProfileAvatarButton extends ConsumerWidget {
  final VoidCallback onTap;
  final double size;

  const ProfileAvatarButton({
    super.key,
    required this.onTap,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    String? avatarUrl;
    if (authState is AuthStateAuthenticated) {
      avatarUrl = authState.profile.avatarUrl;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.gradientAccent,
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentPrimary.withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.bgSecondary,
          ),
          child: ClipOval(
            child: avatarUrl != null
                ? Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    width: size - 4,
                    height: size - 4,
                    errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: size - 4,
                        height: size - 4,
                        color: AppTheme.bgTertiary,
                        child: Center(
                          child: SizedBox(
                            width: size * 0.4,
                            height: size * 0.4,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.accentPrimary,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : _buildDefaultAvatar(),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppTheme.bgTertiary,
      child: Center(
        child: Icon(
          Icons.person_rounded,
          color: AppTheme.textTertiary,
          size: size * 0.55,
        ),
      ),
    );
  }
}
