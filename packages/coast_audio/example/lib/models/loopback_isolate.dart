import 'dart:async';

import 'package:coast_audio/coast_audio.dart';
import 'package:flutter/foundation.dart';

enum LoopbackHostRequest {
  start,
  stop,
  stats,
}

class LoopbackStatsResponse {
  const LoopbackStatsResponse({
    required this.stability,
  });
  final double stability;
}

class _LoopbackMessage {
  const _LoopbackMessage({
    required this.backend,
    required this.inputDeviceId,
    required this.outputDeviceId,
  });
  final AudioDeviceBackend backend;
  final SerializedAudioDeviceId? inputDeviceId;
  final SerializedAudioDeviceId? outputDeviceId;
}

class LoopbackIsolate {
  LoopbackIsolate();
  final _isolate = AudioIsolate<_LoopbackMessage>(_worker)..onUnhandledError = (e, s) => debugPrint('Unhandled error: $e\n$s');

  bool get isLaunched => _isolate.isLaunched;

  Future<void> launch({
    required AudioDeviceBackend backend,
    required AudioDeviceId? inputDeviceId,
    required AudioDeviceId? outputDeviceId,
  }) async {
    await _isolate.launch(
      initialMessage: _LoopbackMessage(
        backend: backend,
        inputDeviceId: inputDeviceId?.serialize(),
        outputDeviceId: outputDeviceId?.serialize(),
      ),
    );
  }

  Future<void> shutdown() {
    return _isolate.shutdown();
  }

  Future<void> start() {
    return _isolate.request(LoopbackHostRequest.start);
  }

  Future<void> stop() {
    return _isolate.request(LoopbackHostRequest.stop);
  }

  Future<LoopbackStatsResponse> stats() {
    return _isolate.request(LoopbackHostRequest.stats);
  }

  static Future<void> _worker(dynamic initialMessage, AudioIsolateWorkerMessenger messenger) async {
    final message = initialMessage as _LoopbackMessage;
    final context = AudioDeviceContext(backends: [message.backend]);
    const format = AudioFormat(sampleRate: 48000, channels: 2);
    const bufferFrameSize = 2048;

    final capture = CaptureDevice(
      context: context,
      format: format,
      bufferFrameSize: bufferFrameSize,
      deviceId: message.inputDeviceId != null ? AudioDeviceId.deserialize(message.inputDeviceId!) : null,
    );
    final playback = PlaybackDevice(
      context: context,
      format: format,
      bufferFrameSize: bufferFrameSize,
      deviceId: message.outputDeviceId != null ? AudioDeviceId.deserialize(message.outputDeviceId!) : null,
    );

    final clock = AudioIntervalClock(const Duration(milliseconds: 1));
    final bufferFrames = AllocatedAudioFrames(length: 2048, format: format);

    clock.callbacks.add((clock) {
      bufferFrames.acquireBuffer((buffer) {
        final readResult = capture.read(buffer);
        if (!readResult.maResult.isSuccess && readResult.maResult != MaResult.atEnd) {
          clock.stop();
          return;
        }
        playback.write(buffer.limit(readResult.framesRead));
      });
    });

    await messenger.listen<LoopbackHostRequest>(
      (request) {
        switch (request) {
          case LoopbackHostRequest.start:
            capture.start();
            playback.start();
            clock.start();
          case LoopbackHostRequest.stop:
            clock.stop();
            capture.stop();
            playback.stop();
          case LoopbackHostRequest.stats:
            final free = playback.availableWriteFrames / bufferFrameSize;
            return LoopbackStatsResponse(stability: 1 - free);
        }
      },
      onShutdown: () {
        clock.stop();
        capture.stop();
        playback.stop();
        bufferFrames.dispose();
      },
    );
  }
}
