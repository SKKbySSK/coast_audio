# Overview

`coast_audio_miniaudio` is an extension package for coast_audio using miniaudio.\
You can use this package to implement audio capture, playback and many other audio capabilities on Android, iOS and macOS.

## Features

- Audio Capture and Playback
  - Supported backends are `Core Audio(iOS/macOS)`, `OpenSL ES(Android)` and `AAudio(Android)`
- Device Enumeration and Selection
- Decoder
  - mp3, flac and wav types are supported

## Setup

This package calls native functions by using ffi.\
To do so, you have to link the `mabridge` library into your application.

Prebuilt binaries are located at [mabridge/prebuilt](https://github.com/SKKbySSK/coast_audio/tree/main/packages/coast_audio_miniaudio/mabridge/prebuilt).

If you are a Flutter user, use the [flutter_coast_audio_miniaudio](https://github.com/SKKbySSK/coast_audio/tree/main/packages/flutter_coast_audio_miniaudio) package which handles this setup step automatically.

## MabDevice

`MabDevice` is an abstract class for interacting audio devices by using `ma_device` and `ma_context` APIs.\
For capturing, use the `MabCaptureDevice` and for playback, use the `MabPlaybackDevice`.

A default audio device will be used if no `device` parameter is specified.

This example plays the loopback audio for 10 seconds.
```dart
MabDeviceContext.enableSharedInstance(
    backends: [
        MabBackend.coreAudio, // Use the Core Audio backend for iOS/macOS
        MabBackend.aaudio, // Use the AAudio backend for Android
    ],
);

const format = AudioFormat(sampleRate: 48000, channels: 2);

final captureDevice = MabCaptureDevice(
    context: MabDeviceContext.sharedInstance, // You should use the same device context on all MabDevice instances.
    format: format,
    bufferFrameSize: 2048, // bufferFrameSize will be used to store the captured data. For low-latency use cases, set this field to smaller size.
);

final playbackDevice = MabPlaybackDevice(
    context: MabDeviceContext.sharedInstance,
    format: format,
    bufferFrameSize: 2048,
);

// Initialize nodes.
final captureNode = MabCaptureDeviceNode(device: captureDevice);
final playbackNode = MabPlaybackDeviceNode(device: playbackDevice);
final graphNode = GraphNode();

// Connect nodes.
graphNode.connect(captureNode.outputBus, playbackNode.inputBus);
graphNode.connectEndpoint(playbackNode.outputBus);

// Start input and output devices.
captureDevice.start();
playbackDevice.start();

final task = AudioTask(
    clock: AudioIntervalClock(const Duration(milliseconds: 16)),
    format: format,
    framesRead: 2048,
    endpoint: graphNode.outputBus,
);

// Start reading audio periodically.
task.start();

// Wait for 10 seconds.
await Future<void>.delayed(const Duration(seconds: 10));

// Dispose all resources.
task.dispose();
captureDevice.dispose();
playbackDevice.dispose();
```

## MabAudioDecoder

`MabAudioDecoder` is a decoder class for decoding mp3, flac and wav data from a file by using `ma_decoder` API.\
This class implements an `AudioDecoder` abstract class so you can use it on the `DecoderNode`.
