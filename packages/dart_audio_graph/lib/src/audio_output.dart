import 'dart:async';

import 'package:dart_audio_graph/dart_audio_graph.dart';

class AudioOutput extends Disposable {
  AudioOutput({
    required this.bus,
    required this.format,
    required this.onOutput,
    required int bufferFrames,
  }) : _buffer = AllocatedFrameBuffer(frames: bufferFrames, format: format);

  final AudioFormat format;
  final AudioOutputBus bus;
  final FutureOr<void> Function(AcquiredFrameBuffer buffer) onOutput;
  final AllocatedFrameBuffer _buffer;
  late final _acquiredBuffer = _buffer.lock();

  bool _isDisposed = false;

  @override
  bool get isDisposed => _isDisposed;

  Future<int> write() async {
    final frameCount = bus.read(_acquiredBuffer);
    await onOutput(_acquiredBuffer.limit(frameCount));
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
    _buffer.unlock();
    _buffer.dispose();
  }
}
