import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';
import 'package:flutter/services.dart';

class FlutterCoastAudioPlugin {
  const FlutterCoastAudioPlugin();

  final _channel = const MethodChannel('flutter_coast_audio_miniaudio');

  Future<List<DeviceInfo>> getDevices(MabDeviceContext context, MabDeviceType type) async {
    final backend = context.activeBackend;

    // We should use the miniaudio implementations for OpenSL and CoreAudio.
    if (backend == MabBackend.openSl || backend == MabBackend.coreAudio) {
      return context.getDevices(type);
    }

    final deviceMaps = await _channel.invokeListMethod<Map<dynamic, dynamic>>('get_devices', type.value);
    final devices = deviceMaps!.map(
      (e) => _SerializedDeviceInfo(
        id: e['id'],
        name: e['name'],
        isDefault: e['is_default'],
      ),
    );

    return devices.map<DeviceInfo>((_SerializedDeviceInfo d) {
      switch (backend) {
        case MabBackend.aaudio:
          return AAudioDeviceInfo(
            id: int.parse(d.id),
            name: d.name,
            type: type,
            isDefault: d.isDefault,
          );
        default:
          throw UnsupportedError('unsupported backend: $backend');
      }
    }).toList(growable: false);
  }

  Future<AudioTime?> getInputLatency() async {
    final latency = await _channel.invokeMethod<double?>('get_input_latency');
    if (latency == null) {
      return null;
    }

    return AudioTime(latency);
  }

  Future<AudioTime?> getOutputLatency() async {
    final latency = await _channel.invokeMethod<double?>('get_output_latency');
    if (latency == null) {
      return null;
    }

    return AudioTime(latency);
  }
}

class _SerializedDeviceInfo {
  const _SerializedDeviceInfo({
    required this.id,
    required this.name,
    required this.isDefault,
  });

  final String id;
  final String name;
  final bool isDefault;
}
