import 'package:flutter/material.dart';
import 'package:flutter_coast_audio_miniaudio/flutter_coast_audio_miniaudio.dart';
import 'package:music_player/main_screen.dart';

final backends = [
  MabBackend.coreAudio,
  MabBackend.aaudio,
];

void main() {
  MabLibrary.initialize();
  MabDeviceContext.enableSharedInstance(backends: backends);

  runApp(const MyApp());

  const format = AudioFormat(sampleRate: 48000, channels: 2); // sampleFormat is float32 by default.
  final functionNode = FunctionNode(
    function: const SineFunction(),
    frequency: 440,
    format: format,
  );
  final frames = AllocatedAudioFrames(
    length: 1024,
    format: format,
  );

  frames.acquireBuffer((buffer) {
    const leftVolume = 1.0;
    const rightVolume = 0.0;

    final framesRead = functionNode.outputBus.read(buffer);
    final floatList = buffer.limit(framesRead).asFloat32ListView();
    for (var i = 0; floatList.length > i; i += format.channels) {
      // interleaved audio sample
      floatList[i] *= leftVolume;
      floatList[i + 1] *= rightVolume;
    }
  });

// Dispose the buffer.
  frames.dispose();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player Demo',
      theme: ThemeData.dark(),
      darkTheme: ThemeData.dark(),
      home: const MainScreen(),
    );
  }
}
