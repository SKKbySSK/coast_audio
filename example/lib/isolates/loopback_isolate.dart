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

/// A loopback isolate that captures audio from an input device and plays it back to an output device.
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

  /// The worker function that runs in the isolate.
  static Future<void> _worker(dynamic initialMessage, AudioIsolateWorkerMessenger messenger) async {
    AudioResourceManager.isDisposeLogEnabled = true;

    final message = initialMessage as _LoopbackMessage;
    final context = AudioDeviceContext(backends: [message.backend]);
    const format = AudioFormat(sampleRate: 48000, channels: 2, sampleFormat: SampleFormat.int16);
    const bufferFrameSize = 1024;

    // Prepare the capture and playback devices.
    final capture = CaptureNode(
      device: context.createCaptureDevice(
        format: format,
        bufferFrameSize: bufferFrameSize,
        deviceId: message.inputDeviceId,
      ),
    );
    final playback = PlaybackNode(
      device: context.createPlaybackDevice(
        format: format,
        bufferFrameSize: bufferFrameSize,
        deviceId: message.outputDeviceId,
      ),
    );

    capture.outputBus.connect(playback.inputBus);

    // Prepare the audio clock with a tick interval of 10ms.
    final clock = AudioIntervalClock(const AudioTime(10 / 1000));
    final bufferFrames = AllocatedAudioFrames(length: bufferFrameSize, format: format);

    messenger.listenRequest<LoopbackHostRequest>(
      (request) async {
        switch (request) {
          case LoopbackHostRequest.start:
            // Start the audio devices and the clock.
            capture.device.start();
            await Future<void>.delayed(const Duration(milliseconds: 100));
            playback.device.start();

            // Start the clock and read from the capture device and write to the playback device every tick(10ms).
            clock.start(onTick: (_) {
              bufferFrames.acquireBuffer((buffer) => playback.outputBus.read(buffer));
            });
          case LoopbackHostRequest.stop:
            clock.stop();
            capture.device.stop();
            playback.device.stop();
          case LoopbackHostRequest.stats:
            final inputStability = capture.device.availableWriteFrames / bufferFrameSize;
            final outputStability = playback.device.availableReadFrames / bufferFrameSize;
            return LoopbackStatsResponse(
              inputStability: inputStability,
              outputStability: outputStability,
              latency: AudioTime.fromFrames(capture.device.availableReadFrames + playback.device.availableReadFrames, format: format),
            );
        }
      },
    );

    await messenger.listenShutdown(
      onShutdown: (reason, e, stackTrace) async {
        clock.stop();
      },
    );
  }
}
