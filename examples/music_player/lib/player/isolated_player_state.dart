import 'package:flutter/foundation.dart';
import 'package:flutter_audio_graph_miniaudio/flutter_audio_graph_miniaudio.dart';
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
    required bool isReady,
    required bool isPlaying,
  }) = _IsolatedPlayerState;
}

class IsolatedPlayerMetadataState {
  const IsolatedPlayerMetadataState(this.metadata);
  final Metadata? metadata;
}

class IsolatedPlayerDeviceState {
  const IsolatedPlayerDeviceState(this.deviceInfo);
  final DeviceInfo<dynamic>? deviceInfo;
}
