import 'package:coast_audio_fft/coast_audio_fft.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_coast_audio_miniaudio/flutter_coast_audio_miniaudio.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'isolated_player_state.freezed.dart';

@freezed
class IsolatedPlayerState with _$IsolatedPlayerState {
  const factory IsolatedPlayerState({
    required AudioFormat format,
    required String? filePath,
    required double volume,
    required AudioTime duration,
    required AudioTime position,
    required MabAudioPlayerState state,
  }) = _IsolatedPlayerState;
}

class IsolatedPlayerMetadataState {
  const IsolatedPlayerMetadataState(this.metadata);
  final Metadata? metadata;
}

class IsolatedPlayerReroutedState {
  const IsolatedPlayerReroutedState(this.deviceInfo);
  final DeviceInfo<dynamic>? deviceInfo;
}

class IsolatedPlayerDeviceState {
  const IsolatedPlayerDeviceState(this.deviceInfo);
  final DeviceInfo<dynamic>? deviceInfo;
}

class IsolatedPlayerFftCompletedState {
  const IsolatedPlayerFftCompletedState(this.result);
  final FftResult result;
}
