import 'dart:io';
import '../../../core/api/api_client.dart';
import '../models/whisper.dart';

/// Whisper API例外
class WhisperApiException implements Exception {
  final String message;
  final int? statusCode;

  WhisperApiException(this.message, {this.statusCode});

  @override
  String toString() => 'WhisperApiException: $message (status: $statusCode)';
}

/// Whisper APIサービス
class WhisperApiService {
  final ApiClient _apiClient;

  WhisperApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// 署名付きURLを取得
  Future<SignedUrlResponse> getSignedUrl({
    required String fileName,
    required String userId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/whispers/signed-url',
        data: {
          'fileName': fileName,
          'userId': userId,
        },
      );

      return SignedUrlResponse.fromJson(response.data);
    } catch (e) {
      throw WhisperApiException('署名付きURLの取得に失敗しました: $e');
    }
  }

  /// GCSに音声ファイルをアップロード
  Future<void> uploadToGcs({
    required String signedUrl,
    required String filePath,
  }) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();

      // DioではなくHttpClientを使用（署名付きURLは外部URL）
      final uri = Uri.parse(signedUrl);
      final httpClient = HttpClient();
      final request = await httpClient.putUrl(uri);

      request.headers.set('Content-Type', 'audio/mp4');
      request.headers.set('Content-Length', bytes.length.toString());
      request.add(bytes);

      final response = await request.close();

      if (response.statusCode != 200) {
        throw WhisperApiException(
          'アップロードに失敗しました',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is WhisperApiException) rethrow;
      throw WhisperApiException('アップロード中にエラーが発生しました: $e');
    }
  }

  /// Whisperを作成
  Future<CreateWhisperResponse> createWhisper({
    required String userId,
    required String fileName,
    required int duration,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/whispers',
        data: {
          'userId': userId,
          'fileName': fileName,
          'duration': duration,
        },
      );

      return CreateWhisperResponse.fromJson(response.data);
    } catch (e) {
      throw WhisperApiException('投稿の作成に失敗しました: $e');
    }
  }

  /// Whisper一覧を取得
  Future<List<Whisper>> getWhispers() async {
    try {
      final response = await _apiClient.dio.get('/api/whispers');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Whisper.fromJson(json)).toList();
    } catch (e) {
      throw WhisperApiException('投稿一覧の取得に失敗しました: $e');
    }
  }

  /// 再生用署名付きURLを取得
  Future<AudioUrlResponse> getAudioUrl(String whisperId) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/whispers/$whisperId/audio-url',
      );
      return AudioUrlResponse.fromJson(response.data);
    } catch (e) {
      throw WhisperApiException('再生URLの取得に失敗しました: $e');
    }
  }

  /// 投稿フロー全体を実行
  /// 1. 署名付きURL取得
  /// 2. GCSにアップロード
  /// 3. Whisper作成
  Future<Whisper> postWhisper({
    required String userId,
    required String filePath,
    required String fileName,
    required int durationSeconds,
  }) async {
    // 1. 署名付きURL取得
    final signedUrlResponse = await getSignedUrl(
      fileName: fileName,
      userId: userId,
    );

    // 2. GCSにアップロード
    await uploadToGcs(
      signedUrl: signedUrlResponse.signedUrl,
      filePath: filePath,
    );

    // 3. Whisper作成
    final createResponse = await createWhisper(
      userId: userId,
      fileName: fileName,
      duration: durationSeconds,
    );

    return createResponse.whisper;
  }
}
