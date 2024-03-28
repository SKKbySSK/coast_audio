import 'package:coast_audio/coast_audio.dart';
import 'package:example/main.dart';
import 'package:example/models/audio_state.dart';
import 'package:flutter/material.dart';

class AudioStatsView extends StatelessWidget {
  const AudioStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey.shade200,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 12, color: Colors.black),
            child: switch (App.of(context).audioState) {
              AudioStateInitial() => const SizedBox(),
              AudioStateConfigured(backend: final backend) => Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(switch (backend) {
                      AudioDeviceBackend.coreAudio => 'Core Audio',
                      AudioDeviceBackend.aaudio => 'AAudio',
                      AudioDeviceBackend.openSLES => 'OpenSL ES',
                      AudioDeviceBackend.wasapi => 'WASAPI',
                      AudioDeviceBackend.alsa => 'ALSA',
                      AudioDeviceBackend.pulseAudio => 'PulseAudio',
                      AudioDeviceBackend.jack => 'JACK',
                      AudioDeviceBackend.dummy => 'Dummy',
                    }),
                  ],
                )
            },
          ),
        ),
      ),
    );
  }
}
