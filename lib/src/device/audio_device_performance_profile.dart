import '../interop/internal/generated/bindings.dart';

enum AudioDevicePerformanceProfile {
  lowLatency(ma_performance_profile.ma_performance_profile_low_latency),
  conservative(ma_performance_profile.ma_performance_profile_conservative);

  const AudioDevicePerformanceProfile(this.caValue);
  final int caValue;
}
