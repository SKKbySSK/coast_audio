# Overview

`dart_audio_graph_miniaudio` is an extension package for dart_audio_graph using miniaudio.\
You can use this package to implement cross-platform audio capture, playback and so on.

## Setup

This package calls native functions by using ffi.\
To do so, you have to link the `mabridge` library into your application.

Prebuilt binaries are located at [mabridge/prebuilt](https://github.com/SKKbySSK/dart_audio_graph/tree/main/packages/dart_audio_graph_miniaudio/mabridge/prebuilt).\

## MabDevice

`MabDevice` is an abstract class for interacting audio devices.\
For capturing, use the `MabDeviceInput` and for playback, use the `MabDeviceOutput`.

A default audio device will be used if no `MabDeviceId` is specified.

This example plays the loopback audio for 10 seconds.
```dart
MabDeviceContext.enableSharedInstance(
  backends: [
    MabBackend.coreAudio, // Core Audio for iOS/macOS
    MabBackend.openSl, // OpenSL ES for Android
  ],
);

final format = AudioFormat(sampleRate: 48000, channels: 2);

final inputDevice = MabDeviceInput(
  context: MabDeviceContext.sharedInstance, // You need to use same device context on all MabDevice instances.
  format: format,
  bufferFrameSize: 2048, // bufferFrameSize will be used to store the captured data. For low-latency use cases, set this field to smaller size.
);

final outputDevice = MabDeviceOutput(
  context: MabDeviceContext.sharedInstance,
  format: format,
  bufferFrameSize: 2048,
);

// Initialize nodes.
final inputNode = MabDeviceInputNode(device: inputDevice);
final outputNode = MabDeviceOutputNode(device: outputDevice);
final graphNode = GraphNode();

// Connect nodes.
graphNode.connect(inputNode.outputBus, outputNode.inputBus);
graphNode.connectEndpoint(outputNode.outputBus);

// Start input and output devices.
inputDevice.start();
outputDevice.start();

final runner = AudioOutput.latency(
  outputBus: graphNode.outputBus,
  format: format,
  latency: const Duration(milliseconds: 20),
);

// Start reading audio periodically.
runner.start();

// Wait for 10 seconds.
await Future.delayed<void>(const Duration(seconds: 10));

// Dispose all resources.
runner.dispose();
inputDevice.dispose();
outputDevice.dispose();
```
