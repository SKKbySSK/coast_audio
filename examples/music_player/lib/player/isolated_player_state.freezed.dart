// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'isolated_player_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$IsolatedPlayerState {
  AudioFormat get format => throw _privateConstructorUsedError;
  String? get filePath => throw _privateConstructorUsedError;
  double get volume => throw _privateConstructorUsedError;
  AudioTime get duration => throw _privateConstructorUsedError;
  AudioTime get position => throw _privateConstructorUsedError;
  bool get isReady => throw _privateConstructorUsedError;
  bool get isPlaying => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $IsolatedPlayerStateCopyWith<IsolatedPlayerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IsolatedPlayerStateCopyWith<$Res> {
  factory $IsolatedPlayerStateCopyWith(
          IsolatedPlayerState value, $Res Function(IsolatedPlayerState) then) =
      _$IsolatedPlayerStateCopyWithImpl<$Res, IsolatedPlayerState>;
  @useResult
  $Res call(
      {AudioFormat format,
      String? filePath,
      double volume,
      AudioTime duration,
      AudioTime position,
      bool isReady,
      bool isPlaying});
}

/// @nodoc
class _$IsolatedPlayerStateCopyWithImpl<$Res, $Val extends IsolatedPlayerState>
    implements $IsolatedPlayerStateCopyWith<$Res> {
  _$IsolatedPlayerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? format = null,
    Object? filePath = freezed,
    Object? volume = null,
    Object? duration = null,
    Object? position = null,
    Object? isReady = null,
    Object? isPlaying = null,
  }) {
    return _then(_value.copyWith(
      format: null == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as AudioFormat,
      filePath: freezed == filePath
          ? _value.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String?,
      volume: null == volume
          ? _value.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as double,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as AudioTime,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as AudioTime,
      isReady: null == isReady
          ? _value.isReady
          : isReady // ignore: cast_nullable_to_non_nullable
              as bool,
      isPlaying: null == isPlaying
          ? _value.isPlaying
          : isPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_IsolatedPlayerStateCopyWith<$Res>
    implements $IsolatedPlayerStateCopyWith<$Res> {
  factory _$$_IsolatedPlayerStateCopyWith(_$_IsolatedPlayerState value,
          $Res Function(_$_IsolatedPlayerState) then) =
      __$$_IsolatedPlayerStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {AudioFormat format,
      String? filePath,
      double volume,
      AudioTime duration,
      AudioTime position,
      bool isReady,
      bool isPlaying});
}

/// @nodoc
class __$$_IsolatedPlayerStateCopyWithImpl<$Res>
    extends _$IsolatedPlayerStateCopyWithImpl<$Res, _$_IsolatedPlayerState>
    implements _$$_IsolatedPlayerStateCopyWith<$Res> {
  __$$_IsolatedPlayerStateCopyWithImpl(_$_IsolatedPlayerState _value,
      $Res Function(_$_IsolatedPlayerState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? format = null,
    Object? filePath = freezed,
    Object? volume = null,
    Object? duration = null,
    Object? position = null,
    Object? isReady = null,
    Object? isPlaying = null,
  }) {
    return _then(_$_IsolatedPlayerState(
      format: null == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as AudioFormat,
      filePath: freezed == filePath
          ? _value.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String?,
      volume: null == volume
          ? _value.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as double,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as AudioTime,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as AudioTime,
      isReady: null == isReady
          ? _value.isReady
          : isReady // ignore: cast_nullable_to_non_nullable
              as bool,
      isPlaying: null == isPlaying
          ? _value.isPlaying
          : isPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$_IsolatedPlayerState
    with DiagnosticableTreeMixin
    implements _IsolatedPlayerState {
  const _$_IsolatedPlayerState(
      {required this.format,
      required this.filePath,
      required this.volume,
      required this.duration,
      required this.position,
      required this.isReady,
      required this.isPlaying});

  @override
  final AudioFormat format;
  @override
  final String? filePath;
  @override
  final double volume;
  @override
  final AudioTime duration;
  @override
  final AudioTime position;
  @override
  final bool isReady;
  @override
  final bool isPlaying;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'IsolatedPlayerState(format: $format, filePath: $filePath, volume: $volume, duration: $duration, position: $position, isReady: $isReady, isPlaying: $isPlaying)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'IsolatedPlayerState'))
      ..add(DiagnosticsProperty('format', format))
      ..add(DiagnosticsProperty('filePath', filePath))
      ..add(DiagnosticsProperty('volume', volume))
      ..add(DiagnosticsProperty('duration', duration))
      ..add(DiagnosticsProperty('position', position))
      ..add(DiagnosticsProperty('isReady', isReady))
      ..add(DiagnosticsProperty('isPlaying', isPlaying));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_IsolatedPlayerState &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.volume, volume) || other.volume == volume) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.isReady, isReady) || other.isReady == isReady) &&
            (identical(other.isPlaying, isPlaying) ||
                other.isPlaying == isPlaying));
  }

  @override
  int get hashCode => Object.hash(runtimeType, format, filePath, volume,
      duration, position, isReady, isPlaying);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_IsolatedPlayerStateCopyWith<_$_IsolatedPlayerState> get copyWith =>
      __$$_IsolatedPlayerStateCopyWithImpl<_$_IsolatedPlayerState>(
          this, _$identity);
}

abstract class _IsolatedPlayerState implements IsolatedPlayerState {
  const factory _IsolatedPlayerState(
      {required final AudioFormat format,
      required final String? filePath,
      required final double volume,
      required final AudioTime duration,
      required final AudioTime position,
      required final bool isReady,
      required final bool isPlaying}) = _$_IsolatedPlayerState;

  @override
  AudioFormat get format;
  @override
  String? get filePath;
  @override
  double get volume;
  @override
  AudioTime get duration;
  @override
  AudioTime get position;
  @override
  bool get isReady;
  @override
  bool get isPlaying;
  @override
  @JsonKey(ignore: true)
  _$$_IsolatedPlayerStateCopyWith<_$_IsolatedPlayerState> get copyWith =>
      throw _privateConstructorUsedError;
}
