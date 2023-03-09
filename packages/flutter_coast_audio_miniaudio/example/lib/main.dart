import 'package:flutter/material.dart';
import 'package:flutter_coast_audio_miniaudio/flutter_coast_audio_miniaudio.dart';

void main() {
  MabLibrary.initialize();
  MabDeviceContext.enableSharedInstance(backends: [
    MabBackend.aaudio,
    MabBackend.coreAudio,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final format = const AudioFormat(sampleRate: 48000, channels: 2);
  late final sineNode = FunctionNode(
    function: const SineFunction(),
    format: format,
    frequency: 440,
  );
  late final outputNode = MabDeviceOutputNode(
    device: MabDeviceOutput(
      context: MabDeviceContext.sharedInstance,
      format: format,
      bufferFrameSize: 2048,
    ),
  );
  final graphNode = GraphNode();

  late final outputTask = AudioTask(
    clock: IntervalAudioClock(const Duration(milliseconds: 16)),
    framesRead: 4096,
    endpoint: graphNode.outputBus,
    format: format,
  );

  @override
  void initState() {
    super.initState();

    graphNode.connect(sineNode.outputBus, outputNode.inputBus);
    graphNode.connectEndpoint(outputNode.outputBus);

    outputTask.start();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => outputNode.device.start(),
                child: const Text('Start'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => outputNode.device.stop(),
                child: const Text('Stop'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
