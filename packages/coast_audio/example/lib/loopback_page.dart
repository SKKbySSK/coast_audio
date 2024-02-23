import 'package:coast_audio/coast_audio.dart';
import 'package:example/models/audio_state.dart';
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
  final format = const AudioFormat(sampleRate: 44100, channels: 2);
  late final capture = CaptureDevice(context: widget.audio.deviceContext, format: format, bufferFrameSize: 2048, device: widget.audio.inputDevice);
  late final playback = PlaybackDevice(context: widget.audio.deviceContext, format: format, bufferFrameSize: 2048, device: widget.audio.outputDevice);
  late final bufferFrames = AllocatedAudioFrames(length: 2048, format: format);
  late final clock = AudioIntervalClock(const Duration(milliseconds: 1))..callbacks.add((clock) => _onTick());

  void _onTick() {
    bufferFrames.acquireBuffer((buffer) {
      final readResult = capture.read(buffer);
      if (!readResult.maResult.isSuccess && !readResult.maResult.isEnd) {
        clock.stop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Capture error: ${MaException(readResult.maResult)}')));
        return;
      }
      playback.write(buffer.limit(readResult.framesRead));
    });
  }

  @override
  void initState() {
    super.initState();
    capture.start();
    playback.start();
    clock.start();
  }

  @override
  void dispose() {
    super.dispose();
    clock.stop();
    capture.stop();
    playback.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loopback'),
      ),
    );
  }
}
