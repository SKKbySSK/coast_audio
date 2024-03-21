import 'dart:async';
import 'dart:core';
import 'dart:isolate';

import 'package:coast_audio/src/isolate/audio_isolate_host_message.dart';
import 'package:coast_audio/src/isolate/audio_isolate_worker_message.dart';

class AudioIsolateHostMessenger {
  final _receivePort = ReceivePort();
  SendPort? _sendPort;

  SendPort get workerToHostSendPort => _receivePort.sendPort;

  late final message = _receivePort.where((r) => r is AudioIsolateWorkerMessage).cast<AudioIsolateWorkerMessage>().asBroadcastStream();

  void attach(SendPort sendPort) {
    _sendPort = sendPort;
  }

  void detach() {
    _sendPort = null;
  }

  Future<TResponse?> request<TRequest, TResponse>(TRequest payload) async {
    final sendPort = _sendPort;
    if (sendPort == null) {
      throw StateError('Messenger is not attached to an worker');
    }

    final request = AudioIsolateHostRequest(payload);
    final responseFuture = message.firstWhere((r) => r is AudioIsolateWorkerResponse && r.requestId == request.id);
    sendPort.send(request);

    final AudioIsolateWorkerResponse response;
    try {
      response = await responseFuture as AudioIsolateWorkerResponse;
    } on StateError {
      return null;
    }

    switch (response) {
      case AudioIsolateWorkerSuccessResponse():
        if (response.payload is TResponse) {
          return response.payload as TResponse;
        } else {
          throw StateError('Unexpected response type: ${response.payload.runtimeType}');
        }
      case AudioIsolateWorkerFailedResponse():
        return Future.error(response.exception, response.stackTrace);
    }
  }

  void requestShutdown() {
    final sendPort = _sendPort;
    if (sendPort == null) {
      throw StateError('Messenger is not attached to an worker');
    }

    sendPort.send(const AudioIsolateShutdownRequest());
  }

  void close() {
    detach();
    _receivePort.close();
  }
}

class AudioIsolateWorkerMessenger {
  AudioIsolateWorkerMessenger();
  final _receivePort = ReceivePort();
  SendPort? _sendPort;

  final _shutdownCompleter = Completer<AudioIsolateShutdownRequest?>();

  StreamSubscription<AudioIsolateHostRequest>? _requestSubscription;

  SendPort get hostToWorkerSendPort => _receivePort.sendPort;

  late final message = _receivePort.where((r) => r is AudioIsolateHostMessage).cast<AudioIsolateHostMessage>().asBroadcastStream();

  late final _requestStream = message.where((r) => r is AudioIsolateHostRequest).cast<AudioIsolateHostRequest>().asBroadcastStream();

  void attach(SendPort sendPort) {
    _sendPort = sendPort;
  }

  void detach() {
    _sendPort = null;
  }

  void onShutdownRequested(AudioIsolateShutdownRequest request) {
    _shutdownCompleter.complete(request);
  }

  Future<void> listen<TRequestPayload>(
    FutureOr<dynamic> Function(TRequestPayload) requestHandler, {
    FutureOr<void> Function(AudioIsolateShutdownReason reason, Object? e, StackTrace? stackTrace)? onShutdown,
  }) async {
    final sendPort = _sendPort;
    if (sendPort == null) {
      throw StateError('Messenger is not attached to an host');
    }

    if (_requestSubscription != null) {
      throw StateError('Messenger is already listening');
    }

    _requestSubscription = _requestStream.listen((request) async {
      try {
        final response = await requestHandler(request.payload as TRequestPayload);
        sendPort.send(AudioIsolateWorkerSuccessResponse(request.id, response));
      } catch (e, stack) {
        sendPort.send(AudioIsolateWorkerFailedResponse(request.id, e, stack));
        _shutdownCompleter.completeError(e, stack);
      }
    });

    try {
      final req = await _shutdownCompleter.future;
      if (req != null) {
        await onShutdown?.call(AudioIsolateShutdownReason.hostRequested, null, null);
      } else {
        await onShutdown?.call(AudioIsolateShutdownReason.workerFinished, null, null);
      }
    } catch (e, stack) {
      await onShutdown?.call(AudioIsolateShutdownReason.exception, e, stack);
    } finally {
      await _requestSubscription?.cancel();
      _requestSubscription = null;
    }
  }

  void close() {
    detach();
    _receivePort.close();
  }
}
