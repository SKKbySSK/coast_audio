import 'flutter_audio_graph_miniaudio_platform_interface.dart';

export 'package:dart_audio_graph/dart_audio_graph.dart';
export 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';

class FlutterAudioGraphMiniaudio {
  Future<String?> getPlatformVersion() {
    return FlutterAudioGraphMiniaudioPlatform.instance.getPlatformVersion();
  }
}
