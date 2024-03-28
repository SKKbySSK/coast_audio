import 'dart:typed_data';

/// A converter to convert audio samples from one format to another.
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

/// Convert 24-bit samples to 32-bit samples.
///
/// The result will be multiplied by 256.
class AudioSampleConverterInt24ToInt32 extends AudioSampleConverter {
  const AudioSampleConverterInt24ToInt32() : super(inputBytes: 3, outputBytes: 4);

  @override
  void convertSample(Uint8List inputBuffer, Uint8List outputBuffer, [int inputOffset = 0, int outputOffset = 0]) {
    outputBuffer[outputOffset + 0] = 0;
    outputBuffer[outputOffset + 1] = inputBuffer[inputOffset + 0];
    outputBuffer[outputOffset + 2] = inputBuffer[inputOffset + 1];
    outputBuffer[outputOffset + 3] = inputBuffer[inputOffset + 2];
  }
}
