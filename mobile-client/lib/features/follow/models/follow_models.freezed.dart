// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follow_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$UserWithFollowStatus {
  String get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  bool get isPrivate => throw _privateConstructorUsedError;
  FollowStatus get followStatus => throw _privateConstructorUsedError;

  /// Create a copy of UserWithFollowStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserWithFollowStatusCopyWith<UserWithFollowStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserWithFollowStatusCopyWith<$Res> {
  factory $UserWithFollowStatusCopyWith(
    UserWithFollowStatus value,
    $Res Function(UserWithFollowStatus) then,
  ) = _$UserWithFollowStatusCopyWithImpl<$Res, UserWithFollowStatus>;
  @useResult
  $Res call({
    String id,
    String? name,
    String? bio,
    String? avatarUrl,
    bool isPrivate,
    FollowStatus followStatus,
  });
}

/// @nodoc
class _$UserWithFollowStatusCopyWithImpl<
  $Res,
  $Val extends UserWithFollowStatus
>
    implements $UserWithFollowStatusCopyWith<$Res> {
  _$UserWithFollowStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserWithFollowStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? bio = freezed,
    Object? avatarUrl = freezed,
    Object? isPrivate = null,
    Object? followStatus = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            bio: freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String?,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            isPrivate: null == isPrivate
                ? _value.isPrivate
                : isPrivate // ignore: cast_nullable_to_non_nullable
                      as bool,
            followStatus: null == followStatus
                ? _value.followStatus
                : followStatus // ignore: cast_nullable_to_non_nullable
                      as FollowStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserWithFollowStatusImplCopyWith<$Res>
    implements $UserWithFollowStatusCopyWith<$Res> {
  factory _$$UserWithFollowStatusImplCopyWith(
    _$UserWithFollowStatusImpl value,
    $Res Function(_$UserWithFollowStatusImpl) then,
  ) = __$$UserWithFollowStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? name,
    String? bio,
    String? avatarUrl,
    bool isPrivate,
    FollowStatus followStatus,
  });
}

/// @nodoc
class __$$UserWithFollowStatusImplCopyWithImpl<$Res>
    extends _$UserWithFollowStatusCopyWithImpl<$Res, _$UserWithFollowStatusImpl>
    implements _$$UserWithFollowStatusImplCopyWith<$Res> {
  __$$UserWithFollowStatusImplCopyWithImpl(
    _$UserWithFollowStatusImpl _value,
    $Res Function(_$UserWithFollowStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserWithFollowStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? bio = freezed,
    Object? avatarUrl = freezed,
    Object? isPrivate = null,
    Object? followStatus = null,
  }) {
    return _then(
      _$UserWithFollowStatusImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        bio: freezed == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String?,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        isPrivate: null == isPrivate
            ? _value.isPrivate
            : isPrivate // ignore: cast_nullable_to_non_nullable
                  as bool,
        followStatus: null == followStatus
            ? _value.followStatus
            : followStatus // ignore: cast_nullable_to_non_nullable
                  as FollowStatus,
      ),
    );
  }
}

/// @nodoc

class _$UserWithFollowStatusImpl implements _UserWithFollowStatus {
  const _$UserWithFollowStatusImpl({
    required this.id,
    this.name,
    this.bio,
    this.avatarUrl,
    this.isPrivate = false,
    this.followStatus = FollowStatus.none,
  });

  @override
  final String id;
  @override
  final String? name;
  @override
  final String? bio;
  @override
  final String? avatarUrl;
  @override
  @JsonKey()
  final bool isPrivate;
  @override
  @JsonKey()
  final FollowStatus followStatus;

  @override
  String toString() {
    return 'UserWithFollowStatus(id: $id, name: $name, bio: $bio, avatarUrl: $avatarUrl, isPrivate: $isPrivate, followStatus: $followStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserWithFollowStatusImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.isPrivate, isPrivate) ||
                other.isPrivate == isPrivate) &&
            (identical(other.followStatus, followStatus) ||
                other.followStatus == followStatus));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    bio,
    avatarUrl,
    isPrivate,
    followStatus,
  );

  /// Create a copy of UserWithFollowStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserWithFollowStatusImplCopyWith<_$UserWithFollowStatusImpl>
  get copyWith =>
      __$$UserWithFollowStatusImplCopyWithImpl<_$UserWithFollowStatusImpl>(
        this,
        _$identity,
      );
}

abstract class _UserWithFollowStatus implements UserWithFollowStatus {
  const factory _UserWithFollowStatus({
    required final String id,
    final String? name,
    final String? bio,
    final String? avatarUrl,
    final bool isPrivate,
    final FollowStatus followStatus,
  }) = _$UserWithFollowStatusImpl;

  @override
  String get id;
  @override
  String? get name;
  @override
  String? get bio;
  @override
  String? get avatarUrl;
  @override
  bool get isPrivate;
  @override
  FollowStatus get followStatus;

  /// Create a copy of UserWithFollowStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserWithFollowStatusImplCopyWith<_$UserWithFollowStatusImpl>
  get copyWith => throw _privateConstructorUsedError;
}

Pagination _$PaginationFromJson(Map<String, dynamic> json) {
  return _Pagination.fromJson(json);
}

