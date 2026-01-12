import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_models.freezed.dart';
part 'home_models.g.dart';

/// ストーリー内の個別アイテム
@freezed
class StoryItem with _$StoryItem {
  const factory StoryItem({
    required String id,
    required int duration,
    required String createdAt,
    @Default(false) bool isViewed,
  }) = _StoryItem;

  factory StoryItem.fromJson(Map<String, dynamic> json) =>
      _$StoryItemFromJson(json);
}

/// ストーリー用ユーザー情報
@freezed
class StoryUser with _$StoryUser {
  const factory StoryUser({
    required String id,
    required String name,
    String? avatarUrl,
  }) = _StoryUser;

  factory StoryUser.fromJson(Map<String, dynamic> json) =>
      _$StoryUserFromJson(json);
}

/// ユーザーごとのストーリー
@freezed
class UserStory with _$UserStory {
  const factory UserStory({
    required StoryUser user,
    required List<StoryItem> stories,
    @Default(true) bool hasUnviewed,
  }) = _UserStory;

  factory UserStory.fromJson(Map<String, dynamic> json) =>
      _$UserStoryFromJson(json);
}

/// ストーリー一覧レスポンス
@freezed
class StoriesResponse with _$StoriesResponse {
  const factory StoriesResponse({
    required List<UserStory> data,
  }) = _StoriesResponse;

  factory StoriesResponse.fromJson(Map<String, dynamic> json) =>
      _$StoriesResponseFromJson(json);
}

/// おすすめユーザー
@freezed
class DiscoverUser with _$DiscoverUser {
  const factory DiscoverUser({
    required String id,
    required String name,
    String? bio,
    String? avatarUrl,
    required int whisperCount,
    required String latestWhisperAt,
    @Default(true) bool hasUnviewed,
  }) = _DiscoverUser;

  factory DiscoverUser.fromJson(Map<String, dynamic> json) =>
      _$DiscoverUserFromJson(json);
}

/// ページネーション
@freezed
class Pagination with _$Pagination {
  const factory Pagination({
    required int total,
    required int page,
    required int limit,
    required int totalPages,
    required bool hasNext,
    required bool hasPrev,
  }) = _Pagination;

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);
}

/// おすすめユーザー一覧レスポンス
@freezed
class DiscoverResponse with _$DiscoverResponse {
  const factory DiscoverResponse({
    required List<DiscoverUser> data,
    required Pagination pagination,
  }) = _DiscoverResponse;

  factory DiscoverResponse.fromJson(Map<String, dynamic> json) =>
      _$DiscoverResponseFromJson(json);
}

/// おすすめユーザーのストーリーレスポンス
@freezed
class DiscoverStoriesResponse with _$DiscoverStoriesResponse {
  const factory DiscoverStoriesResponse({
    StoryUser? user,
    required List<StoryItem> stories,
    @Default(true) bool hasUnviewed,
  }) = _DiscoverStoriesResponse;

  factory DiscoverStoriesResponse.fromJson(Map<String, dynamic> json) =>
      _$DiscoverStoriesResponseFromJson(json);
}

/// My Story用のWhisper
@freezed
class MyWhisper with _$MyWhisper {
  const factory MyWhisper({
    required String id,
    required String userId,
    required String bucketName,
    required String fileName,
    required int duration,
    required String createdAt,
    required String expiresAt,
  }) = _MyWhisper;

  factory MyWhisper.fromJson(Map<String, dynamic> json) =>
      _$MyWhisperFromJson(json);
}
