import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_user.freezed.dart';
part 'search_user.g.dart';

@freezed
class SearchUser with _$SearchUser {
  const factory SearchUser({
    required String id,
    String? username,
    String? name,
    String? avatarUrl,
    @Default(false) bool isPrivate,
    @Default('none') String followStatus,
  }) = _SearchUser;

  factory SearchUser.fromJson(Map<String, dynamic> json) =>
      _$SearchUserFromJson(json);
}

@freezed
class SearchUsersResponse with _$SearchUsersResponse {
  const factory SearchUsersResponse({
    required List<SearchUser> data,
    required SearchPagination pagination,
  }) = _SearchUsersResponse;

  factory SearchUsersResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchUsersResponseFromJson(json);
}

@freezed
class SearchPagination with _$SearchPagination {
  const factory SearchPagination({
    required int total,
    required int page,
    required int limit,
    required int totalPages,
    required bool hasNext,
    required bool hasPrev,
  }) = _SearchPagination;

  factory SearchPagination.fromJson(Map<String, dynamic> json) =>
      _$SearchPaginationFromJson(json);
}