/// @nodoc
mixin _$Pagination {
  int get page => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;

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
  $Res call({int page, int limit, int total, bool hasMore});
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
    Object? page = null,
    Object? limit = null,
    Object? total = null,
    Object? hasMore = null,
  }) {
    return _then(
      _value.copyWith(
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            limit: null == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                      as int,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            hasMore: null == hasMore
                ? _value.hasMore
                : hasMore // ignore: cast_nullable_to_non_nullable
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
  $Res call({int page, int limit, int total, bool hasMore});
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
    Object? page = null,
    Object? limit = null,
    Object? total = null,
    Object? hasMore = null,
  }) {
    return _then(
      _$PaginationImpl(
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        limit: null == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        hasMore: null == hasMore
            ? _value.hasMore
            : hasMore // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaginationImpl implements _Pagination {
  const _$PaginationImpl({
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });

  factory _$PaginationImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaginationImplFromJson(json);

  @override
  final int page;
  @override
  final int limit;
  @override
  final int total;
  @override
  final bool hasMore;

  @override
  String toString() {
    return 'Pagination(page: $page, limit: $limit, total: $total, hasMore: $hasMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaginationImpl &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, page, limit, total, hasMore);

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
    required final int page,
    required final int limit,
    required final int total,
    required final bool hasMore,
  }) = _$PaginationImpl;

  factory _Pagination.fromJson(Map<String, dynamic> json) =
      _$PaginationImpl.fromJson;

  @override
  int get page;
  @override
  int get limit;
  @override
  int get total;
  @override
  bool get hasMore;

  /// Create a copy of Pagination
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaginationImplCopyWith<_$PaginationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UserListResponse {
  List<UserWithFollowStatus> get data => throw _privateConstructorUsedError;
  Pagination get pagination => throw _privateConstructorUsedError;

  /// Create a copy of UserListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserListResponseCopyWith<UserListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserListResponseCopyWith<$Res> {
  factory $UserListResponseCopyWith(
    UserListResponse value,
    $Res Function(UserListResponse) then,
  ) = _$UserListResponseCopyWithImpl<$Res, UserListResponse>;
  @useResult
  $Res call({List<UserWithFollowStatus> data, Pagination pagination});

  $PaginationCopyWith<$Res> get pagination;
}

/// @nodoc
class _$UserListResponseCopyWithImpl<$Res, $Val extends UserListResponse>
    implements $UserListResponseCopyWith<$Res> {
  _$UserListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null, Object? pagination = null}) {
    return _then(
      _value.copyWith(
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<UserWithFollowStatus>,
            pagination: null == pagination
                ? _value.pagination
                : pagination // ignore: cast_nullable_to_non_nullable
                      as Pagination,
          )
          as $Val,
    );
  }

  /// Create a copy of UserListResponse
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
abstract class _$$UserListResponseImplCopyWith<$Res>
    implements $UserListResponseCopyWith<$Res> {
  factory _$$UserListResponseImplCopyWith(
    _$UserListResponseImpl value,
    $Res Function(_$UserListResponseImpl) then,
  ) = __$$UserListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<UserWithFollowStatus> data, Pagination pagination});

  @override
  $PaginationCopyWith<$Res> get pagination;
}

/// @nodoc
class __$$UserListResponseImplCopyWithImpl<$Res>
    extends _$UserListResponseCopyWithImpl<$Res, _$UserListResponseImpl>
    implements _$$UserListResponseImplCopyWith<$Res> {
  __$$UserListResponseImplCopyWithImpl(
    _$UserListResponseImpl _value,
    $Res Function(_$UserListResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null, Object? pagination = null}) {
    return _then(
      _$UserListResponseImpl(
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<UserWithFollowStatus>,
        pagination: null == pagination
            ? _value.pagination
            : pagination // ignore: cast_nullable_to_non_nullable
                  as Pagination,
      ),
    );
  }
}

/// @nodoc

class _$UserListResponseImpl implements _UserListResponse {
  const _$UserListResponseImpl({
    required final List<UserWithFollowStatus> data,
    required this.pagination,
  }) : _data = data;

  final List<UserWithFollowStatus> _data;
  @override
  List<UserWithFollowStatus> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  final Pagination pagination;

  @override
  String toString() {
    return 'UserListResponse(data: $data, pagination: $pagination)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserListResponseImpl &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.pagination, pagination) ||
                other.pagination == pagination));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_data),
    pagination,
  );

  /// Create a copy of UserListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserListResponseImplCopyWith<_$UserListResponseImpl> get copyWith =>
      __$$UserListResponseImplCopyWithImpl<_$UserListResponseImpl>(
        this,
        _$identity,
      );
}

abstract class _UserListResponse implements UserListResponse {
  const factory _UserListResponse({
    required final List<UserWithFollowStatus> data,
    required final Pagination pagination,
  }) = _$UserListResponseImpl;

  @override
  List<UserWithFollowStatus> get data;
  @override
  Pagination get pagination;

  /// Create a copy of UserListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserListResponseImplCopyWith<_$UserListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FollowRequest _$FollowRequestFromJson(Map<String, dynamic> json) {
  return _FollowRequest.fromJson(json);
}

