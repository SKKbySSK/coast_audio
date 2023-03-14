import 'package:flutter_coast_audio_miniaudio/flutter_coast_audio_miniaudio.dart';

extension MabDeviceContextExtension on MabDeviceContext {
  Future<List<DeviceInfo<dynamic>>> getAllDevices(MabDeviceType type) {
    const plugin = FlutterCoastAudioPlugin();
    return plugin.getDevices(this, type);
  }
}
