import 'package:flutter/material.dart';
import 'package:flutter_coast_audio_miniaudio/flutter_coast_audio_miniaudio.dart';
import 'package:music_player/player_screen.dart';

final backends = [
  MabBackend.coreAudio,
  MabBackend.openSl,
  MabBackend.aaudio,
];

void main() {
  MabLibrary.initialize();
  MabDeviceContext.enableSharedInstance(backends: backends);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Player/Recorder Demo',
      theme: ThemeData.dark(),
      darkTheme: ThemeData.dark(),
      home: const PlayerScreen(),
    );
  }
}
