import 'dart:math';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_fft/dart_audio_graph_fft.dart';
import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';
import 'package:example/fft_painter.dart';
import 'package:example/function_graph_node_widget.dart';
import 'package:example/wave_painter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final format = const AudioFormat(sampleRate: 44100, channels: 1);
  final interval = const Duration(milliseconds: 1);
  late final buffer = FrameBuffer.allocate(frames: 256, format: format);
  late final functions = <Key, WaveFunction>{};
  late final mixerNode = MixerNode(format: format, isClampEnabled: true);
  late final volumeNode = VolumeNode(volume: 1);
  late final fftNode = FftNode(
    frames: 8192,
    noCopy: true,
    onFftCompleted: (result) {
      setState(() {
        fftResult = result;
      });
    },
  );
  late final deviceOutput = DeviceOutputNode(format: format, bufferFrameSize: 512);
  late final graphNode = GraphNode();
  late final clock = IntervalAudioClock(interval);
  late final ringBuffer = FrameRingBuffer(frames: 512, format: format);
  late final fftBuffer = FrameBuffer.allocate(frames: ringBuffer.capacity, format: format);
  List<double> fftData = [];
  FftResult? fftResult;

  @override
  void initState() {
    super.initState();

    graphNode.connect(mixerNode.outputBus, volumeNode.inputBus);
    graphNode.connect(volumeNode.outputBus, fftNode.inputBus);
    graphNode.connect(fftNode.outputBus, deviceOutput.inputBus);
    graphNode.connectEndpoint(deviceOutput.outputBus);

    clock.start();
    deviceOutput.start();
    clock.callbacks.add((clock) {
      _readNext();
    });
  }

  void _readNext() {
    final available = deviceOutput.availableWriteFrames;
    final buffer = this.buffer.limit(min(available, this.buffer.sizeInFrames));
    graphNode.outputBus.read(buffer);
    ringBuffer.write(buffer);

    if (ringBuffer.length == ringBuffer.capacity) {
      final readFrames = ringBuffer.read(fftBuffer);
      setState(() {
        fftData = fftBuffer.limit(readFrames).toFloatList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final channelSize = fftData.length ~/ format.channels;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (fftResult != null)
                      SizedBox(
                        height: 200,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                            child: CustomPaint(
                              painter: FftPainter(fftResult!, 0, 4000),
                            ),
                          ),
                        ),
                      ),
                    for (var ch = 0; format.channels > ch; ch++)
                      SizedBox(
                        height: 200,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                            child: CustomPaint(
                              painter: WavePainter(
                                fftData.skip(channelSize * ch).take(channelSize).toList(growable: false),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => clock.start(),
                      child: const Text('Start'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => clock.stop(),
                      child: const Text('Stop'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          functions[UniqueKey()] = const SineFunction();
                        });
                      },
                      child: const Text('Sine'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          functions[UniqueKey()] = const CosineFunction();
                        });
                      },
                      child: const Text('Cosine'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          functions[UniqueKey()] = const SquareFunction();
                        });
                      },
                      child: const Text('Square'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          functions[UniqueKey()] = const TriangleFunction();
                        });
                      },
                      child: const Text('Triangle'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              for (var entry in functions.entries) _buildNodeWidget(entry.key, entry.value),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNodeWidget(Key key, WaveFunction function) {
    return FunctionGraphNodeWidget(
      key: key,
      function: function,
      format: format,
      connect: (outputBus) {
        final inputBus = mixerNode.appendInputBus();
        graphNode.connect(outputBus, inputBus);
      },
    );
  }
}
