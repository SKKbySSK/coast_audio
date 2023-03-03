// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'isolated_player_command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$IsolatedPlayerCommand {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String filePath) open,
    required TResult Function() play,
    required TResult Function() pause,
    required TResult Function() stop,
    required TResult Function(double volume) setVolume,
    required TResult Function(AudioTime position) setPosition,
    required TResult Function(DeviceInfo<dynamic>? deviceInfo) setDevice,
    required TResult Function() dispose,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String filePath)? open,
    TResult? Function()? play,
    TResult? Function()? pause,
    TResult? Function()? stop,
    TResult? Function(double volume)? setVolume,
    TResult? Function(AudioTime position)? setPosition,
    TResult? Function(DeviceInfo<dynamic>? deviceInfo)? setDevice,
    TResult? Function()? dispose,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String filePath)? open,
    TResult Function()? play,
    TResult Function()? pause,
    TResult Function()? stop,
    TResult Function(double volume)? setVolume,
    TResult Function(AudioTime position)? setPosition,
    TResult Function(DeviceInfo<dynamic>? deviceInfo)? setDevice,
    TResult Function()? dispose,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_IsolatedPlayerCommandOpen value) open,
    required TResult Function(_IsolatedPlayerCommandPlay value) play,
    required TResult Function(_IsolatedPlayerCommandPause value) pause,
    required TResult Function(_IsolatedPlayerCommandStop value) stop,
    required TResult Function(_IsolatedPlayerCommandSetVolume value) setVolume,
    required TResult Function(_IsolatedPlayerCommandSetPosition value)
        setPosition,
    required TResult Function(_IsolatedPlayerCommandSetDevice value) setDevice,
    required TResult Function(_IsolatedPlayerCommandDispose value) dispose,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_IsolatedPlayerCommandOpen value)? open,
    TResult? Function(_IsolatedPlayerCommandPlay value)? play,
    TResult? Function(_IsolatedPlayerCommandPause value)? pause,
    TResult? Function(_IsolatedPlayerCommandStop value)? stop,
    TResult? Function(_IsolatedPlayerCommandSetVolume value)? setVolume,
    TResult? Function(_IsolatedPlayerCommandSetPosition value)? setPosition,
    TResult? Function(_IsolatedPlayerCommandSetDevice value)? setDevice,
    TResult? Function(_IsolatedPlayerCommandDispose value)? dispose,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_IsolatedPlayerCommandOpen value)? open,
    TResult Function(_IsolatedPlayerCommandPlay value)? play,
    TResult Function(_IsolatedPlayerCommandPause value)? pause,
    TResult Function(_IsolatedPlayerCommandStop value)? stop,
    TResult Function(_IsolatedPlayerCommandSetVolume value)? setVolume,
    TResult Function(_IsolatedPlayerCommandSetPosition value)? setPosition,
    TResult Function(_IsolatedPlayerCommandSetDevice value)? setDevice,
    TResult Function(_IsolatedPlayerCommandDispose value)? dispose,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IsolatedPlayerCommandCopyWith<$Res> {
  factory $IsolatedPlayerCommandCopyWith(IsolatedPlayerCommand value,
          $Res Function(IsolatedPlayerCommand) then) =
      _$IsolatedPlayerCommandCopyWithImpl<$Res, IsolatedPlayerCommand>;
}

