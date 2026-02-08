// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tutorial_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TutorialState {
  /// ホーム画面チュートリアルが完了済みか
  bool get homeCompleted => throw _privateConstructorUsedError;

  /// 録音画面チュートリアルが完了済みか
  bool get recordingCompleted => throw _privateConstructorUsedError;

  /// 現在チュートリアルを表示中か
  bool get isShowingTutorial => throw _privateConstructorUsedError;

  /// 初期化が完了したか
  bool get isInitialized => throw _privateConstructorUsedError;

  /// Create a copy of TutorialState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorialStateCopyWith<TutorialState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorialStateCopyWith<$Res> {
  factory $TutorialStateCopyWith(
    TutorialState value,
    $Res Function(TutorialState) then,
  ) = _$TutorialStateCopyWithImpl<$Res, TutorialState>;
  @useResult
  $Res call({
    bool homeCompleted,
    bool recordingCompleted,
    bool isShowingTutorial,
    bool isInitialized,
  });
}

/// @nodoc
class _$TutorialStateCopyWithImpl<$Res, $Val extends TutorialState>
    implements $TutorialStateCopyWith<$Res> {
  _$TutorialStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorialState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? homeCompleted = null,
    Object? recordingCompleted = null,
    Object? isShowingTutorial = null,
    Object? isInitialized = null,
  }) {
    return _then(
      _value.copyWith(
            homeCompleted: null == homeCompleted
                ? _value.homeCompleted
                : homeCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            recordingCompleted: null == recordingCompleted
                ? _value.recordingCompleted
                : recordingCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            isShowingTutorial: null == isShowingTutorial
                ? _value.isShowingTutorial
                : isShowingTutorial // ignore: cast_nullable_to_non_nullable
                      as bool,
            isInitialized: null == isInitialized
                ? _value.isInitialized
                : isInitialized // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TutorialStateImplCopyWith<$Res>
    implements $TutorialStateCopyWith<$Res> {
  factory _$$TutorialStateImplCopyWith(
    _$TutorialStateImpl value,
    $Res Function(_$TutorialStateImpl) then,
  ) = __$$TutorialStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool homeCompleted,
    bool recordingCompleted,
    bool isShowingTutorial,
    bool isInitialized,
  });
}

/// @nodoc
class __$$TutorialStateImplCopyWithImpl<$Res>
    extends _$TutorialStateCopyWithImpl<$Res, _$TutorialStateImpl>
    implements _$$TutorialStateImplCopyWith<$Res> {
  __$$TutorialStateImplCopyWithImpl(
    _$TutorialStateImpl _value,
    $Res Function(_$TutorialStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TutorialState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? homeCompleted = null,
    Object? recordingCompleted = null,
    Object? isShowingTutorial = null,
    Object? isInitialized = null,
  }) {
    return _then(
      _$TutorialStateImpl(
        homeCompleted: null == homeCompleted
            ? _value.homeCompleted
            : homeCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        recordingCompleted: null == recordingCompleted
            ? _value.recordingCompleted
            : recordingCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        isShowingTutorial: null == isShowingTutorial
            ? _value.isShowingTutorial
            : isShowingTutorial // ignore: cast_nullable_to_non_nullable
                  as bool,
        isInitialized: null == isInitialized
            ? _value.isInitialized
            : isInitialized // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$TutorialStateImpl implements _TutorialState {
  const _$TutorialStateImpl({
    this.homeCompleted = false,
    this.recordingCompleted = false,
    this.isShowingTutorial = false,
    this.isInitialized = false,
  });

  /// ホーム画面チュートリアルが完了済みか
  @override
  @JsonKey()
  final bool homeCompleted;

  /// 録音画面チュートリアルが完了済みか
  @override
  @JsonKey()
  final bool recordingCompleted;

  /// 現在チュートリアルを表示中か
  @override
  @JsonKey()
  final bool isShowingTutorial;

  /// 初期化が完了したか
  @override
  @JsonKey()
  final bool isInitialized;

  @override
  String toString() {
    return 'TutorialState(homeCompleted: $homeCompleted, recordingCompleted: $recordingCompleted, isShowingTutorial: $isShowingTutorial, isInitialized: $isInitialized)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorialStateImpl &&
            (identical(other.homeCompleted, homeCompleted) ||
                other.homeCompleted == homeCompleted) &&
            (identical(other.recordingCompleted, recordingCompleted) ||
                other.recordingCompleted == recordingCompleted) &&
            (identical(other.isShowingTutorial, isShowingTutorial) ||
                other.isShowingTutorial == isShowingTutorial) &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    homeCompleted,
    recordingCompleted,
    isShowingTutorial,
    isInitialized,
  );

  /// Create a copy of TutorialState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorialStateImplCopyWith<_$TutorialStateImpl> get copyWith =>
      __$$TutorialStateImplCopyWithImpl<_$TutorialStateImpl>(this, _$identity);
}

abstract class _TutorialState implements TutorialState {
  const factory _TutorialState({
    final bool homeCompleted,
    final bool recordingCompleted,
    final bool isShowingTutorial,
    final bool isInitialized,
  }) = _$TutorialStateImpl;

  /// ホーム画面チュートリアルが完了済みか
  @override
  bool get homeCompleted;

  /// 録音画面チュートリアルが完了済みか
  @override
  bool get recordingCompleted;

  /// 現在チュートリアルを表示中か
  @override
  bool get isShowingTutorial;

  /// 初期化が完了したか
  @override
  bool get isInitialized;

  /// Create a copy of TutorialState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorialStateImplCopyWith<_$TutorialStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
