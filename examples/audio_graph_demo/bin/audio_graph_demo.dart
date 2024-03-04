import 'dart:io';

import 'package:coast_audio/coast_audio.dart';

void main() {
  const format = AudioFormat(sampleRate: 48000, channels: 2, sampleFormat: SampleFormat.int16);
  final wavFile = File('test.wav');
  _runMixingDemo(format, wavFile);
}

void _runMixingDemo(AudioFormat format, File file) {
  final endpoint = _buildAudioNodeGraph(format);

  // Allocate 10 seconds audio buffer.
  final frames = AllocatedAudioFrames(
    length: format.sampleRate * 10,
    format: format,
  );

  final dataSource = AudioFileDataSource(
    file: file,
    mode: FileMode.write,
  );

  // Acquire the raw audio buffer from AllocatedAudioFrames
  frames.acquireBuffer((buffer) {
    final readResult = endpoint.read(buffer);
    final readBuffer = buffer.limit(readResult.frameCount);

    final encoder = WavAudioEncoder(dataSource: dataSource, inputFormat: format);
    encoder.start();
    encoder.encode(readBuffer); // Encode the buffer and write to an output data source
    encoder.finalize();
  });

  dataSource.dispose();
}

AudioOutputBus _buildAudioNodeGraph(AudioFormat format) {
  final mixerNode = MixerNode(format: format);
  final masterVolumeNode = VolumeNode(volume: 0.8);

  final freqs = <double>[264, 330, 396];

  // Initialize sine wave nodes and connect them to mixer's input
  for (final freq in freqs) {
    final sineNode = FunctionNode(function: const SineFunction(), format: format, frequency: freq);
    final sineVolumeNode = VolumeNode(volume: 0.2);

    sineNode.outputBus.connect(sineVolumeNode.inputBus);
    sineVolumeNode.outputBus.connect(mixerNode.appendInputBus());
  }

  // Connect the mixer node's output bus to master volume's input bus
  mixerNode.outputBus.connect(masterVolumeNode.inputBus);

  return masterVolumeNode.outputBus;
}
