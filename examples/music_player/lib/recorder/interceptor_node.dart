import 'dart:math';

import 'package:flutter_coast_audio_miniaudio/flutter_coast_audio_miniaudio.dart';

class InterceptorNode extends AutoFormatSingleInoutNode with ProcessorNodeMixin, SyncDisposableNodeMixin {
  InterceptorNode({
    required this.frames,
    required this.format,
    required this.onRead,
  });
  final int frames;
  final AudioFormat format;
  void Function(AudioBuffer buffer)? onRead;

  late final _cbBuffer = AllocatedAudioFrames(length: frames, format: format);
  var _offset = 0;

  @override
  int process(AudioBuffer buffer) {
    var availableBuffer = buffer;
    _cbBuffer.acquireBuffer((cbBuffer) {
      while (availableBuffer.sizeInFrames > 0) {
        final offsetCbBuffer = cbBuffer.offset(_offset);
        final readCount = min(availableBuffer.sizeInFrames, offsetCbBuffer.sizeInFrames);
        availableBuffer.copyTo(offsetCbBuffer, frames: readCount);
        availableBuffer = availableBuffer.offset(readCount);
        _offset += readCount;

        if (_offset == frames) {
          onRead?.call(cbBuffer);
          _offset = 0;
        }
      }
    });

    return buffer.sizeInFrames;
  }

  var _isDisposed = false;
  @override
  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    if (isDisposed) {
      return;
    }
    _isDisposed = true;
    _cbBuffer.dispose();
  }
}