/// @nodoc
class _$IsolatedPlayerCommandCopyWithImpl<$Res,
        $Val extends IsolatedPlayerCommand>
    implements $IsolatedPlayerCommandCopyWith<$Res> {
  _$IsolatedPlayerCommandCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$_IsolatedPlayerCommandOpenCopyWith<$Res> {
  factory _$$_IsolatedPlayerCommandOpenCopyWith(
          _$_IsolatedPlayerCommandOpen value,
          $Res Function(_$_IsolatedPlayerCommandOpen) then) =
      __$$_IsolatedPlayerCommandOpenCopyWithImpl<$Res>;
  @useResult
  $Res call({String filePath});
}

/// @nodoc
class __$$_IsolatedPlayerCommandOpenCopyWithImpl<$Res>
    extends _$IsolatedPlayerCommandCopyWithImpl<$Res,
        _$_IsolatedPlayerCommandOpen>
    implements _$$_IsolatedPlayerCommandOpenCopyWith<$Res> {
  __$$_IsolatedPlayerCommandOpenCopyWithImpl(
      _$_IsolatedPlayerCommandOpen _value,
      $Res Function(_$_IsolatedPlayerCommandOpen) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filePath = null,
  }) {
    return _then(_$_IsolatedPlayerCommandOpen(
      filePath: null == filePath
          ? _value.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_IsolatedPlayerCommandOpen implements _IsolatedPlayerCommandOpen {
  const _$_IsolatedPlayerCommandOpen({required this.filePath});

  @override
  final String filePath;

  @override
  String toString() {
    return 'IsolatedPlayerCommand.open(filePath: $filePath)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_IsolatedPlayerCommandOpen &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath));
  }

  @override
  int get hashCode => Object.hash(runtimeType, filePath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_IsolatedPlayerCommandOpenCopyWith<_$_IsolatedPlayerCommandOpen>
      get copyWith => __$$_IsolatedPlayerCommandOpenCopyWithImpl<
          _$_IsolatedPlayerCommandOpen>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String filePath) open,
    required TResult Function() play,
    required TResult Function() pause,
    required TResult Function() stop,
    required TResult Function(double volume) setVolume,
    required TResult Function(AudioTime position) setPosition,
    required TResult Function(DeviceInfo<dynamic>? deviceInfo) setDevice,
    required TResult Function() dispose,
  }) {
    return open(filePath);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String filePath)? open,
    TResult? Function()? play,
    TResult? Function()? pause,
    TResult? Function()? stop,
    TResult? Function(double volume)? setVolume,
    TResult? Function(AudioTime position)? setPosition,
    TResult? Function(DeviceInfo<dynamic>? deviceInfo)? setDevice,
    TResult? Function()? dispose,
  }) {
    return open?.call(filePath);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String filePath)? open,
    TResult Function()? play,
    TResult Function()? pause,
    TResult Function()? stop,
    TResult Function(double volume)? setVolume,
    TResult Function(AudioTime position)? setPosition,
    TResult Function(DeviceInfo<dynamic>? deviceInfo)? setDevice,
    TResult Function()? dispose,
    required TResult orElse(),
  }) {
    if (open != null) {
      return open(filePath);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_IsolatedPlayerCommandOpen value) open,
    required TResult Function(_IsolatedPlayerCommandPlay value) play,
    required TResult Function(_IsolatedPlayerCommandPause value) pause,
    required TResult Function(_IsolatedPlayerCommandStop value) stop,
    required TResult Function(_IsolatedPlayerCommandSetVolume value) setVolume,
    required TResult Function(_IsolatedPlayerCommandSetPosition value)
        setPosition,
    required TResult Function(_IsolatedPlayerCommandSetDevice value) setDevice,
    required TResult Function(_IsolatedPlayerCommandDispose value) dispose,
  }) {
    return open(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_IsolatedPlayerCommandOpen value)? open,
    TResult? Function(_IsolatedPlayerCommandPlay value)? play,
    TResult? Function(_IsolatedPlayerCommandPause value)? pause,
    TResult? Function(_IsolatedPlayerCommandStop value)? stop,
    TResult? Function(_IsolatedPlayerCommandSetVolume value)? setVolume,
    TResult? Function(_IsolatedPlayerCommandSetPosition value)? setPosition,
    TResult? Function(_IsolatedPlayerCommandSetDevice value)? setDevice,
    TResult? Function(_IsolatedPlayerCommandDispose value)? dispose,
  }) {
    return open?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_IsolatedPlayerCommandOpen value)? open,
    TResult Function(_IsolatedPlayerCommandPlay value)? play,
    TResult Function(_IsolatedPlayerCommandPause value)? pause,
    TResult Function(_IsolatedPlayerCommandStop value)? stop,
    TResult Function(_IsolatedPlayerCommandSetVolume value)? setVolume,
    TResult Function(_IsolatedPlayerCommandSetPosition value)? setPosition,
    TResult Function(_IsolatedPlayerCommandSetDevice value)? setDevice,
    TResult Function(_IsolatedPlayerCommandDispose value)? dispose,
    required TResult orElse(),
  }) {
    if (open != null) {
      return open(this);
    }
    return orElse();
  }
}

abstract class _IsolatedPlayerCommandOpen implements IsolatedPlayerCommand {
  const factory _IsolatedPlayerCommandOpen({required final String filePath}) =
      _$_IsolatedPlayerCommandOpen;

  String get filePath;
  @JsonKey(ignore: true)
  _$$_IsolatedPlayerCommandOpenCopyWith<_$_IsolatedPlayerCommandOpen>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$_IsolatedPlayerCommandPlayCopyWith<$Res> {
  factory _$$_IsolatedPlayerCommandPlayCopyWith(
          _$_IsolatedPlayerCommandPlay value,
          $Res Function(_$_IsolatedPlayerCommandPlay) then) =
      __$$_IsolatedPlayerCommandPlayCopyWithImpl<$Res>;
}

/// @nodoc
class __$$_IsolatedPlayerCommandPlayCopyWithImpl<$Res>
    extends _$IsolatedPlayerCommandCopyWithImpl<$Res,
        _$_IsolatedPlayerCommandPlay>
    implements _$$_IsolatedPlayerCommandPlayCopyWith<$Res> {
  __$$_IsolatedPlayerCommandPlayCopyWithImpl(
      _$_IsolatedPlayerCommandPlay _value,
      $Res Function(_$_IsolatedPlayerCommandPlay) _then)
      : super(_value, _then);
}

/// @nodoc

class _$_IsolatedPlayerCommandPlay implements _IsolatedPlayerCommandPlay {
  const _$_IsolatedPlayerCommandPlay();

