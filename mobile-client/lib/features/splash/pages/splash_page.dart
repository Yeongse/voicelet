import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/splash_init_provider.dart';
import '../models/splash_result.dart';

/// スプラッシュ画面
///
/// アプリ起動時に「夜のささやき」テーマのブランディング要素を表示し、
/// 認証済みならホームへ、未認証ならSign In/Sign Upボタンを表示する。
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _glowController;
  late final AnimationController _buttonsController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _buttonsOpacity;
  late final Animation<Offset> _buttonsSlide;

  bool _isTransitioning = false;
  bool _showAuthButtons = false;

  @override
  void initState() {
    super.initState();

    // メインアニメーションコントローラー（ロゴ、タイトル）
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    // グロー用コントローラー（ゆっくり脈動）
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    )..repeat(reverse: true);

    // 認証ボタン用コントローラー
    _buttonsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // ロゴのスケールアニメーション（ゆっくり浮かび上がる）
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    // ロゴのフェードイン
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    // タイトルのフェードイン（遅延）
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.25, 0.6, curve: Curves.easeOut),
      ),
    );

    // タイトルのスライドアップ
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.25, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // タグラインのフェードイン（さらに遅延）
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
      ),
    );

    // 認証ボタンのアニメーション
    _buttonsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonsController,
        curve: Curves.easeOut,
      ),
    );

    _buttonsSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _buttonsController,
        curve: Curves.easeOutCubic,
      ),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _glowController.dispose();
    _buttonsController.dispose();
    super.dispose();
  }

  void _navigateTo(String path) {
    if (_isTransitioning) return;
    setState(() => _isTransitioning = true);

    _mainController.reverse().then((_) {
      if (mounted) {
        context.go(path);
      }
    });
  }

  void _showButtons() {
    setState(() => _showAuthButtons = true);
    _buttonsController.forward();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<SplashResult>>(splashInitProvider, (previous, next) {
      next.whenData((result) {
        switch (result) {
          case SplashSuccess():
            _navigateTo('/home');
          case SplashNeedsOnboarding():
            // 認証済みだがプロフィール未登録
            _navigateTo('/auth/onboarding');
          case SplashUnauthenticated():
            // 未認証時はボタンを表示
            _showButtons();
          case SplashTimeout():
          case SplashNetworkError():
            // エラー時もボタンを表示
            _showButtons();
        }
      });
    });

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 背景画像
          Image.asset(
            'assets/main_background.png',
            fit: BoxFit.cover,
          ),
          // 上部にグラデーションオーバーレイ（文字の視認性向上）
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
          // コンテンツ
          SafeArea(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _mainController,
                _glowController,
                _buttonsController,
              ]),
              builder: (context, child) {
                return Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(flex: 2),
                          _buildLogo(context),
                          const SizedBox(height: 32),
                          _buildTitle(context),
                          const SizedBox(height: 8),
                          _buildTagline(context),
                          const Spacer(flex: 2),
                          if (_showAuthButtons)
                            _buildAuthButtons(context)
                          else
                            _buildBottomIndicator(context),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                    // 開発者メニュー（右上）
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Opacity(
                        opacity: _taglineOpacity.value * 0.7,
                        child: GestureDetector(
                          onTap: () => context.go('/dev/whispers'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.warning.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.developer_mode_rounded,
                                  size: 14,
                                  color: AppTheme.warning,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'DEV',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.warning,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = screenWidth * 0.35;

    // グローの脈動効果
    final glowIntensity = 0.25 + (_glowController.value * 0.2);

    return Opacity(
      opacity: _logoOpacity.value,
      child: Transform.scale(
        scale: _logoScale.value,
        child: Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              // 外側のソフトグロー
              BoxShadow(
                color:
                    AppTheme.accentPrimary.withValues(alpha: glowIntensity * 0.6),
                blurRadius: 50,
                spreadRadius: 5,
              ),
              // 中間のグロー
              BoxShadow(
                color:
                    AppTheme.particleWarm.withValues(alpha: glowIntensity * 0.3),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/icon.png',
              width: logoSize,
              height: logoSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.gradientAccent,
                  ),
                  child: Icon(
                    Icons.mic_rounded,
                    size: logoSize * 0.45,
                    color: AppTheme.textInverse,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return SlideTransition(
      position: _titleSlide,
      child: Opacity(
        opacity: _titleOpacity.value,
        child: Text(
          'Voicelet',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 44,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            letterSpacing: 3.0,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 15,
                offset: const Offset(0, 2),
              ),
              Shadow(
                color: AppTheme.accentPrimary.withValues(alpha: 0.3),
                blurRadius: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagline(BuildContext context) {
    return Opacity(
      opacity: _taglineOpacity.value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.black.withValues(alpha: 0.35),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Text(
          '今日あった小さなこと、声にしてみる。',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
            letterSpacing: 1.5,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.7),
                blurRadius: 12,
              ),
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButtons(BuildContext context) {
    return SlideTransition(
      position: _buttonsSlide,
      child: Opacity(
        opacity: _buttonsOpacity.value,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              // Sign Up ボタン（メイン）
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.push('/auth/signup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 4,
                    shadowColor: AppTheme.accentPrimary.withValues(alpha: 0.4),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Sign In ボタン（セカンダリ）
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => context.push('/auth/signin'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textPrimary,
                    side: BorderSide(
                      color: AppTheme.textPrimary.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomIndicator(BuildContext context) {
    return Opacity(
      opacity: _taglineOpacity.value * 0.8,
      child: _LoadingDots(controller: _glowController),
    );
  }
}

/// 3つのドットがフェードするローディングインジケーター
class _LoadingDots extends StatelessWidget {
  final AnimationController controller;

  const _LoadingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            // 各ドットに位相差をつけてフェード
            final phase = (controller.value + index * 0.33) % 1.0;
            final opacity = 0.4 + 0.6 * math.sin(phase * math.pi);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.textPrimary.withValues(alpha: opacity),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentPrimary.withValues(alpha: opacity * 0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
