import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:example/backend_page.dart';
import 'package:example/main_page.dart';
import 'package:example/models/audio_state.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS) {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(avAudioSessionCategory: AVAudioSessionCategory.playAndRecord));
    await session.setActive(true);
  }

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  AudioState _state = const AudioStateInitial();

  AudioState get audioState => _state;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'coast_audio Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: switch (_state) {
        AudioStateInitial() => const BackendPage(),
        AudioStateConfigured() => MainPage(audio: _state as AudioStateConfigured),
      },
    );
  }

  void applyAudioState(AudioState state) {
    setState(() {
      _state = state;
    });
  }
}
