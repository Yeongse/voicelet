import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voicelet/features/tutorial/models/tutorial_screen.dart';
import 'package:voicelet/features/tutorial/services/tutorial_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TutorialServiceImpl', () {
    late TutorialServiceImpl service;

    setUp(() async {
      // SharedPreferencesのモックを設定
      SharedPreferences.setMockInitialValues({});
      service = TutorialServiceImpl();
    });

    group('isCompleted', () {
      test('初期状態では未完了を返す', () async {
        final result = await service.isCompleted(TutorialScreen.home);
        expect(result, isFalse);
      });

      test('完了済みにした後はtrueを返す', () async {
        await service.setCompleted(TutorialScreen.home);
        final result = await service.isCompleted(TutorialScreen.home);
        expect(result, isTrue);
      });

      test('異なる画面の状態は独立している', () async {
        await service.setCompleted(TutorialScreen.home);

        final homeResult = await service.isCompleted(TutorialScreen.home);
        final recordingResult =
            await service.isCompleted(TutorialScreen.recording);

        expect(homeResult, isTrue);
        expect(recordingResult, isFalse);
      });
    });

    group('setCompleted', () {
      test('完了状態を永続化する', () async {
        await service.setCompleted(TutorialScreen.recording);

        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getBool(TutorialScreen.recording.storageKey);

        expect(stored, isTrue);
      });
    });

    group('resetAll', () {
      test('全ての完了状態をリセットする', () async {
        // 両方を完了済みに
        await service.setCompleted(TutorialScreen.home);
        await service.setCompleted(TutorialScreen.recording);

        // リセット
        await service.resetAll();

        // 両方とも未完了に戻っている
        final homeResult = await service.isCompleted(TutorialScreen.home);
        final recordingResult =
            await service.isCompleted(TutorialScreen.recording);

        expect(homeResult, isFalse);
        expect(recordingResult, isFalse);
      });
    });
  });

  group('TutorialScreen', () {
    test('storageKeyが正しく生成される', () {
      expect(TutorialScreen.home.storageKey, 'tutorial_home_completed');
      expect(
          TutorialScreen.recording.storageKey, 'tutorial_recording_completed');
    });
  });
}
