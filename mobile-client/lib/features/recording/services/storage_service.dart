import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// ストレージエラーの種類
enum StorageErrorType {
  insufficientSpace,
  fileNotFound,
  accessDenied,
  unknown,
}

/// ストレージ例外
class StorageException implements Exception {
  final String message;
  final StorageErrorType type;

  StorageException(this.message, this.type);

  @override
  String toString() => 'StorageException: $message (type: $type)';
}

/// ストレージ情報
class StorageInfo {
  final int availableBytes;
  final bool hasEnoughSpace;

  StorageInfo({
    required this.availableBytes,
    required this.hasEnoughSpace,
  });
}

/// 録音ファイルのローカル保存・削除を管理するサービス
class StorageService {
  /// 最小必要容量（10MB）
  static const int minRequiredBytes = 10 * 1024 * 1024;

  /// ユニークなファイル名を生成
  /// フォーマット: {userId}_{timestamp}.m4a
  String generateFileName(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${userId}_$timestamp.m4a';
  }

  /// 一時保存用のファイルパスを生成
  Future<String> getTempFilePath(String fileName) async {
    final directory = await getTemporaryDirectory();
    return '${directory.path}/$fileName';
  }

  /// ファイルが存在するか確認
  Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    return file.exists();
  }

  /// ファイルを削除
  Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      try {
        await file.delete();
      } on FileSystemException catch (e) {
        throw StorageException(
          'ファイルの削除に失敗しました: ${e.message}',
          StorageErrorType.accessDenied,
        );
      }
    } else {
      throw StorageException(
        'ファイルが見つかりません: $filePath',
        StorageErrorType.fileNotFound,
      );
    }
  }

  /// ストレージ容量を確認
  Future<StorageInfo> getStorageInfo() async {
    try {
      final directory = await getTemporaryDirectory();

      // iOSでは正確な空き容量を取得するのが難しいため、
      // ファイルシステムのアクセス可能性を確認
      // 実際のアプリでは、録音前に十分な容量があるかを確認
      final testFile = File('${directory.path}/.storage_check');
      try {
        await testFile.writeAsBytes([0]);
        await testFile.delete();
        return StorageInfo(
          availableBytes: minRequiredBytes * 10, // 推定値
          hasEnoughSpace: true,
        );
      } catch (e) {
        return StorageInfo(
          availableBytes: 0,
          hasEnoughSpace: false,
        );
      }
    } catch (e) {
      throw StorageException(
        'ストレージ情報の取得に失敗しました',
        StorageErrorType.unknown,
      );
    }
  }

  /// ファイルサイズを取得
  Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return file.length();
    }
    throw StorageException(
      'ファイルが見つかりません: $filePath',
      StorageErrorType.fileNotFound,
    );
  }
}
