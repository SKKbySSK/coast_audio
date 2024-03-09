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
  var _isListening = false;

  AudioIsolateShutdownRequest? _shutdownRequest;

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
    _shutdownRequest = request;
  }

  Future<void> listen<TRequestPayload>(
    FutureOr<dynamic> Function(TRequestPayload) requestHandler, {
    FutureOr<void> Function(AudioIsolateShutdownReason reason, Object? e, StackTrace? stackTrace)? onShutdown,
  }) async {
    final sendPort = _sendPort;
    if (sendPort == null) {
      throw StateError('Messenger is not attached to an host');
    }

    if (_isListening) {
      throw StateError('Messenger is already listening');
    }

    _isListening = true;

    Object? exception;
    StackTrace? stackTrace;

    await _requestStream.forEach(
      (request) async {
        try {
          final response = await requestHandler(request.payload as TRequestPayload);
          sendPort.send(AudioIsolateWorkerSuccessResponse(request.id, response));
        } catch (e, stack) {
          sendPort.send(AudioIsolateWorkerFailedResponse(request.id, e, stack));
          exception = e;
          stackTrace = stack;
        }
      },
    );

    if (exception != null) {
      await onShutdown?.call(AudioIsolateShutdownReason.exception, exception, stackTrace);
    } else if (_shutdownRequest != null) {
      await onShutdown?.call(AudioIsolateShutdownReason.hostRequested, null, null);
    } else {
      await onShutdown?.call(AudioIsolateShutdownReason.workerFinished, null, null);
    }
  }

  void close() {
    detach();
    _receivePort.close();
  }
}
