import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:coast_audio/coast_audio.dart';
import 'package:example/isolates/player_isolate.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class PlayerTile extends StatefulWidget {
  const PlayerTile({
    super.key,
    required this.backend,
    required this.outputDevice,
    required this.file,
  });
  final AudioDeviceBackend backend;
  final AudioDeviceInfo? outputDevice;
  final XFile file;

  @override
  State<PlayerTile> createState() => _PlayerTileState();
}

class _PlayerTileState extends State<PlayerTile> {
  final playerIsolate = PlayerIsolate();
  Timer? _timer;
  String? _fatalMessage;

  var _stats = PlayerStatsResponse(
    position: AudioTime.zero,
    duration: AudioTime.zero,
    volume: 1,
    isPlaying: false,
  );

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    if (playerIsolate.isLaunched) {
      playerIsolate.shutdown();
    }
  }

  Future<void> _init() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(avAudioSessionCategory: AVAudioSessionCategory.playback));
      await session.setActive(true);
    }

    final shouldReadContent = widget.file.path.startsWith('content');

    await playerIsolate.launch(
      backend: widget.backend,
      outputDeviceId: widget.outputDevice?.id,
      path: shouldReadContent ? null : widget.file.path,
      content: shouldReadContent ? await widget.file.readAsBytes() : null,
    );

    _timer = Timer.periodic(
      const Duration(milliseconds: 50),
      (timer) async {
        if (!playerIsolate.isLaunched) {
          return;
        }

        final stats = await playerIsolate.stats();
        if (!context.mounted) {
          return;
        }

        if (stats == null) {
          return;
        }

        setState(() => _stats = stats);
      },
    );

    try {
      await playerIsolate.attach();
    } on Exception catch (e) {
      setState(() {
        _fatalMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_fatalMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            Expanded(child: Text(_fatalMessage!)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () async {
              if (_stats.isPlaying) {
                await playerIsolate.pause();
              } else {
                await playerIsolate.play();
              }
              setState(() {
                _stats = PlayerStatsResponse(
                  position: _stats.position,
                  duration: _stats.duration,
                  volume: _stats.volume,
                  isPlaying: !_stats.isPlaying,
                );
              });
            },
            iconSize: 48,
            icon: Icon(_stats.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        child: Center(
                          child: Text(_stats.position.formatMMSS()),
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: _stats.position.seconds.toDouble(),
                          max: _stats.duration.seconds.toDouble(),
                          min: 0,
                          onChanged: (value) async {
                            final stats = await playerIsolate.seek(AudioTime(value));
                            if (stats == null) {
                              return;
                            }
                            setState(() {
                              _stats = stats;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: Center(
                          child: Text(_stats.duration.formatMMSS()),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 60,
                        child: Center(
                          child: Icon(Icons.volume_up),
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: _stats.volume,
                          max: 1,
                          min: 0,
                          onChanged: (value) async {
                            final stats = await playerIsolate.setVolume(value);
                            if (stats == null) {
                              return;
                            }
                            setState(() {
                              _stats = stats;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: Center(
                          child: Text('${(_stats.volume * 100).toStringAsFixed(0)}%'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
