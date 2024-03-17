import 'dart:ffi';

import 'package:coast_audio/coast_audio.dart';

import '../interop/internal/generated/bindings.dart';

/// An audio device notification which is sent when the audio device state changes.
///
/// You can listen to these notifications by using `AudioDevice.notification.listen`.
class AudioDeviceNotification {
  const AudioDeviceNotification({
    required this.type,
    required this.state,
  });

  factory AudioDeviceNotification.fromPointer(Pointer<ca_device_notification> pNotification) {
    final notification = pNotification.ref;
    return AudioDeviceNotification(
      type: AudioDeviceNotificationType.values.firstWhere((e) => notification.type == e.maValue),
      state: AudioDeviceState.values.firstWhere((e) => notification.state == e.maValue),
    );
  }

  /// The notification type.
  final AudioDeviceNotificationType type;

  /// The device state.
  final AudioDeviceState state;
}

/// Types of audio device notifications.
enum AudioDeviceNotificationType {
  /// The device has started.
  started(ma_device_notification_type.ma_device_notification_type_started),

  /// The device has stopped.
  stopped(ma_device_notification_type.ma_device_notification_type_stopped),

  /// The old device is disconnected and the new device will be used.
  rerouted(ma_device_notification_type.ma_device_notification_type_rerouted),

  /// The device has been interrupted.
  ///
  /// This can happen on iOS when some situation occurs, such as a phone call.
  interruptionBegan(ma_device_notification_type.ma_device_notification_type_interruption_began),

  /// The device's interruption has ended.
  interruptionEnded(ma_device_notification_type.ma_device_notification_type_interruption_ended);

  const AudioDeviceNotificationType(this.maValue);
  final int maValue;
}
