// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileImpl _$$ProfileImplFromJson(Map<String, dynamic> json) =>
    _$ProfileImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      name: json['name'] as String?,
      bio: json['bio'] as String?,
      birthMonth: json['birthMonth'] as String?,
      age: (json['age'] as num?)?.toInt(),
      avatarUrl: json['avatarUrl'] as String?,
      isPrivate: json['isPrivate'] as bool? ?? false,
      followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
      followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
      followStatus: json['followStatus'] as String? ?? 'none',
      isOwnProfile: json['isOwnProfile'] as bool? ?? false,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$$ProfileImplToJson(_$ProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'name': instance.name,
      'bio': instance.bio,
      'birthMonth': instance.birthMonth,
      'age': instance.age,
      'avatarUrl': instance.avatarUrl,
      'isPrivate': instance.isPrivate,
      'followingCount': instance.followingCount,
      'followersCount': instance.followersCount,
      'followStatus': instance.followStatus,
      'isOwnProfile': instance.isOwnProfile,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
