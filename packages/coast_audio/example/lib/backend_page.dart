import 'dart:io';

import 'package:coast_audio/coast_audio.dart';
import 'package:example/main.dart';
import 'package:example/models/audio_state.dart';
import 'package:flutter/material.dart';

class BackendPage extends StatefulWidget {
  const BackendPage({super.key});

  @override
  State<BackendPage> createState() => _BackendPageState();
}

class _BackendPageState extends State<BackendPage> {
  final backends = <AudioDeviceBackend, bool>{};

  @override
  void initState() {
    super.initState();
    for (final backend in AudioDeviceBackend.values) {
      backends[backend] = switch (backend) {
        AudioDeviceBackend.coreAudio => Platform.isMacOS || Platform.isIOS,
        AudioDeviceBackend.aaudio => Platform.isAndroid,
        AudioDeviceBackend.openSLES => Platform.isAndroid,
        AudioDeviceBackend.wasapi => Platform.isWindows,
        AudioDeviceBackend.alsa => Platform.isLinux,
        AudioDeviceBackend.pulseAudio => Platform.isLinux,
        AudioDeviceBackend.jack => Platform.isLinux,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Backend'),
      ),
      body: ListView.builder(
        itemCount: AudioDeviceBackend.values.length,
        itemBuilder: (context, index) {
          final backend = AudioDeviceBackend.values[index];
          return CheckboxListTile.adaptive(
            value: backends[backend],
            title: Text(
              switch (backend) {
                AudioDeviceBackend.coreAudio => 'Core Audio',
                AudioDeviceBackend.aaudio => 'AAudio',
                AudioDeviceBackend.openSLES => 'OpenSL ES',
                AudioDeviceBackend.wasapi => 'WASAPI',
                AudioDeviceBackend.alsa => 'ALSA',
                AudioDeviceBackend.pulseAudio => 'PulseAudio',
                AudioDeviceBackend.jack => 'JACK',
              },
            ),
            subtitle: Text(
              switch (backend) {
                AudioDeviceBackend.coreAudio => 'macOS, iOS',
                AudioDeviceBackend.aaudio => 'Android 8+',
                AudioDeviceBackend.openSLES => 'Android 4.1+',
                AudioDeviceBackend.wasapi => 'Windows Vista+',
                AudioDeviceBackend.alsa => 'Linux',
                AudioDeviceBackend.pulseAudio => 'Linux',
                AudioDeviceBackend.jack => 'Linux',
              },
            ),
            onChanged: (isChecked) {
              setState(() {
                backends[backend] = isChecked!;
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: backends.values.any((v) => v)
            ? () {
                final AudioDeviceContext deviceContext;
                try {
                  deviceContext = AudioDeviceContext(
                    backends: backends.entries.where((e) => e.value).map((e) => e.key).toList(),
                  );
                } on MaException catch (e) {
                  switch (e.result.name) {
                    case MaResultName.noBackend:
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not activate any of the selected backends.'),
                        ),
                      );
                    default:
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '\'${switch (deviceContext.activeBackend) {
                        AudioDeviceBackend.coreAudio => 'Core Audio',
                        AudioDeviceBackend.aaudio => 'AAudio',
                        AudioDeviceBackend.openSLES => 'OpenSL ES',
                        AudioDeviceBackend.wasapi => 'WASAPI',
                        AudioDeviceBackend.alsa => 'ALSA',
                        AudioDeviceBackend.pulseAudio => 'PulseAudio',
                        AudioDeviceBackend.jack => 'JACK',
                      }}\' activated.',
                    ),
                  ),
                );
                context.findAncestorStateOfType<AppState>()!.applyAudioState(
                      AudioStateConfigured(
                        deviceContext: deviceContext,
                        inputDevice: deviceContext.getDevices(AudioDeviceType.capture).where((d) => d.isDefault).firstOrNull,
                        outputDevice: deviceContext.getDevices(AudioDeviceType.playback).where((d) => d.isDefault).firstOrNull,
                      ),
                    );
              }
            : null,
        child: const Icon(Icons.check),
      ),
    );
  }
}
