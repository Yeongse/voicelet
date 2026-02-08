import 'package:freezed_annotation/freezed_annotation.dart';

part 'tutorial_state.freezed.dart';

/// チュートリアル状態モデル
@freezed
class TutorialState with _$TutorialState {
  const factory TutorialState({
    /// ホーム画面チュートリアルが完了済みか
    @Default(false) bool homeCompleted,

    /// 録音画面チュートリアルが完了済みか
    @Default(false) bool recordingCompleted,

    /// 現在チュートリアルを表示中か
    @Default(false) bool isShowingTutorial,

    /// 初期化が完了したか
    @Default(false) bool isInitialized,
  }) = _TutorialState;
}
