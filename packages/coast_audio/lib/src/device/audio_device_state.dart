import 'package:coast_audio/ca_device/bindings.dart';

enum AudioDeviceState {
  uninitialized(ca_device_state.ca_device_state_uninitialized),
  stopped(ca_device_state.ca_device_state_stopped),
  started(ca_device_state.ca_device_state_started),
  starting(ca_device_state.ca_device_state_starting),
  stopping(ca_device_state.ca_device_state_stopping);

  const AudioDeviceState(this.caValue);
  final int caValue;
}
