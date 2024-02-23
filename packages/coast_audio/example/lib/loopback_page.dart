import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:example/models/audio_state.dart';
import 'package:example/models/loopback_isolate.dart';
import 'package:flutter/material.dart';

class LoopbackPage extends StatefulWidget {
  const LoopbackPage({
    super.key,
    required this.audio,
  });
  final AudioStateConfigured audio;

  @override
  State<LoopbackPage> createState() => _LoopbackPageState();
}

class _LoopbackPageState extends State<LoopbackPage> {
  final loopbackIsolate = LoopbackIsolate();

  var _isStarted = false;
  var _stats = const LoopbackStatsResponse(stability: 0);

  @override
  void initState() {
    super.initState();
    _init().onError((error, stackTrace) {
      debugPrint('Error initializing loopback: $error');
      debugPrintStack(stackTrace: stackTrace);
    });
  }

  @override
  void dispose() {
    super.dispose();
    loopbackIsolate.shutdown();
  }

  Future<void> _init() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(avAudioSessionCategory: AVAudioSessionCategory.playAndRecord));
      await session.setActive(true);
    }

    await loopbackIsolate.launch(
      backend: widget.audio.deviceContext.activeBackend,
      inputDeviceId: widget.audio.inputDevice?.id,
      outputDeviceId: widget.audio.outputDevice?.id,
    );

    Timer.periodic(
      const Duration(milliseconds: 20),
      (timer) async {
        if (!loopbackIsolate.isLaunched) {
          return;
        }

        final stats = await loopbackIsolate.stats();
        if (context.mounted) {
          setState(() => _stats = stats);
        } else {
          timer.cancel();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loopback'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isStarted)
              ElevatedButton.icon(
                onPressed: () {
                  loopbackIsolate.stop();
                  setState(() {
                    _isStarted = false;
                  });
                },
                label: const Text('Stop'),
                icon: const Icon(Icons.stop),
              ),
            if (!_isStarted)
              ElevatedButton.icon(
                onPressed: () {
                  loopbackIsolate.start();
                  setState(() {
                    _isStarted = true;
                  });
                },
                label: const Text('Start'),
                icon: const Icon(Icons.play_arrow),
              ),
            const SizedBox(height: 12),
            Text(
              'Stability: ${(_stats.stability * 100).toStringAsFixed(1)}%',
            ),
          ],
        ),
      ),
    );
  }
}
