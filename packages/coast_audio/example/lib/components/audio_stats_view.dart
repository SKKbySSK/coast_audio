import 'package:coast_audio/coast_audio.dart';
import 'package:example/main.dart';
import 'package:example/models/audio_state.dart';
import 'package:flutter/material.dart';

class AudioStatsView extends StatelessWidget {
  const AudioStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: DefaultTextStyle(
        style: const TextStyle(fontSize: 12, color: Colors.black),
        child: switch (context.findAncestorStateOfType<AppState>()!.audioState) {
          AudioStateInitial() => const SizedBox(),
          AudioStateConfigured(deviceContext: final deviceContext, inputDevice: final input, outputDevice: final output) => Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(switch (deviceContext.activeBackend) {
                  AudioDeviceBackend.coreAudio => 'Core Audio',
                  AudioDeviceBackend.aaudio => 'AAudio',
                  AudioDeviceBackend.openSLES => 'OpenSL ES',
                  AudioDeviceBackend.wasapi => 'WASAPI',
                  AudioDeviceBackend.alsa => 'ALSA',
                  AudioDeviceBackend.pulseAudio => 'PulseAudio',
                  AudioDeviceBackend.jack => 'JACK',
                }),
                const Spacer(),
                const SizedBox(width: 8),
                const Icon(Icons.mic, size: 18),
                const SizedBox(width: 2),
                Text(input?.name ?? 'N/A'),
                const SizedBox(width: 8),
                const Icon(Icons.volume_up, size: 18),
                const SizedBox(width: 2),
                Text(output?.name ?? 'N/A'),
              ],
            )
        },
      ),
    );
  }
}
