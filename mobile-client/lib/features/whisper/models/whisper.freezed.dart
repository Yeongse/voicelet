// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'whisper.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SignedUrlResponse _$SignedUrlResponseFromJson(Map<String, dynamic> json) {
  return _SignedUrlResponse.fromJson(json);
}

/// @nodoc
mixin _$SignedUrlResponse {
  String get signedUrl => throw _privateConstructorUsedError;
  String get bucketName => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  String get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this SignedUrlResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SignedUrlResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SignedUrlResponseCopyWith<SignedUrlResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SignedUrlResponseCopyWith<$Res> {
  factory $SignedUrlResponseCopyWith(
    SignedUrlResponse value,
    $Res Function(SignedUrlResponse) then,
  ) = _$SignedUrlResponseCopyWithImpl<$Res, SignedUrlResponse>;
  @useResult
  $Res call({
    String signedUrl,
    String bucketName,
    String fileName,
    String expiresAt,
  });
}

/// @nodoc
class _$SignedUrlResponseCopyWithImpl<$Res, $Val extends SignedUrlResponse>
    implements $SignedUrlResponseCopyWith<$Res> {
  _$SignedUrlResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SignedUrlResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? signedUrl = null,
    Object? bucketName = null,
    Object? fileName = null,
    Object? expiresAt = null,
  }) {
    return _then(
      _value.copyWith(
            signedUrl: null == signedUrl
                ? _value.signedUrl
                : signedUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            bucketName: null == bucketName
                ? _value.bucketName
                : bucketName // ignore: cast_nullable_to_non_nullable
                      as String,
            fileName: null == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
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
abstract class _$$SignedUrlResponseImplCopyWith<$Res>
    implements $SignedUrlResponseCopyWith<$Res> {
  factory _$$SignedUrlResponseImplCopyWith(
    _$SignedUrlResponseImpl value,
    $Res Function(_$SignedUrlResponseImpl) then,
  ) = __$$SignedUrlResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String signedUrl,
    String bucketName,
    String fileName,
    String expiresAt,
  });
}

/// @nodoc
class __$$SignedUrlResponseImplCopyWithImpl<$Res>
    extends _$SignedUrlResponseCopyWithImpl<$Res, _$SignedUrlResponseImpl>
    implements _$$SignedUrlResponseImplCopyWith<$Res> {
  __$$SignedUrlResponseImplCopyWithImpl(
    _$SignedUrlResponseImpl _value,
    $Res Function(_$SignedUrlResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignedUrlResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? signedUrl = null,
    Object? bucketName = null,
    Object? fileName = null,
    Object? expiresAt = null,
  }) {
    return _then(
      _$SignedUrlResponseImpl(
        signedUrl: null == signedUrl
            ? _value.signedUrl
            : signedUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        bucketName: null == bucketName
            ? _value.bucketName
            : bucketName // ignore: cast_nullable_to_non_nullable
                  as String,
        fileName: null == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
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
class _$SignedUrlResponseImpl implements _SignedUrlResponse {
  const _$SignedUrlResponseImpl({
    required this.signedUrl,
    required this.bucketName,
    required this.fileName,
    required this.expiresAt,
  });

  factory _$SignedUrlResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SignedUrlResponseImplFromJson(json);

  @override
  final String signedUrl;
  @override
  final String bucketName;
  @override
  final String fileName;
  @override
  final String expiresAt;

  @override
  String toString() {
    return 'SignedUrlResponse(signedUrl: $signedUrl, bucketName: $bucketName, fileName: $fileName, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SignedUrlResponseImpl &&
            (identical(other.signedUrl, signedUrl) ||
                other.signedUrl == signedUrl) &&
            (identical(other.bucketName, bucketName) ||
                other.bucketName == bucketName) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, signedUrl, bucketName, fileName, expiresAt);

  /// Create a copy of SignedUrlResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SignedUrlResponseImplCopyWith<_$SignedUrlResponseImpl> get copyWith =>
      __$$SignedUrlResponseImplCopyWithImpl<_$SignedUrlResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SignedUrlResponseImplToJson(this);
  }
}

abstract class _SignedUrlResponse implements SignedUrlResponse {
  const factory _SignedUrlResponse({
    required final String signedUrl,
    required final String bucketName,
    required final String fileName,
    required final String expiresAt,
  }) = _$SignedUrlResponseImpl;

  factory _SignedUrlResponse.fromJson(Map<String, dynamic> json) =
      _$SignedUrlResponseImpl.fromJson;

  @override
  String get signedUrl;
  @override
  String get bucketName;
  @override
  String get fileName;
  @override
  String get expiresAt;

  /// Create a copy of SignedUrlResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SignedUrlResponseImplCopyWith<_$SignedUrlResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Whisper _$WhisperFromJson(Map<String, dynamic> json) {
  return _Whisper.fromJson(json);
}

/// @nodoc
mixin _$Whisper {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get bucketName => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Whisper to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Whisper
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WhisperCopyWith<Whisper> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WhisperCopyWith<$Res> {
  factory $WhisperCopyWith(Whisper value, $Res Function(Whisper) then) =
      _$WhisperCopyWithImpl<$Res, Whisper>;
  @useResult
  $Res call({
    String id,
    String userId,
    String bucketName,
    String fileName,
    int duration,
    String createdAt,
  });
}

/// @nodoc
class _$WhisperCopyWithImpl<$Res, $Val extends Whisper>
    implements $WhisperCopyWith<$Res> {
  _$WhisperCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Whisper
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WhisperImplCopyWith<$Res> implements $WhisperCopyWith<$Res> {
  factory _$$WhisperImplCopyWith(
    _$WhisperImpl value,
    $Res Function(_$WhisperImpl) then,
  ) = __$$WhisperImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String bucketName,
    String fileName,
    int duration,
    String createdAt,
  });
}

/// @nodoc
class __$$WhisperImplCopyWithImpl<$Res>
    extends _$WhisperCopyWithImpl<$Res, _$WhisperImpl>
    implements _$$WhisperImplCopyWith<$Res> {
  __$$WhisperImplCopyWithImpl(
    _$WhisperImpl _value,
    $Res Function(_$WhisperImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Whisper
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
  }) {
    return _then(
      _$WhisperImpl(
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WhisperImpl implements _Whisper {
  const _$WhisperImpl({
    required this.id,
    required this.userId,
    required this.bucketName,
    required this.fileName,
    required this.duration,
    required this.createdAt,
  });

  factory _$WhisperImpl.fromJson(Map<String, dynamic> json) =>
      _$$WhisperImplFromJson(json);

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
  String toString() {
    return 'Whisper(id: $id, userId: $userId, bucketName: $bucketName, fileName: $fileName, duration: $duration, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WhisperImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.bucketName, bucketName) ||
                other.bucketName == bucketName) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
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
  );

  /// Create a copy of Whisper
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WhisperImplCopyWith<_$WhisperImpl> get copyWith =>
      __$$WhisperImplCopyWithImpl<_$WhisperImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WhisperImplToJson(this);
  }
}

abstract class _Whisper implements Whisper {
  const factory _Whisper({
    required final String id,
    required final String userId,
    required final String bucketName,
    required final String fileName,
    required final int duration,
    required final String createdAt,
  }) = _$WhisperImpl;

  factory _Whisper.fromJson(Map<String, dynamic> json) = _$WhisperImpl.fromJson;

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

  /// Create a copy of Whisper
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WhisperImplCopyWith<_$WhisperImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AudioUrlResponse _$AudioUrlResponseFromJson(Map<String, dynamic> json) {
  return _AudioUrlResponse.fromJson(json);
}

/// @nodoc
mixin _$AudioUrlResponse {
  String get signedUrl => throw _privateConstructorUsedError;
  String get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this AudioUrlResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AudioUrlResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AudioUrlResponseCopyWith<AudioUrlResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AudioUrlResponseCopyWith<$Res> {
  factory $AudioUrlResponseCopyWith(
    AudioUrlResponse value,
    $Res Function(AudioUrlResponse) then,
  ) = _$AudioUrlResponseCopyWithImpl<$Res, AudioUrlResponse>;
  @useResult
  $Res call({String signedUrl, String expiresAt});
}

/// @nodoc
class _$AudioUrlResponseCopyWithImpl<$Res, $Val extends AudioUrlResponse>
    implements $AudioUrlResponseCopyWith<$Res> {
  _$AudioUrlResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AudioUrlResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? signedUrl = null, Object? expiresAt = null}) {
    return _then(
      _value.copyWith(
            signedUrl: null == signedUrl
                ? _value.signedUrl
                : signedUrl // ignore: cast_nullable_to_non_nullable
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
abstract class _$$AudioUrlResponseImplCopyWith<$Res>
    implements $AudioUrlResponseCopyWith<$Res> {
  factory _$$AudioUrlResponseImplCopyWith(
    _$AudioUrlResponseImpl value,
    $Res Function(_$AudioUrlResponseImpl) then,
  ) = __$$AudioUrlResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String signedUrl, String expiresAt});
}

/// @nodoc
class __$$AudioUrlResponseImplCopyWithImpl<$Res>
    extends _$AudioUrlResponseCopyWithImpl<$Res, _$AudioUrlResponseImpl>
    implements _$$AudioUrlResponseImplCopyWith<$Res> {
  __$$AudioUrlResponseImplCopyWithImpl(
    _$AudioUrlResponseImpl _value,
    $Res Function(_$AudioUrlResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AudioUrlResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? signedUrl = null, Object? expiresAt = null}) {
    return _then(
      _$AudioUrlResponseImpl(
        signedUrl: null == signedUrl
            ? _value.signedUrl
            : signedUrl // ignore: cast_nullable_to_non_nullable
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
class _$AudioUrlResponseImpl implements _AudioUrlResponse {
  const _$AudioUrlResponseImpl({
    required this.signedUrl,
    required this.expiresAt,
  });

  factory _$AudioUrlResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AudioUrlResponseImplFromJson(json);

  @override
  final String signedUrl;
  @override
  final String expiresAt;

  @override
  String toString() {
    return 'AudioUrlResponse(signedUrl: $signedUrl, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AudioUrlResponseImpl &&
            (identical(other.signedUrl, signedUrl) ||
                other.signedUrl == signedUrl) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, signedUrl, expiresAt);

  /// Create a copy of AudioUrlResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AudioUrlResponseImplCopyWith<_$AudioUrlResponseImpl> get copyWith =>
      __$$AudioUrlResponseImplCopyWithImpl<_$AudioUrlResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AudioUrlResponseImplToJson(this);
  }
}

abstract class _AudioUrlResponse implements AudioUrlResponse {
  const factory _AudioUrlResponse({
    required final String signedUrl,
    required final String expiresAt,
  }) = _$AudioUrlResponseImpl;

  factory _AudioUrlResponse.fromJson(Map<String, dynamic> json) =
      _$AudioUrlResponseImpl.fromJson;

  @override
  String get signedUrl;
  @override
  String get expiresAt;

  /// Create a copy of AudioUrlResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AudioUrlResponseImplCopyWith<_$AudioUrlResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateWhisperResponse _$CreateWhisperResponseFromJson(
  Map<String, dynamic> json,
) {
  return _CreateWhisperResponse.fromJson(json);
}

/// @nodoc
mixin _$CreateWhisperResponse {
  String get message => throw _privateConstructorUsedError;
  Whisper get whisper => throw _privateConstructorUsedError;

  /// Serializes this CreateWhisperResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateWhisperResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateWhisperResponseCopyWith<CreateWhisperResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateWhisperResponseCopyWith<$Res> {
  factory $CreateWhisperResponseCopyWith(
    CreateWhisperResponse value,
    $Res Function(CreateWhisperResponse) then,
  ) = _$CreateWhisperResponseCopyWithImpl<$Res, CreateWhisperResponse>;
  @useResult
  $Res call({String message, Whisper whisper});

  $WhisperCopyWith<$Res> get whisper;
}

/// @nodoc
class _$CreateWhisperResponseCopyWithImpl<
  $Res,
  $Val extends CreateWhisperResponse
>
    implements $CreateWhisperResponseCopyWith<$Res> {
  _$CreateWhisperResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateWhisperResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? whisper = null}) {
    return _then(
      _value.copyWith(
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            whisper: null == whisper
                ? _value.whisper
                : whisper // ignore: cast_nullable_to_non_nullable
                      as Whisper,
          )
          as $Val,
    );
  }

  /// Create a copy of CreateWhisperResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WhisperCopyWith<$Res> get whisper {
    return $WhisperCopyWith<$Res>(_value.whisper, (value) {
      return _then(_value.copyWith(whisper: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CreateWhisperResponseImplCopyWith<$Res>
    implements $CreateWhisperResponseCopyWith<$Res> {
  factory _$$CreateWhisperResponseImplCopyWith(
    _$CreateWhisperResponseImpl value,
    $Res Function(_$CreateWhisperResponseImpl) then,
  ) = __$$CreateWhisperResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, Whisper whisper});

  @override
  $WhisperCopyWith<$Res> get whisper;
}

/// @nodoc
class __$$CreateWhisperResponseImplCopyWithImpl<$Res>
    extends
        _$CreateWhisperResponseCopyWithImpl<$Res, _$CreateWhisperResponseImpl>
    implements _$$CreateWhisperResponseImplCopyWith<$Res> {
  __$$CreateWhisperResponseImplCopyWithImpl(
    _$CreateWhisperResponseImpl _value,
    $Res Function(_$CreateWhisperResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateWhisperResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? whisper = null}) {
    return _then(
      _$CreateWhisperResponseImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        whisper: null == whisper
            ? _value.whisper
            : whisper // ignore: cast_nullable_to_non_nullable
                  as Whisper,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateWhisperResponseImpl implements _CreateWhisperResponse {
  const _$CreateWhisperResponseImpl({
    required this.message,
    required this.whisper,
  });

  factory _$CreateWhisperResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateWhisperResponseImplFromJson(json);

  @override
  final String message;
  @override
  final Whisper whisper;

  @override
  String toString() {
    return 'CreateWhisperResponse(message: $message, whisper: $whisper)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateWhisperResponseImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.whisper, whisper) || other.whisper == whisper));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message, whisper);

  /// Create a copy of CreateWhisperResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateWhisperResponseImplCopyWith<_$CreateWhisperResponseImpl>
  get copyWith =>
      __$$CreateWhisperResponseImplCopyWithImpl<_$CreateWhisperResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateWhisperResponseImplToJson(this);
  }
}

abstract class _CreateWhisperResponse implements CreateWhisperResponse {
  const factory _CreateWhisperResponse({
    required final String message,
    required final Whisper whisper,
  }) = _$CreateWhisperResponseImpl;

  factory _CreateWhisperResponse.fromJson(Map<String, dynamic> json) =
      _$CreateWhisperResponseImpl.fromJson;

  @override
  String get message;
  @override
  Whisper get whisper;

  /// Create a copy of CreateWhisperResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateWhisperResponseImplCopyWith<_$CreateWhisperResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
