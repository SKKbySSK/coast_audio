import '../interop/generated/bindings.dart';

enum AudioDeviceNotification {
  started(ma_device_notification_type.ma_device_notification_type_started),
  stopped(ma_device_notification_type.ma_device_notification_type_stopped),
  rerouted(ma_device_notification_type.ma_device_notification_type_rerouted),
  interruptionBegan(ma_device_notification_type.ma_device_notification_type_interruption_began),
  interruptionEnded(ma_device_notification_type.ma_device_notification_type_interruption_ended);

  const AudioDeviceNotification(this.caValue);
  final int caValue;
}
