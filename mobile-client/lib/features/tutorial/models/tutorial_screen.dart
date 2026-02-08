/// チュートリアル画面の識別子
enum TutorialScreen {
  /// ホーム画面チュートリアル
  home,

  /// 録音画面チュートリアル
  recording;

  /// SharedPreferences用のストレージキーを取得
  String get storageKey => 'tutorial_${name}_completed';
}
