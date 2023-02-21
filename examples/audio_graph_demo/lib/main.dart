import 'dart:io';
import 'dart:typed_data';

import 'package:dart_audio_graph/dart_audio_graph.dart';

void main() {
  final format = AudioFormat(sampleRate: 48000, channels: 2);
  final graphNode = GraphNode();
  final mixerNode = MixerNode(format: format);

  // Initialize sine wave node and connect to mixer input #1
  {
    final sineNode = FunctionNode(function: const SineFunction(), format: format, frequency: 440);
    final sineVolumeNode = VolumeNode(volume: 0.5);

    graphNode.connect(sineNode.outputBus, sineVolumeNode.inputBus);
    graphNode.connect(sineVolumeNode.outputBus, mixerNode.appendInputBus());
  }

  // Initialize square wave node and connect to mixer input #2
  {
    final squareNode = FunctionNode(function: const SquareFunction(), format: format, frequency: 880);
    final squareVolumeNode = VolumeNode(volume: 0.2);

    graphNode.connect(squareNode.outputBus, squareVolumeNode.inputBus);
    graphNode.connect(squareVolumeNode.outputBus, mixerNode.appendInputBus());
  }

  // Connect the mixer node's output to master volume's input
  {
    final masterVolumeNode = VolumeNode(volume: 1);
    graphNode.connect(mixerNode.outputBus, masterVolumeNode.inputBus);

    // Connect master volume to graph node's endpoint
    graphNode.connectEndpoint(masterVolumeNode.outputBus);
  }

  // Allocate buffers for 10 seconds.
  final buffer = AllocatedFrameBuffer(frames: format.sampleRate * 10, format: format);

  final pcmFile = File('test.pcm');

  // Read the output data to the buffer.
  buffer.acquireBuffer((rawBuffer) {
    final framesRead = graphNode.outputBus.read(rawBuffer);
    final readBuffer = rawBuffer.limit(framesRead);

    // Flush deinterleaved audio data to the file.
    pcmFile.writeAsBytesSync(Uint8List.sublistView(readBuffer.copyFloat32List(deinterleave: true)), flush: true);
  });

  buffer.dispose();

  // Uncomment this line to convert raw pcm data to wav using ffmpeg
  // Process.runSync('ffmpeg', '-f f32le -ar ${format.sampleRate} -ac ${format.channels} -i test.pcm test.wav'.split(' '));
}
