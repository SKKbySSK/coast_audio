import 'dart:io';

import 'package:dart_audio_graph/dart_audio_graph.dart';

void main() {
  final wavFile = File('test.wav');
  _runMixingDemo(wavFile);
}

void _runMixingDemo(File file) {
  final sourceFormat = AudioFormat(sampleRate: 48000, channels: 2, sampleFormat: SampleFormat.float32);
  final outputFormat = sourceFormat.copyWith(sampleFormat: SampleFormat.int16);
  final graphNode = GraphNode();
  final mixerNode = MixerNode(format: sourceFormat);
  final masterVolumeNode = VolumeNode(volume: 0.8);

  final freqs = <double>[264, 330, 396];

  // Initialize sine wave node and connect to mixer input #1
  for (final freq in freqs) {
    final sineNode = FunctionNode(function: const SineFunction(), format: sourceFormat, frequency: freq);
    final sineVolumeNode = VolumeNode(volume: 0.2);

    graphNode.connect(sineNode.outputBus, sineVolumeNode.inputBus);
    graphNode.connect(sineVolumeNode.outputBus, mixerNode.appendInputBus());
  }

  // Connect the mixer node's output to master volume's input
  graphNode.connect(mixerNode.outputBus, masterVolumeNode.inputBus);

  // Connect master volume to graph node's endpoint
  final converterNode = ConverterNode(converter: AudioFormatConverter(inputFormat: sourceFormat, outputFormat: outputFormat));
  graphNode.connect(masterVolumeNode.outputBus, converterNode.inputBus);
  graphNode.connectEndpoint(converterNode.outputBus);

  // Allocate buffers for 10 seconds.
  final buffer = AllocatedFrameBuffer(frames: outputFormat.sampleRate * 10, format: outputFormat);

  // Read the output data to the buffer.
  buffer.acquireBuffer((rawBuffer) {
    final framesRead = graphNode.outputBus.read(rawBuffer);
    final readBuffer = rawBuffer.limit(framesRead);

    final dataSource = AudioFileDataSource(file: file, mode: FileMode.write);
    final encoder = WavAudioEncoder(dataSource: dataSource, format: outputFormat);
    encoder.start();
    encoder.encode(readBuffer);
    encoder.stop();
  });

  buffer.dispose();
}
