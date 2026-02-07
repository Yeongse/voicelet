// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SearchUserImpl _$$SearchUserImplFromJson(Map<String, dynamic> json) =>
    _$SearchUserImpl(
      id: json['id'] as String,
      username: json['username'] as String?,
      name: json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isPrivate: json['isPrivate'] as bool? ?? false,
      followStatus: json['followStatus'] as String? ?? 'none',
    );

Map<String, dynamic> _$$SearchUserImplToJson(_$SearchUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'isPrivate': instance.isPrivate,
      'followStatus': instance.followStatus,
    };

_$SearchUsersResponseImpl _$$SearchUsersResponseImplFromJson(
  Map<String, dynamic> json,
) => _$SearchUsersResponseImpl(
  data: (json['data'] as List<dynamic>)
      .map((e) => SearchUser.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: SearchPagination.fromJson(
    json['pagination'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$$SearchUsersResponseImplToJson(
  _$SearchUsersResponseImpl instance,
) => <String, dynamic>{
  'data': instance.data,
  'pagination': instance.pagination,
};

_$SearchPaginationImpl _$$SearchPaginationImplFromJson(
  Map<String, dynamic> json,
) => _$SearchPaginationImpl(
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  hasNext: json['hasNext'] as bool,
  hasPrev: json['hasPrev'] as bool,
);

Map<String, dynamic> _$$SearchPaginationImplToJson(
  _$SearchPaginationImpl instance,
) => <String, dynamic>{
  'total': instance.total,
  'page': instance.page,
  'limit': instance.limit,
  'totalPages': instance.totalPages,
  'hasNext': instance.hasNext,
  'hasPrev': instance.hasPrev,
};
