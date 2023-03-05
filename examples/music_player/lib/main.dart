import 'package:flutter/material.dart';
import 'package:flutter_audio_graph_miniaudio/flutter_audio_graph_miniaudio.dart';
import 'package:music_player/main_screen.dart';

final backends = [
  MabBackend.coreAudio,
  MabBackend.aaudio,
  MabBackend.openSl,
];

void main() {
  MabLibrary.initialize();
  MabDeviceContext.enableSharedInstance(backends: backends);

  runApp(const MyApp());
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
