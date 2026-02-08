import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../models/tutorial_screen.dart';
import '../models/tutorial_state.dart';
import '../services/tutorial_service.dart';

/// TutorialServiceプロバイダー
final tutorialServiceProvider = Provider<TutorialService>((ref) {
  return TutorialServiceImpl();
});

/// チュートリアル状態管理プロバイダー
final tutorialProvider =
    StateNotifierProvider<TutorialNotifier, TutorialState>((ref) {
  return TutorialNotifier(ref.read(tutorialServiceProvider));
});

/// チュートリアル状態管理Notifier
class TutorialNotifier extends StateNotifier<TutorialState> {
  final TutorialService _service;
  TutorialCoachMark? _tutorialCoachMark;

  TutorialNotifier(this._service) : super(const TutorialState()) {
    _initialize();
  }

  /// 初期化処理：永続化されている完了状態を読み込む
  Future<void> _initialize() async {
    final homeCompleted = await _service.isCompleted(TutorialScreen.home);
    final recordingCompleted =
        await _service.isCompleted(TutorialScreen.recording);

    state = state.copyWith(
      homeCompleted: homeCompleted,
      recordingCompleted: recordingCompleted,
      isInitialized: true,
    );
  }

  /// 指定画面のチュートリアルを表示すべきかチェック
  bool shouldShowTutorial(TutorialScreen screen) {
    if (!state.isInitialized) return false;
    if (state.isShowingTutorial) return false;

    switch (screen) {
      case TutorialScreen.home:
        return !state.homeCompleted;
      case TutorialScreen.recording:
        // ホーム画面のチュートリアルが完了していない場合は表示しない
        if (!state.homeCompleted) return false;
        return !state.recordingCompleted;
    }
  }

  /// チュートリアルを表示
  void showTutorial({
    required BuildContext context,
    required TutorialScreen screen,
    required List<TargetFocus> targets,
    VoidCallback? onFinish,
    VoidCallback? onSkip,
  }) {
    if (state.isShowingTutorial) return;
    if (targets.isEmpty) return;

    state = state.copyWith(isShowingTutorial: true);

    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.85,
      hideSkip: true,
      paddingFocus: 8,
      pulseEnable: true,
      focusAnimationDuration: const Duration(milliseconds: 400),
      unFocusAnimationDuration: const Duration(milliseconds: 400),
      onFinish: () {
        _onTutorialComplete(screen, onFinish);
      },
      onClickTarget: (target) {
        // 各ターゲットがクリックされた時の処理
      },
      onSkip: () {
        _handleSkip(context, screen, onSkip);
        return false; // falseを返してデフォルトのスキップ動作を抑制
      },
    );

    _tutorialCoachMark!.show(context: context);
  }

  /// 復習モードでチュートリアルを表示
  void showTutorialForReview({
    required BuildContext context,
    required TutorialScreen screen,
    required List<TargetFocus> targets,
    VoidCallback? onFinish,
  }) {
    if (state.isShowingTutorial) return;
    if (targets.isEmpty) return;

    state = state.copyWith(isShowingTutorial: true);

    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.85,
      hideSkip: true,
      paddingFocus: 8,
      pulseEnable: true,
      focusAnimationDuration: const Duration(milliseconds: 400),
      unFocusAnimationDuration: const Duration(milliseconds: 400),
      onFinish: () {
        state = state.copyWith(isShowingTutorial: false);
        onFinish?.call();
      },
      onClickTarget: (target) {},
      onSkip: () {
        state = state.copyWith(isShowingTutorial: false);
        return true;
      },
    );

    _tutorialCoachMark!.show(context: context);
  }

  /// スキップ処理（確認ダイアログなしで直接スキップ）
  Future<void> _handleSkip(
    BuildContext context,
    TutorialScreen screen,
    VoidCallback? onSkip,
  ) async {
    _tutorialCoachMark?.finish();
    await _markCompleted(screen);
    state = state.copyWith(isShowingTutorial: false);
    onSkip?.call();
  }

  /// チュートリアル完了処理
  Future<void> _onTutorialComplete(
    TutorialScreen screen,
    VoidCallback? onFinish,
  ) async {
    await _markCompleted(screen);
    state = state.copyWith(isShowingTutorial: false);
    onFinish?.call();
  }

  /// 完了状態を記録
  Future<void> _markCompleted(TutorialScreen screen) async {
    await _service.setCompleted(screen);

    switch (screen) {
      case TutorialScreen.home:
        state = state.copyWith(homeCompleted: true);
        break;
      case TutorialScreen.recording:
        state = state.copyWith(recordingCompleted: true);
        break;
    }
  }

  /// 全てのチュートリアル状態をリセット（デバッグ用）
  Future<void> resetAll() async {
    await _service.resetAll();
    state = const TutorialState(isInitialized: true);
  }

  /// 現在のチュートリアルを強制終了
  void dismiss() {
    _tutorialCoachMark?.finish();
    state = state.copyWith(isShowingTutorial: false);
  }
}
