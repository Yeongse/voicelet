import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/whisper.dart';
import '../services/whisper_api_service.dart';

/// 投稿状態
enum PostingState {
  idle,
  gettingSignedUrl,
  uploading,
  creating,
  success,
  error,
}

/// 投稿の進捗状態
class PostingProgress {
  final PostingState state;
  final String? errorMessage;
  final Whisper? whisper;

  const PostingProgress({
    required this.state,
    this.errorMessage,
    this.whisper,
  });

  factory PostingProgress.idle() => const PostingProgress(state: PostingState.idle);

  factory PostingProgress.gettingSignedUrl() =>
      const PostingProgress(state: PostingState.gettingSignedUrl);

  factory PostingProgress.uploading() =>
      const PostingProgress(state: PostingState.uploading);

  factory PostingProgress.creating() =>
      const PostingProgress(state: PostingState.creating);

  factory PostingProgress.success(Whisper whisper) =>
      PostingProgress(state: PostingState.success, whisper: whisper);

  factory PostingProgress.error(String message) =>
      PostingProgress(state: PostingState.error, errorMessage: message);

  bool get isLoading =>
      state == PostingState.gettingSignedUrl ||
      state == PostingState.uploading ||
      state == PostingState.creating;

  String get statusMessage {
    switch (state) {
      case PostingState.idle:
        return '';
      case PostingState.gettingSignedUrl:
        return '準備中...';
      case PostingState.uploading:
        return 'アップロード中...';
      case PostingState.creating:
        return '投稿を作成中...';
      case PostingState.success:
        return '投稿しました';
      case PostingState.error:
        return errorMessage ?? 'エラーが発生しました';
    }
  }
}

/// WhisperAPIサービスプロバイダー
final whisperApiServiceProvider = Provider<WhisperApiService>((ref) {
  return WhisperApiService();
});

/// 投稿進捗プロバイダー
final postingProgressProvider =
    StateNotifierProvider<PostingProgressNotifier, PostingProgress>((ref) {
  return PostingProgressNotifier(ref.watch(whisperApiServiceProvider));
});

class PostingProgressNotifier extends StateNotifier<PostingProgress> {
  final WhisperApiService _apiService;

  PostingProgressNotifier(this._apiService) : super(PostingProgress.idle());

  /// 音声を投稿
  Future<Whisper?> postWhisper({
    required String userId,
    required String filePath,
    required String fileName,
    required int durationSeconds,
  }) async {
    try {
      // 1. 署名付きURL取得
      state = PostingProgress.gettingSignedUrl();
      final signedUrlResponse = await _apiService.getSignedUrl(
        fileName: fileName,
        userId: userId,
      );

      // 2. アップロード
      state = PostingProgress.uploading();
      await _apiService.uploadToGcs(
        signedUrl: signedUrlResponse.signedUrl,
        filePath: filePath,
      );

      // 3. Whisper作成
      state = PostingProgress.creating();
      final response = await _apiService.createWhisper(
        userId: userId,
        fileName: fileName,
        duration: durationSeconds,
      );

      state = PostingProgress.success(response.whisper);
      return response.whisper;
    } on WhisperApiException catch (e) {
      state = PostingProgress.error(e.message);
      return null;
    } catch (e) {
      state = PostingProgress.error('予期しないエラーが発生しました');
      return null;
    }
  }

  /// 状態をリセット
  void reset() {
    state = PostingProgress.idle();
  }
}

/// Whisper一覧プロバイダー
final whispersProvider = FutureProvider<List<Whisper>>((ref) async {
  final apiService = ref.watch(whisperApiServiceProvider);
  return apiService.getWhispers();
});
