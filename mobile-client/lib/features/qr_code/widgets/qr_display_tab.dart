import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../utils/qr_code_utils.dart';

/// 自分のQRコードを表示するタブ
class QrDisplayTab extends ConsumerWidget {
  const QrDisplayTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final profileAsync = ref.watch(myProfileProvider);

    if (currentUserId == null) {
      return Center(
        child: Text(
          'ログインが必要です',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    final qrData = QrCodeUtils.generateQrData(currentUserId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          // プロフィール情報
          profileAsync.when(
            data: (profile) => Column(
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
                        blurRadius: 12,
                        spreadRadius: 2,
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
                      child: profile.avatarUrl != null
                          ? Image.network(
                              profile.avatarUrl!,
                              fit: BoxFit.cover,
                              width: 76,
                              height: 76,
                              errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                            )
                          : _buildDefaultAvatar(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 名前
                Text(
                  profile.name ?? '名前未設定',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                // ユーザー名
                if (profile.username != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '@${profile.username}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
            loading: () => Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.bgTertiary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppTheme.bgTertiary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 32),
          // QRコード
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: AppTheme.shadowMd,
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF1A1625),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF1A1625),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 説明テキスト
          Text(
            'このQRコードをスキャンして\nプロフィールにアクセス',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 76,
      height: 76,
      color: AppTheme.bgTertiary,
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: 40,
          color: AppTheme.textTertiary,
        ),
      ),
    );
  }
}
