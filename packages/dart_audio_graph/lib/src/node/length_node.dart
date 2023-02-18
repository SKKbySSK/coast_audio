import 'dart:math';

import '../../dart_audio_graph.dart';

class LengthNode extends FixedFormatSingleInoutNode {
  LengthNode({
    this.maxFrameCount,
    required AudioFormat format,
  }) : super(format);

  int _framesRead = 0;

  int get framesRead => _framesRead;

  int? maxFrameCount;

  AudioTime get time => AudioTime.fromFrames(frames: _framesRead, format: format);

  AudioTime? get maxTime => maxFrameCount == null ? null : AudioTime.fromFrames(frames: maxFrameCount!, format: format);

  set maxTime(AudioTime? time) {
    if (time == null) {
      maxFrameCount = null;
      return;
    }

    final maxBytes = (time.seconds * format.sampleRate * format.channels).toInt();
    maxFrameCount = maxBytes ~/ format.bytesPerFrame;
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
