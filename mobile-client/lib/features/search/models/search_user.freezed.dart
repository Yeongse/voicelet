// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SearchUser _$SearchUserFromJson(Map<String, dynamic> json) {
  return _SearchUser.fromJson(json);
}

/// @nodoc
mixin _$SearchUser {
  String get id => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  bool get isPrivate => throw _privateConstructorUsedError;
  String get followStatus => throw _privateConstructorUsedError;

  /// Serializes this SearchUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchUserCopyWith<SearchUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchUserCopyWith<$Res> {
  factory $SearchUserCopyWith(
    SearchUser value,
    $Res Function(SearchUser) then,
  ) = _$SearchUserCopyWithImpl<$Res, SearchUser>;
  @useResult
  $Res call({
    String id,
    String? username,
    String? name,
    String? avatarUrl,
    bool isPrivate,
    String followStatus,
  });
}

/// @nodoc
class _$SearchUserCopyWithImpl<$Res, $Val extends SearchUser>
    implements $SearchUserCopyWith<$Res> {
  _$SearchUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = freezed,
    Object? name = freezed,
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
            username: freezed == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
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
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchUserImplCopyWith<$Res>
    implements $SearchUserCopyWith<$Res> {
  factory _$$SearchUserImplCopyWith(
    _$SearchUserImpl value,
    $Res Function(_$SearchUserImpl) then,
  ) = __$$SearchUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? username,
    String? name,
    String? avatarUrl,
    bool isPrivate,
    String followStatus,
  });
}

