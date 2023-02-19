import 'package:dart_audio_graph/dart_audio_graph.dart';

class AudioSampleFormatConverter {
  AudioSampleFormatConverter({
    required this.inputSampleFormat,
    required this.outputSampleFormat,
  }) {
    final void Function(AcquiredFrameBuffer bufferOut, AcquiredFrameBuffer bufferIn) converter;
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
          case SampleFormat.float32:
            converter = _convertInt16ToFloat32;
            break;
        }
        break;
      case SampleFormat.int32:
        switch (outputSampleFormat) {
          case SampleFormat.uint8:
            converter = _convertFloat32ToUint8;
            break;
          case SampleFormat.int16:
            converter = _convertFloat32ToInt16;
            break;
          case SampleFormat.int32:
          case SampleFormat.float32:
            converter = _copy;
            break;
        }
        break;
      case SampleFormat.float32:
        switch (outputSampleFormat) {
          case SampleFormat.uint8:
            converter = _convertFloat32ToUint8;
            break;
          case SampleFormat.int16:
            converter = _convertFloat32ToInt16;
            break;
          case SampleFormat.int32:
          case SampleFormat.float32:
            converter = _copy;
            break;
        }
        break;
    }
    _converter = converter;
  }

  static bool needsConversion(SampleFormat format1, SampleFormat format2) => format1.isCompatible(format2);

  final SampleFormat inputSampleFormat;
  final SampleFormat outputSampleFormat;

  late final void Function(AcquiredFrameBuffer bufferOut, AcquiredFrameBuffer bufferIn) _converter;

  void convert({required AcquiredFrameBuffer bufferOut, required AcquiredFrameBuffer bufferIn}) {
    assert(bufferOut.sizeInFrames == bufferIn.sizeInFrames);
    _converter(bufferOut, bufferIn);
  }

  static void _convertInt16ToFloat32(AcquiredFrameBuffer bufferOut, AcquiredFrameBuffer bufferIn) {
    final listIn = bufferIn.asInt16ListView();
    final listOut = bufferOut.asFloat32ListView();

    for (var i = 0; i < listIn.length; i += 1) {
      listOut[i] = listIn[i] / 32768;
    }
  }

  static void _convertFloat32ToInt16(AcquiredFrameBuffer bufferOut, AcquiredFrameBuffer bufferIn) {
    final listIn = bufferIn.asFloat32ListView();
    final listOut = bufferOut.asInt16ListView();

    for (var i = 0; i < listIn.length; i += 1) {
      listOut[i] = (listIn[i] * 32768).toInt();
    }
  }

  static void _convertUint8ToFloat32(AcquiredFrameBuffer bufferOut, AcquiredFrameBuffer bufferIn) {
    final listIn = bufferIn.asUint8ListView();
    final listOut = bufferOut.asFloat32ListView();

    for (var i = 0; i < listIn.length; i += 1) {
      listOut[i] = (listIn[i] * 0.00784313725490196078) - 1;
    }
  }

  static void _convertFloat32ToUint8(AcquiredFrameBuffer bufferOut, AcquiredFrameBuffer bufferIn) {
    final listIn = bufferIn.asFloat32ListView();
    final listOut = bufferOut.asUint8ListView();

    for (var i = 0; i < listIn.length; i += 1) {
      listOut[i] = ((listIn[i] + 1) * 127.5).toInt();
    }
  }

  static void _convertUint8ToInt16(AcquiredFrameBuffer bufferOut, AcquiredFrameBuffer bufferIn) {
    final listIn = bufferIn.asUint8ListView();
    final listOut = bufferOut.asInt16ListView();

    for (var i = 0; i < listIn.length; i += 1) {
      listOut[i] = ((listIn[i] - 128) << 8).toInt();
    }
  }

  static void _convertInt16ToUint8(AcquiredFrameBuffer bufferOut, AcquiredFrameBuffer bufferIn) {
    final listIn = bufferIn.asUint8ListView();
    final listOut = bufferOut.asInt16ListView();

    for (var i = 0; i < listIn.length; i += 1) {
      listOut[i] = ((listIn[i] >> 8) + 128).toInt();
    }
  }

  static void _copy(AcquiredFrameBuffer bufferOut, AcquiredFrameBuffer bufferIn) {
    bufferIn.copy(bufferOut);
  }
}
