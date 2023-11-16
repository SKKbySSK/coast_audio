import 'package:flutter_coast_audio_miniaudio/flutter_coast_audio_miniaudio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'isolated_player_command.freezed.dart';

@freezed
class IsolatedPlayerCommand with _$IsolatedPlayerCommand {
  const factory IsolatedPlayerCommand.openFile({required String filePath}) = _IsolatedPlayerCommandOpenFile;
  const factory IsolatedPlayerCommand.openBuffer({required List<int> buffer}) = _IsolatedPlayerCommandOpenBuffer;
  const factory IsolatedPlayerCommand.openHttpUrl({required String url}) = _IsolatedPlayerCommandOpenHttpUrl;
  const factory IsolatedPlayerCommand.play() = _IsolatedPlayerCommandPlay;
  const factory IsolatedPlayerCommand.pause() = _IsolatedPlayerCommandPause;
  const factory IsolatedPlayerCommand.stop() = _IsolatedPlayerCommandStop;
  const factory IsolatedPlayerCommand.setVolume({required double volume}) = _IsolatedPlayerCommandSetVolume;
  const factory IsolatedPlayerCommand.setPosition({required AudioTime position}) = _IsolatedPlayerCommandSetPosition;
  const factory IsolatedPlayerCommand.setDevice({required DeviceInfo<dynamic>? deviceInfo}) = _IsolatedPlayerCommandSetDevice;
  const factory IsolatedPlayerCommand.dispose() = _IsolatedPlayerCommandDispose;
}
