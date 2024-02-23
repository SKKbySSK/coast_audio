import 'dart:async';
import 'dart:isolate';

import 'package:coast_audio/src/isolate/audio_isolate_host_message.dart';
import 'package:coast_audio/src/isolate/audio_isolate_worker_message.dart';

class AudioIsolateException implements Exception {
  AudioIsolateException(this.exception, this.stack);
  final Object exception;
  final StackTrace stack;
}

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

  Future<TResponse> request<TRequest, TResponse>(TRequest payload) async {
    final sendPort = _sendPort;
    if (sendPort == null) {
      throw StateError('Messenger is not attached to an worker');
    }

    final request = AudioIsolateHostRequest(payload);
    final responseFuture = message.firstWhere((r) => r is AudioIsolateWorkerResponse && r.requestId == request.id);
    sendPort.send(request);

    final response = (await responseFuture) as AudioIsolateWorkerResponse;
    switch (response) {
      case AudioIsolateWorkerSuccessResponse():
        if (response.payload is TResponse) {
          return response.payload as TResponse;
        } else {
          throw StateError('Unexpected response type: ${response.payload.runtimeType}');
        }
      case AudioIsolateWorkerFailedResponse():
        throw AudioIsolateException(response.exception, response.stackTrace);
    }
  }

  void close() {
    _sendPort?.send(const AudioIsolateShutdownRequest());
    detach();
    _receivePort.close();
  }
}

class AudioIsolateWorkerMessenger {
  AudioIsolateWorkerMessenger();
  final _receivePort = ReceivePort();
  SendPort? _sendPort;
  var _isListening = false;

  SendPort get hostToWorkerSendPort => _receivePort.sendPort;

  late final message = _receivePort.where((r) => r is AudioIsolateHostMessage).cast<AudioIsolateHostMessage>().asBroadcastStream();

  late final _requestStream = message.where((r) => r is AudioIsolateHostRequest).cast<AudioIsolateHostRequest>().asBroadcastStream();

  void attach(SendPort sendPort) {
    _sendPort = sendPort;
  }

  void detach() {
    _sendPort = null;
  }

  Future<void> listen<TRequestPayload>(FutureOr<dynamic> Function(TRequestPayload) requestHandler, {FutureOr<void> Function()? onShutdown}) async {
    final sendPort = _sendPort;
    if (sendPort == null) {
      throw StateError('Messenger is not attached to an host');
    }

    if (_isListening) {
      throw StateError('Messenger is already listening');
    }

    _isListening = true;

    await _requestStream.forEach((request) async {
      try {
        final response = await requestHandler(request.payload as TRequestPayload);
        sendPort.send(AudioIsolateWorkerSuccessResponse(request.id, response));
      } catch (e, stack) {
        sendPort.send(AudioIsolateWorkerFailedResponse(request.id, e, stack));
      }
    });
    await onShutdown?.call();
  }

  void close() {
    detach();
    _receivePort.close();
  }
}
