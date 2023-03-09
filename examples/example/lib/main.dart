import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';
import 'package:example/audio_session_manager.dart';
import 'package:example/main_screen.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  MabLibrary.initialize();
  MabDeviceContext.enableSharedInstance(
    backends: [
      MabBackend.coreAudio,
      MabBackend.aaudio,
      MabBackend.openSl,
    ],
  );

  WidgetsFlutterBinding.ensureInitialized();
  await AudioSessionManager.initialize();
  await AudioSessionManager.activate();

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
