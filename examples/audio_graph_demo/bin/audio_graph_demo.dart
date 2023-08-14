import 'dart:io';

import 'package:coast_audio/coast_audio.dart';

void main() {
  final wavFile = File('test.wav');
  _runMixingDemo(wavFile);
}

void _runMixingDemo(File file) {
  final disposableBag = SyncDisposableBag();
  final format = AudioFormat(sampleRate: 48000, channels: 2, sampleFormat: SampleFormat.int16);
  final graphNode = GraphNode();
  final mixerNode = MixerNode(format: format)..syncDisposeOn(disposableBag);
  final masterVolumeNode = VolumeNode(volume: 0.8);

  final freqs = <double>[264, 330, 396];

  // Initialize sine wave nodes and connect them to mixer's input
  for (final freq in freqs) {
    final sineNode = FunctionNode(function: const SineFunction(), format: format, frequency: freq);
    final sineVolumeNode = VolumeNode(volume: 0.2);

    graphNode.connect(sineNode.outputBus, sineVolumeNode.inputBus);
    graphNode.connect(sineVolumeNode.outputBus, mixerNode.appendInputBus());
  }

  // Connect the mixer node's output bus to master volume's input bus
  graphNode.connect(mixerNode.outputBus, masterVolumeNode.inputBus);

  // Connect master volume node to endpoint
  graphNode.connectEndpoint(masterVolumeNode.outputBus);

  // Allocate 10 seconds audio buffer.
  final frames = AllocatedAudioFrames(
    length: format.sampleRate * 10,
    format: format,
  )..syncDisposeOn(disposableBag);

  // Acquire the raw audio buffer from AllocatedAudioFrames
  frames.acquireBuffer((buffer) {
    // Read the graph's output data
    final framesRead = graphNode.outputBus.read(buffer);
    final readBuffer = buffer.limit(framesRead);

    final dataSource = AudioFileDataSource(
      file: file,
      mode: FileMode.write,
    )..syncDisposeOn(disposableBag);

    final encoder = WavAudioEncoder(dataSource: dataSource, inputFormat: format);
    encoder.start();
    encoder.encode(readBuffer); // Encode the buffer and write to an output data source
    encoder.finalize();
  });

  disposableBag.dispose();
}
