import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../core/theme/app_theme.dart';

/// チュートリアルステップのコンテンツビルダー
class TutorialContent {
  /// チュートリアルコンテンツウィジェットを作成（コントローラー付き）
  static Widget buildWithController({
    required String title,
    required String description,
    required int currentStep,
    required int totalSteps,
    required TutorialCoachMarkController controller,
    bool isLastStep = false,
    VoidCallback? onSkip,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ステップインジケーター
        Row(
          children: List.generate(totalSteps, (index) {
            final isActive = index == currentStep;
            return Container(
              width: isActive ? 24 : 8,
              height: 8,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.accentPrimary
                    : AppTheme.textSecondary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        // タイトル
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        // 説明
        Text(
          description,
          style: TextStyle(
            fontSize: 15,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        // ボタン行
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // スキップボタン
            if (onSkip != null)
              GestureDetector(
                onTap: onSkip,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.textSecondary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'スキップ',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              )
            else
              const SizedBox.shrink(),
            // 次へ/完了ボタン
            GestureDetector(
              onTap: () {
                if (isLastStep) {
                  controller.skip(); // 最後のステップではskipで完了
                } else {
                  controller.next();
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: AppTheme.gradientAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isLastStep ? '完了' : '次へ',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textInverse,
                      ),
                    ),
                    if (!isLastStep) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: AppTheme.textInverse,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// TargetFocusを作成するヘルパー
  static TargetFocus createTarget({
    required GlobalKey key,
    required String identify,
    required String title,
    required String description,
    required int currentStep,
    required int totalSteps,
    ContentAlign align = ContentAlign.bottom,
    ShapeLightFocus shape = ShapeLightFocus.RRect,
    double? radius,
    bool isLastStep = false,
    VoidCallback? onSkip,
  }) {
    return TargetFocus(
      identify: identify,
      keyTarget: key,
      alignSkip: Alignment.topRight,
      enableOverlayTab: false, // 画面タップで遷移しない
      enableTargetTab: false, // ターゲットタップで遷移しない
      shape: shape,
      radius: radius ?? 12,
      paddingFocus: 8,
      contents: [
        TargetContent(
          align: align,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          builder: (context, controller) {
            return buildWithController(
              title: title,
              description: description,
              currentStep: currentStep,
              totalSteps: totalSteps,
              controller: controller,
              isLastStep: isLastStep,
              onSkip: onSkip,
            );
          },
        ),
      ],
    );
  }

  /// オンボーディング完了メッセージ用のTargetFocusを作成
  static TargetFocus createCompletionTarget({
    required String identify,
    required int currentStep,
    required int totalSteps,
  }) {
    return TargetFocus(
      identify: identify,
      targetPosition: TargetPosition(
        const Size(0, 0),
        const Offset(-1000, -1000), // 画面外に配置（ハイライトなし）
      ),
      alignSkip: Alignment.topRight,
      enableOverlayTab: false,
      enableTargetTab: false,
      shape: ShapeLightFocus.Circle,
      radius: 0,
      contents: [
        TargetContent(
          align: ContentAlign.custom,
          customPosition: CustomTargetContentPosition(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
          ),
          builder: (context, controller) {
            return Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.bgSecondary,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.accentPrimary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentPrimary.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // アイコン
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.gradientAccent,
                      ),
                      child: const Icon(
                        Icons.celebration_rounded,
                        size: 40,
                        color: AppTheme.textInverse,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // タイトル
                    const Text(
                      'チュートリアル完了！',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // メッセージ
                    Text(
                      'ご視聴ありがとうございます！\n\nVoiceletで声を通じた\n新しいつながりを楽しんでください',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // ステップインジケーター
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(totalSteps, (index) {
                        final isActive = index == currentStep;
                        return Container(
                          width: isActive ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppTheme.accentPrimary
                                : AppTheme.textSecondary.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    // 完了ボタン
                    GestureDetector(
                      onTap: () => controller.skip(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppTheme.gradientAccent,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentPrimary.withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'はじめる',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textInverse,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
