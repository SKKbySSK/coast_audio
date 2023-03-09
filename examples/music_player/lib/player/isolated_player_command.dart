import 'package:flutter_coast_audio_miniaudio/flutter_coast_audio_miniaudio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'isolated_player_command.freezed.dart';

@freezed
class IsolatedPlayerCommand with _$IsolatedPlayerCommand {
  const factory IsolatedPlayerCommand.open({required String filePath}) = _IsolatedPlayerCommandOpen;
  const factory IsolatedPlayerCommand.play() = _IsolatedPlayerCommandPlay;
  const factory IsolatedPlayerCommand.pause() = _IsolatedPlayerCommandPause;
  const factory IsolatedPlayerCommand.stop() = _IsolatedPlayerCommandStop;
  const factory IsolatedPlayerCommand.setVolume({required double volume}) = _IsolatedPlayerCommandSetVolume;
  const factory IsolatedPlayerCommand.setPosition({required AudioTime position}) = _IsolatedPlayerCommandSetPosition;
  const factory IsolatedPlayerCommand.setDevice({required DeviceInfo<dynamic>? deviceInfo}) = _IsolatedPlayerCommandSetDevice;
  const factory IsolatedPlayerCommand.dispose() = _IsolatedPlayerCommandDispose;
}
