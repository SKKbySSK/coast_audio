import 'package:audio_recorder/main_screen.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_coast_audio_miniaudio/flutter_coast_audio_miniaudio.dart';

final backends = [
  MabBackend.coreAudio,
  MabBackend.aaudio,
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MabLibrary.initialize();
  MabDeviceContext.enableSharedInstance(backends: backends);

  final session = await AudioSession.instance;
  await session.configure(
    AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.defaultToSpeaker |
          AVAudioSessionCategoryOptions.allowBluetooth |
          AVAudioSessionCategoryOptions.allowBluetoothA2dp |
          AVAudioSessionCategoryOptions.allowAirPlay,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
    ),
  );
  await session.setActive(true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Recorder Demo',
      theme: ThemeData.dark(),
      darkTheme: ThemeData.dark(),
      home: const MainScreen(),
    );
  }
}
