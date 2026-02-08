import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/tutorial_screen.dart';

/// チュートリアル完了状態の永続化を管理するサービス
abstract class TutorialService {
  /// 指定画面のチュートリアルが完了済みかを確認
  Future<bool> isCompleted(TutorialScreen screen);

  /// 指定画面のチュートリアルを完了済みとしてマーク
  Future<void> setCompleted(TutorialScreen screen);

  /// 全てのチュートリアル状態をリセット（デバッグ用）
  Future<void> resetAll();
}

/// SharedPreferencesを使用したTutorialServiceの実装
class TutorialServiceImpl implements TutorialService {
  TutorialServiceImpl();

  @override
  Future<bool> isCompleted(TutorialScreen screen) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(screen.storageKey) ?? false;
    } catch (e) {
      // エラー発生時は未完了として扱い、チュートリアルを表示
      debugPrint('TutorialService.isCompleted error: $e');
      return false;
    }
  }

  @override
  Future<void> setCompleted(TutorialScreen screen) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(screen.storageKey, true);
    } catch (e) {
      // エラー発生時はログ出力のみ（次回起動時に再表示される）
      debugPrint('TutorialService.setCompleted error: $e');
    }
  }

  @override
  Future<void> resetAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final screen in TutorialScreen.values) {
        await prefs.remove(screen.storageKey);
      }
    } catch (e) {
      debugPrint('TutorialService.resetAll error: $e');
    }
  }
}
