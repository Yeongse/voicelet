import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../models/follow_models.dart';

class FollowApiService {
  final Dio _dio = ApiClient().dio;

  /// フォロー（公開アカウント）またはフォローリクエスト送信（鍵垢）
  /// 201: フォロー作成、202: リクエスト送信
  Future<({bool isFollowed, String? requestId})> follow(String userId) async {
    final response = await _dio.post('/api/follows', data: {'followingId': userId});

    if (response.statusCode == 201) {
      return (isFollowed: true, requestId: null);
    } else if (response.statusCode == 202) {
      final data = response.data as Map<String, dynamic>;
      final requestId = (data['followRequest'] as Map<String, dynamic>?)?['id'] as String?;
      return (isFollowed: false, requestId: requestId);
    }
    throw Exception('Unexpected status code: ${response.statusCode}');
  }

  /// アンフォロー
  Future<void> unfollow(String userId) async {
    await _dio.delete('/api/follows/$userId');
  }

  /// フォロワー削除
  Future<void> removeFollower(String userId) async {
    await _dio.delete('/api/followers/$userId');
  }

  /// フォロー中ユーザー一覧取得
  Future<UserListResponse> getFollowing(String userId, {int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      '/api/users/$userId/following',
      queryParameters: {'page': page, 'limit': limit},
    );
    return UserListResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// フォロワー一覧取得
  Future<UserListResponse> getFollowers(String userId, {int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      '/api/users/$userId/followers',
      queryParameters: {'page': page, 'limit': limit},
    );
    return UserListResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// フォローリクエスト一覧取得（受信）
  Future<FollowRequestListResponse> getFollowRequests({int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      '/api/follow-requests',
      queryParameters: {'page': page, 'limit': limit},
    );
    return FollowRequestListResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// 送信済みフォローリクエスト一覧取得
  Future<SentFollowRequestListResponse> getSentFollowRequests({int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      '/api/follow-requests/sent',
      queryParameters: {'page': page, 'limit': limit},
    );
    return SentFollowRequestListResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// フォローリクエスト数取得
  Future<int> getFollowRequestCount() async {
    final response = await _dio.get('/api/follow-requests/count');
    return (response.data as Map<String, dynamic>)['count'] as int;
  }

  /// フォローリクエスト承認
  Future<Follow> approveRequest(String requestId) async {
    final response = await _dio.post(
      '/api/follow-requests/$requestId/approve',
      data: <String, dynamic>{},
    );
    final data = response.data as Map<String, dynamic>;
    return Follow.fromJson(data['follow'] as Map<String, dynamic>);
  }

  /// フォローリクエスト拒否
  Future<void> rejectRequest(String requestId) async {
    await _dio.post(
      '/api/follow-requests/$requestId/reject',
      data: <String, dynamic>{},
    );
  }

  /// フォローリクエスト取消
  Future<void> cancelRequest(String requestId) async {
    await _dio.delete(
      '/api/follow-requests/$requestId',
      data: <String, dynamic>{},
    );
  }
}