  @override
  String toString() {
    return 'IsolatedPlayerCommand.play()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_IsolatedPlayerCommandPlay);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String filePath) open,
    required TResult Function() play,
    required TResult Function() pause,
    required TResult Function() stop,
    required TResult Function(double volume) setVolume,
    required TResult Function(AudioTime position) setPosition,
    required TResult Function(DeviceInfo<dynamic>? deviceInfo) setDevice,
    required TResult Function() dispose,
  }) {
    return play();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String filePath)? open,
    TResult? Function()? play,
    TResult? Function()? pause,
    TResult? Function()? stop,
    TResult? Function(double volume)? setVolume,
    TResult? Function(AudioTime position)? setPosition,
    TResult? Function(DeviceInfo<dynamic>? deviceInfo)? setDevice,
    TResult? Function()? dispose,
  }) {
    return play?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String filePath)? open,
    TResult Function()? play,
    TResult Function()? pause,
    TResult Function()? stop,
    TResult Function(double volume)? setVolume,
    TResult Function(AudioTime position)? setPosition,
    TResult Function(DeviceInfo<dynamic>? deviceInfo)? setDevice,
    TResult Function()? dispose,
    required TResult orElse(),
  }) {
    if (play != null) {
      return play();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_IsolatedPlayerCommandOpen value) open,
    required TResult Function(_IsolatedPlayerCommandPlay value) play,
    required TResult Function(_IsolatedPlayerCommandPause value) pause,
    required TResult Function(_IsolatedPlayerCommandStop value) stop,
    required TResult Function(_IsolatedPlayerCommandSetVolume value) setVolume,
    required TResult Function(_IsolatedPlayerCommandSetPosition value)
        setPosition,
    required TResult Function(_IsolatedPlayerCommandSetDevice value) setDevice,
    required TResult Function(_IsolatedPlayerCommandDispose value) dispose,
  }) {
    return play(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_IsolatedPlayerCommandOpen value)? open,
    TResult? Function(_IsolatedPlayerCommandPlay value)? play,
    TResult? Function(_IsolatedPlayerCommandPause value)? pause,
    TResult? Function(_IsolatedPlayerCommandStop value)? stop,
    TResult? Function(_IsolatedPlayerCommandSetVolume value)? setVolume,
    TResult? Function(_IsolatedPlayerCommandSetPosition value)? setPosition,
    TResult? Function(_IsolatedPlayerCommandSetDevice value)? setDevice,
    TResult? Function(_IsolatedPlayerCommandDispose value)? dispose,
  }) {
    return play?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_IsolatedPlayerCommandOpen value)? open,
    TResult Function(_IsolatedPlayerCommandPlay value)? play,
    TResult Function(_IsolatedPlayerCommandPause value)? pause,
    TResult Function(_IsolatedPlayerCommandStop value)? stop,
    TResult Function(_IsolatedPlayerCommandSetVolume value)? setVolume,
    TResult Function(_IsolatedPlayerCommandSetPosition value)? setPosition,
    TResult Function(_IsolatedPlayerCommandSetDevice value)? setDevice,
    TResult Function(_IsolatedPlayerCommandDispose value)? dispose,
    required TResult orElse(),
  }) {
    if (play != null) {
      return play(this);
    }
    return orElse();
  }
}

abstract class _IsolatedPlayerCommandPlay implements IsolatedPlayerCommand {
  const factory _IsolatedPlayerCommandPlay() = _$_IsolatedPlayerCommandPlay;
}

/// @nodoc
abstract class _$$_IsolatedPlayerCommandPauseCopyWith<$Res> {
  factory _$$_IsolatedPlayerCommandPauseCopyWith(
          _$_IsolatedPlayerCommandPause value,
          $Res Function(_$_IsolatedPlayerCommandPause) then) =
      __$$_IsolatedPlayerCommandPauseCopyWithImpl<$Res>;
}

/// @nodoc
class __$$_IsolatedPlayerCommandPauseCopyWithImpl<$Res>
    extends _$IsolatedPlayerCommandCopyWithImpl<$Res,
        _$_IsolatedPlayerCommandPause>
    implements _$$_IsolatedPlayerCommandPauseCopyWith<$Res> {
  __$$_IsolatedPlayerCommandPauseCopyWithImpl(
      _$_IsolatedPlayerCommandPause _value,
      $Res Function(_$_IsolatedPlayerCommandPause) _then)
      : super(_value, _then);
}

/// @nodoc

class _$_IsolatedPlayerCommandPause implements _IsolatedPlayerCommandPause {
  const _$_IsolatedPlayerCommandPause();

  @override
  String toString() {
    return 'IsolatedPlayerCommand.pause()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_IsolatedPlayerCommandPause);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String filePath) open,
    required TResult Function() play,
    required TResult Function() pause,
    required TResult Function() stop,
    required TResult Function(double volume) setVolume,
    required TResult Function(AudioTime position) setPosition,
    required TResult Function(DeviceInfo<dynamic>? deviceInfo) setDevice,
    required TResult Function() dispose,
  }) {
    return pause();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String filePath)? open,
    TResult? Function()? play,
    TResult? Function()? pause,
    TResult? Function()? stop,
    TResult? Function(double volume)? setVolume,
    TResult? Function(AudioTime position)? setPosition,
    TResult? Function(DeviceInfo<dynamic>? deviceInfo)? setDevice,
    TResult? Function()? dispose,
  }) {
    return pause?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String filePath)? open,
    TResult Function()? play,
    TResult Function()? pause,
    TResult Function()? stop,
    TResult Function(double volume)? setVolume,
    TResult Function(AudioTime position)? setPosition,
    TResult Function(DeviceInfo<dynamic>? deviceInfo)? setDevice,
    TResult Function()? dispose,
    required TResult orElse(),
  }) {
    if (pause != null) {
      return pause();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_IsolatedPlayerCommandOpen value) open,
    required TResult Function(_IsolatedPlayerCommandPlay value) play,
    required TResult Function(_IsolatedPlayerCommandPause value) pause,
    required TResult Function(_IsolatedPlayerCommandStop value) stop,
    required TResult Function(_IsolatedPlayerCommandSetVolume value) setVolume,
    required TResult Function(_IsolatedPlayerCommandSetPosition value)
        setPosition,
    required TResult Function(_IsolatedPlayerCommandSetDevice value) setDevice,
    required TResult Function(_IsolatedPlayerCommandDispose value) dispose,
  }) {
    return pause(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_IsolatedPlayerCommandOpen value)? open,
    TResult? Function(_IsolatedPlayerCommandPlay value)? play,
    TResult? Function(_IsolatedPlayerCommandPause value)? pause,
    TResult? Function(_IsolatedPlayerCommandStop value)? stop,
    TResult? Function(_IsolatedPlayerCommandSetVolume value)? setVolume,
    TResult? Function(_IsolatedPlayerCommandSetPosition value)? setPosition,
    TResult? Function(_IsolatedPlayerCommandSetDevice value)? setDevice,
    TResult? Function(_IsolatedPlayerCommandDispose value)? dispose,
  }) {
    return pause?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_IsolatedPlayerCommandOpen value)? open,
    TResult Function(_IsolatedPlayerCommandPlay value)? play,
    TResult Function(_IsolatedPlayerCommandPause value)? pause,
    TResult Function(_IsolatedPlayerCommandStop value)? stop,
    TResult Function(_IsolatedPlayerCommandSetVolume value)? setVolume,
    TResult Function(_IsolatedPlayerCommandSetPosition value)? setPosition,
    TResult Function(_IsolatedPlayerCommandSetDevice value)? setDevice,
    TResult Function(_IsolatedPlayerCommandDispose value)? dispose,
    required TResult orElse(),
  }) {
    if (pause != null) {
      return pause(this);
    }
    return orElse();
  }
}

