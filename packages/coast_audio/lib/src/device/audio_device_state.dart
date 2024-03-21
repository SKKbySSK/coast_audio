import '../interop/generated/bindings.dart';

enum AudioDeviceState {
  uninitialized(ma_device_state.ma_device_state_uninitialized),
  stopped(ma_device_state.ma_device_state_stopped),
  started(ma_device_state.ma_device_state_started),
  starting(ma_device_state.ma_device_state_starting),
  stopping(ma_device_state.ma_device_state_stopping);

  const AudioDeviceState(this.caValue);
  final int caValue;
}
