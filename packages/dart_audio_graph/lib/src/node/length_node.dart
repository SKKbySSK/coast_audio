import 'dart:math';

import '../../dart_audio_graph.dart';

class LengthNode extends PassthroughNode {
  LengthNode({
    required AudioFormat format,
    this.maxFrameCount,
  }) : super(format);

  int _framesRead = 0;

  int get framesRead => _framesRead;

  int? maxFrameCount;

  AudioTime get time => AudioTime.fromFrames(frames: _framesRead, format: currentInputFormat!);

  AudioTime? get maxTime => maxFrameCount == null ? null : AudioTime.fromFrames(frames: maxFrameCount!, format: currentInputFormat!);

  set maxTime(AudioTime? time) {
    if (time == null) {
      maxFrameCount = null;
      return;
    }

    final maxBytes = (time.seconds * currentInputFormat!.sampleRate * currentInputFormat!.channels).toInt();
    maxFrameCount = maxBytes ~/ currentInputFormat!.bytesPerFrame;
  }

  @override
  int read(AudioOutputBus outputBus, FrameBuffer buffer) {
    final maxFrameCount = this.maxFrameCount;
    final int framesRead;
    if (maxFrameCount == null) {
      framesRead = super.read(outputBus, buffer);
    } else {
      final frames = max(min(maxFrameCount - _framesRead, buffer.sizeInFrames), 0);
      framesRead = super.read(outputBus, buffer.limit(frames));
    }

    _framesRead += framesRead;
    return framesRead;
  }
}
