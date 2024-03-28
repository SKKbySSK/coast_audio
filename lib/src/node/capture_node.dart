import 'package:coast_audio/coast_audio.dart';

class CaptureNode extends AudioNode with SingleOutNodeMixin {
  CaptureNode({
    required this.device,
    this.autoStart = true,
  });

  final CaptureDevice device;

  bool autoStart;

  @override
  final List<AudioInputBus> inputs = const [];

  @override
  late final outputBus = AudioOutputBus(node: this, formatResolver: (_) => device.format);

  @override
  AudioReadResult read(AudioOutputBus outputBus, AudioBuffer buffer) {
    if (autoStart && !device.isStarted) {
      device.start();
    }

    final result = device.read(buffer);
    return AudioReadResult(
      frameCount: result.framesRead,
      isEnd: false,
    );
  }
}
