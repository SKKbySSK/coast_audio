import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_audio_graph_miniaudio_method_channel.dart';

abstract class FlutterAudioGraphMiniaudioPlatform extends PlatformInterface {
  /// Constructs a FlutterAudioGraphMiniaudioPlatform.
  FlutterAudioGraphMiniaudioPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterAudioGraphMiniaudioPlatform _instance = MethodChannelFlutterAudioGraphMiniaudio();

  /// The default instance of [FlutterAudioGraphMiniaudioPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterAudioGraphMiniaudio].
  static FlutterAudioGraphMiniaudioPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterAudioGraphMiniaudioPlatform] when
  /// they register themselves.
  static set instance(FlutterAudioGraphMiniaudioPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