/// @nodoc
class __$$SearchUserImplCopyWithImpl<$Res>
    extends _$SearchUserCopyWithImpl<$Res, _$SearchUserImpl>
    implements _$$SearchUserImplCopyWith<$Res> {
  __$$SearchUserImplCopyWithImpl(
    _$SearchUserImpl _value,
    $Res Function(_$SearchUserImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = freezed,
    Object? name = freezed,
    Object? avatarUrl = freezed,
    Object? isPrivate = null,
    Object? followStatus = null,
  }) {
    return _then(
      _$SearchUserImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        username: freezed == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
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
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchUserImpl implements _SearchUser {
  const _$SearchUserImpl({
    required this.id,
    this.username,
    this.name,
    this.avatarUrl,
    this.isPrivate = false,
    this.followStatus = 'none',
  });

  factory _$SearchUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchUserImplFromJson(json);

  @override
  final String id;
  @override
  final String? username;
  @override
  final String? name;
  @override
  final String? avatarUrl;
  @override
  @JsonKey()
  final bool isPrivate;
  @override
  @JsonKey()
  final String followStatus;

  @override
  String toString() {
    return 'SearchUser(id: $id, username: $username, name: $name, avatarUrl: $avatarUrl, isPrivate: $isPrivate, followStatus: $followStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.isPrivate, isPrivate) ||
                other.isPrivate == isPrivate) &&
            (identical(other.followStatus, followStatus) ||
                other.followStatus == followStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    username,
    name,
    avatarUrl,
    isPrivate,
    followStatus,
  );

  /// Create a copy of SearchUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchUserImplCopyWith<_$SearchUserImpl> get copyWith =>
      __$$SearchUserImplCopyWithImpl<_$SearchUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchUserImplToJson(this);
  }
}

abstract class _SearchUser implements SearchUser {
  const factory _SearchUser({
    required final String id,
    final String? username,
    final String? name,
    final String? avatarUrl,
    final bool isPrivate,
    final String followStatus,
  }) = _$SearchUserImpl;

  factory _SearchUser.fromJson(Map<String, dynamic> json) =
      _$SearchUserImpl.fromJson;

  @override
  String get id;
  @override
  String? get username;
  @override
  String? get name;
  @override
  String? get avatarUrl;
  @override
  bool get isPrivate;
  @override
  String get followStatus;

  /// Create a copy of SearchUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchUserImplCopyWith<_$SearchUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchUsersResponse _$SearchUsersResponseFromJson(Map<String, dynamic> json) {
  return _SearchUsersResponse.fromJson(json);
}

/// @nodoc
mixin _$SearchUsersResponse {
  List<SearchUser> get data => throw _privateConstructorUsedError;
  SearchPagination get pagination => throw _privateConstructorUsedError;

  /// Serializes this SearchUsersResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchUsersResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchUsersResponseCopyWith<SearchUsersResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchUsersResponseCopyWith<$Res> {
  factory $SearchUsersResponseCopyWith(
    SearchUsersResponse value,
    $Res Function(SearchUsersResponse) then,
  ) = _$SearchUsersResponseCopyWithImpl<$Res, SearchUsersResponse>;
  @useResult
  $Res call({List<SearchUser> data, SearchPagination pagination});

  $SearchPaginationCopyWith<$Res> get pagination;
}

/// @nodoc
class _$SearchUsersResponseCopyWithImpl<$Res, $Val extends SearchUsersResponse>
    implements $SearchUsersResponseCopyWith<$Res> {
  _$SearchUsersResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchUsersResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null, Object? pagination = null}) {
    return _then(
      _value.copyWith(
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<SearchUser>,
            pagination: null == pagination
                ? _value.pagination
                : pagination // ignore: cast_nullable_to_non_nullable
                      as SearchPagination,
          )
          as $Val,
    );
  }

  /// Create a copy of SearchUsersResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SearchPaginationCopyWith<$Res> get pagination {
    return $SearchPaginationCopyWith<$Res>(_value.pagination, (value) {
      return _then(_value.copyWith(pagination: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SearchUsersResponseImplCopyWith<$Res>
    implements $SearchUsersResponseCopyWith<$Res> {
  factory _$$SearchUsersResponseImplCopyWith(
    _$SearchUsersResponseImpl value,
    $Res Function(_$SearchUsersResponseImpl) then,
  ) = __$$SearchUsersResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<SearchUser> data, SearchPagination pagination});

  @override
  $SearchPaginationCopyWith<$Res> get pagination;
}

/// @nodoc
class __$$SearchUsersResponseImplCopyWithImpl<$Res>
    extends _$SearchUsersResponseCopyWithImpl<$Res, _$SearchUsersResponseImpl>
    implements _$$SearchUsersResponseImplCopyWith<$Res> {
  __$$SearchUsersResponseImplCopyWithImpl(
    _$SearchUsersResponseImpl _value,
    $Res Function(_$SearchUsersResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchUsersResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? data = null, Object? pagination = null}) {
    return _then(
      _$SearchUsersResponseImpl(
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<SearchUser>,
        pagination: null == pagination
            ? _value.pagination
            : pagination // ignore: cast_nullable_to_non_nullable
                  as SearchPagination,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchUsersResponseImpl implements _SearchUsersResponse {
  const _$SearchUsersResponseImpl({
    required final List<SearchUser> data,
    required this.pagination,
  }) : _data = data;

  factory _$SearchUsersResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchUsersResponseImplFromJson(json);

  final List<SearchUser> _data;
  @override
  List<SearchUser> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  final SearchPagination pagination;

  @override
  String toString() {
    return 'SearchUsersResponse(data: $data, pagination: $pagination)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchUsersResponseImpl &&
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

  /// Create a copy of SearchUsersResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchUsersResponseImplCopyWith<_$SearchUsersResponseImpl> get copyWith =>
      __$$SearchUsersResponseImplCopyWithImpl<_$SearchUsersResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchUsersResponseImplToJson(this);
  }
}

abstract class _SearchUsersResponse implements SearchUsersResponse {
  const factory _SearchUsersResponse({
    required final List<SearchUser> data,
    required final SearchPagination pagination,
  }) = _$SearchUsersResponseImpl;

  factory _SearchUsersResponse.fromJson(Map<String, dynamic> json) =
      _$SearchUsersResponseImpl.fromJson;

  @override
  List<SearchUser> get data;
  @override
  SearchPagination get pagination;

  /// Create a copy of SearchUsersResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchUsersResponseImplCopyWith<_$SearchUsersResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchPagination _$SearchPaginationFromJson(Map<String, dynamic> json) {
  return _SearchPagination.fromJson(json);
}

/// @nodoc
mixin _$SearchPagination {
  int get total => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  bool get hasNext => throw _privateConstructorUsedError;
  bool get hasPrev => throw _privateConstructorUsedError;

  /// Serializes this SearchPagination to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchPagination
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchPaginationCopyWith<SearchPagination> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchPaginationCopyWith<$Res> {
  factory $SearchPaginationCopyWith(
    SearchPagination value,
    $Res Function(SearchPagination) then,
  ) = _$SearchPaginationCopyWithImpl<$Res, SearchPagination>;
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
class _$SearchPaginationCopyWithImpl<$Res, $Val extends SearchPagination>
    implements $SearchPaginationCopyWith<$Res> {
  _$SearchPaginationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchPagination
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
abstract class _$$SearchPaginationImplCopyWith<$Res>
    implements $SearchPaginationCopyWith<$Res> {
  factory _$$SearchPaginationImplCopyWith(
    _$SearchPaginationImpl value,
    $Res Function(_$SearchPaginationImpl) then,
  ) = __$$SearchPaginationImplCopyWithImpl<$Res>;
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
class __$$SearchPaginationImplCopyWithImpl<$Res>
    extends _$SearchPaginationCopyWithImpl<$Res, _$SearchPaginationImpl>
    implements _$$SearchPaginationImplCopyWith<$Res> {
  __$$SearchPaginationImplCopyWithImpl(
    _$SearchPaginationImpl _value,
    $Res Function(_$SearchPaginationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchPagination
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
      _$SearchPaginationImpl(
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
class _$SearchPaginationImpl implements _SearchPagination {
  const _$SearchPaginationImpl({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory _$SearchPaginationImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchPaginationImplFromJson(json);

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
    return 'SearchPagination(total: $total, page: $page, limit: $limit, totalPages: $totalPages, hasNext: $hasNext, hasPrev: $hasPrev)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchPaginationImpl &&
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

  /// Create a copy of SearchPagination
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchPaginationImplCopyWith<_$SearchPaginationImpl> get copyWith =>
      __$$SearchPaginationImplCopyWithImpl<_$SearchPaginationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchPaginationImplToJson(this);
  }
}

abstract class _SearchPagination implements SearchPagination {
  const factory _SearchPagination({
    required final int total,
    required final int page,
    required final int limit,
    required final int totalPages,
    required final bool hasNext,
    required final bool hasPrev,
  }) = _$SearchPaginationImpl;

  factory _SearchPagination.fromJson(Map<String, dynamic> json) =
      _$SearchPaginationImpl.fromJson;

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

  /// Create a copy of SearchPagination
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchPaginationImplCopyWith<_$SearchPaginationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
