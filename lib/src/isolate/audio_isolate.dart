import 'dart:async';
import 'dart:isolate';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/experimental.dart';
import 'package:coast_audio/src/isolate/audio_isolate_worker_message.dart';

Future<void> _audioIsolateRunner<TInitialMessage>(SendPort sendPort, {AudioIsolateWorker? worker}) async {
  final messenger = AudioIsolateWorkerMessenger()..attach(sendPort);
  sendPort.send(AudioIsolateLaunchedResponse(sendPort: messenger.hostToWorkerSendPort));

  final req = (await messenger.message.firstWhere((r) => r is AudioIsolateRunRequest<TInitialMessage>)) as AudioIsolateRunRequest<dynamic>;

  var isShutdownRequested = false;

  Future<void> runWorker() async {
    try {
      await req.worker(req.initialMessage, messenger);
      if (!isShutdownRequested) {
        messenger.onWorkerFinished();
        sendPort.send(const AudioIsolateShutdownResponse(reason: AudioIsolateShutdownReason.workerFinished));
      }
    } catch (e, s) {
      messenger.hostToWorkerSendPort.send(AudioIsolateWorkerFailedResponse(0, e, s));
      sendPort.send(
        AudioIsolateShutdownResponse(
          reason: AudioIsolateShutdownReason.exception,
          exception: e,
          stackTrace: s,
        ),
      );
    }
  }

  Future<void> gracefulStop() async {
    try {
      final request = await messenger.message.firstWhere((r) => r is AudioIsolateShutdownRequest);
      messenger.onShutdownRequested(request as AudioIsolateShutdownRequest);
      isShutdownRequested = true;

      sendPort.send(const AudioIsolateShutdownResponse(reason: AudioIsolateShutdownReason.hostRequested));
    } on StateError {
      return;
    }
  }

  try {
    await Future.wait<void>([
      gracefulStop(),
      runWorker(),
    ]);
  } finally {
    messenger.close();
    AudioResourceManager.disposeAll();
    Isolate.exit();
  }
}

typedef AudioIsolateWorker<TInitialMessage> = FutureOr<void> Function(TInitialMessage? initialMessage, AudioIsolateWorkerMessenger messenger);

class AudioIsolate<TInitialMessage> {
  AudioIsolate(this._worker) {
    _messenger.message.listen(_messengerListener);
  }

  final AudioIsolateWorker<TInitialMessage> _worker;

  var _messenger = AudioIsolateHostMessenger();

  _AudioIsolateSession<TInitialMessage>? _session;

  bool get isLaunched => _session != null;

  Future<AudioIsolateLaunchedResponse> launch({TInitialMessage? initialMessage}) async {
    if (_session != null) {
      throw StateError('AudioIsolate is already running');
    }

    final isolate = await Isolate.spawn(
      _audioIsolateRunner,
      _messenger.workerToHostSendPort,
      paused: true,
    );
    final session = _AudioIsolateSession(initialMessage, isolate);
    _session = session;

    isolate.resume(isolate.pauseCapability!);

    return session.launchCompleter.future;
  }

  Future<AudioIsolateShutdownResponse> attach() {
    final session = _session;
    if (session == null) {
      throw StateError('AudioIsolate is not running');
    }

    return session.lifecycleCompleter.future;
  }

  Future<TResponse?> request<TResponse>(dynamic payload) async {
    if (_session == null) {
      throw StateError('AudioIsolate is not running');
    }

    return _messenger.request(payload);
  }

  Future<AudioIsolateShutdownResponse> shutdown() async {
    final session = _session;
    if (session == null) {
      throw StateError('AudioIsolate is not running');
    }

    _messenger.requestShutdown();
    return session.shutdownCompleter.future;
  }

  void _messengerListener(AudioIsolateWorkerMessage response) async {
    final session = _session;
    if (session == null) {
      throw StateError('Unexpected Audio Isolate State');
    }

    switch (response) {
      case AudioIsolateLaunchedResponse():
        _messenger.attach(response.sendPort);
        response.sendPort.send(
          AudioIsolateRunRequest<TInitialMessage>(
            initialMessage: session.initialMessage,
            worker: _worker,
          ),
        );
        session.launchCompleter.complete(response);
      case AudioIsolateShutdownResponse():
        _session = null;
        _messenger.close();

        _messenger = AudioIsolateHostMessenger();
        _messenger.message.listen(_messengerListener);

        if (response.exception != null && !session.launchCompleter.isCompleted) {
          session.launchCompleter.completeError(response.exception!, response.stackTrace!);
        }

        if (response.exception == null) {
          session.lifecycleCompleter.complete(response);
        } else {
          session.lifecycleCompleter.completeError(response.exception!, response.stackTrace!);
        }

        session.shutdownCompleter.complete(response);
      case AudioIsolateWorkerResponse():
        break;
    }
  }
}

class _AudioIsolateSession<TInitialMessage> {
  _AudioIsolateSession(this.initialMessage, this.isolate);
  final TInitialMessage? initialMessage;
  final Isolate isolate;
  final Completer<AudioIsolateLaunchedResponse> launchCompleter = Completer();
  final Completer<AudioIsolateShutdownResponse> lifecycleCompleter = Completer();
  final Completer<AudioIsolateShutdownResponse> shutdownCompleter = Completer();
}
