import 'dart:typed_data';

/// convert a sample from one format to another.
///
/// NOTE: This class is in early development and may change in the future.
abstract class AudioSampleConverter {
  const AudioSampleConverter({
    required this.inputBytes,
    required this.outputBytes,
  });

  /// The number of bytes per input sample.
  final int inputBytes;

  /// The number of bytes per output sample.
  final int outputBytes;

  /// Converts a single sample from [inputBuffer] and writes the result to [outputBuffer].
  void convertSample(Uint8List inputBuffer, Uint8List outputBuffer, [int inputOffset = 0, int outputOffset = 0]);

  /// Converts all samples from [inputBuffer] and writes the result to [outputBuffer].
  void convertSamples(Uint8List inputBuffer, Uint8List outputBuffer, [int inputOffset = 0, int outputOffset = 0]) {
    final sampleCount = inputBuffer.length ~/ inputBytes;
    for (var i = 0; sampleCount > i; i++) {
      convertSample(inputBuffer, outputBuffer, inputOffset, outputOffset);
      outputOffset += outputBytes;
      inputOffset += inputBytes;
    }
  }
}

/// An audio resampler to convert 24-bit samples to 32-bit samples.
class AudioSampleConverterInt24ToInt32 extends AudioSampleConverter {
  AudioSampleConverterInt24ToInt32() : super(inputBytes: 3, outputBytes: 4);

  @override
  void convertSample(Uint8List inputBuffer, Uint8List outputBuffer, [int inputOffset = 0, int outputOffset = 0]) {
    outputBuffer[outputOffset + 0] = inputBuffer[inputOffset + 0];
    outputBuffer[outputOffset + 1] = inputBuffer[inputOffset + 1];
    outputBuffer[outputOffset + 2] = inputBuffer[inputOffset + 2];
    outputBuffer[outputOffset + 3] = (inputBuffer[inputOffset + 2] & 0x80 >> 7) == 1 ? 0xFF : 0x00; // maintain sign bit
  }
}
