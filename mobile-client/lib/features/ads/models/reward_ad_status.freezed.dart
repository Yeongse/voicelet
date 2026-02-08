// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reward_ad_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RewardAdStatus _$RewardAdStatusFromJson(Map<String, dynamic> json) {
  return _RewardAdStatus.fromJson(json);
}

/// @nodoc
mixin _$RewardAdStatus {
  int get remainingCount => throw _privateConstructorUsedError;
  String get nextResetAt => throw _privateConstructorUsedError;
  int get todayClearedCount => throw _privateConstructorUsedError;

  /// Serializes this RewardAdStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RewardAdStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RewardAdStatusCopyWith<RewardAdStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RewardAdStatusCopyWith<$Res> {
  factory $RewardAdStatusCopyWith(
    RewardAdStatus value,
    $Res Function(RewardAdStatus) then,
  ) = _$RewardAdStatusCopyWithImpl<$Res, RewardAdStatus>;
  @useResult
  $Res call({int remainingCount, String nextResetAt, int todayClearedCount});
}

/// @nodoc
class _$RewardAdStatusCopyWithImpl<$Res, $Val extends RewardAdStatus>
    implements $RewardAdStatusCopyWith<$Res> {
  _$RewardAdStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RewardAdStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? remainingCount = null,
    Object? nextResetAt = null,
    Object? todayClearedCount = null,
  }) {
    return _then(
      _value.copyWith(
            remainingCount: null == remainingCount
                ? _value.remainingCount
                : remainingCount // ignore: cast_nullable_to_non_nullable
                      as int,
            nextResetAt: null == nextResetAt
                ? _value.nextResetAt
                : nextResetAt // ignore: cast_nullable_to_non_nullable
                      as String,
            todayClearedCount: null == todayClearedCount
                ? _value.todayClearedCount
                : todayClearedCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RewardAdStatusImplCopyWith<$Res>
    implements $RewardAdStatusCopyWith<$Res> {
  factory _$$RewardAdStatusImplCopyWith(
    _$RewardAdStatusImpl value,
    $Res Function(_$RewardAdStatusImpl) then,
  ) = __$$RewardAdStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int remainingCount, String nextResetAt, int todayClearedCount});
}

/// @nodoc
class __$$RewardAdStatusImplCopyWithImpl<$Res>
    extends _$RewardAdStatusCopyWithImpl<$Res, _$RewardAdStatusImpl>
    implements _$$RewardAdStatusImplCopyWith<$Res> {
  __$$RewardAdStatusImplCopyWithImpl(
    _$RewardAdStatusImpl _value,
    $Res Function(_$RewardAdStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RewardAdStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? remainingCount = null,
    Object? nextResetAt = null,
    Object? todayClearedCount = null,
  }) {
    return _then(
      _$RewardAdStatusImpl(
        remainingCount: null == remainingCount
            ? _value.remainingCount
            : remainingCount // ignore: cast_nullable_to_non_nullable
                  as int,
        nextResetAt: null == nextResetAt
            ? _value.nextResetAt
            : nextResetAt // ignore: cast_nullable_to_non_nullable
                  as String,
        todayClearedCount: null == todayClearedCount
            ? _value.todayClearedCount
            : todayClearedCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RewardAdStatusImpl implements _RewardAdStatus {
  const _$RewardAdStatusImpl({
    required this.remainingCount,
    required this.nextResetAt,
    this.todayClearedCount = 0,
  });

  factory _$RewardAdStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$RewardAdStatusImplFromJson(json);

  @override
  final int remainingCount;
  @override
  final String nextResetAt;
  @override
  @JsonKey()
  final int todayClearedCount;

  @override
  String toString() {
    return 'RewardAdStatus(remainingCount: $remainingCount, nextResetAt: $nextResetAt, todayClearedCount: $todayClearedCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RewardAdStatusImpl &&
            (identical(other.remainingCount, remainingCount) ||
                other.remainingCount == remainingCount) &&
            (identical(other.nextResetAt, nextResetAt) ||
                other.nextResetAt == nextResetAt) &&
            (identical(other.todayClearedCount, todayClearedCount) ||
                other.todayClearedCount == todayClearedCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, remainingCount, nextResetAt, todayClearedCount);

  /// Create a copy of RewardAdStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RewardAdStatusImplCopyWith<_$RewardAdStatusImpl> get copyWith =>
      __$$RewardAdStatusImplCopyWithImpl<_$RewardAdStatusImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RewardAdStatusImplToJson(this);
  }
}

abstract class _RewardAdStatus implements RewardAdStatus {
  const factory _RewardAdStatus({
    required final int remainingCount,
    required final String nextResetAt,
    final int todayClearedCount,
  }) = _$RewardAdStatusImpl;

  factory _RewardAdStatus.fromJson(Map<String, dynamic> json) =
      _$RewardAdStatusImpl.fromJson;

  @override
  int get remainingCount;
  @override
  String get nextResetAt;
  @override
  int get todayClearedCount;

  /// Create a copy of RewardAdStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RewardAdStatusImplCopyWith<_$RewardAdStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RewardAdUseResponse _$RewardAdUseResponseFromJson(Map<String, dynamic> json) {
  return _RewardAdUseResponse.fromJson(json);
}

/// @nodoc
mixin _$RewardAdUseResponse {
  bool get success => throw _privateConstructorUsedError;
  int get clearedCount => throw _privateConstructorUsedError;
  int get remainingCount => throw _privateConstructorUsedError;
  String get nextResetAt => throw _privateConstructorUsedError;

  /// Serializes this RewardAdUseResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RewardAdUseResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RewardAdUseResponseCopyWith<RewardAdUseResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RewardAdUseResponseCopyWith<$Res> {
  factory $RewardAdUseResponseCopyWith(
    RewardAdUseResponse value,
    $Res Function(RewardAdUseResponse) then,
  ) = _$RewardAdUseResponseCopyWithImpl<$Res, RewardAdUseResponse>;
  @useResult
  $Res call({
    bool success,
    int clearedCount,
    int remainingCount,
    String nextResetAt,
  });
}

/// @nodoc
class _$RewardAdUseResponseCopyWithImpl<$Res, $Val extends RewardAdUseResponse>
    implements $RewardAdUseResponseCopyWith<$Res> {
  _$RewardAdUseResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RewardAdUseResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? clearedCount = null,
    Object? remainingCount = null,
    Object? nextResetAt = null,
  }) {
    return _then(
      _value.copyWith(
            success: null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool,
            clearedCount: null == clearedCount
                ? _value.clearedCount
                : clearedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            remainingCount: null == remainingCount
                ? _value.remainingCount
                : remainingCount // ignore: cast_nullable_to_non_nullable
                      as int,
            nextResetAt: null == nextResetAt
                ? _value.nextResetAt
                : nextResetAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RewardAdUseResponseImplCopyWith<$Res>
    implements $RewardAdUseResponseCopyWith<$Res> {
  factory _$$RewardAdUseResponseImplCopyWith(
    _$RewardAdUseResponseImpl value,
    $Res Function(_$RewardAdUseResponseImpl) then,
  ) = __$$RewardAdUseResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool success,
    int clearedCount,
    int remainingCount,
    String nextResetAt,
  });
}

/// @nodoc
class __$$RewardAdUseResponseImplCopyWithImpl<$Res>
    extends _$RewardAdUseResponseCopyWithImpl<$Res, _$RewardAdUseResponseImpl>
    implements _$$RewardAdUseResponseImplCopyWith<$Res> {
  __$$RewardAdUseResponseImplCopyWithImpl(
    _$RewardAdUseResponseImpl _value,
    $Res Function(_$RewardAdUseResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RewardAdUseResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? clearedCount = null,
    Object? remainingCount = null,
    Object? nextResetAt = null,
  }) {
    return _then(
      _$RewardAdUseResponseImpl(
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        clearedCount: null == clearedCount
            ? _value.clearedCount
            : clearedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        remainingCount: null == remainingCount
            ? _value.remainingCount
            : remainingCount // ignore: cast_nullable_to_non_nullable
                  as int,
        nextResetAt: null == nextResetAt
            ? _value.nextResetAt
            : nextResetAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RewardAdUseResponseImpl implements _RewardAdUseResponse {
  const _$RewardAdUseResponseImpl({
    required this.success,
    required this.clearedCount,
    required this.remainingCount,
    required this.nextResetAt,
  });

  factory _$RewardAdUseResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$RewardAdUseResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final int clearedCount;
  @override
  final int remainingCount;
  @override
  final String nextResetAt;

  @override
  String toString() {
    return 'RewardAdUseResponse(success: $success, clearedCount: $clearedCount, remainingCount: $remainingCount, nextResetAt: $nextResetAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RewardAdUseResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.clearedCount, clearedCount) ||
                other.clearedCount == clearedCount) &&
            (identical(other.remainingCount, remainingCount) ||
                other.remainingCount == remainingCount) &&
            (identical(other.nextResetAt, nextResetAt) ||
                other.nextResetAt == nextResetAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    success,
    clearedCount,
    remainingCount,
    nextResetAt,
  );

  /// Create a copy of RewardAdUseResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RewardAdUseResponseImplCopyWith<_$RewardAdUseResponseImpl> get copyWith =>
      __$$RewardAdUseResponseImplCopyWithImpl<_$RewardAdUseResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RewardAdUseResponseImplToJson(this);
  }
}

abstract class _RewardAdUseResponse implements RewardAdUseResponse {
  const factory _RewardAdUseResponse({
    required final bool success,
    required final int clearedCount,
    required final int remainingCount,
    required final String nextResetAt,
  }) = _$RewardAdUseResponseImpl;

  factory _RewardAdUseResponse.fromJson(Map<String, dynamic> json) =
      _$RewardAdUseResponseImpl.fromJson;

  @override
  bool get success;
  @override
  int get clearedCount;
  @override
  int get remainingCount;
  @override
  String get nextResetAt;

  /// Create a copy of RewardAdUseResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RewardAdUseResponseImplCopyWith<_$RewardAdUseResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
