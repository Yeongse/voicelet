import 'package:freezed_annotation/freezed_annotation.dart';

part 'follow_models.freezed.dart';
part 'follow_models.g.dart';

/// フォロー状態
enum FollowStatus {
  none,
  following,
  requested,
}

/// フォロー情報付きユーザー
@freezed
class UserWithFollowStatus with _$UserWithFollowStatus {
  const factory UserWithFollowStatus({
    required String id,
    String? name,
    String? bio,
    String? avatarUrl,
    @Default(false) bool isPrivate,
    @Default(FollowStatus.none) FollowStatus followStatus,
  }) = _UserWithFollowStatus;

  factory UserWithFollowStatus.fromJson(Map<String, dynamic> json) {
    final statusStr = json['followStatus'] as String? ?? 'none';
    final status = FollowStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => FollowStatus.none,
    );
    return UserWithFollowStatus(
      id: json['id'] as String,
      name: json['name'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isPrivate: json['isPrivate'] as bool? ?? false,
      followStatus: status,
    );
  }
}

/// ページネーション情報
@freezed
class Pagination with _$Pagination {
  const factory Pagination({
    required int page,
    required int limit,
    required int total,
    required bool hasMore,
  }) = _Pagination;

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);
}

/// ユーザー一覧レスポンス
@freezed
class UserListResponse with _$UserListResponse {
  const factory UserListResponse({
    required List<UserWithFollowStatus> data,
    required Pagination pagination,
  }) = _UserListResponse;

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    return UserListResponse(
      data: (json['data'] as List)
          .map((e) => UserWithFollowStatus.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }
}

/// フォローリクエスト
@freezed
class FollowRequest with _$FollowRequest {
  const factory FollowRequest({
    required String id,
    required FollowRequester requester,
    required String createdAt,
  }) = _FollowRequest;

  factory FollowRequest.fromJson(Map<String, dynamic> json) =>
      _$FollowRequestFromJson(json);
}

/// リクエスト送信者
@freezed
class FollowRequester with _$FollowRequester {
  const factory FollowRequester({
    required String id,
    String? name,
    String? avatarUrl,
  }) = _FollowRequester;

  factory FollowRequester.fromJson(Map<String, dynamic> json) =>
      _$FollowRequesterFromJson(json);
}

/// フォローリクエスト一覧レスポンス
@freezed
class FollowRequestListResponse with _$FollowRequestListResponse {
  const factory FollowRequestListResponse({
    required List<FollowRequest> data,
    required Pagination pagination,
  }) = _FollowRequestListResponse;

  factory FollowRequestListResponse.fromJson(Map<String, dynamic> json) =>
      _$FollowRequestListResponseFromJson(json);
}

/// フォローレスポンス
@freezed
class FollowResponse with _$FollowResponse {
  const factory FollowResponse({
    required String message,
    Follow? follow,
  }) = _FollowResponse;

  factory FollowResponse.fromJson(Map<String, dynamic> json) =>
      _$FollowResponseFromJson(json);
}

/// フォロー情報
@freezed
class Follow with _$Follow {
  const factory Follow({
    required String id,
    required String followerId,
    required String followingId,
    required String createdAt,
  }) = _Follow;

  factory Follow.fromJson(Map<String, dynamic> json) => _$FollowFromJson(json);
}

/// フォローリクエスト作成レスポンス
@freezed
class FollowRequestResponse with _$FollowRequestResponse {
  const factory FollowRequestResponse({
    required String message,
    FollowRequestData? followRequest,
  }) = _FollowRequestResponse;

  factory FollowRequestResponse.fromJson(Map<String, dynamic> json) =>
      _$FollowRequestResponseFromJson(json);
}

/// フォローリクエストデータ
@freezed
class FollowRequestData with _$FollowRequestData {
  const factory FollowRequestData({
    required String id,
    required String requesterId,
    required String targetId,
    required String createdAt,
  }) = _FollowRequestData;

  factory FollowRequestData.fromJson(Map<String, dynamic> json) =>
      _$FollowRequestDataFromJson(json);
}

/// 送信済みフォローリクエスト
@freezed
class SentFollowRequest with _$SentFollowRequest {
  const factory SentFollowRequest({
    required String id,
    required FollowRequestTarget target,
    required String createdAt,
  }) = _SentFollowRequest;

  factory SentFollowRequest.fromJson(Map<String, dynamic> json) =>
      _$SentFollowRequestFromJson(json);
}

/// リクエスト対象ユーザー
@freezed
class FollowRequestTarget with _$FollowRequestTarget {
  const factory FollowRequestTarget({
    required String id,
    String? name,
    String? avatarUrl,
  }) = _FollowRequestTarget;

  factory FollowRequestTarget.fromJson(Map<String, dynamic> json) =>
      _$FollowRequestTargetFromJson(json);
}

/// 送信済みフォローリクエスト一覧レスポンス
@freezed
class SentFollowRequestListResponse with _$SentFollowRequestListResponse {
  const factory SentFollowRequestListResponse({
    required List<SentFollowRequest> data,
    required Pagination pagination,
  }) = _SentFollowRequestListResponse;

  factory SentFollowRequestListResponse.fromJson(Map<String, dynamic> json) =>
      _$SentFollowRequestListResponseFromJson(json);
}
