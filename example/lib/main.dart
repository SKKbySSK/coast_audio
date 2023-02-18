import 'dart:io';
import 'dart:math';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_fft/dart_audio_graph_fft.dart';
import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';
import 'package:example/component/audio_file_node_view.dart';
import 'package:example/component/function_graph_node_view.dart';
import 'package:example/main_screen.dart';
import 'package:example/painter/fft_painter.dart';
import 'package:example/painter/wave_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

void main() {
  MabDeviceContext.enableSharedInstance(backends: MabBackend.values);
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
      home: const MainScreen(),
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
  final format = const AudioFormat(sampleRate: 48000, channels: 2);
  final interval = const Duration(milliseconds: 1);
  late final buffer = FrameBuffer.allocate(frames: 4096, format: format);
  late final functions = <Key, WaveFunction>{};
  late final files = <Key, String>{};
  late final mixerNode = MixerNode(isClampEnabled: true);
  late final volumeNode = VolumeNode(volume: 1);
  late final fftNode = FftNode(
    frames: 1024,
    noCopy: true,
    onFftCompleted: (result) {
      setState(() {
        fftResult = result;
      });
    },
  );
  late final deviceOutput = MabDeviceOutput(
    context: MabDeviceContext.sharedInstance,
    format: format,
    bufferFrameSize: 4096,
    noFixedSizedCallback: true,
  );
  late final deviceOutputNode = MabDeviceOutputNode(deviceOutput: deviceOutput);

  late final deviceInput = MabDeviceInput(
    context: MabDeviceContext.sharedInstance,
    format: format,
    bufferFrameSize: 4096,
    noFixedSizedCallback: true,
  );
  late final deviceInputNode = MabDeviceInputNode(deviceInput: deviceInput);

  late final graphNode = GraphNode();
  late final clock = IntervalAudioClock(interval);
  late final ringBuffer = FrameRingBuffer(frames: 512, format: format);
  late final fftBuffer = FrameBuffer.allocate(frames: ringBuffer.capacity, format: format);
  List<double> fftData = [];
  Map<int, String> filePaths = {};
  FftResult? fftResult;

  @override
  void initState() {
    super.initState();
    _exportSampleFiles();

    final linearFuncNode = FunctionNode(function: LinearFunction(0), format: format, frequency: 0);
    graphNode.connect(linearFuncNode.outputBus, mixerNode.appendInputBus());
    graphNode.connect(deviceInputNode.outputBus, mixerNode.appendInputBus());
    graphNode.connect(mixerNode.outputBus, volumeNode.inputBus);
    graphNode.connect(volumeNode.outputBus, fftNode.inputBus);
    graphNode.connect(fftNode.outputBus, deviceOutputNode.inputBus);
    graphNode.connectEndpoint(deviceOutputNode.outputBus);

    clock.start();
    clock.callbacks.add((clock) {
      _readNext();
    });
  }

  void _exportSampleFiles() async {
    for (var i = 1; 2 >= i; i++) {
      final directory = await getApplicationDocumentsDirectory();
      final name = 'sample$i.mp3';
      final mp3Path = path.join(directory.path, name);
      final data = await rootBundle.load('assets/$name');
      await File(mp3Path).writeAsBytes(data.buffer.asUint8List());
      setState(() {
        filePaths[i] = mp3Path;
      });
    }
  }

  void _readNext() {
    final readFrames = min(deviceOutput.availableWriteFrames, this.buffer.sizeInFrames);
    if (readFrames == 0) {
      return;
    }

    final buffer = this.buffer.limit(readFrames);
    graphNode.outputBus.read(buffer);
    ringBuffer.write(buffer);

    if (ringBuffer.length == ringBuffer.capacity) {
      final readFrames = ringBuffer.read(fftBuffer);
      setState(() {
        fftData = fftBuffer.limit(readFrames).copyFloatList(deinterleave: true);
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
                        height: 100,
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
                    SizedBox(
                      height: 100,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var ch = 0; format.channels > ch; ch++)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                    ),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CustomPaint(
                                          painter: WavePainter(
                                            fftData.skip(channelSize * ch).take(channelSize).toList(growable: false),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Text('${ch + 1}ch'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
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
                    const Text('In'),
                    const SizedBox(width: 8),
                    Text(deviceInput.backend.name.toUpperCase()),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => deviceInput.start(),
                      child: const Text('Start'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => deviceInput.stop(),
                      child: const Text('Stop'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const Text('Out'),
                    const SizedBox(width: 8),
                    Text(deviceOutput.backend.name.toUpperCase()),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => deviceOutput.start(),
                      child: const Text('Start'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => deviceOutput.stop(),
                      child: const Text('Stop'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 90,
                      child: Text('Master Vol'),
                    ),
                    Expanded(
                      child: Slider(
                        value: volumeNode.volume,
                        min: 0,
                        max: 1,
                        onChanged: (vol) {
                          setState(() {
                            volumeNode.volume = vol;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text('${(volumeNode.volume * 100).toStringAsPrecision(3)}%'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    for (var entry in filePaths.entries) ...[
                      ElevatedButton(
                        onPressed: () {
                          files[UniqueKey()] = entry.value;
                        },
                        child: Text(path.basename(entry.value)),
                      ),
                      const SizedBox(width: 8),
                    ]
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
              for (var entry in files.entries) _buildFileNodeWidget(entry.key, entry.value),
              for (var entry in functions.entries) _buildFunctionNodeWidget(entry.key, entry.value),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileNodeWidget(Key key, String filePath) {
    return AudioFileNodeView(
      key: key,
      filePath: filePath,
      format: format,
      connect: (outputBus) {
        final inputBus = mixerNode.appendInputBus();
        graphNode.connect(outputBus, inputBus);
      },
    );
  }

  Widget _buildFunctionNodeWidget(Key key, WaveFunction function) {
    return FunctionGraphNodeView(
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
