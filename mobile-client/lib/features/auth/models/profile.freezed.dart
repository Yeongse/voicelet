// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  return _Profile.fromJson(json);
}

/// @nodoc
mixin _$Profile {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  String? get birthMonth => throw _privateConstructorUsedError;
  int? get age => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  bool get isPrivate => throw _privateConstructorUsedError;
  int get followingCount => throw _privateConstructorUsedError;
  int get followersCount => throw _privateConstructorUsedError;
  String get followStatus => throw _privateConstructorUsedError;
  bool get isOwnProfile => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileCopyWith<Profile> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileCopyWith<$Res> {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) then) =
      _$ProfileCopyWithImpl<$Res, Profile>;
  @useResult
  $Res call({
    String id,
    String email,
    String? username,
    String? name,
    String? bio,
    String? birthMonth,
    int? age,
    String? avatarUrl,
    bool isPrivate,
    int followingCount,
    int followersCount,
    String followStatus,
    bool isOwnProfile,
    String createdAt,
    String updatedAt,
  });
}

/// @nodoc
class _$ProfileCopyWithImpl<$Res, $Val extends Profile>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? username = freezed,
    Object? name = freezed,
    Object? bio = freezed,
    Object? birthMonth = freezed,
    Object? age = freezed,
    Object? avatarUrl = freezed,
    Object? isPrivate = null,
    Object? followingCount = null,
    Object? followersCount = null,
    Object? followStatus = null,
    Object? isOwnProfile = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            username: freezed == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            bio: freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String?,
            birthMonth: freezed == birthMonth
                ? _value.birthMonth
                : birthMonth // ignore: cast_nullable_to_non_nullable
                      as String?,
            age: freezed == age
                ? _value.age
                : age // ignore: cast_nullable_to_non_nullable
                      as int?,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            isPrivate: null == isPrivate
                ? _value.isPrivate
                : isPrivate // ignore: cast_nullable_to_non_nullable
                      as bool,
            followingCount: null == followingCount
                ? _value.followingCount
                : followingCount // ignore: cast_nullable_to_non_nullable
                      as int,
            followersCount: null == followersCount
                ? _value.followersCount
                : followersCount // ignore: cast_nullable_to_non_nullable
                      as int,
            followStatus: null == followStatus
                ? _value.followStatus
                : followStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            isOwnProfile: null == isOwnProfile
                ? _value.isOwnProfile
                : isOwnProfile // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProfileImplCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$$ProfileImplCopyWith(
    _$ProfileImpl value,
    $Res Function(_$ProfileImpl) then,
  ) = __$$ProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String email,
    String? username,
    String? name,
    String? bio,
    String? birthMonth,
    int? age,
    String? avatarUrl,
    bool isPrivate,
    int followingCount,
    int followersCount,
    String followStatus,
    bool isOwnProfile,
    String createdAt,
    String updatedAt,
  });
}

/// @nodoc
class __$$ProfileImplCopyWithImpl<$Res>
    extends _$ProfileCopyWithImpl<$Res, _$ProfileImpl>
    implements _$$ProfileImplCopyWith<$Res> {
  __$$ProfileImplCopyWithImpl(
    _$ProfileImpl _value,
    $Res Function(_$ProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? username = freezed,
    Object? name = freezed,
    Object? bio = freezed,
    Object? birthMonth = freezed,
    Object? age = freezed,
    Object? avatarUrl = freezed,
    Object? isPrivate = null,
    Object? followingCount = null,
    Object? followersCount = null,
    Object? followStatus = null,
    Object? isOwnProfile = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ProfileImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        username: freezed == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        bio: freezed == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String?,
        birthMonth: freezed == birthMonth
            ? _value.birthMonth
            : birthMonth // ignore: cast_nullable_to_non_nullable
                  as String?,
        age: freezed == age
            ? _value.age
            : age // ignore: cast_nullable_to_non_nullable
                  as int?,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        isPrivate: null == isPrivate
            ? _value.isPrivate
            : isPrivate // ignore: cast_nullable_to_non_nullable
                  as bool,
        followingCount: null == followingCount
            ? _value.followingCount
            : followingCount // ignore: cast_nullable_to_non_nullable
                  as int,
        followersCount: null == followersCount
            ? _value.followersCount
            : followersCount // ignore: cast_nullable_to_non_nullable
                  as int,
        followStatus: null == followStatus
            ? _value.followStatus
            : followStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        isOwnProfile: null == isOwnProfile
            ? _value.isOwnProfile
            : isOwnProfile // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileImpl implements _Profile {
  const _$ProfileImpl({
    required this.id,
    required this.email,
    this.username,
    this.name,
    this.bio,
    this.birthMonth,
    this.age,
    this.avatarUrl,
    this.isPrivate = false,
    this.followingCount = 0,
    this.followersCount = 0,
    this.followStatus = 'none',
    this.isOwnProfile = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$ProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String? username;
  @override
  final String? name;
  @override
  final String? bio;
  @override
  final String? birthMonth;
  @override
  final int? age;
  @override
  final String? avatarUrl;
  @override
  @JsonKey()
  final bool isPrivate;
  @override
  @JsonKey()
  final int followingCount;
  @override
  @JsonKey()
  final int followersCount;
  @override
  @JsonKey()
  final String followStatus;
  @override
  @JsonKey()
  final bool isOwnProfile;
  @override
  final String createdAt;
  @override
  final String updatedAt;

  @override
  String toString() {
    return 'Profile(id: $id, email: $email, username: $username, name: $name, bio: $bio, birthMonth: $birthMonth, age: $age, avatarUrl: $avatarUrl, isPrivate: $isPrivate, followingCount: $followingCount, followersCount: $followersCount, followStatus: $followStatus, isOwnProfile: $isOwnProfile, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.birthMonth, birthMonth) ||
                other.birthMonth == birthMonth) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.isPrivate, isPrivate) ||
                other.isPrivate == isPrivate) &&
            (identical(other.followingCount, followingCount) ||
                other.followingCount == followingCount) &&
            (identical(other.followersCount, followersCount) ||
                other.followersCount == followersCount) &&
            (identical(other.followStatus, followStatus) ||
                other.followStatus == followStatus) &&
            (identical(other.isOwnProfile, isOwnProfile) ||
                other.isOwnProfile == isOwnProfile) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    email,
    username,
    name,
    bio,
    birthMonth,
    age,
    avatarUrl,
    isPrivate,
    followingCount,
    followersCount,
    followStatus,
    isOwnProfile,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileImplCopyWith<_$ProfileImpl> get copyWith =>
      __$$ProfileImplCopyWithImpl<_$ProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileImplToJson(this);
  }
}

abstract class _Profile implements Profile {
  const factory _Profile({
    required final String id,
    required final String email,
    final String? username,
    final String? name,
    final String? bio,
    final String? birthMonth,
    final int? age,
    final String? avatarUrl,
    final bool isPrivate,
    final int followingCount,
    final int followersCount,
    final String followStatus,
    final bool isOwnProfile,
    required final String createdAt,
    required final String updatedAt,
  }) = _$ProfileImpl;

  factory _Profile.fromJson(Map<String, dynamic> json) = _$ProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String? get username;
  @override
  String? get name;
  @override
  String? get bio;
  @override
  String? get birthMonth;
  @override
  int? get age;
  @override
  String? get avatarUrl;
  @override
  bool get isPrivate;
  @override
  int get followingCount;
  @override
  int get followersCount;
  @override
  String get followStatus;
  @override
  bool get isOwnProfile;
  @override
  String get createdAt;
  @override
  String get updatedAt;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileImplCopyWith<_$ProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
