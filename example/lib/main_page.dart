import 'package:coast_audio/coast_audio.dart';
import 'package:example/components/action_tile.dart';
import 'package:example/components/select_device_dialog.dart';
import 'package:example/main.dart';
import 'package:example/models/audio_state.dart';
import 'package:example/pages/loopback_page.dart';
import 'package:example/pages/player_page.dart';
import 'package:example/pages/recorder_page.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
    required this.audio,
  });
  final AudioStateConfigured audio;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('coast_audio'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ActionTile(
                title: 'Loopback',
                body: 'Loopback audio from capture device to playback device',
                isMicRequired: true,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LoopbackPage(audio: widget.audio),
                  ),
                ),
              ),
              ActionTile(
                title: 'Audio Player',
                body: 'Play audio from wav file',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PlayerPage(audio: widget.audio),
                  ),
                ),
              ),
              ActionTile(
                title: 'Audio Recorder',
                body: 'Record audio from capture device and save to file',
                isMicRequired: true,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RecorderPage(audio: widget.audio),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'input',
            onPressed: () async {
              final device = await showDialog<AudioDeviceInfo>(
                context: context,
                builder: (context) {
                  return SelectDeviceDialog(
                    backend: widget.audio.backend,
                    deviceType: AudioDeviceType.capture,
                  );
                },
              );
              if (device == null || !context.mounted) {
                return;
              }

              App.of(context).applyAudioState(
                widget.audio.copyWith(inputDevice: device),
              );
            },
            label: Row(
              children: [
                const Icon(Icons.mic),
                const SizedBox(width: 8),
                Text(widget.audio.inputDevice?.name ?? 'Unknown'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'output',
            onPressed: () async {
              final device = await showDialog<AudioDeviceInfo>(
                context: context,
                builder: (context) {
                  return SelectDeviceDialog(
                    backend: widget.audio.backend,
                    deviceType: AudioDeviceType.playback,
                  );
                },
              );
              if (device == null || !context.mounted) {
                return;
              }

              App.of(context).applyAudioState(
                widget.audio.copyWith(outputDevice: device),
              );
            },
            label: Row(
              children: [
                const Icon(Icons.volume_up),
                const SizedBox(width: 8),
                Text(widget.audio.outputDevice?.name ?? 'Unknown'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
