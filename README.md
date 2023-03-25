# Overview

![logo_banner.png](resources/logo_banner.png)

`coast_audio` is a high performance audio processing library written in dart.\
This repository contains four packages.

## [coast_audio](https://github.com/SKKbySSK/coast_audio/tree/main/packages/coast_audio)
- A core implementations for audio processing on Dart.
- Contains node graph system, audio buffer management, codec, etc.
- Does not include any playback or capture capabilities.

## [coast_audio_miniaudio](https://github.com/SKKbySSK/coast_audio/tree/main/packages/coast_audio_miniaudio)
- An extension package to add many audio capabilities by using [miniaudio](https://github.com/mackron/miniaudio).
- Use this package if you want to play or capture the audio.
- You have to link with the `mabridge` library in your app. (See the [setup](https://github.com/SKKbySSK/coast_audio/tree/main/packages/coast_audio_miniaudio#setup) section for more details.)
  - If you are a Flutter user, use the [flutter_coast_audio_miniaudio](https://github.com/SKKbySSK/coast_audio/tree/main/packages/flutter_coast_audio_miniaudio) package for convenience.

### [flutter_coast_audio_miniaudio](https://github.com/SKKbySSK/coast_audio/tree/main/packages/flutter_coast_audio_miniaudio)
- A convenient package which handles `mabridge` linking automatically.

## [coast_audio_fft](https://github.com/SKKbySSK/coast_audio/tree/main/packages/coast_audio_fft)
- An extension package to run FFT spectrum analysis.
