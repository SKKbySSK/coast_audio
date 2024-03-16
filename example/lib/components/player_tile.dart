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
  String? _fatalMessage;
  var _volume = 1.0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    super.dispose();
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
          _PlayerTimerBuilder(
            playerIsolate: playerIsolate,
            onTick: (isolate) => isolate.getState(),
            builder: (context, state) {
              return IconButton(
                onPressed: () async {
                  if (state == null) {
                    return;
                  }

                  if (state.isPlaying) {
                    await playerIsolate.pause();
                  } else {
                    await playerIsolate.play();
                  }
                },
                iconSize: 48,
                icon: Icon((state?.isPlaying ?? false) ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded),
              );
            },
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: RepaintBoundary(
                    child: _PlayerTimerBuilder(
                        playerIsolate: playerIsolate,
                        onTick: (isolate) {
                          return isolate.getPosition();
                        },
                        builder: (context, result) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 60,
                                child: Center(
                                  child: Text(result?.position.formatMMSS() ?? '00:00'),
                                ),
                              ),
                              Expanded(
                                child: Slider(
                                  value: result?.position.seconds.toDouble() ?? 0,
                                  max: result?.duration.seconds.toDouble() ?? 0,
                                  min: 0,
                                  onChanged: (value) async {
                                    await playerIsolate.seek(AudioTime(value));
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 60,
                                child: Center(
                                  child: Text(result?.duration.formatMMSS() ?? '00:00'),
                                ),
                              ),
                            ],
                          );
                        }),
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
                          value: _volume,
                          max: 1,
                          min: 0,
                          onChanged: (value) async {
                            await playerIsolate.setVolume(value);
                            setState(() {
                              _volume = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: Center(
                          child: Text('${(_volume * 100).toStringAsFixed(0)}%'),
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

class _PlayerTimerBuilder<T> extends StatefulWidget {
  const _PlayerTimerBuilder({
    required this.playerIsolate,
    required this.onTick,
    required this.builder,
  });
  final PlayerIsolate playerIsolate;
  final Future<T?> Function(PlayerIsolate) onTick;
  final Widget Function(BuildContext, T?) builder;

  @override
  State<_PlayerTimerBuilder<T>> createState() => _PlayerTimerBuilderState();
}

class _PlayerTimerBuilderState<T> extends State<_PlayerTimerBuilder<T>> {
  Timer? _timer;
  T? _result;

  Future<void> _init() async {
    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) async {
        if (!widget.playerIsolate.isLaunched) {
          return;
        }

        final result = await widget.onTick(widget.playerIsolate);
        if (result == null || !mounted) {
          return;
        }

        setState(() => _result = result);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _result);
  }
}
