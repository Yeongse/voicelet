// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoryItemImpl _$$StoryItemImplFromJson(Map<String, dynamic> json) =>
    _$StoryItemImpl(
      id: json['id'] as String,
      duration: (json['duration'] as num).toInt(),
      createdAt: json['createdAt'] as String,
      isViewed: json['isViewed'] as bool? ?? false,
    );

Map<String, dynamic> _$$StoryItemImplToJson(_$StoryItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'duration': instance.duration,
      'createdAt': instance.createdAt,
      'isViewed': instance.isViewed,
    };

_$StoryUserImpl _$$StoryUserImplFromJson(Map<String, dynamic> json) =>
    _$StoryUserImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$$StoryUserImplToJson(_$StoryUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
    };

_$UserStoryImpl _$$UserStoryImplFromJson(Map<String, dynamic> json) =>
    _$UserStoryImpl(
      user: StoryUser.fromJson(json['user'] as Map<String, dynamic>),
      stories: (json['stories'] as List<dynamic>)
          .map((e) => StoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasUnviewed: json['hasUnviewed'] as bool? ?? true,
    );

Map<String, dynamic> _$$UserStoryImplToJson(_$UserStoryImpl instance) =>
    <String, dynamic>{
      'user': instance.user,
      'stories': instance.stories,
      'hasUnviewed': instance.hasUnviewed,
    };

_$StoriesResponseImpl _$$StoriesResponseImplFromJson(
  Map<String, dynamic> json,
) => _$StoriesResponseImpl(
  data: (json['data'] as List<dynamic>)
      .map((e) => UserStory.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$StoriesResponseImplToJson(
  _$StoriesResponseImpl instance,
) => <String, dynamic>{'data': instance.data};

_$DiscoverUserImpl _$$DiscoverUserImplFromJson(Map<String, dynamic> json) =>
    _$DiscoverUserImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      whisperCount: (json['whisperCount'] as num).toInt(),
      latestWhisperAt: json['latestWhisperAt'] as String,
      hasUnviewed: json['hasUnviewed'] as bool? ?? true,
    );

Map<String, dynamic> _$$DiscoverUserImplToJson(_$DiscoverUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'bio': instance.bio,
      'avatarUrl': instance.avatarUrl,
      'whisperCount': instance.whisperCount,
      'latestWhisperAt': instance.latestWhisperAt,
      'hasUnviewed': instance.hasUnviewed,
    };

_$PaginationImpl _$$PaginationImplFromJson(Map<String, dynamic> json) =>
    _$PaginationImpl(
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      hasNext: json['hasNext'] as bool,
      hasPrev: json['hasPrev'] as bool,
    );

Map<String, dynamic> _$$PaginationImplToJson(_$PaginationImpl instance) =>
    <String, dynamic>{
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'totalPages': instance.totalPages,
      'hasNext': instance.hasNext,
      'hasPrev': instance.hasPrev,
    };

_$DiscoverResponseImpl _$$DiscoverResponseImplFromJson(
  Map<String, dynamic> json,
) => _$DiscoverResponseImpl(
  data: (json['data'] as List<dynamic>)
      .map((e) => DiscoverUser.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$DiscoverResponseImplToJson(
  _$DiscoverResponseImpl instance,
) => <String, dynamic>{
  'data': instance.data,
  'pagination': instance.pagination,
};

_$DiscoverStoriesResponseImpl _$$DiscoverStoriesResponseImplFromJson(
  Map<String, dynamic> json,
) => _$DiscoverStoriesResponseImpl(
  user: json['user'] == null
      ? null
      : StoryUser.fromJson(json['user'] as Map<String, dynamic>),
  stories: (json['stories'] as List<dynamic>)
      .map((e) => StoryItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  hasUnviewed: json['hasUnviewed'] as bool? ?? true,
);

Map<String, dynamic> _$$DiscoverStoriesResponseImplToJson(
  _$DiscoverStoriesResponseImpl instance,
) => <String, dynamic>{
  'user': instance.user,
  'stories': instance.stories,
  'hasUnviewed': instance.hasUnviewed,
};

_$MyWhisperImpl _$$MyWhisperImplFromJson(Map<String, dynamic> json) =>
    _$MyWhisperImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      bucketName: json['bucketName'] as String,
      fileName: json['fileName'] as String,
      duration: (json['duration'] as num).toInt(),
      createdAt: json['createdAt'] as String,
      expiresAt: json['expiresAt'] as String,
    );

Map<String, dynamic> _$$MyWhisperImplToJson(_$MyWhisperImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'bucketName': instance.bucketName,
      'fileName': instance.fileName,
      'duration': instance.duration,
      'createdAt': instance.createdAt,
      'expiresAt': instance.expiresAt,
    };

_$WhisperViewerImpl _$$WhisperViewerImplFromJson(Map<String, dynamic> json) =>
    _$WhisperViewerImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      viewedAt: json['viewedAt'] as String,
    );

Map<String, dynamic> _$$WhisperViewerImplToJson(_$WhisperViewerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'viewedAt': instance.viewedAt,
    };

_$ViewersResponseImpl _$$ViewersResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ViewersResponseImpl(
  data: (json['data'] as List<dynamic>)
      .map((e) => WhisperViewer.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['totalCount'] as num).toInt(),
);

Map<String, dynamic> _$$ViewersResponseImplToJson(
  _$ViewersResponseImpl instance,
) => <String, dynamic>{
  'data': instance.data,
  'totalCount': instance.totalCount,
};