abstract class _IsolatedPlayerCommandPause implements IsolatedPlayerCommand {
  const factory _IsolatedPlayerCommandPause() = _$_IsolatedPlayerCommandPause;
}

/// @nodoc
abstract class _$$_IsolatedPlayerCommandStopCopyWith<$Res> {
  factory _$$_IsolatedPlayerCommandStopCopyWith(
          _$_IsolatedPlayerCommandStop value,
          $Res Function(_$_IsolatedPlayerCommandStop) then) =
      __$$_IsolatedPlayerCommandStopCopyWithImpl<$Res>;
}

/// @nodoc
class __$$_IsolatedPlayerCommandStopCopyWithImpl<$Res>
    extends _$IsolatedPlayerCommandCopyWithImpl<$Res,
        _$_IsolatedPlayerCommandStop>
    implements _$$_IsolatedPlayerCommandStopCopyWith<$Res> {
  __$$_IsolatedPlayerCommandStopCopyWithImpl(
      _$_IsolatedPlayerCommandStop _value,
      $Res Function(_$_IsolatedPlayerCommandStop) _then)
      : super(_value, _then);
}

/// @nodoc

class _$_IsolatedPlayerCommandStop implements _IsolatedPlayerCommandStop {
  const _$_IsolatedPlayerCommandStop();

  @override
  String toString() {
    return 'IsolatedPlayerCommand.stop()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_IsolatedPlayerCommandStop);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String filePath) open,
    required TResult Function() play,
    required TResult Function() pause,
    required TResult Function() stop,
    required TResult Function(double volume) setVolume,
    required TResult Function(AudioTime position) setPosition,
    required TResult Function(DeviceInfo<dynamic>? deviceInfo) setDevice,
    required TResult Function() dispose,
  }) {
    return stop();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String filePath)? open,
    TResult? Function()? play,
    TResult? Function()? pause,
    TResult? Function()? stop,
    TResult? Function(double volume)? setVolume,
    TResult? Function(AudioTime position)? setPosition,
    TResult? Function(DeviceInfo<dynamic>? deviceInfo)? setDevice,
    TResult? Function()? dispose,
  }) {
    return stop?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String filePath)? open,
    TResult Function()? play,
    TResult Function()? pause,
    TResult Function()? stop,
    TResult Function(double volume)? setVolume,
    TResult Function(AudioTime position)? setPosition,
    TResult Function(DeviceInfo<dynamic>? deviceInfo)? setDevice,
    TResult Function()? dispose,
    required TResult orElse(),
  }) {
    if (stop != null) {
      return stop();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_IsolatedPlayerCommandOpen value) open,
    required TResult Function(_IsolatedPlayerCommandPlay value) play,
    required TResult Function(_IsolatedPlayerCommandPause value) pause,
    required TResult Function(_IsolatedPlayerCommandStop value) stop,
    required TResult Function(_IsolatedPlayerCommandSetVolume value) setVolume,
    required TResult Function(_IsolatedPlayerCommandSetPosition value)
        setPosition,
    required TResult Function(_IsolatedPlayerCommandSetDevice value) setDevice,
    required TResult Function(_IsolatedPlayerCommandDispose value) dispose,
  }) {
    return stop(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_IsolatedPlayerCommandOpen value)? open,
    TResult? Function(_IsolatedPlayerCommandPlay value)? play,
    TResult? Function(_IsolatedPlayerCommandPause value)? pause,
    TResult? Function(_IsolatedPlayerCommandStop value)? stop,
    TResult? Function(_IsolatedPlayerCommandSetVolume value)? setVolume,
    TResult? Function(_IsolatedPlayerCommandSetPosition value)? setPosition,
    TResult? Function(_IsolatedPlayerCommandSetDevice value)? setDevice,
    TResult? Function(_IsolatedPlayerCommandDispose value)? dispose,
  }) {
    return stop?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_IsolatedPlayerCommandOpen value)? open,
    TResult Function(_IsolatedPlayerCommandPlay value)? play,
    TResult Function(_IsolatedPlayerCommandPause value)? pause,
    TResult Function(_IsolatedPlayerCommandStop value)? stop,
    TResult Function(_IsolatedPlayerCommandSetVolume value)? setVolume,
    TResult Function(_IsolatedPlayerCommandSetPosition value)? setPosition,
    TResult Function(_IsolatedPlayerCommandSetDevice value)? setDevice,
    TResult Function(_IsolatedPlayerCommandDispose value)? dispose,
    required TResult orElse(),
  }) {
    if (stop != null) {
      return stop(this);
    }
    return orElse();
  }
}

