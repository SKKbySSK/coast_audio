import '../interop/internal/generated/bindings.dart';

/// The performance profile of the audio device.
enum AudioDevicePerformanceProfile {
  /// Low latency performance profile.
  ///
  /// This profile is optimized for low latency but may increase CPU load.
  lowLatency(ma_performance_profile.ma_performance_profile_low_latency),

  /// Conservative performance profile.
  ///
  /// This profile is optimized for low CPU load but may increase latency.
  conservative(ma_performance_profile.ma_performance_profile_conservative);

  const AudioDevicePerformanceProfile(this.maValue);
  final int maValue;
}
