// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StoryItem _$StoryItemFromJson(Map<String, dynamic> json) {
  return _StoryItem.fromJson(json);
}

/// @nodoc
mixin _$StoryItem {
  String get id => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  bool get isViewed => throw _privateConstructorUsedError;

  /// Serializes this StoryItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoryItemCopyWith<StoryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoryItemCopyWith<$Res> {
  factory $StoryItemCopyWith(StoryItem value, $Res Function(StoryItem) then) =
      _$StoryItemCopyWithImpl<$Res, StoryItem>;
  @useResult
  $Res call({String id, int duration, String createdAt, bool isViewed});
}

/// @nodoc
class _$StoryItemCopyWithImpl<$Res, $Val extends StoryItem>
    implements $StoryItemCopyWith<$Res> {
  _$StoryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? duration = null,
    Object? createdAt = null,
    Object? isViewed = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            isViewed: null == isViewed
                ? _value.isViewed
                : isViewed // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StoryItemImplCopyWith<$Res>
    implements $StoryItemCopyWith<$Res> {
  factory _$$StoryItemImplCopyWith(
    _$StoryItemImpl value,
    $Res Function(_$StoryItemImpl) then,
  ) = __$$StoryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, int duration, String createdAt, bool isViewed});
}

/// @nodoc
class __$$StoryItemImplCopyWithImpl<$Res>
    extends _$StoryItemCopyWithImpl<$Res, _$StoryItemImpl>
    implements _$$StoryItemImplCopyWith<$Res> {
  __$$StoryItemImplCopyWithImpl(
    _$StoryItemImpl _value,
    $Res Function(_$StoryItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? duration = null,
    Object? createdAt = null,
    Object? isViewed = null,
  }) {
    return _then(
      _$StoryItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        isViewed: null == isViewed
            ? _value.isViewed
            : isViewed // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StoryItemImpl implements _StoryItem {
  const _$StoryItemImpl({
    required this.id,
    required this.duration,
    required this.createdAt,
    required this.isViewed,
  });

  factory _$StoryItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoryItemImplFromJson(json);

  @override
  final String id;
  @override
  final int duration;
  @override
  final String createdAt;
  @override
  final bool isViewed;

  @override
  String toString() {
    return 'StoryItem(id: $id, duration: $duration, createdAt: $createdAt, isViewed: $isViewed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoryItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isViewed, isViewed) ||
                other.isViewed == isViewed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, duration, createdAt, isViewed);

  /// Create a copy of StoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoryItemImplCopyWith<_$StoryItemImpl> get copyWith =>
      __$$StoryItemImplCopyWithImpl<_$StoryItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoryItemImplToJson(this);
  }
}

abstract class _StoryItem implements StoryItem {
  const factory _StoryItem({
    required final String id,
    required final int duration,
    required final String createdAt,
    required final bool isViewed,
  }) = _$StoryItemImpl;

  factory _StoryItem.fromJson(Map<String, dynamic> json) =
      _$StoryItemImpl.fromJson;

  @override
  String get id;
  @override
  int get duration;
  @override
  String get createdAt;
  @override
  bool get isViewed;

  /// Create a copy of StoryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoryItemImplCopyWith<_$StoryItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StoryUser _$StoryUserFromJson(Map<String, dynamic> json) {
  return _StoryUser.fromJson(json);
}

/// @nodoc
mixin _$StoryUser {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;

  /// Serializes this StoryUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StoryUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoryUserCopyWith<StoryUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoryUserCopyWith<$Res> {
  factory $StoryUserCopyWith(StoryUser value, $Res Function(StoryUser) then) =
      _$StoryUserCopyWithImpl<$Res, StoryUser>;
  @useResult
  $Res call({String id, String name, String? avatarUrl});
}

/// @nodoc
class _$StoryUserCopyWithImpl<$Res, $Val extends StoryUser>
    implements $StoryUserCopyWith<$Res> {
  _$StoryUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StoryUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatarUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StoryUserImplCopyWith<$Res>
    implements $StoryUserCopyWith<$Res> {
  factory _$$StoryUserImplCopyWith(
    _$StoryUserImpl value,
    $Res Function(_$StoryUserImpl) then,
  ) = __$$StoryUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String? avatarUrl});
}

