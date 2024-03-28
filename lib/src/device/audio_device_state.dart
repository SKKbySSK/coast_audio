import '../interop/internal/generated/bindings.dart';

/// The state of the audio device.
enum AudioDeviceState {
  /// The device is uninitialized.
  uninitialized(ma_device_state.ma_device_state_uninitialized),

  /// The device is stopped.
  stopped(ma_device_state.ma_device_state_stopped),

  /// The device is started.
  started(ma_device_state.ma_device_state_started),

  /// The device is starting.
  starting(ma_device_state.ma_device_state_starting),

  /// The device is stopping.
  stopping(ma_device_state.ma_device_state_stopping);

  const AudioDeviceState(this.maValue);
  final int maValue;
}