abstract class _IsolatedPlayerCommandStop implements IsolatedPlayerCommand {
  const factory _IsolatedPlayerCommandStop() = _$_IsolatedPlayerCommandStop;
}

/// @nodoc
abstract class _$$_IsolatedPlayerCommandSetVolumeCopyWith<$Res> {
  factory _$$_IsolatedPlayerCommandSetVolumeCopyWith(
          _$_IsolatedPlayerCommandSetVolume value,
          $Res Function(_$_IsolatedPlayerCommandSetVolume) then) =
      __$$_IsolatedPlayerCommandSetVolumeCopyWithImpl<$Res>;
  @useResult
  $Res call({double volume});
}

/// @nodoc
class __$$_IsolatedPlayerCommandSetVolumeCopyWithImpl<$Res>
    extends _$IsolatedPlayerCommandCopyWithImpl<$Res,
        _$_IsolatedPlayerCommandSetVolume>
    implements _$$_IsolatedPlayerCommandSetVolumeCopyWith<$Res> {
  __$$_IsolatedPlayerCommandSetVolumeCopyWithImpl(
      _$_IsolatedPlayerCommandSetVolume _value,
      $Res Function(_$_IsolatedPlayerCommandSetVolume) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? volume = null,
  }) {
    return _then(_$_IsolatedPlayerCommandSetVolume(
      volume: null == volume
          ? _value.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$_IsolatedPlayerCommandSetVolume
    implements _IsolatedPlayerCommandSetVolume {
  const _$_IsolatedPlayerCommandSetVolume({required this.volume});

  @override
  final double volume;

  @override
  String toString() {
    return 'IsolatedPlayerCommand.setVolume(volume: $volume)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_IsolatedPlayerCommandSetVolume &&
            (identical(other.volume, volume) || other.volume == volume));
  }

  @override
  int get hashCode => Object.hash(runtimeType, volume);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_IsolatedPlayerCommandSetVolumeCopyWith<_$_IsolatedPlayerCommandSetVolume>
      get copyWith => __$$_IsolatedPlayerCommandSetVolumeCopyWithImpl<
          _$_IsolatedPlayerCommandSetVolume>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String filePath) open,
    required TResult Function() play,
    required TResult Function() pause,
    required TResult Function() stop,
    required TResult Function(double volume) setVolume,
    required TResult Function(AudioTime position) setPosition,
    required TResult Function(DeviceInfo<dynamic>? deviceInfo) setDevice,
    required TResult Function() dispose,
  }) {
    return setVolume(volume);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String filePath)? open,
    TResult? Function()? play,
    TResult? Function()? pause,
    TResult? Function()? stop,
    TResult? Function(double volume)? setVolume,
    TResult? Function(AudioTime position)? setPosition,
    TResult? Function(DeviceInfo<dynamic>? deviceInfo)? setDevice,
    TResult? Function()? dispose,
  }) {
    return setVolume?.call(volume);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String filePath)? open,
    TResult Function()? play,
    TResult Function()? pause,
    TResult Function()? stop,
    TResult Function(double volume)? setVolume,
    TResult Function(AudioTime position)? setPosition,
    TResult Function(DeviceInfo<dynamic>? deviceInfo)? setDevice,
    TResult Function()? dispose,
    required TResult orElse(),
  }) {
    if (setVolume != null) {
      return setVolume(volume);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_IsolatedPlayerCommandOpen value) open,
    required TResult Function(_IsolatedPlayerCommandPlay value) play,
    required TResult Function(_IsolatedPlayerCommandPause value) pause,
    required TResult Function(_IsolatedPlayerCommandStop value) stop,
    required TResult Function(_IsolatedPlayerCommandSetVolume value) setVolume,
    required TResult Function(_IsolatedPlayerCommandSetPosition value)
        setPosition,
    required TResult Function(_IsolatedPlayerCommandSetDevice value) setDevice,
    required TResult Function(_IsolatedPlayerCommandDispose value) dispose,
  }) {
    return setVolume(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_IsolatedPlayerCommandOpen value)? open,
    TResult? Function(_IsolatedPlayerCommandPlay value)? play,
    TResult? Function(_IsolatedPlayerCommandPause value)? pause,
    TResult? Function(_IsolatedPlayerCommandStop value)? stop,
    TResult? Function(_IsolatedPlayerCommandSetVolume value)? setVolume,
    TResult? Function(_IsolatedPlayerCommandSetPosition value)? setPosition,
    TResult? Function(_IsolatedPlayerCommandSetDevice value)? setDevice,
    TResult? Function(_IsolatedPlayerCommandDispose value)? dispose,
  }) {
    return setVolume?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_IsolatedPlayerCommandOpen value)? open,
    TResult Function(_IsolatedPlayerCommandPlay value)? play,
    TResult Function(_IsolatedPlayerCommandPause value)? pause,
    TResult Function(_IsolatedPlayerCommandStop value)? stop,
    TResult Function(_IsolatedPlayerCommandSetVolume value)? setVolume,
    TResult Function(_IsolatedPlayerCommandSetPosition value)? setPosition,
    TResult Function(_IsolatedPlayerCommandSetDevice value)? setDevice,
    TResult Function(_IsolatedPlayerCommandDispose value)? dispose,
    required TResult orElse(),
  }) {
    if (setVolume != null) {
      return setVolume(this);
    }
    return orElse();
  }
}

