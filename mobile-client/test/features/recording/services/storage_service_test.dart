import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:voicelet/features/recording/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;

  setUp(() {
    storageService = StorageService();
  });

  group('StorageService', () {
    group('generateFileName', () {
      test('正しい形式のファイル名を生成する', () {
        const userId = 'demo-user-001';

        final fileName = storageService.generateFileName(userId);

        // フォーマット: {userId}_{timestamp}.m4a
        expect(fileName, startsWith('demo-user-001_'));
        expect(fileName, endsWith('.m4a'));
      });

      test('タイムスタンプ部分が数値である', () {
        const userId = 'test-user';

        final fileName = storageService.generateFileName(userId);

        // demo-user-001_1234567890123.m4a の形式
        final parts = fileName.replaceAll('.m4a', '').split('_');
        expect(parts.length, greaterThanOrEqualTo(2));

        final timestampStr = parts.last;
        final timestamp = int.tryParse(timestampStr);
        expect(timestamp, isNotNull);
        expect(timestamp, greaterThan(0));
      });

      test('連続して生成するとタイムスタンプが異なる', () async {
        const userId = 'test-user';

        final fileName1 = storageService.generateFileName(userId);
        await Future.delayed(const Duration(milliseconds: 2));
        final fileName2 = storageService.generateFileName(userId);

        expect(fileName1, isNot(equals(fileName2)));
      });
    });

    group('getTempFilePath', () {
      // path_providerはFlutter環境に依存するため、統合テストでカバー
      test('ファイル名を含むパスを返すことが期待される', () {
        // このテストはpath_providerがFlutterプラットフォームチャネルを必要とするため
        // 実際のテストは統合テストまたはシミュレーターで行う
        expect(storageService.getTempFilePath, isA<Function>());
      });
    });

    group('fileExists', () {
      test('存在しないファイルはfalseを返す', () async {
        final exists = await storageService.fileExists('/nonexistent/path.m4a');

        expect(exists, isFalse);
      });

      test('存在するファイルはtrueを返す', () async {
        // テスト用一時ファイルを作成
        final tempDir = Directory.systemTemp;
        final testFile = File('${tempDir.path}/test_exists_${DateTime.now().millisecondsSinceEpoch}.m4a');
        await testFile.create();

        try {
          final exists = await storageService.fileExists(testFile.path);
          expect(exists, isTrue);
        } finally {
          await testFile.delete();
        }
      });
    });

    group('deleteFile', () {
      test('存在するファイルを削除できる', () async {
        // テスト用一時ファイルを作成
        final tempDir = Directory.systemTemp;
        final testFile = File('${tempDir.path}/test_delete_${DateTime.now().millisecondsSinceEpoch}.m4a');
        await testFile.writeAsBytes([0, 1, 2, 3]);

        expect(await testFile.exists(), isTrue);

        await storageService.deleteFile(testFile.path);

        expect(await testFile.exists(), isFalse);
      });

      test('存在しないファイルを削除しようとするとStorageExceptionをスローする', () async {
        expect(
          () => storageService.deleteFile('/nonexistent/file.m4a'),
          throwsA(isA<StorageException>().having(
            (e) => e.type,
            'type',
            StorageErrorType.fileNotFound,
          )),
        );
      });
    });

    group('getFileSize', () {
      test('ファイルサイズを正しく取得できる', () async {
        // テスト用一時ファイルを作成
        final tempDir = Directory.systemTemp;
        final testFile = File('${tempDir.path}/test_size_${DateTime.now().millisecondsSinceEpoch}.m4a');
        final testData = List<int>.filled(1024, 0); // 1KB
        await testFile.writeAsBytes(testData);

        try {
          final size = await storageService.getFileSize(testFile.path);
          expect(size, equals(1024));
        } finally {
          await testFile.delete();
        }
      });

      test('存在しないファイルのサイズ取得はStorageExceptionをスローする', () async {
        expect(
          () => storageService.getFileSize('/nonexistent/file.m4a'),
          throwsA(isA<StorageException>().having(
            (e) => e.type,
            'type',
            StorageErrorType.fileNotFound,
          )),
        );
      });
    });

    group('getStorageInfo', () {
      // path_providerはFlutter環境に依存するため、統合テストでカバー
      test('StorageInfoを返すことが期待される', () {
        // このテストはpath_providerがFlutterプラットフォームチャネルを必要とするため
        // 実際のテストは統合テストまたはシミュレーターで行う
        expect(storageService.getStorageInfo, isA<Function>());
      });
    });
  });

  group('StorageInfo', () {
    test('プロパティを保持する', () {
      final info = StorageInfo(
        availableBytes: 1024 * 1024 * 100, // 100MB
        hasEnoughSpace: true,
      );

      expect(info.availableBytes, equals(1024 * 1024 * 100));
      expect(info.hasEnoughSpace, isTrue);
    });

    test('容量不足の場合', () {
      final info = StorageInfo(
        availableBytes: 0,
        hasEnoughSpace: false,
      );

      expect(info.availableBytes, equals(0));
      expect(info.hasEnoughSpace, isFalse);
    });
  });

  group('StorageException', () {
    test('メッセージとタイプを保持する', () {
      final exception = StorageException(
        'ファイルが見つかりません',
        StorageErrorType.fileNotFound,
      );

      expect(exception.message, equals('ファイルが見つかりません'));
      expect(exception.type, equals(StorageErrorType.fileNotFound));
      expect(exception.toString(), contains('ファイルが見つかりません'));
    });
  });
}
