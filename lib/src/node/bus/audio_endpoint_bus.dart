import 'package:coast_audio/coast_audio.dart';

/// An audio endpoint bus that cannot be connected to any input bus.
class AudioEndpointBus extends AudioOutputBus {
  AudioEndpointBus({required super.node, required super.formatResolver});

  @override
  void connect(AudioInputBus inputBus) {
    throw AudioEndpointBusConnectionError();
  }

  @override
  bool canConnect(AudioInputBus inputBus) {
    return false;
  }
}

class AudioEndpointBusConnectionError extends Error {
  AudioEndpointBusConnectionError();

  @override
  String toString() {
    return 'AudioEndpointBus cannot be connected to any input bus';
  }
}
