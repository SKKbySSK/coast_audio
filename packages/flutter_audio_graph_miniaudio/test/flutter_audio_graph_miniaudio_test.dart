import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_audio_graph_miniaudio/flutter_audio_graph_miniaudio.dart';
import 'package:flutter_audio_graph_miniaudio/flutter_audio_graph_miniaudio_platform_interface.dart';
import 'package:flutter_audio_graph_miniaudio/flutter_audio_graph_miniaudio_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterAudioGraphMiniaudioPlatform
    with MockPlatformInterfaceMixin
    implements FlutterAudioGraphMiniaudioPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterAudioGraphMiniaudioPlatform initialPlatform = FlutterAudioGraphMiniaudioPlatform.instance;

  test('$MethodChannelFlutterAudioGraphMiniaudio is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterAudioGraphMiniaudio>());
  });

  test('getPlatformVersion', () async {
    FlutterAudioGraphMiniaudio flutterAudioGraphMiniaudioPlugin = FlutterAudioGraphMiniaudio();
    MockFlutterAudioGraphMiniaudioPlatform fakePlatform = MockFlutterAudioGraphMiniaudioPlatform();
    FlutterAudioGraphMiniaudioPlatform.instance = fakePlatform;

    expect(await flutterAudioGraphMiniaudioPlugin.getPlatformVersion(), '42');
  });
}