abstract class _IsolatedPlayerCommandSetVolume
    implements IsolatedPlayerCommand {
  const factory _IsolatedPlayerCommandSetVolume(
      {required final double volume}) = _$_IsolatedPlayerCommandSetVolume;

  double get volume;
  @JsonKey(ignore: true)
  _$$_IsolatedPlayerCommandSetVolumeCopyWith<_$_IsolatedPlayerCommandSetVolume>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$_IsolatedPlayerCommandSetPositionCopyWith<$Res> {
  factory _$$_IsolatedPlayerCommandSetPositionCopyWith(
          _$_IsolatedPlayerCommandSetPosition value,
          $Res Function(_$_IsolatedPlayerCommandSetPosition) then) =
      __$$_IsolatedPlayerCommandSetPositionCopyWithImpl<$Res>;
  @useResult
  $Res call({AudioTime position});
}

/// @nodoc
class __$$_IsolatedPlayerCommandSetPositionCopyWithImpl<$Res>
    extends _$IsolatedPlayerCommandCopyWithImpl<$Res,
        _$_IsolatedPlayerCommandSetPosition>
    implements _$$_IsolatedPlayerCommandSetPositionCopyWith<$Res> {
  __$$_IsolatedPlayerCommandSetPositionCopyWithImpl(
      _$_IsolatedPlayerCommandSetPosition _value,
      $Res Function(_$_IsolatedPlayerCommandSetPosition) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
  }) {
    return _then(_$_IsolatedPlayerCommandSetPosition(
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as AudioTime,
    ));
  }
}

/// @nodoc

class _$_IsolatedPlayerCommandSetPosition
    implements _IsolatedPlayerCommandSetPosition {
  const _$_IsolatedPlayerCommandSetPosition({required this.position});

  @override
  final AudioTime position;

  @override
  String toString() {
    return 'IsolatedPlayerCommand.setPosition(position: $position)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_IsolatedPlayerCommandSetPosition &&
            (identical(other.position, position) ||
                other.position == position));
  }

  @override
  int get hashCode => Object.hash(runtimeType, position);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_IsolatedPlayerCommandSetPositionCopyWith<
          _$_IsolatedPlayerCommandSetPosition>
      get copyWith => __$$_IsolatedPlayerCommandSetPositionCopyWithImpl<
          _$_IsolatedPlayerCommandSetPosition>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String filePath) open,
    required TResult Function() play,
    required TResult Function() pause,
    required TResult Function() stop,
    required TResult Function(double volume) setVolume,
    required TResult Function(AudioTime position) setPosition,
    required TResult Function(DeviceInfo<dynamic>? deviceInfo) setDevice,
    required TResult Function() dispose,
  }) {
    return setPosition(position);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String filePath)? open,
    TResult? Function()? play,
    TResult? Function()? pause,
    TResult? Function()? stop,
    TResult? Function(double volume)? setVolume,
    TResult? Function(AudioTime position)? setPosition,
    TResult? Function(DeviceInfo<dynamic>? deviceInfo)? setDevice,
    TResult? Function()? dispose,
  }) {
    return setPosition?.call(position);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String filePath)? open,
    TResult Function()? play,
    TResult Function()? pause,
    TResult Function()? stop,
    TResult Function(double volume)? setVolume,
    TResult Function(AudioTime position)? setPosition,
    TResult Function(DeviceInfo<dynamic>? deviceInfo)? setDevice,
    TResult Function()? dispose,
    required TResult orElse(),
  }) {
    if (setPosition != null) {
      return setPosition(position);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_IsolatedPlayerCommandOpen value) open,
    required TResult Function(_IsolatedPlayerCommandPlay value) play,
    required TResult Function(_IsolatedPlayerCommandPause value) pause,
    required TResult Function(_IsolatedPlayerCommandStop value) stop,
    required TResult Function(_IsolatedPlayerCommandSetVolume value) setVolume,
    required TResult Function(_IsolatedPlayerCommandSetPosition value)
        setPosition,
    required TResult Function(_IsolatedPlayerCommandSetDevice value) setDevice,
    required TResult Function(_IsolatedPlayerCommandDispose value) dispose,
  }) {
    return setPosition(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_IsolatedPlayerCommandOpen value)? open,
    TResult? Function(_IsolatedPlayerCommandPlay value)? play,
    TResult? Function(_IsolatedPlayerCommandPause value)? pause,
    TResult? Function(_IsolatedPlayerCommandStop value)? stop,
    TResult? Function(_IsolatedPlayerCommandSetVolume value)? setVolume,
    TResult? Function(_IsolatedPlayerCommandSetPosition value)? setPosition,
    TResult? Function(_IsolatedPlayerCommandSetDevice value)? setDevice,
    TResult? Function(_IsolatedPlayerCommandDispose value)? dispose,
  }) {
    return setPosition?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_IsolatedPlayerCommandOpen value)? open,
    TResult Function(_IsolatedPlayerCommandPlay value)? play,
    TResult Function(_IsolatedPlayerCommandPause value)? pause,
    TResult Function(_IsolatedPlayerCommandStop value)? stop,
    TResult Function(_IsolatedPlayerCommandSetVolume value)? setVolume,
    TResult Function(_IsolatedPlayerCommandSetPosition value)? setPosition,
    TResult Function(_IsolatedPlayerCommandSetDevice value)? setDevice,
    TResult Function(_IsolatedPlayerCommandDispose value)? dispose,
    required TResult orElse(),
  }) {
    if (setPosition != null) {
      return setPosition(this);
    }
    return orElse();
  }
}

