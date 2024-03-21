import 'dart:async';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/experimental.dart';

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
  final AudioDeviceId? inputDeviceId;
  final AudioDeviceId? outputDeviceId;
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
        inputDeviceId: inputDeviceId,
        outputDeviceId: outputDeviceId,
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
    AudioResourceManager.isDisposeLogEnabled = true;

    final message = initialMessage as _LoopbackMessage;
    final context = AudioDeviceContext(backends: [message.backend]);
    const format = AudioFormat(sampleRate: 48000, channels: 2, sampleFormat: SampleFormat.int16);
    const bufferFrameSize = 1024;

    final capture = context.createCaptureDevice(
      format: format,
      bufferFrameSize: bufferFrameSize,
      deviceId: message.inputDeviceId,
    );
    final playback = context.createPlaybackDevice(
      format: format,
      bufferFrameSize: bufferFrameSize,
      deviceId: message.outputDeviceId,
    );

    final clock = AudioIntervalClock(const AudioTime(10 / 1000));
    final bufferFrames = AllocatedAudioFrames(length: bufferFrameSize, format: format);

    messenger.listenRequest<LoopbackHostRequest>(
      (request) async {
        switch (request) {
          case LoopbackHostRequest.start:
            capture.start();
            await Future<void>.delayed(const Duration(milliseconds: 100));
            playback.start();
            clock.start(onTick: (_) {
              bufferFrames.acquireBuffer((buffer) {
                final readResult = capture.read(buffer);
                if (!readResult.maResult.isSuccess && readResult.maResult != MaResult.atEnd) {
                  clock.stop();
                  return;
                }
                playback.write(buffer.limit(readResult.framesRead));
              });
            });
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
    );

    await messenger.listenShutdown(
      (reason, e, stackTrace) async {
        clock.stop();
      },
    );
  }
}
