// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaginationImpl _$$PaginationImplFromJson(Map<String, dynamic> json) =>
    _$PaginationImpl(
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      hasMore: json['hasMore'] as bool,
    );

Map<String, dynamic> _$$PaginationImplToJson(_$PaginationImpl instance) =>
    <String, dynamic>{
      'page': instance.page,
      'limit': instance.limit,
      'total': instance.total,
      'hasMore': instance.hasMore,
    };

_$FollowRequestImpl _$$FollowRequestImplFromJson(Map<String, dynamic> json) =>
    _$FollowRequestImpl(
      id: json['id'] as String,
      requester: FollowRequester.fromJson(
        json['requester'] as Map<String, dynamic>,
      ),
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$$FollowRequestImplToJson(_$FollowRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'requester': instance.requester,
      'createdAt': instance.createdAt,
    };

_$FollowRequesterImpl _$$FollowRequesterImplFromJson(
  Map<String, dynamic> json,
) => _$FollowRequesterImpl(
  id: json['id'] as String,
  name: json['name'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
);

Map<String, dynamic> _$$FollowRequesterImplToJson(
  _$FollowRequesterImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'avatarUrl': instance.avatarUrl,
};

_$FollowRequestListResponseImpl _$$FollowRequestListResponseImplFromJson(
  Map<String, dynamic> json,
) => _$FollowRequestListResponseImpl(
  data: (json['data'] as List<dynamic>)
      .map((e) => FollowRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$FollowRequestListResponseImplToJson(
  _$FollowRequestListResponseImpl instance,
) => <String, dynamic>{
  'data': instance.data,
  'pagination': instance.pagination,
};

_$FollowResponseImpl _$$FollowResponseImplFromJson(Map<String, dynamic> json) =>
    _$FollowResponseImpl(
      message: json['message'] as String,
      follow: json['follow'] == null
          ? null
          : Follow.fromJson(json['follow'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$FollowResponseImplToJson(
  _$FollowResponseImpl instance,
) => <String, dynamic>{'message': instance.message, 'follow': instance.follow};

_$FollowImpl _$$FollowImplFromJson(Map<String, dynamic> json) => _$FollowImpl(
  id: json['id'] as String,
  followerId: json['followerId'] as String,
  followingId: json['followingId'] as String,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$$FollowImplToJson(_$FollowImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'followerId': instance.followerId,
      'followingId': instance.followingId,
      'createdAt': instance.createdAt,
    };

_$FollowRequestResponseImpl _$$FollowRequestResponseImplFromJson(
  Map<String, dynamic> json,
) => _$FollowRequestResponseImpl(
  message: json['message'] as String,
  followRequest: json['followRequest'] == null
      ? null
      : FollowRequestData.fromJson(
          json['followRequest'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$$FollowRequestResponseImplToJson(
  _$FollowRequestResponseImpl instance,
) => <String, dynamic>{
  'message': instance.message,
  'followRequest': instance.followRequest,
};

_$FollowRequestDataImpl _$$FollowRequestDataImplFromJson(
  Map<String, dynamic> json,
) => _$FollowRequestDataImpl(
  id: json['id'] as String,
  requesterId: json['requesterId'] as String,
  targetId: json['targetId'] as String,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$$FollowRequestDataImplToJson(
  _$FollowRequestDataImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'requesterId': instance.requesterId,
  'targetId': instance.targetId,
  'createdAt': instance.createdAt,
};

_$SentFollowRequestImpl _$$SentFollowRequestImplFromJson(
  Map<String, dynamic> json,
) => _$SentFollowRequestImpl(
  id: json['id'] as String,
  target: FollowRequestTarget.fromJson(json['target'] as Map<String, dynamic>),
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$$SentFollowRequestImplToJson(
  _$SentFollowRequestImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'target': instance.target,
  'createdAt': instance.createdAt,
};

_$FollowRequestTargetImpl _$$FollowRequestTargetImplFromJson(
  Map<String, dynamic> json,
) => _$FollowRequestTargetImpl(
  id: json['id'] as String,
  name: json['name'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
);

Map<String, dynamic> _$$FollowRequestTargetImplToJson(
  _$FollowRequestTargetImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'avatarUrl': instance.avatarUrl,
};

_$SentFollowRequestListResponseImpl
_$$SentFollowRequestListResponseImplFromJson(Map<String, dynamic> json) =>
    _$SentFollowRequestListResponseImpl(
      data: (json['data'] as List<dynamic>)
          .map((e) => SentFollowRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$$SentFollowRequestListResponseImplToJson(
  _$SentFollowRequestListResponseImpl instance,
) => <String, dynamic>{
  'data': instance.data,
  'pagination': instance.pagination,
};
