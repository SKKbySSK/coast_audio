import 'package:coast_audio/generated/bindings.dart';

enum AudioDeviceNotification {
  started(ca_device_notification_type.ca_device_notification_type_started),
  stopped(ca_device_notification_type.ca_device_notification_type_stopped),
  rerouted(ca_device_notification_type.ca_device_notification_type_rerouted),
  interruptionBegan(ca_device_notification_type.ca_device_notification_type_interruption_began),
  interruptionEnded(ca_device_notification_type.ca_device_notification_type_interruption_ended);

  const AudioDeviceNotification(this.caValue);
  final int caValue;
}