abstract class _IsolatedPlayerCommandSetPosition
    implements IsolatedPlayerCommand {
  const factory _IsolatedPlayerCommandSetPosition(
          {required final AudioTime position}) =
      _$_IsolatedPlayerCommandSetPosition;

  AudioTime get position;
  @JsonKey(ignore: true)
  _$$_IsolatedPlayerCommandSetPositionCopyWith<
          _$_IsolatedPlayerCommandSetPosition>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$_IsolatedPlayerCommandSetDeviceCopyWith<$Res> {
  factory _$$_IsolatedPlayerCommandSetDeviceCopyWith(
          _$_IsolatedPlayerCommandSetDevice value,
          $Res Function(_$_IsolatedPlayerCommandSetDevice) then) =
      __$$_IsolatedPlayerCommandSetDeviceCopyWithImpl<$Res>;
  @useResult
  $Res call({DeviceInfo<dynamic>? deviceInfo});
}

/// @nodoc
class __$$_IsolatedPlayerCommandSetDeviceCopyWithImpl<$Res>
    extends _$IsolatedPlayerCommandCopyWithImpl<$Res,
        _$_IsolatedPlayerCommandSetDevice>
    implements _$$_IsolatedPlayerCommandSetDeviceCopyWith<$Res> {
  __$$_IsolatedPlayerCommandSetDeviceCopyWithImpl(
      _$_IsolatedPlayerCommandSetDevice _value,
      $Res Function(_$_IsolatedPlayerCommandSetDevice) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceInfo = freezed,
  }) {
    return _then(_$_IsolatedPlayerCommandSetDevice(
      deviceInfo: freezed == deviceInfo
          ? _value.deviceInfo
          : deviceInfo // ignore: cast_nullable_to_non_nullable
              as DeviceInfo<dynamic>?,
    ));
  }
}

/// @nodoc

class _$_IsolatedPlayerCommandSetDevice
    implements _IsolatedPlayerCommandSetDevice {
  const _$_IsolatedPlayerCommandSetDevice({required this.deviceInfo});

  @override
  final DeviceInfo<dynamic>? deviceInfo;

  @override
  String toString() {
    return 'IsolatedPlayerCommand.setDevice(deviceInfo: $deviceInfo)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_IsolatedPlayerCommandSetDevice &&
            (identical(other.deviceInfo, deviceInfo) ||
                other.deviceInfo == deviceInfo));
  }

  @override
  int get hashCode => Object.hash(runtimeType, deviceInfo);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_IsolatedPlayerCommandSetDeviceCopyWith<_$_IsolatedPlayerCommandSetDevice>
      get copyWith => __$$_IsolatedPlayerCommandSetDeviceCopyWithImpl<
          _$_IsolatedPlayerCommandSetDevice>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String filePath) open,
    required TResult Function() play,
    required TResult Function() pause,
    required TResult Function() stop,
    required TResult Function(double volume) setVolume,
    required TResult Function(AudioTime position) setPosition,
    required TResult Function(DeviceInfo<dynamic>? deviceInfo) setDevice,
    required TResult Function() dispose,
  }) {
    return setDevice(deviceInfo);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String filePath)? open,
    TResult? Function()? play,
    TResult? Function()? pause,
    TResult? Function()? stop,
    TResult? Function(double volume)? setVolume,
    TResult? Function(AudioTime position)? setPosition,
    TResult? Function(DeviceInfo<dynamic>? deviceInfo)? setDevice,
    TResult? Function()? dispose,
  }) {
    return setDevice?.call(deviceInfo);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String filePath)? open,
    TResult Function()? play,
    TResult Function()? pause,
    TResult Function()? stop,
    TResult Function(double volume)? setVolume,
    TResult Function(AudioTime position)? setPosition,
    TResult Function(DeviceInfo<dynamic>? deviceInfo)? setDevice,
    TResult Function()? dispose,
    required TResult orElse(),
  }) {
    if (setDevice != null) {
      return setDevice(deviceInfo);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_IsolatedPlayerCommandOpen value) open,
    required TResult Function(_IsolatedPlayerCommandPlay value) play,
    required TResult Function(_IsolatedPlayerCommandPause value) pause,
    required TResult Function(_IsolatedPlayerCommandStop value) stop,
    required TResult Function(_IsolatedPlayerCommandSetVolume value) setVolume,
    required TResult Function(_IsolatedPlayerCommandSetPosition value)
        setPosition,
    required TResult Function(_IsolatedPlayerCommandSetDevice value) setDevice,
    required TResult Function(_IsolatedPlayerCommandDispose value) dispose,
  }) {
    return setDevice(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_IsolatedPlayerCommandOpen value)? open,
    TResult? Function(_IsolatedPlayerCommandPlay value)? play,
    TResult? Function(_IsolatedPlayerCommandPause value)? pause,
    TResult? Function(_IsolatedPlayerCommandStop value)? stop,
    TResult? Function(_IsolatedPlayerCommandSetVolume value)? setVolume,
    TResult? Function(_IsolatedPlayerCommandSetPosition value)? setPosition,
    TResult? Function(_IsolatedPlayerCommandSetDevice value)? setDevice,
    TResult? Function(_IsolatedPlayerCommandDispose value)? dispose,
  }) {
    return setDevice?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_IsolatedPlayerCommandOpen value)? open,
    TResult Function(_IsolatedPlayerCommandPlay value)? play,
    TResult Function(_IsolatedPlayerCommandPause value)? pause,
    TResult Function(_IsolatedPlayerCommandStop value)? stop,
    TResult Function(_IsolatedPlayerCommandSetVolume value)? setVolume,
    TResult Function(_IsolatedPlayerCommandSetPosition value)? setPosition,
    TResult Function(_IsolatedPlayerCommandSetDevice value)? setDevice,
    TResult Function(_IsolatedPlayerCommandDispose value)? dispose,
    required TResult orElse(),
  }) {
    if (setDevice != null) {
      return setDevice(this);
    }
    return orElse();
  }
}

