import 'package:example/components/action_tile.dart';
import 'package:example/components/audio_stats_view.dart';
import 'package:example/loopback_page.dart';
import 'package:example/models/audio_state.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
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
                      body: 'Play audio from file',
                      onTap: () {},
                    ),
                    ActionTile(
                      title: 'Audio Recorder',
                      body: 'Record audio from capture device and save to file',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            const AudioStatsView(),
          ],
        ),
      ),
    );
  }
}
