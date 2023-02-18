import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';
import 'package:example/main_screen.dart';
import 'package:flutter/material.dart';

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
