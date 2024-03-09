import 'dart:async';

import 'package:coast_audio/coast_audio.dart';

enum LoopbackHostRequest {
  start,
  stop,
  stats,
}

class LoopbackStatsResponse {
  const LoopbackStatsResponse({
    required this.inputStability,
    required this.outputStability,
    required this.latency,
  });
  final double inputStability;
  final double outputStability;
  final AudioTime latency;
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
  final _isolate = AudioIsolate<_LoopbackMessage>(_worker);

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

  Future<LoopbackStatsResponse?> stats() {
    return _isolate.request(LoopbackHostRequest.stats);
  }

  static Future<void> _worker(dynamic initialMessage, AudioIsolateWorkerMessenger messenger) async {
    final message = initialMessage as _LoopbackMessage;
    final context = AudioDeviceContext(backends: [message.backend]);
    const format = AudioFormat(sampleRate: 48000, channels: 2, sampleFormat: SampleFormat.int16);
    const bufferFrameSize = 1024;

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

    final clock = AudioIntervalClock(const Duration(milliseconds: 10));
    final bufferFrames = AllocatedAudioFrames(length: bufferFrameSize, format: format);

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
            final inputStability = capture.availableWriteFrames / bufferFrameSize;
            final outputStability = playback.availableReadFrames / bufferFrameSize;
            return LoopbackStatsResponse(
              inputStability: inputStability,
              outputStability: outputStability,
              latency: AudioTime.fromFrames(capture.availableReadFrames + playback.availableReadFrames, format: format),
            );
        }
      },
      onShutdown: (reason, e, stackTrace) {
        clock.stop();
        capture.stop();
        playback.stop();
        bufferFrames.dispose();
      },
    );
  }
}
