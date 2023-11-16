import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_coast_audio_miniaudio/flutter_coast_audio_miniaudio.dart';
import 'package:music_player/recorder/audio_recorder.dart';
import 'package:music_player/recorder/record_repository.dart';
import 'package:music_player/widgets/loopback_button.dart';
import 'package:music_player/widgets/record_button.dart';
import 'package:music_player/widgets/rms_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class RecorderScreen extends StatefulWidget {
  const RecorderScreen({
    Key? key,
    required this.onRecorded,
  }) : super(key: key);
  final void Function(AudioInputDataSource dataSource) onRecorded;

  @override
  State<RecorderScreen> createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen> {
  RecordRepository? recordRepo;
  final sourceFormat = const AudioFormat(sampleRate: 44100, channels: 2, sampleFormat: SampleFormat.float32);
  final bufferFrameSize = 2048;
  late final outputFormat = sourceFormat.copyWith(sampleRate: 48000, channels: 1, sampleFormat: SampleFormat.int16);
  late final recorder = AudioRecorder(captureFormat: sourceFormat, bufferFrameSize: bufferFrameSize);
  AudioMemoryDataSource? _recordingDataSource;
  var _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void dispose() {
    recorder.stop();
    super.dispose();
  }

  void _prepare() async {
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
                        final dataSource = AudioMemoryDataSource();
                        _recordingDataSource = dataSource;

                        final encoder = MabAudioEncoder(
                          dataSource: dataSource,
                          encodingFormat: MabEncodingFormat.wav,
                          inputFormat: outputFormat,
                        );
                        await recorder.open(encoder);
                        recorder.start();
                      },
                      onStop: () async {
                        await recorder.stop();
                        _recordingDataSource!.position = 0;
                        widget.onRecorded(_recordingDataSource!);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
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