/// @nodoc
class __$$StoryUserImplCopyWithImpl<$Res>
    extends _$StoryUserCopyWithImpl<$Res, _$StoryUserImpl>
    implements _$$StoryUserImplCopyWith<$Res> {
  __$$StoryUserImplCopyWithImpl(
    _$StoryUserImpl _value,
    $Res Function(_$StoryUserImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StoryUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatarUrl = freezed,
  }) {
    return _then(
      _$StoryUserImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StoryUserImpl implements _StoryUser {
  const _$StoryUserImpl({required this.id, required this.name, this.avatarUrl});

  factory _$StoryUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoryUserImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? avatarUrl;

  @override
  String toString() {
    return 'StoryUser(id: $id, name: $name, avatarUrl: $avatarUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoryUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, avatarUrl);

  /// Create a copy of StoryUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoryUserImplCopyWith<_$StoryUserImpl> get copyWith =>
      __$$StoryUserImplCopyWithImpl<_$StoryUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoryUserImplToJson(this);
  }
}

abstract class _StoryUser implements StoryUser {
  const factory _StoryUser({
    required final String id,
    required final String name,
    final String? avatarUrl,
  }) = _$StoryUserImpl;

  factory _StoryUser.fromJson(Map<String, dynamic> json) =
      _$StoryUserImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get avatarUrl;

  /// Create a copy of StoryUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoryUserImplCopyWith<_$StoryUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserStory _$UserStoryFromJson(Map<String, dynamic> json) {
  return _UserStory.fromJson(json);
}

/// @nodoc
mixin _$UserStory {
  StoryUser get user => throw _privateConstructorUsedError;
  List<StoryItem> get stories => throw _privateConstructorUsedError;
  bool get hasUnviewed => throw _privateConstructorUsedError;

  /// Serializes this UserStory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserStory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserStoryCopyWith<UserStory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserStoryCopyWith<$Res> {
  factory $UserStoryCopyWith(UserStory value, $Res Function(UserStory) then) =
      _$UserStoryCopyWithImpl<$Res, UserStory>;
  @useResult
  $Res call({StoryUser user, List<StoryItem> stories, bool hasUnviewed});

  $StoryUserCopyWith<$Res> get user;
}

/// @nodoc
class _$UserStoryCopyWithImpl<$Res, $Val extends UserStory>
    implements $UserStoryCopyWith<$Res> {
  _$UserStoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserStory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? stories = null,
    Object? hasUnviewed = null,
  }) {
    return _then(
      _value.copyWith(
            user: null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as StoryUser,
            stories: null == stories
                ? _value.stories
                : stories // ignore: cast_nullable_to_non_nullable
                      as List<StoryItem>,
            hasUnviewed: null == hasUnviewed
                ? _value.hasUnviewed
                : hasUnviewed // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of UserStory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StoryUserCopyWith<$Res> get user {
    return $StoryUserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserStoryImplCopyWith<$Res>
    implements $UserStoryCopyWith<$Res> {
  factory _$$UserStoryImplCopyWith(
    _$UserStoryImpl value,
    $Res Function(_$UserStoryImpl) then,
  ) = __$$UserStoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({StoryUser user, List<StoryItem> stories, bool hasUnviewed});

  @override
  $StoryUserCopyWith<$Res> get user;
}

/// @nodoc
class __$$UserStoryImplCopyWithImpl<$Res>
    extends _$UserStoryCopyWithImpl<$Res, _$UserStoryImpl>
    implements _$$UserStoryImplCopyWith<$Res> {
  __$$UserStoryImplCopyWithImpl(
    _$UserStoryImpl _value,
    $Res Function(_$UserStoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserStory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? stories = null,
    Object? hasUnviewed = null,
  }) {
    return _then(
      _$UserStoryImpl(
        user: null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as StoryUser,
        stories: null == stories
            ? _value._stories
            : stories // ignore: cast_nullable_to_non_nullable
                  as List<StoryItem>,
        hasUnviewed: null == hasUnviewed
            ? _value.hasUnviewed
            : hasUnviewed // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserStoryImpl implements _UserStory {
  const _$UserStoryImpl({
    required this.user,
    required final List<StoryItem> stories,
    required this.hasUnviewed,
  }) : _stories = stories;

  factory _$UserStoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserStoryImplFromJson(json);

  @override
  final StoryUser user;
  final List<StoryItem> _stories;
  @override
  List<StoryItem> get stories {
    if (_stories is EqualUnmodifiableListView) return _stories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stories);
  }

  @override
  final bool hasUnviewed;

  @override
  String toString() {
    return 'UserStory(user: $user, stories: $stories, hasUnviewed: $hasUnviewed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserStoryImpl &&
            (identical(other.user, user) || other.user == user) &&
            const DeepCollectionEquality().equals(other._stories, _stories) &&
            (identical(other.hasUnviewed, hasUnviewed) ||
                other.hasUnviewed == hasUnviewed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    user,
    const DeepCollectionEquality().hash(_stories),
    hasUnviewed,
  );

  /// Create a copy of UserStory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserStoryImplCopyWith<_$UserStoryImpl> get copyWith =>
      __$$UserStoryImplCopyWithImpl<_$UserStoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserStoryImplToJson(this);
  }
}

abstract class _UserStory implements UserStory {
  const factory _UserStory({
    required final StoryUser user,
    required final List<StoryItem> stories,
    required final bool hasUnviewed,
  }) = _$UserStoryImpl;

  factory _UserStory.fromJson(Map<String, dynamic> json) =
      _$UserStoryImpl.fromJson;

  @override
  StoryUser get user;
  @override
  List<StoryItem> get stories;
  @override
  bool get hasUnviewed;

  /// Create a copy of UserStory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserStoryImplCopyWith<_$UserStoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StoriesResponse _$StoriesResponseFromJson(Map<String, dynamic> json) {
  return _StoriesResponse.fromJson(json);
}

/// @nodoc
mixin _$StoriesResponse {
  List<UserStory> get data => throw _privateConstructorUsedError;

  /// Serializes this StoriesResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StoriesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoriesResponseCopyWith<StoriesResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoriesResponseCopyWith<$Res> {
  factory $StoriesResponseCopyWith(
    StoriesResponse value,
    $Res Function(StoriesResponse) then,
  ) = _$StoriesResponseCopyWithImpl<$Res, StoriesResponse>;
  @useResult
  $Res call({List<UserStory> data});
}

/// @nodoc
class _$StoriesResponseCopyWithImpl<$Res, $Val extends StoriesResponse>
    implements $StoriesResponseCopyWith<$Res> {
  _$StoriesResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StoriesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _value.copyWith(
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<UserStory>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StoriesResponseImplCopyWith<$Res>
    implements $StoriesResponseCopyWith<$Res> {
  factory _$$StoriesResponseImplCopyWith(
    _$StoriesResponseImpl value,
    $Res Function(_$StoriesResponseImpl) then,
  ) = __$$StoriesResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<UserStory> data});
}

/// @nodoc
class __$$StoriesResponseImplCopyWithImpl<$Res>
    extends _$StoriesResponseCopyWithImpl<$Res, _$StoriesResponseImpl>
    implements _$$StoriesResponseImplCopyWith<$Res> {
  __$$StoriesResponseImplCopyWithImpl(
    _$StoriesResponseImpl _value,
    $Res Function(_$StoriesResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StoriesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null}) {
    return _then(
      _$StoriesResponseImpl(
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<UserStory>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StoriesResponseImpl implements _StoriesResponse {
  const _$StoriesResponseImpl({required final List<UserStory> data})
    : _data = data;

  factory _$StoriesResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoriesResponseImplFromJson(json);

  final List<UserStory> _data;
  @override
  List<UserStory> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'StoriesResponse(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoriesResponseImpl &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_data));

  /// Create a copy of StoriesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoriesResponseImplCopyWith<_$StoriesResponseImpl> get copyWith =>
      __$$StoriesResponseImplCopyWithImpl<_$StoriesResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StoriesResponseImplToJson(this);
  }
}

abstract class _StoriesResponse implements StoriesResponse {
  const factory _StoriesResponse({required final List<UserStory> data}) =
      _$StoriesResponseImpl;

  factory _StoriesResponse.fromJson(Map<String, dynamic> json) =
      _$StoriesResponseImpl.fromJson;

  @override
  List<UserStory> get data;

  /// Create a copy of StoriesResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoriesResponseImplCopyWith<_$StoriesResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DiscoverUser _$DiscoverUserFromJson(Map<String, dynamic> json) {
  return _DiscoverUser.fromJson(json);
}

/// @nodoc
mixin _$DiscoverUser {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  int get whisperCount => throw _privateConstructorUsedError;
  String get latestWhisperAt => throw _privateConstructorUsedError;

  /// Serializes this DiscoverUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DiscoverUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiscoverUserCopyWith<DiscoverUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscoverUserCopyWith<$Res> {
  factory $DiscoverUserCopyWith(
    DiscoverUser value,
    $Res Function(DiscoverUser) then,
  ) = _$DiscoverUserCopyWithImpl<$Res, DiscoverUser>;
  @useResult
  $Res call({
    String id,
    String name,
    String? avatarUrl,
    int whisperCount,
    String latestWhisperAt,
  });
}

/// @nodoc
class _$DiscoverUserCopyWithImpl<$Res, $Val extends DiscoverUser>
    implements $DiscoverUserCopyWith<$Res> {
  _$DiscoverUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiscoverUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatarUrl = freezed,
    Object? whisperCount = null,
    Object? latestWhisperAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            whisperCount: null == whisperCount
                ? _value.whisperCount
                : whisperCount // ignore: cast_nullable_to_non_nullable
                      as int,
            latestWhisperAt: null == latestWhisperAt
                ? _value.latestWhisperAt
                : latestWhisperAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DiscoverUserImplCopyWith<$Res>
    implements $DiscoverUserCopyWith<$Res> {
  factory _$$DiscoverUserImplCopyWith(
    _$DiscoverUserImpl value,
    $Res Function(_$DiscoverUserImpl) then,
  ) = __$$DiscoverUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? avatarUrl,
    int whisperCount,
    String latestWhisperAt,
  });
}

/// @nodoc
class __$$DiscoverUserImplCopyWithImpl<$Res>
    extends _$DiscoverUserCopyWithImpl<$Res, _$DiscoverUserImpl>
    implements _$$DiscoverUserImplCopyWith<$Res> {
  __$$DiscoverUserImplCopyWithImpl(
    _$DiscoverUserImpl _value,
    $Res Function(_$DiscoverUserImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiscoverUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatarUrl = freezed,
    Object? whisperCount = null,
    Object? latestWhisperAt = null,
  }) {
    return _then(
      _$DiscoverUserImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        whisperCount: null == whisperCount
            ? _value.whisperCount
            : whisperCount // ignore: cast_nullable_to_non_nullable
                  as int,
        latestWhisperAt: null == latestWhisperAt
            ? _value.latestWhisperAt
            : latestWhisperAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DiscoverUserImpl implements _DiscoverUser {
  const _$DiscoverUserImpl({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.whisperCount,
    required this.latestWhisperAt,
  });

  factory _$DiscoverUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiscoverUserImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? avatarUrl;
  @override
  final int whisperCount;
  @override
  final String latestWhisperAt;

  @override
  String toString() {
    return 'DiscoverUser(id: $id, name: $name, avatarUrl: $avatarUrl, whisperCount: $whisperCount, latestWhisperAt: $latestWhisperAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscoverUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.whisperCount, whisperCount) ||
                other.whisperCount == whisperCount) &&
            (identical(other.latestWhisperAt, latestWhisperAt) ||
                other.latestWhisperAt == latestWhisperAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    avatarUrl,
    whisperCount,
    latestWhisperAt,
  );

  /// Create a copy of DiscoverUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscoverUserImplCopyWith<_$DiscoverUserImpl> get copyWith =>
      __$$DiscoverUserImplCopyWithImpl<_$DiscoverUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiscoverUserImplToJson(this);
  }
}

abstract class _DiscoverUser implements DiscoverUser {
  const factory _DiscoverUser({
    required final String id,
    required final String name,
    final String? avatarUrl,
    required final int whisperCount,
    required final String latestWhisperAt,
  }) = _$DiscoverUserImpl;

  factory _DiscoverUser.fromJson(Map<String, dynamic> json) =
      _$DiscoverUserImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get avatarUrl;
  @override
  int get whisperCount;
  @override
  String get latestWhisperAt;

  /// Create a copy of DiscoverUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiscoverUserImplCopyWith<_$DiscoverUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Pagination _$PaginationFromJson(Map<String, dynamic> json) {
  return _Pagination.fromJson(json);
}

/// @nodoc
mixin _$Pagination {
  int get total => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  bool get hasNext => throw _privateConstructorUsedError;
  bool get hasPrev => throw _privateConstructorUsedError;

  /// Serializes this Pagination to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Pagination
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaginationCopyWith<Pagination> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaginationCopyWith<$Res> {
  factory $PaginationCopyWith(
    Pagination value,
    $Res Function(Pagination) then,
  ) = _$PaginationCopyWithImpl<$Res, Pagination>;
  @useResult
  $Res call({
    int total,
    int page,
    int limit,
    int totalPages,
    bool hasNext,
    bool hasPrev,
  });
}

/// @nodoc
class _$PaginationCopyWithImpl<$Res, $Val extends Pagination>
    implements $PaginationCopyWith<$Res> {
  _$PaginationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Pagination
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? page = null,
    Object? limit = null,
    Object? totalPages = null,
    Object? hasNext = null,
    Object? hasPrev = null,
  }) {
    return _then(
      _value.copyWith(
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            limit: null == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                      as int,
            totalPages: null == totalPages
                ? _value.totalPages
                : totalPages // ignore: cast_nullable_to_non_nullable
                      as int,
            hasNext: null == hasNext
                ? _value.hasNext
                : hasNext // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasPrev: null == hasPrev
                ? _value.hasPrev
                : hasPrev // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaginationImplCopyWith<$Res>
    implements $PaginationCopyWith<$Res> {
  factory _$$PaginationImplCopyWith(
    _$PaginationImpl value,
    $Res Function(_$PaginationImpl) then,
  ) = __$$PaginationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int total,
    int page,
    int limit,
    int totalPages,
    bool hasNext,
    bool hasPrev,
  });
}

/// @nodoc
class __$$PaginationImplCopyWithImpl<$Res>
    extends _$PaginationCopyWithImpl<$Res, _$PaginationImpl>
    implements _$$PaginationImplCopyWith<$Res> {
  __$$PaginationImplCopyWithImpl(
    _$PaginationImpl _value,
    $Res Function(_$PaginationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Pagination
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? page = null,
    Object? limit = null,
    Object? totalPages = null,
    Object? hasNext = null,
    Object? hasPrev = null,
  }) {
    return _then(
      _$PaginationImpl(
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        limit: null == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int,
        totalPages: null == totalPages
            ? _value.totalPages
            : totalPages // ignore: cast_nullable_to_non_nullable
                  as int,
        hasNext: null == hasNext
            ? _value.hasNext
            : hasNext // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasPrev: null == hasPrev
            ? _value.hasPrev
            : hasPrev // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaginationImpl implements _Pagination {
  const _$PaginationImpl({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory _$PaginationImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaginationImplFromJson(json);

  @override
  final int total;
  @override
  final int page;
  @override
  final int limit;
  @override
  final int totalPages;
  @override
  final bool hasNext;
  @override
  final bool hasPrev;

  @override
  String toString() {
    return 'Pagination(total: $total, page: $page, limit: $limit, totalPages: $totalPages, hasNext: $hasNext, hasPrev: $hasPrev)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaginationImpl &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.hasNext, hasNext) || other.hasNext == hasNext) &&
            (identical(other.hasPrev, hasPrev) || other.hasPrev == hasPrev));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    total,
    page,
    limit,
    totalPages,
    hasNext,
    hasPrev,
  );

  /// Create a copy of Pagination
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaginationImplCopyWith<_$PaginationImpl> get copyWith =>
      __$$PaginationImplCopyWithImpl<_$PaginationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaginationImplToJson(this);
  }
}

abstract class _Pagination implements Pagination {
  const factory _Pagination({
    required final int total,
    required final int page,
    required final int limit,
    required final int totalPages,
    required final bool hasNext,
    required final bool hasPrev,
  }) = _$PaginationImpl;

  factory _Pagination.fromJson(Map<String, dynamic> json) =
      _$PaginationImpl.fromJson;

  @override
  int get total;
  @override
  int get page;
  @override
  int get limit;
  @override
  int get totalPages;
  @override
  bool get hasNext;
  @override
  bool get hasPrev;

  /// Create a copy of Pagination
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaginationImplCopyWith<_$PaginationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DiscoverResponse _$DiscoverResponseFromJson(Map<String, dynamic> json) {
  return _DiscoverResponse.fromJson(json);
}

/// @nodoc
mixin _$DiscoverResponse {
  List<DiscoverUser> get data => throw _privateConstructorUsedError;
  Pagination get pagination => throw _privateConstructorUsedError;

  /// Serializes this DiscoverResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DiscoverResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiscoverResponseCopyWith<DiscoverResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscoverResponseCopyWith<$Res> {
  factory $DiscoverResponseCopyWith(
    DiscoverResponse value,
    $Res Function(DiscoverResponse) then,
  ) = _$DiscoverResponseCopyWithImpl<$Res, DiscoverResponse>;
  @useResult
  $Res call({List<DiscoverUser> data, Pagination pagination});

  $PaginationCopyWith<$Res> get pagination;
}

/// @nodoc
class _$DiscoverResponseCopyWithImpl<$Res, $Val extends DiscoverResponse>
    implements $DiscoverResponseCopyWith<$Res> {
  _$DiscoverResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiscoverResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null, Object? pagination = null}) {
    return _then(
      _value.copyWith(
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<DiscoverUser>,
            pagination: null == pagination
                ? _value.pagination
                : pagination // ignore: cast_nullable_to_non_nullable
                      as Pagination,
          )
          as $Val,
    );
  }

  /// Create a copy of DiscoverResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaginationCopyWith<$Res> get pagination {
    return $PaginationCopyWith<$Res>(_value.pagination, (value) {
      return _then(_value.copyWith(pagination: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DiscoverResponseImplCopyWith<$Res>
    implements $DiscoverResponseCopyWith<$Res> {
  factory _$$DiscoverResponseImplCopyWith(
    _$DiscoverResponseImpl value,
    $Res Function(_$DiscoverResponseImpl) then,
  ) = __$$DiscoverResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<DiscoverUser> data, Pagination pagination});

  @override
  $PaginationCopyWith<$Res> get pagination;
}

/// @nodoc
class __$$DiscoverResponseImplCopyWithImpl<$Res>
    extends _$DiscoverResponseCopyWithImpl<$Res, _$DiscoverResponseImpl>
    implements _$$DiscoverResponseImplCopyWith<$Res> {
  __$$DiscoverResponseImplCopyWithImpl(
    _$DiscoverResponseImpl _value,
    $Res Function(_$DiscoverResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiscoverResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null, Object? pagination = null}) {
    return _then(
      _$DiscoverResponseImpl(
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<DiscoverUser>,
        pagination: null == pagination
            ? _value.pagination
            : pagination // ignore: cast_nullable_to_non_nullable
                  as Pagination,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DiscoverResponseImpl implements _DiscoverResponse {
  const _$DiscoverResponseImpl({
    required final List<DiscoverUser> data,
    required this.pagination,
  }) : _data = data;

  factory _$DiscoverResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiscoverResponseImplFromJson(json);

  final List<DiscoverUser> _data;
  @override
  List<DiscoverUser> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  final Pagination pagination;

  @override
  String toString() {
    return 'DiscoverResponse(data: $data, pagination: $pagination)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscoverResponseImpl &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.pagination, pagination) ||
                other.pagination == pagination));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_data),
    pagination,
  );

  /// Create a copy of DiscoverResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscoverResponseImplCopyWith<_$DiscoverResponseImpl> get copyWith =>
      __$$DiscoverResponseImplCopyWithImpl<_$DiscoverResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DiscoverResponseImplToJson(this);
  }
}

abstract class _DiscoverResponse implements DiscoverResponse {
  const factory _DiscoverResponse({
    required final List<DiscoverUser> data,
    required final Pagination pagination,
  }) = _$DiscoverResponseImpl;

  factory _DiscoverResponse.fromJson(Map<String, dynamic> json) =
      _$DiscoverResponseImpl.fromJson;

  @override
  List<DiscoverUser> get data;
  @override
  Pagination get pagination;

  /// Create a copy of DiscoverResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiscoverResponseImplCopyWith<_$DiscoverResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DiscoverStoriesResponse _$DiscoverStoriesResponseFromJson(
  Map<String, dynamic> json,
) {
  return _DiscoverStoriesResponse.fromJson(json);
}

/// @nodoc
mixin _$DiscoverStoriesResponse {
  StoryUser? get user => throw _privateConstructorUsedError;
  List<StoryItem> get stories => throw _privateConstructorUsedError;

  /// Serializes this DiscoverStoriesResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DiscoverStoriesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiscoverStoriesResponseCopyWith<DiscoverStoriesResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscoverStoriesResponseCopyWith<$Res> {
  factory $DiscoverStoriesResponseCopyWith(
    DiscoverStoriesResponse value,
    $Res Function(DiscoverStoriesResponse) then,
  ) = _$DiscoverStoriesResponseCopyWithImpl<$Res, DiscoverStoriesResponse>;
  @useResult
  $Res call({StoryUser? user, List<StoryItem> stories});

  $StoryUserCopyWith<$Res>? get user;
}

/// @nodoc
class _$DiscoverStoriesResponseCopyWithImpl<
  $Res,
  $Val extends DiscoverStoriesResponse
>
    implements $DiscoverStoriesResponseCopyWith<$Res> {
  _$DiscoverStoriesResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiscoverStoriesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? user = freezed, Object? stories = null}) {
    return _then(
      _value.copyWith(
            user: freezed == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as StoryUser?,
            stories: null == stories
                ? _value.stories
                : stories // ignore: cast_nullable_to_non_nullable
                      as List<StoryItem>,
          )
          as $Val,
    );
  }

  /// Create a copy of DiscoverStoriesResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StoryUserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $StoryUserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DiscoverStoriesResponseImplCopyWith<$Res>
    implements $DiscoverStoriesResponseCopyWith<$Res> {
  factory _$$DiscoverStoriesResponseImplCopyWith(
    _$DiscoverStoriesResponseImpl value,
    $Res Function(_$DiscoverStoriesResponseImpl) then,
  ) = __$$DiscoverStoriesResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({StoryUser? user, List<StoryItem> stories});

  @override
  $StoryUserCopyWith<$Res>? get user;
}

/// @nodoc
class __$$DiscoverStoriesResponseImplCopyWithImpl<$Res>
    extends
        _$DiscoverStoriesResponseCopyWithImpl<
          $Res,
          _$DiscoverStoriesResponseImpl
        >
    implements _$$DiscoverStoriesResponseImplCopyWith<$Res> {
  __$$DiscoverStoriesResponseImplCopyWithImpl(
    _$DiscoverStoriesResponseImpl _value,
    $Res Function(_$DiscoverStoriesResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiscoverStoriesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? user = freezed, Object? stories = null}) {
    return _then(
      _$DiscoverStoriesResponseImpl(
        user: freezed == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as StoryUser?,
        stories: null == stories
            ? _value._stories
            : stories // ignore: cast_nullable_to_non_nullable
                  as List<StoryItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DiscoverStoriesResponseImpl implements _DiscoverStoriesResponse {
  const _$DiscoverStoriesResponseImpl({
    this.user,
    required final List<StoryItem> stories,
  }) : _stories = stories;

  factory _$DiscoverStoriesResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiscoverStoriesResponseImplFromJson(json);

  @override
  final StoryUser? user;
  final List<StoryItem> _stories;
  @override
  List<StoryItem> get stories {
    if (_stories is EqualUnmodifiableListView) return _stories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stories);
  }

  @override
  String toString() {
    return 'DiscoverStoriesResponse(user: $user, stories: $stories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscoverStoriesResponseImpl &&
            (identical(other.user, user) || other.user == user) &&
            const DeepCollectionEquality().equals(other._stories, _stories));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    user,
    const DeepCollectionEquality().hash(_stories),
  );

  /// Create a copy of DiscoverStoriesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscoverStoriesResponseImplCopyWith<_$DiscoverStoriesResponseImpl>
  get copyWith =>
      __$$DiscoverStoriesResponseImplCopyWithImpl<
        _$DiscoverStoriesResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiscoverStoriesResponseImplToJson(this);
  }
}

abstract class _DiscoverStoriesResponse implements DiscoverStoriesResponse {
  const factory _DiscoverStoriesResponse({
    final StoryUser? user,
    required final List<StoryItem> stories,
  }) = _$DiscoverStoriesResponseImpl;

  factory _DiscoverStoriesResponse.fromJson(Map<String, dynamic> json) =
      _$DiscoverStoriesResponseImpl.fromJson;

  @override
  StoryUser? get user;
  @override
  List<StoryItem> get stories;

  /// Create a copy of DiscoverStoriesResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiscoverStoriesResponseImplCopyWith<_$DiscoverStoriesResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MyWhisper _$MyWhisperFromJson(Map<String, dynamic> json) {
  return _MyWhisper.fromJson(json);
}

/// @nodoc
mixin _$MyWhisper {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get bucketName => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this MyWhisper to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MyWhisper
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MyWhisperCopyWith<MyWhisper> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MyWhisperCopyWith<$Res> {
  factory $MyWhisperCopyWith(MyWhisper value, $Res Function(MyWhisper) then) =
      _$MyWhisperCopyWithImpl<$Res, MyWhisper>;
  @useResult
  $Res call({
    String id,
    String userId,
    String bucketName,
    String fileName,
    int duration,
    String createdAt,
    String expiresAt,
  });
}

/// @nodoc
class _$MyWhisperCopyWithImpl<$Res, $Val extends MyWhisper>
    implements $MyWhisperCopyWith<$Res> {
  _$MyWhisperCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MyWhisper
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? bucketName = null,
    Object? fileName = null,
    Object? duration = null,
    Object? createdAt = null,
    Object? expiresAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            bucketName: null == bucketName
                ? _value.bucketName
                : bucketName // ignore: cast_nullable_to_non_nullable
                      as String,
            fileName: null == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                      as String,
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            expiresAt: null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MyWhisperImplCopyWith<$Res>
    implements $MyWhisperCopyWith<$Res> {
  factory _$$MyWhisperImplCopyWith(
    _$MyWhisperImpl value,
    $Res Function(_$MyWhisperImpl) then,
  ) = __$$MyWhisperImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String bucketName,
    String fileName,
    int duration,
    String createdAt,
    String expiresAt,
  });
}

/// @nodoc
class __$$MyWhisperImplCopyWithImpl<$Res>
    extends _$MyWhisperCopyWithImpl<$Res, _$MyWhisperImpl>
    implements _$$MyWhisperImplCopyWith<$Res> {
  __$$MyWhisperImplCopyWithImpl(
    _$MyWhisperImpl _value,
    $Res Function(_$MyWhisperImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MyWhisper
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? bucketName = null,
    Object? fileName = null,
    Object? duration = null,
    Object? createdAt = null,
    Object? expiresAt = null,
  }) {
    return _then(
      _$MyWhisperImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        bucketName: null == bucketName
            ? _value.bucketName
            : bucketName // ignore: cast_nullable_to_non_nullable
                  as String,
        fileName: null == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String,
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        expiresAt: null == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MyWhisperImpl implements _MyWhisper {
  const _$MyWhisperImpl({
    required this.id,
    required this.userId,
    required this.bucketName,
    required this.fileName,
    required this.duration,
    required this.createdAt,
    required this.expiresAt,
  });

  factory _$MyWhisperImpl.fromJson(Map<String, dynamic> json) =>
      _$$MyWhisperImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String bucketName;
  @override
  final String fileName;
  @override
  final int duration;
  @override
  final String createdAt;
  @override
  final String expiresAt;

  @override
  String toString() {
    return 'MyWhisper(id: $id, userId: $userId, bucketName: $bucketName, fileName: $fileName, duration: $duration, createdAt: $createdAt, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MyWhisperImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.bucketName, bucketName) ||
                other.bucketName == bucketName) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    bucketName,
    fileName,
    duration,
    createdAt,
    expiresAt,
  );

  /// Create a copy of MyWhisper
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MyWhisperImplCopyWith<_$MyWhisperImpl> get copyWith =>
      __$$MyWhisperImplCopyWithImpl<_$MyWhisperImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MyWhisperImplToJson(this);
  }
}

abstract class _MyWhisper implements MyWhisper {
  const factory _MyWhisper({
    required final String id,
    required final String userId,
    required final String bucketName,
    required final String fileName,
    required final int duration,
    required final String createdAt,
    required final String expiresAt,
  }) = _$MyWhisperImpl;

  factory _MyWhisper.fromJson(Map<String, dynamic> json) =
      _$MyWhisperImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get bucketName;
  @override
  String get fileName;
  @override
  int get duration;
  @override
  String get createdAt;
  @override
  String get expiresAt;

  /// Create a copy of MyWhisper
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MyWhisperImplCopyWith<_$MyWhisperImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
