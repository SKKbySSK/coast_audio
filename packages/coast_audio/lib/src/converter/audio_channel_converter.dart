import 'package:coast_audio/coast_audio.dart';

class AudioChannelConverter {
  AudioChannelConverter({required this.inputChannels, required this.outputChannels}) {
    final void Function(AudioFrameBuffer bufferOut, AudioFrameBuffer bufferIn) converter;
    assert((inputChannels == outputChannels) || inputChannels == 1 || outputChannels == 1);
    if (inputChannels == outputChannels) {
      converter = _copy;
    } else if (outputChannels == 1) {
      converter = _mixToMono;
    } else {
      converter = _splitFromMono;
    }
    _converter = converter;
  }

  static bool needsConversion(int channel1, int channel2) => channel1 != channel2;

  final int inputChannels;
  final int outputChannels;

  late final void Function(AudioFrameBuffer bufferOut, AudioFrameBuffer bufferIn) _converter;

  void convert({required AudioFrameBuffer bufferOut, required AudioFrameBuffer bufferIn}) {
    assert(bufferOut.sizeInFrames == bufferIn.sizeInFrames);
    _converter(bufferOut, bufferIn);
  }

  void _mixToMono(AudioFrameBuffer bufferOut, AudioFrameBuffer bufferIn) {
    switch (bufferOut.format.sampleFormat) {
      case SampleFormat.uint8:
        final listIn = bufferIn.asUint8ListViewFrames();
        final listOut = bufferOut.asUint8ListViewFrames();
        double x;
        for (var i = 0; listOut.length > i; i++) {
          x = 0.0;
          for (var ch = 0; inputChannels > ch; ch++) {
            x += listIn[(i * inputChannels) + ch];
          }
          listOut[i] = x ~/ inputChannels;
        }
        break;
      case SampleFormat.int16:
        final listIn = bufferIn.asInt16ListView();
        final listOut = bufferOut.asInt16ListView();
        double x;
        for (var i = 0; listOut.length > i; i++) {
          x = 0.0;
          for (var ch = 0; inputChannels > ch; ch++) {
            x += listIn[(i * inputChannels) + ch];
          }
          listOut[i] = x ~/ inputChannels;
        }
        break;
      case SampleFormat.int32:
      case SampleFormat.float32:
        final listIn = bufferIn.asFloat32ListView();
        final listOut = bufferOut.asFloat32ListView();
        double x;
        for (var i = 0; listOut.length > i; i++) {
          x = 0.0;
          for (var ch = 0; inputChannels > ch; ch++) {
            x += listIn[(i * inputChannels) + ch];
          }
          listOut[i] = x / inputChannels;
        }
        break;
    }
  }

  void _splitFromMono(AudioFrameBuffer bufferOut, AudioFrameBuffer bufferIn) {
    switch (bufferOut.format.sampleFormat) {
      case SampleFormat.uint8:
        final listIn = bufferIn.asUint8ListViewFrames();
        final listOut = bufferOut.asUint8ListViewFrames();
        int x;
        for (var i = 0; listIn.length > i; i++) {
          x = listIn[i];
          for (var ch = 0; outputChannels > ch; ch++) {
            listOut[(i * outputChannels) + ch] = x;
          }
        }
        break;
      case SampleFormat.int16:
        final listIn = bufferIn.asInt16ListView();
        final listOut = bufferOut.asInt16ListView();
        int x;
        for (var i = 0; listIn.length > i; i++) {
          x = listIn[i];
          for (var ch = 0; outputChannels > ch; ch++) {
            listOut[(i * outputChannels) + ch] = x;
          }
        }
        break;
      case SampleFormat.int32:
      case SampleFormat.float32:
        final listIn = bufferIn.asFloat32ListView();
        final listOut = bufferOut.asFloat32ListView();
        double x;
        for (var i = 0; listIn.length > i; i++) {
          x = listIn[i];
          for (var ch = 0; outputChannels > ch; ch++) {
            listOut[(i * outputChannels) + ch] = x;
          }
        }
        break;
    }
  }

  static void _copy(AudioFrameBuffer bufferOut, AudioFrameBuffer bufferIn) {
    bufferIn.copyTo(bufferOut);
  }
}
