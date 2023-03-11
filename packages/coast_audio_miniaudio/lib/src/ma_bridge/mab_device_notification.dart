import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';

class MabDeviceNotification {
  const MabDeviceNotification({required this.type});
  factory MabDeviceNotification.fromValues({
    required int type,
  }) {
    return MabDeviceNotification(
      type: MabDeviceNotificationType.values.firstWhere((t) => t.value == type),
    );
  }

  final MabDeviceNotificationType type;
}
