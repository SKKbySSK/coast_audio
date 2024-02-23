import 'package:coast_audio/src/isolate/audio_isolate.dart';

sealed class AudioIsolateHostMessage {
  const AudioIsolateHostMessage();
}

class AudioIsolateHostRequest<TPayload> extends AudioIsolateHostMessage {
  static var _id = 0;

  static int _getId() {
    return _id++;
  }

  AudioIsolateHostRequest(this.payload) : id = _getId();
  final int id;
  final TPayload payload;
}

class AudioIsolateRunRequest<TInitialMessage> extends AudioIsolateHostMessage {
  const AudioIsolateRunRequest({
    required this.initialMessage,
    required this.worker,
  });
  final TInitialMessage? initialMessage;
  final AudioIsolateWorker<TInitialMessage> worker;
}

class AudioIsolateShutdownRequest extends AudioIsolateHostMessage {
  const AudioIsolateShutdownRequest();
}
