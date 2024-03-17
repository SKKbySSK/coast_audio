import 'dart:io';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/experimental.dart';

class _RecorderMessage {
  const _RecorderMessage({
    required this.backend,
    required this.inputDeviceId,
    required this.path,
  });
  final AudioDeviceBackend backend;
  final AudioDeviceId? inputDeviceId;
  final String path;
}

class RecorderIsolate {
  RecorderIsolate();
  final _isolate = AudioIsolate<_RecorderMessage>(_worker);

  bool get isLaunched => _isolate.isLaunched;

  Future<void> start({
    required AudioDeviceBackend backend,
    required AudioDeviceId? inputDeviceId,
    required String path,
  }) async {
    await _isolate.launch(
      initialMessage: _RecorderMessage(
        backend: backend,
        inputDeviceId: inputDeviceId,
        path: path,
      ),
    );
  }

  Future<void> stop() {
    return _isolate.shutdown();
  }

  // The worker function used to initialize the audio player in the isolate
  static Future<void> _worker(dynamic initialMessage, AudioIsolateWorkerMessenger messenger) async {
    AudioResourceManager.isDisposeLogEnabled = true;

    final message = initialMessage as _RecorderMessage;

    const format = AudioFormat(sampleRate: 48000, channels: 2, sampleFormat: SampleFormat.int16);

    final bufferFrameSize = const AudioTime(0.4).computeFrames(format);

    final context = AudioDeviceContext(backends: [message.backend]);
    final device = context.createCaptureDevice(
      format: format,
      bufferFrameSize: bufferFrameSize,
      deviceId: message.inputDeviceId,
    );

    final dataSource = AudioFileDataSource(file: File(message.path), mode: FileMode.write);

    final encoder = WavAudioEncoder(dataSource: dataSource, inputFormat: format);

    final clock = AudioIntervalClock(const Duration(milliseconds: 200));

    final bufferFrames = AllocatedAudioFrames(length: bufferFrameSize, format: format);
    clock.callbacks.add((clock) {
      bufferFrames.acquireBuffer((buffer) {
        final result = device.read(buffer);
        encoder.encode(buffer.limit(result.framesRead));
      });
    });

    encoder.start();
    device.start();
    clock.start();

    await messenger.listenShutdown(
      (reason, e, stackTrace) async {
        device.stop();
        clock.stop();
        encoder.finalize();
      },
    );
  }
}
