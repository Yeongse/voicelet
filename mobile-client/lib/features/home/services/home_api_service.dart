import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../models/home_models.dart';

class HomeApiService {
  final ApiClient _apiClient = ApiClient();

  /// フォロー中ユーザーのストーリー取得
  Future<StoriesResponse> getStories({required String userId}) async {
    final response = await _apiClient.dio.get(
      '/api/stories',
      queryParameters: {'userId': userId},
    );
    return StoriesResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// 自分のWhisper一覧取得
  Future<List<MyWhisper>> getMyWhispers({required String userId}) async {
    final response = await _apiClient.dio.get(
      '/api/whispers',
      queryParameters: {'userId': userId, 'limit': 20},
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['data'] as List;
    return items.map((e) => MyWhisper.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// おすすめユーザー一覧取得
  Future<DiscoverResponse> getDiscover({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.dio.get(
      '/api/discover',
      queryParameters: {'userId': userId, 'page': page, 'limit': limit},
    );
    return DiscoverResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// おすすめユーザーのストーリー取得
  Future<DiscoverStoriesResponse> getDiscoverUserStories({
    required String userId,
    required String targetUserId,
  }) async {
    final response = await _apiClient.dio.get(
      '/api/discover/$targetUserId/stories',
      queryParameters: {'userId': userId},
    );
    return DiscoverStoriesResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// フォロー
  Future<void> follow({
    required String followingId,
  }) async {
    await _apiClient.dio.post(
      '/api/follows',
      data: {'followingId': followingId},
    );
  }

  /// アンフォロー
  Future<void> unfollow({
    required String followingId,
  }) async {
    await _apiClient.dio.delete(
      '/api/follows/$followingId',
      options: Options(contentType: null),
    );
  }

  /// 視聴履歴記録
  Future<void> recordView({
    required String userId,
    required String whisperId,
  }) async {
    await _apiClient.dio.post(
      '/api/whisper-views',
      data: {'userId': userId, 'whisperId': whisperId},
    );
  }

  /// Whisper音声URL取得
  Future<String> getAudioUrl({required String whisperId}) async {
    final response = await _apiClient.dio.get('/api/whispers/$whisperId/audio-url');
    final data = response.data as Map<String, dynamic>;
    return data['signedUrl'] as String;
  }

  /// ストーリー閲覧者一覧取得
  Future<ViewersResponse> getViewers({
    required String whisperId,
    required String userId,
  }) async {
    final response = await _apiClient.dio.get(
      '/api/whispers/$whisperId/viewers',
      queryParameters: {'userId': userId},
    );
    return ViewersResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// ストーリー削除
  Future<void> deleteWhisper({
    required String whisperId,
    required String userId,
  }) async {
    await _apiClient.dio.delete(
      '/api/whispers/$whisperId',
      queryParameters: {'userId': userId},
      options: Options(contentType: null),
    );
  }
}
