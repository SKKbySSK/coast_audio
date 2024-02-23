import 'package:coast_audio/generated/bindings.dart';

enum AudioDevicePerformanceProfile {
  lowLatency(ca_performance_profile.ca_performance_profile_low_latency),
  conservative(ca_performance_profile.ca_performance_profile_conservative);

  const AudioDevicePerformanceProfile(this.caValue);
  final int caValue;
}
