import 'dart:async';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:disposing/disposing.dart';

class AudioOutput extends Disposable {
  AudioOutput({
    required this.bus,
    required this.format,
    required this.onOutput,
    required int bufferFrames,
  }) : _buffer = FrameBuffer.allocate(frames: bufferFrames, format: format);

  final AudioFormat format;
  final AudioOutputBus bus;
  final FutureOr<void> Function(FrameBuffer buffer) onOutput;
  final FrameBuffer _buffer;

  bool _isDisposed = false;

  @override
  bool get isDisposed => _isDisposed;

  Future<int> write() async {
    final frameCount = bus.read(_buffer);
    await onOutput(_buffer.limit(frameCount));
    return frameCount;
  }

  Future<int> writeAll() async {
    var totalFrames = 0;

    var framesWrite = await write();
    totalFrames += framesWrite;

    while (framesWrite > 0) {
      framesWrite = await write();
      totalFrames += framesWrite;
    }

    return totalFrames;
  }

  void dispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    _buffer.dispose();
  }
}