/// @nodoc
mixin _$FollowRequest {
  String get id => throw _privateConstructorUsedError;
  FollowRequester get requester => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this FollowRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FollowRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FollowRequestCopyWith<FollowRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowRequestCopyWith<$Res> {
  factory $FollowRequestCopyWith(
    FollowRequest value,
    $Res Function(FollowRequest) then,
  ) = _$FollowRequestCopyWithImpl<$Res, FollowRequest>;
  @useResult
  $Res call({String id, FollowRequester requester, String createdAt});

  $FollowRequesterCopyWith<$Res> get requester;
}

/// @nodoc
class _$FollowRequestCopyWithImpl<$Res, $Val extends FollowRequest>
    implements $FollowRequestCopyWith<$Res> {
  _$FollowRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FollowRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? requester = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            requester: null == requester
                ? _value.requester
                : requester // ignore: cast_nullable_to_non_nullable
                      as FollowRequester,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of FollowRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FollowRequesterCopyWith<$Res> get requester {
    return $FollowRequesterCopyWith<$Res>(_value.requester, (value) {
      return _then(_value.copyWith(requester: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FollowRequestImplCopyWith<$Res>
    implements $FollowRequestCopyWith<$Res> {
  factory _$$FollowRequestImplCopyWith(
    _$FollowRequestImpl value,
    $Res Function(_$FollowRequestImpl) then,
  ) = __$$FollowRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, FollowRequester requester, String createdAt});

  @override
  $FollowRequesterCopyWith<$Res> get requester;
}

/// @nodoc
class __$$FollowRequestImplCopyWithImpl<$Res>
    extends _$FollowRequestCopyWithImpl<$Res, _$FollowRequestImpl>
    implements _$$FollowRequestImplCopyWith<$Res> {
  __$$FollowRequestImplCopyWithImpl(
    _$FollowRequestImpl _value,
    $Res Function(_$FollowRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FollowRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? requester = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$FollowRequestImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        requester: null == requester
            ? _value.requester
            : requester // ignore: cast_nullable_to_non_nullable
                  as FollowRequester,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FollowRequestImpl implements _FollowRequest {
  const _$FollowRequestImpl({
    required this.id,
    required this.requester,
    required this.createdAt,
  });

  factory _$FollowRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$FollowRequestImplFromJson(json);

  @override
  final String id;
  @override
  final FollowRequester requester;
  @override
  final String createdAt;

  @override
  String toString() {
    return 'FollowRequest(id: $id, requester: $requester, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.requester, requester) ||
                other.requester == requester) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, requester, createdAt);

  /// Create a copy of FollowRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowRequestImplCopyWith<_$FollowRequestImpl> get copyWith =>
      __$$FollowRequestImplCopyWithImpl<_$FollowRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FollowRequestImplToJson(this);
  }
}

abstract class _FollowRequest implements FollowRequest {
  const factory _FollowRequest({
    required final String id,
    required final FollowRequester requester,
    required final String createdAt,
  }) = _$FollowRequestImpl;

  factory _FollowRequest.fromJson(Map<String, dynamic> json) =
      _$FollowRequestImpl.fromJson;

  @override
  String get id;
  @override
  FollowRequester get requester;
  @override
  String get createdAt;

  /// Create a copy of FollowRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FollowRequestImplCopyWith<_$FollowRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FollowRequester _$FollowRequesterFromJson(Map<String, dynamic> json) {
  return _FollowRequester.fromJson(json);
}

/// @nodoc
mixin _$FollowRequester {
  String get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;

  /// Serializes this FollowRequester to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FollowRequester
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FollowRequesterCopyWith<FollowRequester> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowRequesterCopyWith<$Res> {
  factory $FollowRequesterCopyWith(
    FollowRequester value,
    $Res Function(FollowRequester) then,
  ) = _$FollowRequesterCopyWithImpl<$Res, FollowRequester>;
  @useResult
  $Res call({String id, String? name, String? avatarUrl});
}

/// @nodoc
class _$FollowRequesterCopyWithImpl<$Res, $Val extends FollowRequester>
    implements $FollowRequesterCopyWith<$Res> {
  _$FollowRequesterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FollowRequester
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? avatarUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$FollowRequesterImplCopyWith<$Res>
    implements $FollowRequesterCopyWith<$Res> {
  factory _$$FollowRequesterImplCopyWith(
    _$FollowRequesterImpl value,
    $Res Function(_$FollowRequesterImpl) then,
  ) = __$$FollowRequesterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String? name, String? avatarUrl});
}

/// @nodoc
class __$$FollowRequesterImplCopyWithImpl<$Res>
    extends _$FollowRequesterCopyWithImpl<$Res, _$FollowRequesterImpl>
    implements _$$FollowRequesterImplCopyWith<$Res> {
  __$$FollowRequesterImplCopyWithImpl(
    _$FollowRequesterImpl _value,
    $Res Function(_$FollowRequesterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FollowRequester
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? avatarUrl = freezed,
  }) {
    return _then(
      _$FollowRequesterImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$FollowRequesterImpl implements _FollowRequester {
  const _$FollowRequesterImpl({required this.id, this.name, this.avatarUrl});

  factory _$FollowRequesterImpl.fromJson(Map<String, dynamic> json) =>
      _$$FollowRequesterImplFromJson(json);

  @override
  final String id;
  @override
  final String? name;
  @override
  final String? avatarUrl;

  @override
  String toString() {
    return 'FollowRequester(id: $id, name: $name, avatarUrl: $avatarUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowRequesterImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, avatarUrl);

  /// Create a copy of FollowRequester
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowRequesterImplCopyWith<_$FollowRequesterImpl> get copyWith =>
      __$$FollowRequesterImplCopyWithImpl<_$FollowRequesterImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FollowRequesterImplToJson(this);
  }
}

abstract class _FollowRequester implements FollowRequester {
  const factory _FollowRequester({
    required final String id,
    final String? name,
    final String? avatarUrl,
  }) = _$FollowRequesterImpl;

  factory _FollowRequester.fromJson(Map<String, dynamic> json) =
      _$FollowRequesterImpl.fromJson;

  @override
  String get id;
  @override
  String? get name;
  @override
  String? get avatarUrl;

  /// Create a copy of FollowRequester
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FollowRequesterImplCopyWith<_$FollowRequesterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FollowRequestListResponse _$FollowRequestListResponseFromJson(
  Map<String, dynamic> json,
) {
  return _FollowRequestListResponse.fromJson(json);
}

/// @nodoc
mixin _$FollowRequestListResponse {
  List<FollowRequest> get data => throw _privateConstructorUsedError;
  Pagination get pagination => throw _privateConstructorUsedError;

  /// Serializes this FollowRequestListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FollowRequestListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FollowRequestListResponseCopyWith<FollowRequestListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowRequestListResponseCopyWith<$Res> {
  factory $FollowRequestListResponseCopyWith(
    FollowRequestListResponse value,
    $Res Function(FollowRequestListResponse) then,
  ) = _$FollowRequestListResponseCopyWithImpl<$Res, FollowRequestListResponse>;
  @useResult
  $Res call({List<FollowRequest> data, Pagination pagination});

  $PaginationCopyWith<$Res> get pagination;
}

/// @nodoc
class _$FollowRequestListResponseCopyWithImpl<
  $Res,
  $Val extends FollowRequestListResponse
>
    implements $FollowRequestListResponseCopyWith<$Res> {
  _$FollowRequestListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FollowRequestListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null, Object? pagination = null}) {
    return _then(
      _value.copyWith(
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<FollowRequest>,
            pagination: null == pagination
                ? _value.pagination
                : pagination // ignore: cast_nullable_to_non_nullable
                      as Pagination,
          )
          as $Val,
    );
  }

  /// Create a copy of FollowRequestListResponse
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
abstract class _$$FollowRequestListResponseImplCopyWith<$Res>
    implements $FollowRequestListResponseCopyWith<$Res> {
  factory _$$FollowRequestListResponseImplCopyWith(
    _$FollowRequestListResponseImpl value,
    $Res Function(_$FollowRequestListResponseImpl) then,
  ) = __$$FollowRequestListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<FollowRequest> data, Pagination pagination});

  @override
  $PaginationCopyWith<$Res> get pagination;
}

/// @nodoc
class __$$FollowRequestListResponseImplCopyWithImpl<$Res>
    extends
        _$FollowRequestListResponseCopyWithImpl<
          $Res,
          _$FollowRequestListResponseImpl
        >
    implements _$$FollowRequestListResponseImplCopyWith<$Res> {
  __$$FollowRequestListResponseImplCopyWithImpl(
    _$FollowRequestListResponseImpl _value,
    $Res Function(_$FollowRequestListResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FollowRequestListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null, Object? pagination = null}) {
    return _then(
      _$FollowRequestListResponseImpl(
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<FollowRequest>,
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
class _$FollowRequestListResponseImpl implements _FollowRequestListResponse {
  const _$FollowRequestListResponseImpl({
    required final List<FollowRequest> data,
    required this.pagination,
  }) : _data = data;

  factory _$FollowRequestListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$FollowRequestListResponseImplFromJson(json);

  final List<FollowRequest> _data;
  @override
  List<FollowRequest> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  final Pagination pagination;

  @override
  String toString() {
    return 'FollowRequestListResponse(data: $data, pagination: $pagination)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowRequestListResponseImpl &&
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

  /// Create a copy of FollowRequestListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowRequestListResponseImplCopyWith<_$FollowRequestListResponseImpl>
  get copyWith =>
      __$$FollowRequestListResponseImplCopyWithImpl<
        _$FollowRequestListResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FollowRequestListResponseImplToJson(this);
  }
}

abstract class _FollowRequestListResponse implements FollowRequestListResponse {
  const factory _FollowRequestListResponse({
    required final List<FollowRequest> data,
    required final Pagination pagination,
  }) = _$FollowRequestListResponseImpl;

  factory _FollowRequestListResponse.fromJson(Map<String, dynamic> json) =
      _$FollowRequestListResponseImpl.fromJson;

  @override
  List<FollowRequest> get data;
  @override
  Pagination get pagination;

  /// Create a copy of FollowRequestListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FollowRequestListResponseImplCopyWith<_$FollowRequestListResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

FollowResponse _$FollowResponseFromJson(Map<String, dynamic> json) {
  return _FollowResponse.fromJson(json);
}

/// @nodoc
mixin _$FollowResponse {
  String get message => throw _privateConstructorUsedError;
  Follow? get follow => throw _privateConstructorUsedError;

  /// Serializes this FollowResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FollowResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FollowResponseCopyWith<FollowResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowResponseCopyWith<$Res> {
  factory $FollowResponseCopyWith(
    FollowResponse value,
    $Res Function(FollowResponse) then,
  ) = _$FollowResponseCopyWithImpl<$Res, FollowResponse>;
  @useResult
  $Res call({String message, Follow? follow});

  $FollowCopyWith<$Res>? get follow;
}

/// @nodoc
class _$FollowResponseCopyWithImpl<$Res, $Val extends FollowResponse>
    implements $FollowResponseCopyWith<$Res> {
  _$FollowResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FollowResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? follow = freezed}) {
    return _then(
      _value.copyWith(
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            follow: freezed == follow
                ? _value.follow
                : follow // ignore: cast_nullable_to_non_nullable
                      as Follow?,
          )
          as $Val,
    );
  }

  /// Create a copy of FollowResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FollowCopyWith<$Res>? get follow {
    if (_value.follow == null) {
      return null;
    }

    return $FollowCopyWith<$Res>(_value.follow!, (value) {
      return _then(_value.copyWith(follow: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FollowResponseImplCopyWith<$Res>
    implements $FollowResponseCopyWith<$Res> {
  factory _$$FollowResponseImplCopyWith(
    _$FollowResponseImpl value,
    $Res Function(_$FollowResponseImpl) then,
  ) = __$$FollowResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, Follow? follow});

  @override
  $FollowCopyWith<$Res>? get follow;
}

/// @nodoc
class __$$FollowResponseImplCopyWithImpl<$Res>
    extends _$FollowResponseCopyWithImpl<$Res, _$FollowResponseImpl>
    implements _$$FollowResponseImplCopyWith<$Res> {
  __$$FollowResponseImplCopyWithImpl(
    _$FollowResponseImpl _value,
    $Res Function(_$FollowResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FollowResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? follow = freezed}) {
    return _then(
      _$FollowResponseImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        follow: freezed == follow
            ? _value.follow
            : follow // ignore: cast_nullable_to_non_nullable
                  as Follow?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FollowResponseImpl implements _FollowResponse {
  const _$FollowResponseImpl({required this.message, this.follow});

  factory _$FollowResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$FollowResponseImplFromJson(json);

  @override
  final String message;
  @override
  final Follow? follow;

  @override
  String toString() {
    return 'FollowResponse(message: $message, follow: $follow)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowResponseImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.follow, follow) || other.follow == follow));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message, follow);

  /// Create a copy of FollowResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowResponseImplCopyWith<_$FollowResponseImpl> get copyWith =>
      __$$FollowResponseImplCopyWithImpl<_$FollowResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FollowResponseImplToJson(this);
  }
}

abstract class _FollowResponse implements FollowResponse {
  const factory _FollowResponse({
    required final String message,
    final Follow? follow,
  }) = _$FollowResponseImpl;

  factory _FollowResponse.fromJson(Map<String, dynamic> json) =
      _$FollowResponseImpl.fromJson;

  @override
  String get message;
  @override
  Follow? get follow;

  /// Create a copy of FollowResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FollowResponseImplCopyWith<_$FollowResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Follow _$FollowFromJson(Map<String, dynamic> json) {
  return _Follow.fromJson(json);
}

/// @nodoc
mixin _$Follow {
  String get id => throw _privateConstructorUsedError;
  String get followerId => throw _privateConstructorUsedError;
  String get followingId => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Follow to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Follow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FollowCopyWith<Follow> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowCopyWith<$Res> {
  factory $FollowCopyWith(Follow value, $Res Function(Follow) then) =
      _$FollowCopyWithImpl<$Res, Follow>;
  @useResult
  $Res call({
    String id,
    String followerId,
    String followingId,
    String createdAt,
  });
}

/// @nodoc
class _$FollowCopyWithImpl<$Res, $Val extends Follow>
    implements $FollowCopyWith<$Res> {
  _$FollowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Follow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? followerId = null,
    Object? followingId = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            followerId: null == followerId
                ? _value.followerId
                : followerId // ignore: cast_nullable_to_non_nullable
                      as String,
            followingId: null == followingId
                ? _value.followingId
                : followingId // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FollowImplCopyWith<$Res> implements $FollowCopyWith<$Res> {
  factory _$$FollowImplCopyWith(
    _$FollowImpl value,
    $Res Function(_$FollowImpl) then,
  ) = __$$FollowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String followerId,
    String followingId,
    String createdAt,
  });
}

/// @nodoc
class __$$FollowImplCopyWithImpl<$Res>
    extends _$FollowCopyWithImpl<$Res, _$FollowImpl>
    implements _$$FollowImplCopyWith<$Res> {
  __$$FollowImplCopyWithImpl(
    _$FollowImpl _value,
    $Res Function(_$FollowImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Follow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? followerId = null,
    Object? followingId = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$FollowImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        followerId: null == followerId
            ? _value.followerId
            : followerId // ignore: cast_nullable_to_non_nullable
                  as String,
        followingId: null == followingId
            ? _value.followingId
            : followingId // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FollowImpl implements _Follow {
  const _$FollowImpl({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.createdAt,
  });

  factory _$FollowImpl.fromJson(Map<String, dynamic> json) =>
      _$$FollowImplFromJson(json);

  @override
  final String id;
  @override
  final String followerId;
  @override
  final String followingId;
  @override
  final String createdAt;

  @override
  String toString() {
    return 'Follow(id: $id, followerId: $followerId, followingId: $followingId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.followerId, followerId) ||
                other.followerId == followerId) &&
            (identical(other.followingId, followingId) ||
                other.followingId == followingId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, followerId, followingId, createdAt);

  /// Create a copy of Follow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowImplCopyWith<_$FollowImpl> get copyWith =>
      __$$FollowImplCopyWithImpl<_$FollowImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FollowImplToJson(this);
  }
}

abstract class _Follow implements Follow {
  const factory _Follow({
    required final String id,
    required final String followerId,
    required final String followingId,
    required final String createdAt,
  }) = _$FollowImpl;

  factory _Follow.fromJson(Map<String, dynamic> json) = _$FollowImpl.fromJson;

  @override
  String get id;
  @override
  String get followerId;
  @override
  String get followingId;
  @override
  String get createdAt;

  /// Create a copy of Follow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FollowImplCopyWith<_$FollowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FollowRequestResponse _$FollowRequestResponseFromJson(
  Map<String, dynamic> json,
) {
  return _FollowRequestResponse.fromJson(json);
}

/// @nodoc
mixin _$FollowRequestResponse {
  String get message => throw _privateConstructorUsedError;
  FollowRequestData? get followRequest => throw _privateConstructorUsedError;

  /// Serializes this FollowRequestResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FollowRequestResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FollowRequestResponseCopyWith<FollowRequestResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowRequestResponseCopyWith<$Res> {
  factory $FollowRequestResponseCopyWith(
    FollowRequestResponse value,
    $Res Function(FollowRequestResponse) then,
  ) = _$FollowRequestResponseCopyWithImpl<$Res, FollowRequestResponse>;
  @useResult
  $Res call({String message, FollowRequestData? followRequest});

  $FollowRequestDataCopyWith<$Res>? get followRequest;
}

/// @nodoc
class _$FollowRequestResponseCopyWithImpl<
  $Res,
  $Val extends FollowRequestResponse
>
    implements $FollowRequestResponseCopyWith<$Res> {
  _$FollowRequestResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FollowRequestResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? followRequest = freezed}) {
    return _then(
      _value.copyWith(
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            followRequest: freezed == followRequest
                ? _value.followRequest
                : followRequest // ignore: cast_nullable_to_non_nullable
                      as FollowRequestData?,
          )
          as $Val,
    );
  }

  /// Create a copy of FollowRequestResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FollowRequestDataCopyWith<$Res>? get followRequest {
    if (_value.followRequest == null) {
      return null;
    }

    return $FollowRequestDataCopyWith<$Res>(_value.followRequest!, (value) {
      return _then(_value.copyWith(followRequest: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FollowRequestResponseImplCopyWith<$Res>
    implements $FollowRequestResponseCopyWith<$Res> {
  factory _$$FollowRequestResponseImplCopyWith(
    _$FollowRequestResponseImpl value,
    $Res Function(_$FollowRequestResponseImpl) then,
  ) = __$$FollowRequestResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, FollowRequestData? followRequest});

  @override
  $FollowRequestDataCopyWith<$Res>? get followRequest;
}

/// @nodoc
class __$$FollowRequestResponseImplCopyWithImpl<$Res>
    extends
        _$FollowRequestResponseCopyWithImpl<$Res, _$FollowRequestResponseImpl>
    implements _$$FollowRequestResponseImplCopyWith<$Res> {
  __$$FollowRequestResponseImplCopyWithImpl(
    _$FollowRequestResponseImpl _value,
    $Res Function(_$FollowRequestResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FollowRequestResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? followRequest = freezed}) {
    return _then(
      _$FollowRequestResponseImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        followRequest: freezed == followRequest
            ? _value.followRequest
            : followRequest // ignore: cast_nullable_to_non_nullable
                  as FollowRequestData?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FollowRequestResponseImpl implements _FollowRequestResponse {
  const _$FollowRequestResponseImpl({
    required this.message,
    this.followRequest,
  });

  factory _$FollowRequestResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$FollowRequestResponseImplFromJson(json);

  @override
  final String message;
  @override
  final FollowRequestData? followRequest;

  @override
  String toString() {
    return 'FollowRequestResponse(message: $message, followRequest: $followRequest)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowRequestResponseImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.followRequest, followRequest) ||
                other.followRequest == followRequest));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message, followRequest);

  /// Create a copy of FollowRequestResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowRequestResponseImplCopyWith<_$FollowRequestResponseImpl>
  get copyWith =>
      __$$FollowRequestResponseImplCopyWithImpl<_$FollowRequestResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FollowRequestResponseImplToJson(this);
  }
}

abstract class _FollowRequestResponse implements FollowRequestResponse {
  const factory _FollowRequestResponse({
    required final String message,
    final FollowRequestData? followRequest,
  }) = _$FollowRequestResponseImpl;

  factory _FollowRequestResponse.fromJson(Map<String, dynamic> json) =
      _$FollowRequestResponseImpl.fromJson;

  @override
  String get message;
  @override
  FollowRequestData? get followRequest;

  /// Create a copy of FollowRequestResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FollowRequestResponseImplCopyWith<_$FollowRequestResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

FollowRequestData _$FollowRequestDataFromJson(Map<String, dynamic> json) {
  return _FollowRequestData.fromJson(json);
}

/// @nodoc
mixin _$FollowRequestData {
  String get id => throw _privateConstructorUsedError;
  String get requesterId => throw _privateConstructorUsedError;
  String get targetId => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this FollowRequestData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FollowRequestData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FollowRequestDataCopyWith<FollowRequestData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowRequestDataCopyWith<$Res> {
  factory $FollowRequestDataCopyWith(
    FollowRequestData value,
    $Res Function(FollowRequestData) then,
  ) = _$FollowRequestDataCopyWithImpl<$Res, FollowRequestData>;
  @useResult
  $Res call({String id, String requesterId, String targetId, String createdAt});
}

/// @nodoc
class _$FollowRequestDataCopyWithImpl<$Res, $Val extends FollowRequestData>
    implements $FollowRequestDataCopyWith<$Res> {
  _$FollowRequestDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FollowRequestData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? requesterId = null,
    Object? targetId = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            requesterId: null == requesterId
                ? _value.requesterId
                : requesterId // ignore: cast_nullable_to_non_nullable
                      as String,
            targetId: null == targetId
                ? _value.targetId
                : targetId // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FollowRequestDataImplCopyWith<$Res>
    implements $FollowRequestDataCopyWith<$Res> {
  factory _$$FollowRequestDataImplCopyWith(
    _$FollowRequestDataImpl value,
    $Res Function(_$FollowRequestDataImpl) then,
  ) = __$$FollowRequestDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String requesterId, String targetId, String createdAt});
}

/// @nodoc
class __$$FollowRequestDataImplCopyWithImpl<$Res>
    extends _$FollowRequestDataCopyWithImpl<$Res, _$FollowRequestDataImpl>
    implements _$$FollowRequestDataImplCopyWith<$Res> {
  __$$FollowRequestDataImplCopyWithImpl(
    _$FollowRequestDataImpl _value,
    $Res Function(_$FollowRequestDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FollowRequestData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? requesterId = null,
    Object? targetId = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$FollowRequestDataImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        requesterId: null == requesterId
            ? _value.requesterId
            : requesterId // ignore: cast_nullable_to_non_nullable
                  as String,
        targetId: null == targetId
            ? _value.targetId
            : targetId // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FollowRequestDataImpl implements _FollowRequestData {
  const _$FollowRequestDataImpl({
    required this.id,
    required this.requesterId,
    required this.targetId,
    required this.createdAt,
  });

  factory _$FollowRequestDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$FollowRequestDataImplFromJson(json);

  @override
  final String id;
  @override
  final String requesterId;
  @override
  final String targetId;
  @override
  final String createdAt;

  @override
  String toString() {
    return 'FollowRequestData(id: $id, requesterId: $requesterId, targetId: $targetId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowRequestDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.requesterId, requesterId) ||
                other.requesterId == requesterId) &&
            (identical(other.targetId, targetId) ||
                other.targetId == targetId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, requesterId, targetId, createdAt);

  /// Create a copy of FollowRequestData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowRequestDataImplCopyWith<_$FollowRequestDataImpl> get copyWith =>
      __$$FollowRequestDataImplCopyWithImpl<_$FollowRequestDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FollowRequestDataImplToJson(this);
  }
}

abstract class _FollowRequestData implements FollowRequestData {
  const factory _FollowRequestData({
    required final String id,
    required final String requesterId,
    required final String targetId,
    required final String createdAt,
  }) = _$FollowRequestDataImpl;

  factory _FollowRequestData.fromJson(Map<String, dynamic> json) =
      _$FollowRequestDataImpl.fromJson;

  @override
  String get id;
  @override
  String get requesterId;
  @override
  String get targetId;
  @override
  String get createdAt;

  /// Create a copy of FollowRequestData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FollowRequestDataImplCopyWith<_$FollowRequestDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SentFollowRequest _$SentFollowRequestFromJson(Map<String, dynamic> json) {
  return _SentFollowRequest.fromJson(json);
}

/// @nodoc
mixin _$SentFollowRequest {
  String get id => throw _privateConstructorUsedError;
  FollowRequestTarget get target => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SentFollowRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SentFollowRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SentFollowRequestCopyWith<SentFollowRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SentFollowRequestCopyWith<$Res> {
  factory $SentFollowRequestCopyWith(
    SentFollowRequest value,
    $Res Function(SentFollowRequest) then,
  ) = _$SentFollowRequestCopyWithImpl<$Res, SentFollowRequest>;
  @useResult
  $Res call({String id, FollowRequestTarget target, String createdAt});

  $FollowRequestTargetCopyWith<$Res> get target;
}

/// @nodoc
class _$SentFollowRequestCopyWithImpl<$Res, $Val extends SentFollowRequest>
    implements $SentFollowRequestCopyWith<$Res> {
  _$SentFollowRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SentFollowRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? target = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            target: null == target
                ? _value.target
                : target // ignore: cast_nullable_to_non_nullable
                      as FollowRequestTarget,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of SentFollowRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FollowRequestTargetCopyWith<$Res> get target {
    return $FollowRequestTargetCopyWith<$Res>(_value.target, (value) {
      return _then(_value.copyWith(target: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SentFollowRequestImplCopyWith<$Res>
    implements $SentFollowRequestCopyWith<$Res> {
  factory _$$SentFollowRequestImplCopyWith(
    _$SentFollowRequestImpl value,
    $Res Function(_$SentFollowRequestImpl) then,
  ) = __$$SentFollowRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, FollowRequestTarget target, String createdAt});

  @override
  $FollowRequestTargetCopyWith<$Res> get target;
}

/// @nodoc
class __$$SentFollowRequestImplCopyWithImpl<$Res>
    extends _$SentFollowRequestCopyWithImpl<$Res, _$SentFollowRequestImpl>
    implements _$$SentFollowRequestImplCopyWith<$Res> {
  __$$SentFollowRequestImplCopyWithImpl(
    _$SentFollowRequestImpl _value,
    $Res Function(_$SentFollowRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SentFollowRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? target = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$SentFollowRequestImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        target: null == target
            ? _value.target
            : target // ignore: cast_nullable_to_non_nullable
                  as FollowRequestTarget,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SentFollowRequestImpl implements _SentFollowRequest {
  const _$SentFollowRequestImpl({
    required this.id,
    required this.target,
    required this.createdAt,
  });

  factory _$SentFollowRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SentFollowRequestImplFromJson(json);

  @override
  final String id;
  @override
  final FollowRequestTarget target;
  @override
  final String createdAt;

  @override
  String toString() {
    return 'SentFollowRequest(id: $id, target: $target, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SentFollowRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, target, createdAt);

  /// Create a copy of SentFollowRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SentFollowRequestImplCopyWith<_$SentFollowRequestImpl> get copyWith =>
      __$$SentFollowRequestImplCopyWithImpl<_$SentFollowRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SentFollowRequestImplToJson(this);
  }
}

abstract class _SentFollowRequest implements SentFollowRequest {
  const factory _SentFollowRequest({
    required final String id,
    required final FollowRequestTarget target,
    required final String createdAt,
  }) = _$SentFollowRequestImpl;

  factory _SentFollowRequest.fromJson(Map<String, dynamic> json) =
      _$SentFollowRequestImpl.fromJson;

  @override
  String get id;
  @override
  FollowRequestTarget get target;
  @override
  String get createdAt;

  /// Create a copy of SentFollowRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SentFollowRequestImplCopyWith<_$SentFollowRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FollowRequestTarget _$FollowRequestTargetFromJson(Map<String, dynamic> json) {
  return _FollowRequestTarget.fromJson(json);
}

/// @nodoc
mixin _$FollowRequestTarget {
  String get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;

  /// Serializes this FollowRequestTarget to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FollowRequestTarget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FollowRequestTargetCopyWith<FollowRequestTarget> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowRequestTargetCopyWith<$Res> {
  factory $FollowRequestTargetCopyWith(
    FollowRequestTarget value,
    $Res Function(FollowRequestTarget) then,
  ) = _$FollowRequestTargetCopyWithImpl<$Res, FollowRequestTarget>;
  @useResult
  $Res call({String id, String? name, String? avatarUrl});
}

/// @nodoc
class _$FollowRequestTargetCopyWithImpl<$Res, $Val extends FollowRequestTarget>
    implements $FollowRequestTargetCopyWith<$Res> {
  _$FollowRequestTargetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FollowRequestTarget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? avatarUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$FollowRequestTargetImplCopyWith<$Res>
    implements $FollowRequestTargetCopyWith<$Res> {
  factory _$$FollowRequestTargetImplCopyWith(
    _$FollowRequestTargetImpl value,
    $Res Function(_$FollowRequestTargetImpl) then,
  ) = __$$FollowRequestTargetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String? name, String? avatarUrl});
}

/// @nodoc
class __$$FollowRequestTargetImplCopyWithImpl<$Res>
    extends _$FollowRequestTargetCopyWithImpl<$Res, _$FollowRequestTargetImpl>
    implements _$$FollowRequestTargetImplCopyWith<$Res> {
  __$$FollowRequestTargetImplCopyWithImpl(
    _$FollowRequestTargetImpl _value,
    $Res Function(_$FollowRequestTargetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FollowRequestTarget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? avatarUrl = freezed,
  }) {
    return _then(
      _$FollowRequestTargetImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$FollowRequestTargetImpl implements _FollowRequestTarget {
  const _$FollowRequestTargetImpl({
    required this.id,
    this.name,
    this.avatarUrl,
  });

  factory _$FollowRequestTargetImpl.fromJson(Map<String, dynamic> json) =>
      _$$FollowRequestTargetImplFromJson(json);

  @override
  final String id;
  @override
  final String? name;
  @override
  final String? avatarUrl;

  @override
  String toString() {
    return 'FollowRequestTarget(id: $id, name: $name, avatarUrl: $avatarUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowRequestTargetImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, avatarUrl);

  /// Create a copy of FollowRequestTarget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowRequestTargetImplCopyWith<_$FollowRequestTargetImpl> get copyWith =>
      __$$FollowRequestTargetImplCopyWithImpl<_$FollowRequestTargetImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FollowRequestTargetImplToJson(this);
  }
}

abstract class _FollowRequestTarget implements FollowRequestTarget {
  const factory _FollowRequestTarget({
    required final String id,
    final String? name,
    final String? avatarUrl,
  }) = _$FollowRequestTargetImpl;

  factory _FollowRequestTarget.fromJson(Map<String, dynamic> json) =
      _$FollowRequestTargetImpl.fromJson;

  @override
  String get id;
  @override
  String? get name;
  @override
  String? get avatarUrl;

  /// Create a copy of FollowRequestTarget
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FollowRequestTargetImplCopyWith<_$FollowRequestTargetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SentFollowRequestListResponse _$SentFollowRequestListResponseFromJson(
  Map<String, dynamic> json,
) {
  return _SentFollowRequestListResponse.fromJson(json);
}

/// @nodoc
mixin _$SentFollowRequestListResponse {
  List<SentFollowRequest> get data => throw _privateConstructorUsedError;
  Pagination get pagination => throw _privateConstructorUsedError;

  /// Serializes this SentFollowRequestListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SentFollowRequestListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SentFollowRequestListResponseCopyWith<SentFollowRequestListResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SentFollowRequestListResponseCopyWith<$Res> {
  factory $SentFollowRequestListResponseCopyWith(
    SentFollowRequestListResponse value,
    $Res Function(SentFollowRequestListResponse) then,
  ) =
      _$SentFollowRequestListResponseCopyWithImpl<
        $Res,
        SentFollowRequestListResponse
      >;
  @useResult
  $Res call({List<SentFollowRequest> data, Pagination pagination});

  $PaginationCopyWith<$Res> get pagination;
}

/// @nodoc
class _$SentFollowRequestListResponseCopyWithImpl<
  $Res,
  $Val extends SentFollowRequestListResponse
>
    implements $SentFollowRequestListResponseCopyWith<$Res> {
  _$SentFollowRequestListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SentFollowRequestListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null, Object? pagination = null}) {
    return _then(
      _value.copyWith(
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<SentFollowRequest>,
            pagination: null == pagination
                ? _value.pagination
                : pagination // ignore: cast_nullable_to_non_nullable
                      as Pagination,
          )
          as $Val,
    );
  }

  /// Create a copy of SentFollowRequestListResponse
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
abstract class _$$SentFollowRequestListResponseImplCopyWith<$Res>
    implements $SentFollowRequestListResponseCopyWith<$Res> {
  factory _$$SentFollowRequestListResponseImplCopyWith(
    _$SentFollowRequestListResponseImpl value,
    $Res Function(_$SentFollowRequestListResponseImpl) then,
  ) = __$$SentFollowRequestListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<SentFollowRequest> data, Pagination pagination});

  @override
  $PaginationCopyWith<$Res> get pagination;
}

/// @nodoc
class __$$SentFollowRequestListResponseImplCopyWithImpl<$Res>
    extends
        _$SentFollowRequestListResponseCopyWithImpl<
          $Res,
          _$SentFollowRequestListResponseImpl
        >
    implements _$$SentFollowRequestListResponseImplCopyWith<$Res> {
  __$$SentFollowRequestListResponseImplCopyWithImpl(
    _$SentFollowRequestListResponseImpl _value,
    $Res Function(_$SentFollowRequestListResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SentFollowRequestListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null, Object? pagination = null}) {
    return _then(
      _$SentFollowRequestListResponseImpl(
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<SentFollowRequest>,
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
class _$SentFollowRequestListResponseImpl
    implements _SentFollowRequestListResponse {
  const _$SentFollowRequestListResponseImpl({
    required final List<SentFollowRequest> data,
    required this.pagination,
  }) : _data = data;

  factory _$SentFollowRequestListResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$SentFollowRequestListResponseImplFromJson(json);

  final List<SentFollowRequest> _data;
  @override
  List<SentFollowRequest> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  final Pagination pagination;

  @override
  String toString() {
    return 'SentFollowRequestListResponse(data: $data, pagination: $pagination)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SentFollowRequestListResponseImpl &&
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

  /// Create a copy of SentFollowRequestListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SentFollowRequestListResponseImplCopyWith<
    _$SentFollowRequestListResponseImpl
  >
  get copyWith =>
      __$$SentFollowRequestListResponseImplCopyWithImpl<
        _$SentFollowRequestListResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SentFollowRequestListResponseImplToJson(this);
  }
}

abstract class _SentFollowRequestListResponse
    implements SentFollowRequestListResponse {
  const factory _SentFollowRequestListResponse({
    required final List<SentFollowRequest> data,
    required final Pagination pagination,
  }) = _$SentFollowRequestListResponseImpl;

  factory _SentFollowRequestListResponse.fromJson(Map<String, dynamic> json) =
      _$SentFollowRequestListResponseImpl.fromJson;

  @override
  List<SentFollowRequest> get data;
  @override
  Pagination get pagination;

  /// Create a copy of SentFollowRequestListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SentFollowRequestListResponseImplCopyWith<
    _$SentFollowRequestListResponseImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
