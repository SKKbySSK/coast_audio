import 'dart:io';

import 'package:audio_recorder/recorder/audio_recorder.dart';
import 'package:audio_recorder/recorder/record_repository.dart';
import 'package:audio_recorder/widgets/loopback_button.dart';
import 'package:audio_recorder/widgets/record_button.dart';
import 'package:audio_recorder/widgets/records_list_view.dart';
import 'package:audio_recorder/widgets/rms_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_coast_audio_miniaudio/flutter_coast_audio_miniaudio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  RecordRepository? recordRepo;
  final sourceFormat = const AudioFormat(sampleRate: 44100, channels: 2, sampleFormat: SampleFormat.float32);
  final bufferFrameSize = 2048;
  late final outputFormat = sourceFormat.copyWith(sampleRate: 48000, channels: 1, sampleFormat: SampleFormat.int16);
  late final recorder = AudioRecorder(captureFormat: sourceFormat, bufferFrameSize: bufferFrameSize);
  File? _recording;
  var _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  void _prepare() async {
    final doc = await getApplicationDocumentsDirectory();
    setState(() {
      recordRepo = RecordRepository(doc);
    });

    if (Platform.isIOS || Platform.isAndroid) {
      final status = await Permission.microphone.request();
      setState(() {
        _hasPermission = status == PermissionStatus.granted;
      });
    } else {
      setState(() {
        _hasPermission = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Permission denied'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => openAppSettings(),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Recorder'),
      ),
      drawer: Drawer(
        child: RecordsListView(
          repository: recordRepo!,
          recording: _recording,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Column(
                  children: [
                    RotatedBox(
                      quarterTurns: -1,
                      child: Slider(
                        value: recorder.volume,
                        onChanged: (v) {
                          setState(() {
                            recorder.volume = v;
                          });
                        },
                      ),
                    ),
                    const Icon(Icons.mic),
                  ],
                ),
                Column(
                  children: [
                    RotatedBox(
                      quarterTurns: -1,
                      child: Slider(
                        value: recorder.echo,
                        onChanged: (v) {
                          setState(() {
                            recorder.echo = v;
                          });
                        },
                      ),
                    ),
                    const Icon(Icons.multitrack_audio_outlined),
                  ],
                ),
              ],
            ),
            Expanded(
              child: RmsView(
                recorder: recorder,
                maxRmsLength: MediaQuery.of(context).size.width ~/ 1.2,
              ),
            ),
            const Divider(
              thickness: 1,
              height: 1,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: RecordButton(
                      recorder: recorder,
                      onRecord: () async {
                        final file = await recordRepo!.createNewRecord();
                        debugPrint('record created: ${file.absolute.path}');
                        await recorder.openFile(file, outputFormat);
                        recorder.start();

                        setState(() {
                          _recording = file;
                        });
                      },
                      onStop: () async {
                        await recorder.stop();
                        setState(() {
                          _recording = null;
                        });
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: LoopbackButton(
                      recorder: recorder,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
