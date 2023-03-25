import 'package:coast_audio/coast_audio.dart';

class AudioSampleFormatConverter {
  AudioSampleFormatConverter({
    required this.inputSampleFormat,
    required this.outputSampleFormat,
  }) {
    final void Function(AudioFrameBuffer bufferOut, AudioFrameBuffer bufferIn) converter;
    switch (inputSampleFormat) {
      case SampleFormat.uint8:
        switch (outputSampleFormat) {
          case SampleFormat.uint8:
            converter = _copy;
            break;
          case SampleFormat.int16:
            converter = _convertUint8ToInt16;
            break;
          case SampleFormat.int32:
            converter = (a, b) {
              _convertUint8ToFloat32(a, b);
              _convertFloat32ToInt(a, b, outputSampleFormat.max);
            };
            break;
          case SampleFormat.float32:
            converter = _convertUint8ToFloat32;
            break;
        }
        break;
      case SampleFormat.int16:
        switch (outputSampleFormat) {
          case SampleFormat.uint8:
            converter = _convertInt16ToUint8;
            break;
          case SampleFormat.int16:
            converter = _copy;
            break;
          case SampleFormat.int32:
            converter = (a, b) {
              _convertIntToFloat32(a, b, inputSampleFormat.max);
              _convertFloat32ToInt(a, b, outputSampleFormat.max);
            };
            break;
          case SampleFormat.float32:
            converter = (a, b) => _convertIntToFloat32(a, b, inputSampleFormat.max);
            break;
        }
        break;
      case SampleFormat.int32:
        switch (outputSampleFormat) {
          case SampleFormat.uint8:
            converter = _convertFloat32ToUint8;
            break;
          case SampleFormat.int16:
            converter = _convertInt32ToInt16;
            break;
          case SampleFormat.int32:
            converter = _copy;
            break;
          case SampleFormat.float32:
            converter = (a, b) => _convertIntToFloat32(a, b, inputSampleFormat.max);
            break;
        }
        break;
      case SampleFormat.float32:
        switch (outputSampleFormat) {
          case SampleFormat.uint8:
            converter = _convertFloat32ToUint8;
            break;
          case SampleFormat.int16:
          case SampleFormat.int32:
            converter = (a, b) => _convertFloat32ToInt(a, b, outputSampleFormat.max);
            break;
          case SampleFormat.float32:
            converter = _copy;
            break;
        }
        break;
    }
    _converter = converter;
  }

  static bool needsConversion(SampleFormat format1, SampleFormat format2) => format1 != format2;

  final SampleFormat inputSampleFormat;
  final SampleFormat outputSampleFormat;

  late final void Function(AudioFrameBuffer bufferOut, AudioFrameBuffer bufferIn) _converter;

  int convert({required AudioFrameBuffer bufferOut, required AudioFrameBuffer bufferIn}) {
    assert(bufferOut.sizeInFrames >= bufferIn.sizeInFrames);
    _converter(bufferOut, bufferIn);
    return bufferOut.sizeInFrames;
  }

  static void _convertIntToFloat32(AudioFrameBuffer bufferOut, AudioFrameBuffer bufferIn, int max) {
    final listIn = bufferIn.asInt16ListView();
    final listOut = bufferOut.asFloat32ListView();

    for (var i = 0; i < listIn.length; i += 1) {
      listOut[i] = listIn[i] / max;
    }
  }

  static void _convertFloat32ToInt(AudioFrameBuffer bufferOut, AudioFrameBuffer bufferIn, int max) {
    final listIn = bufferIn.asFloat32ListView();
    final listOut = bufferOut.asInt16ListView();

    for (var i = 0; i < listIn.length; i += 1) {
      listOut[i] = (listIn[i] * max).toInt();
    }
  }

  static void _convertUint8ToFloat32(AudioFrameBuffer bufferOut, AudioFrameBuffer bufferIn) {
    final listIn = bufferIn.asUint8ListViewFrames();
    final listOut = bufferOut.asFloat32ListView();

    for (var i = 0; i < listIn.length; i += 1) {
      listOut[i] = (listIn[i] * 0.00784313725490196078) - 1;
    }
  }

  static void _convertFloat32ToUint8(AudioFrameBuffer bufferOut, AudioFrameBuffer bufferIn) {
    final listIn = bufferIn.asFloat32ListView();
    final listOut = bufferOut.asUint8ListViewFrames();

    for (var i = 0; i < listIn.length; i += 1) {
      listOut[i] = ((listIn[i] + 1) * 127.5).toInt();
    }
  }

  static void _convertUint8ToInt16(AudioFrameBuffer bufferOut, AudioFrameBuffer bufferIn) {
    final listIn = bufferIn.asUint8ListViewFrames();
    final listOut = bufferOut.asInt16ListView();

    for (var i = 0; i < listIn.length; i += 1) {
      listOut[i] = ((listIn[i] - 128) << 8).toInt();
    }
  }

  static void _convertInt16ToUint8(AudioFrameBuffer bufferOut, AudioFrameBuffer bufferIn) {
    final listIn = bufferIn.asUint8ListViewFrames();
    final listOut = bufferOut.asInt16ListView();

    for (var i = 0; i < listIn.length; i += 1) {
      listOut[i] = ((listIn[i] >> 8) + 128).toInt();
    }
  }

  static void _convertInt32ToInt16(AudioFrameBuffer bufferOut, AudioFrameBuffer bufferIn) {
    final listIn = bufferIn.asInt32ListView();
    final listOut = bufferOut.asInt16ListView();

    double s;
    for (var i = 0; i < listIn.length; i += 1) {
      s = listIn[i] / SampleFormat.int32.max;
      listOut[i] = (s * SampleFormat.int16.max).toInt();
    }
  }

  static void _copy(AudioFrameBuffer bufferOut, AudioFrameBuffer bufferIn) {
    bufferIn.copyTo(bufferOut);
  }
}