abstract class _IsolatedPlayerCommandSetDevice
    implements IsolatedPlayerCommand {
  const factory _IsolatedPlayerCommandSetDevice(
          {required final DeviceInfo<dynamic>? deviceInfo}) =
      _$_IsolatedPlayerCommandSetDevice;

  DeviceInfo<dynamic>? get deviceInfo;
  @JsonKey(ignore: true)
  _$$_IsolatedPlayerCommandSetDeviceCopyWith<_$_IsolatedPlayerCommandSetDevice>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$_IsolatedPlayerCommandDisposeCopyWith<$Res> {
  factory _$$_IsolatedPlayerCommandDisposeCopyWith(
          _$_IsolatedPlayerCommandDispose value,
          $Res Function(_$_IsolatedPlayerCommandDispose) then) =
      __$$_IsolatedPlayerCommandDisposeCopyWithImpl<$Res>;
}

/// @nodoc
class __$$_IsolatedPlayerCommandDisposeCopyWithImpl<$Res>
    extends _$IsolatedPlayerCommandCopyWithImpl<$Res,
        _$_IsolatedPlayerCommandDispose>
    implements _$$_IsolatedPlayerCommandDisposeCopyWith<$Res> {
  __$$_IsolatedPlayerCommandDisposeCopyWithImpl(
      _$_IsolatedPlayerCommandDispose _value,
      $Res Function(_$_IsolatedPlayerCommandDispose) _then)
      : super(_value, _then);
}

/// @nodoc

class _$_IsolatedPlayerCommandDispose implements _IsolatedPlayerCommandDispose {
  const _$_IsolatedPlayerCommandDispose();

  @override
  String toString() {
    return 'IsolatedPlayerCommand.dispose()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_IsolatedPlayerCommandDispose);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String filePath) open,
    required TResult Function() play,
    required TResult Function() pause,
    required TResult Function() stop,
    required TResult Function(double volume) setVolume,
    required TResult Function(AudioTime position) setPosition,
    required TResult Function(DeviceInfo<dynamic>? deviceInfo) setDevice,
    required TResult Function() dispose,
  }) {
    return dispose();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String filePath)? open,
    TResult? Function()? play,
    TResult? Function()? pause,
    TResult? Function()? stop,
    TResult? Function(double volume)? setVolume,
    TResult? Function(AudioTime position)? setPosition,
    TResult? Function(DeviceInfo<dynamic>? deviceInfo)? setDevice,
    TResult? Function()? dispose,
  }) {
    return dispose?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String filePath)? open,
    TResult Function()? play,
    TResult Function()? pause,
    TResult Function()? stop,
    TResult Function(double volume)? setVolume,
    TResult Function(AudioTime position)? setPosition,
    TResult Function(DeviceInfo<dynamic>? deviceInfo)? setDevice,
    TResult Function()? dispose,
    required TResult orElse(),
  }) {
    if (dispose != null) {
      return dispose();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_IsolatedPlayerCommandOpen value) open,
    required TResult Function(_IsolatedPlayerCommandPlay value) play,
    required TResult Function(_IsolatedPlayerCommandPause value) pause,
    required TResult Function(_IsolatedPlayerCommandStop value) stop,
    required TResult Function(_IsolatedPlayerCommandSetVolume value) setVolume,
    required TResult Function(_IsolatedPlayerCommandSetPosition value)
        setPosition,
    required TResult Function(_IsolatedPlayerCommandSetDevice value) setDevice,
    required TResult Function(_IsolatedPlayerCommandDispose value) dispose,
  }) {
    return dispose(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_IsolatedPlayerCommandOpen value)? open,
    TResult? Function(_IsolatedPlayerCommandPlay value)? play,
    TResult? Function(_IsolatedPlayerCommandPause value)? pause,
    TResult? Function(_IsolatedPlayerCommandStop value)? stop,
    TResult? Function(_IsolatedPlayerCommandSetVolume value)? setVolume,
    TResult? Function(_IsolatedPlayerCommandSetPosition value)? setPosition,
    TResult? Function(_IsolatedPlayerCommandSetDevice value)? setDevice,
    TResult? Function(_IsolatedPlayerCommandDispose value)? dispose,
  }) {
    return dispose?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_IsolatedPlayerCommandOpen value)? open,
    TResult Function(_IsolatedPlayerCommandPlay value)? play,
    TResult Function(_IsolatedPlayerCommandPause value)? pause,
    TResult Function(_IsolatedPlayerCommandStop value)? stop,
    TResult Function(_IsolatedPlayerCommandSetVolume value)? setVolume,
    TResult Function(_IsolatedPlayerCommandSetPosition value)? setPosition,
    TResult Function(_IsolatedPlayerCommandSetDevice value)? setDevice,
    TResult Function(_IsolatedPlayerCommandDispose value)? dispose,
    required TResult orElse(),
  }) {
    if (dispose != null) {
      return dispose(this);
    }
    return orElse();
  }
}

abstract class _IsolatedPlayerCommandDispose implements IsolatedPlayerCommand {
  const factory _IsolatedPlayerCommandDispose() =
      _$_IsolatedPlayerCommandDispose;
}
