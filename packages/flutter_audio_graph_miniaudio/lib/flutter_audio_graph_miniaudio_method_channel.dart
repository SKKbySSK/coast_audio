import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_audio_graph_miniaudio_platform_interface.dart';

/// An implementation of [FlutterAudioGraphMiniaudioPlatform] that uses method channels.
class MethodChannelFlutterAudioGraphMiniaudio extends FlutterAudioGraphMiniaudioPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_audio_graph_miniaudio');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
