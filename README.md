# Overview

![demo.git](resources/demo.gif)

`dart_audio_graph` is a high performance audio processing library written in dart.\
This repository contains four packages.

## [dart_audio_graph](https://github.com/SKKbySSK/dart_audio_graph/tree/main/packages/dart_audio_graph)
- A core implementations for audio processing on Dart.
- Contains node graph system, audio buffer management, codec, etc.
- Does not include any playback or capture capabilities.

## [dart_audio_graph_miniaudio](https://github.com/SKKbySSK/dart_audio_graph/tree/main/packages/dart_audio_graph_miniaudio)
- An extension package to add many audio capabilities by using [miniaudio](https://github.com/mackron/miniaudio).
- Use this package if you want to play or capture the audio.
- You have to link with the `mabridge` library in your app. (See the [Setup](https://github.com/SKKbySSK/dart_audio_graph/tree/main/packages/dart_audio_graph_miniaudio#setup) section for more details.)
  - If you are a Flutter user, use the [flutter_audio_graph_miniaudio](https://github.com/SKKbySSK/dart_audio_graph/tree/main/packages/flutter_audio_graph_miniaudio) package for convenience.

### [flutter_audio_graph_miniaudio](https://github.com/SKKbySSK/dart_audio_graph/tree/main/packages/flutter_audio_graph_miniaudio)
- A convenient package which handles `mabridge` linking automatically.

## [dart_audio_graph_fft](https://github.com/SKKbySSK/dart_audio_graph/tree/main/packages/dart_audio_graph_fft)
- An extension package to run FFT spectrum analysis.
