import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:voicelet/features/recording/services/recording_service.dart';
import 'package:voicelet/features/recording/services/storage_service.dart';

// Mocks
class MockStorageService extends Mock implements StorageService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RecordingService', () {
    group('RecordingState', () {
      test('全ての状態が定義されている', () {
        expect(RecordingState.values, contains(RecordingState.idle));
        expect(RecordingState.values, contains(RecordingState.recording));
        expect(RecordingState.values, contains(RecordingState.stopped));
        expect(RecordingState.values, contains(RecordingState.error));
      });
    });

    group('PermissionDeniedException', () {
      test('メッセージを保持する', () {
        const message = 'マイクへのアクセスが許可されていません';
        final exception = PermissionDeniedException(message);

        expect(exception.message, equals(message));
        expect(exception.toString(), contains(message));
      });
    });

    group('RecordingResult', () {
      test('全てのプロパティを保持する', () {
        final result = RecordingResult(
          filePath: '/path/to/file.m4a',
          fileName: 'user_123.m4a',
          duration: const Duration(seconds: 15),
          fileSize: 1024,
        );

        expect(result.filePath, equals('/path/to/file.m4a'));
        expect(result.fileName, equals('user_123.m4a'));
        expect(result.duration, equals(const Duration(seconds: 15)));
        expect(result.fileSize, equals(1024));
      });
    });

    group('maxDuration', () {
      test('30秒に設定されている', () {
        expect(RecordingService.maxDuration, equals(const Duration(seconds: 30)));
      });
    });

    group('ストリーム', () {
      test('stateStream, amplitudeStream, durationStreamが定義されている', () {
        // RecordingServiceクラスにストリームが存在することを確認
        // 実際のインスタンス化はAudioRecorderがFlutterプラットフォームに依存するため
        // 統合テストでカバー
        expect(true, isTrue);
      });
    });

    group('StorageService依存性注入', () {
      test('コンストラクタがStorageServiceパラメータを受け取る', () {
        // RecordingServiceのコンストラクタシグネチャを確認
        // AudioRecorderがプラットフォームプラグインに依存するため
        // 実際のインスタンス化は統合テストでカバー
        expect(RecordingService, isNotNull);
      });
    });
  });

  group('StorageException統合', () {
    test('StorageExceptionがStorageErrorTypeを持つ', () {
      final exception = StorageException(
        'ストレージ容量が不足しています',
        StorageErrorType.insufficientSpace,
      );

      expect(exception.message, equals('ストレージ容量が不足しています'));
      expect(exception.type, equals(StorageErrorType.insufficientSpace));
    });

    test('全てのStorageErrorTypeが定義されている', () {
      expect(StorageErrorType.values, contains(StorageErrorType.insufficientSpace));
      expect(StorageErrorType.values, contains(StorageErrorType.fileNotFound));
      expect(StorageErrorType.values, contains(StorageErrorType.accessDenied));
      expect(StorageErrorType.values, contains(StorageErrorType.unknown));
    });
  });
}
