# Overview

`dart_audio_graph` is a high performance audio processing library written in dart.\
This repository contains three packages.

- [dart_audio_graph](https://github.com/SKKbySSK/dart_audio_graph/tree/main/packages/dart_audio_graph)
  - core implementations of dart_audio_graph
  - does not include playback or capture capabilities
    - add the `dart_audio_graph_miniaudio` package if you want it
- [dart_audio_graph_miniaudio](https://github.com/SKKbySSK/dart_audio_graph/tree/main/packages/dart_audio_graph_miniaudio)
  - an extension package to add many audio capabilities using [miniaudio](https://github.com/mackron/miniaudio)
  - use this package if you want to playback or capture on the device
- [dart_audio_graph_fft](https://github.com/SKKbySSK/dart_audio_graph/tree/main/packages/dart_audio_graph_fft)
  - an extension package to add FFT spectrum analysis
