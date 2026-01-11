import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

/// Sign Up画面（外部認証プロバイダー選択）
class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  bool _isLoading = false;
  String? _error;

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
      // 認証状態の変更はref.listenで処理される
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signUpWithApple() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authProvider.notifier).signInWithApple();
      // 認証状態の変更はref.listenで処理される
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 認証状態を監視
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthStateNeedsOnboarding) {
        // 新規ユーザーはオンボーディングへ
        context.go('/auth/onboarding');
      } else if (next is AuthStateAuthenticated) {
        // 既存ユーザーはホームへ
        context.go('/home');
      }
    });

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 背景画像
          Image.asset('assets/main_background.png', fit: BoxFit.cover),
          // グラデーションオーバーレイ
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
          // コンテンツ
          SafeArea(
            child: Column(
              children: [
                // 戻るボタン
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                // タイトル
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'アカウントを作成して始めましょう',
                  style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
                ),
                const Spacer(),
                // 認証プロバイダーボタン
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      // Google
                      _buildProviderButton(
                        onPressed: _isLoading ? null : _signUpWithGoogle,
                        icon: 'assets/icons/google.png',
                        iconFallback: Icons.g_mobiledata_rounded,
                        label: 'Continue with Google',
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                      ),
                      const SizedBox(height: 16),
                      // Apple
                      _buildProviderButton(
                        onPressed: _isLoading ? null : _signUpWithApple,
                        icon: 'assets/icons/apple.png',
                        iconFallback: Icons.apple_rounded,
                        label: 'Continue with Apple',
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                    ],
                  ),
                ),
                // エラーメッセージ
                if (_error != null) ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
                // ローディング
                if (_isLoading) ...[
                  const SizedBox(height: 24),
                  CircularProgressIndicator(color: AppTheme.accentPrimary),
                ],
                const Spacer(flex: 2),
                // 利用規約
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'アカウントを作成することで、利用規約とプライバシーポリシーに同意したことになります。',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                // 既にアカウントがある場合
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '既にアカウントをお持ちの方は',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            context.pushReplacement('/auth/signin'),
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: AppTheme.accentPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderButton({
    required VoidCallback? onPressed,
    required String icon,
    required IconData iconFallback,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return Icon(iconFallback, size: 24);
              },
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
