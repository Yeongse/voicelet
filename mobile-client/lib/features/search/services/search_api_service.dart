import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../models/search_user.dart';

class SearchApiService {
  final Dio _dio = ApiClient().dio;

  Future<SearchUsersResponse> searchUsers({
    required String query,
    String? userId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/api/search/users',
      queryParameters: {
        'query': query,
        if (userId != null) 'userId': userId,
        'page': page,
        'limit': limit,
      },
    );
    return SearchUsersResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<bool> checkUsernameAvailability(String username) async {
    final response = await _dio.get(
      '/api/usernames/check',
      queryParameters: {'username': username},
    );
    final data = response.data as Map<String, dynamic>;
    return data['available'] as bool;
  }
}
