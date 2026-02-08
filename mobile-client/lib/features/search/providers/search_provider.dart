import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/search_user.dart';
import '../services/search_api_service.dart';

part 'search_provider.g.dart';

@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void update(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

@riverpod
Future<SearchUsersResponse> searchUsers(
  SearchUsersRef ref, {
  required String query,
  int page = 1,
  int limit = 20,
}) async {
  if (query.isEmpty) {
    return const SearchUsersResponse(
      data: [],
      pagination: SearchPagination(
        total: 0,
        page: 1,
        limit: 20,
        totalPages: 0,
        hasNext: false,
        hasPrev: false,
      ),
    );
  }

  final currentUserId = ref.watch(currentUserIdProvider);
  final searchService = SearchApiService();
  return searchService.searchUsers(
    query: query,
    userId: currentUserId,
    page: page,
    limit: limit,
  );
}
