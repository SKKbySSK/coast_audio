import 'dart:async';
import 'dart:isolate';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/src/isolate/audio_isolate_worker_message.dart';

Future<void> _audioIsolateRunner<TInitialMessage>(SendPort sendPort, {AudioIsolateWorker? worker}) async {
  final messenger = AudioIsolateWorkerMessenger()..attach(sendPort);
  sendPort.send(AudioIsolateLaunchedResponse(sendPort: messenger.hostToWorkerSendPort));

  final req = (await messenger.message.firstWhere((r) => r is AudioIsolateRunRequest<TInitialMessage>)) as AudioIsolateRunRequest<dynamic>;

  Future<void> runWorker() async {
    try {
      await req.worker(req.initialMessage, messenger);
      sendPort.send(const AudioIsolateShutdownResponse());
    } catch (e, s) {
      messenger.hostToWorkerSendPort.send(AudioIsolateWorkerFailedResponse(0, e, s));
      sendPort.send(AudioIsolateShutdownResponse(exception: e, stackTrace: s));
    }
  }

  Future<void> gracefulStop() async {
    await messenger.message.firstWhere((r) => r is AudioIsolateShutdownRequest);
    messenger.close();
  }

  await Future.wait<void>([
    gracefulStop(),
    runWorker(),
  ]);
}

typedef AudioIsolateWorker<TInitialMessage> = FutureOr<void> Function(TInitialMessage? initialMessage, AudioIsolateWorkerMessenger messenger);

class AudioIsolate<TInitialMessage> {
  AudioIsolate(this._worker) {
    _messenger.message.listen((message) async {
      switch (message) {
        case AudioIsolateLaunchedResponse():
          _messenger.attach(message.sendPort);
          message.sendPort.send(
            AudioIsolateRunRequest<TInitialMessage>(
              initialMessage: _initialMessage,
              worker: _worker,
            ),
          );
          _launchCompleter?.complete();
          _launchCompleter = null;
          _initialMessage = null;
        case AudioIsolateShutdownResponse():
          if (message.exception != null) {
            _launchCompleter?.completeError(message.exception!, message.stackTrace);
            _launchCompleter = null;
            _initialMessage = null;
          }
          _isolate?.kill();
          _isolate = null;
          _messenger = AudioIsolateHostMessenger();
          _shutdownCompleter?.complete();
          _shutdownCompleter = null;
        case AudioIsolateWorkerResponse():
          break;
      }
    });
  }

  final AudioIsolateWorker<TInitialMessage> _worker;

  var _messenger = AudioIsolateHostMessenger();

  TInitialMessage? _initialMessage;
  Completer<void>? _launchCompleter;
  Completer<void>? _shutdownCompleter;
  Isolate? _isolate;

  bool get isLaunched => _isolate != null && _shutdownCompleter == null && _launchCompleter == null;

  Future<void> launch({TInitialMessage? initialMessage}) async {
    if (_launchCompleter != null) {
      throw StateError('AudioIsolate is already running');
    }

    final completer = Completer();
    _launchCompleter = completer;
    _initialMessage = initialMessage;

    final isolate = await Isolate.spawn(_audioIsolateRunner, _messenger.workerToHostSendPort);
    await completer.future;
    _isolate = isolate;
  }

  Future<TResponse> request<TResponse>(dynamic payload) async {
    if (_isolate == null) {
      throw StateError('AudioIsolate is not running');
    }

    if (_shutdownCompleter != null) {
      throw StateError('AudioIsolate is shutting down');
    }

    return _messenger.request(payload);
  }

  Future<void> shutdown() async {
    if (_shutdownCompleter != null) {
      return _shutdownCompleter!.future;
    }

    final completer = Completer();
    _shutdownCompleter = completer;

    _messenger.close();
    await completer.future;
  }
}
