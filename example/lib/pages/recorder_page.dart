import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:example/components/player_tile.dart';
import 'package:example/isolates/recorder_isolate.dart';
import 'package:example/models/audio_state.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class RecorderPage extends StatefulWidget {
  const RecorderPage({
    super.key,
    required this.audio,
  });
  final AudioStateConfigured audio;

  @override
  State<RecorderPage> createState() => _RecorderPageState();
}

class _RecorderPageState extends State<RecorderPage> {
  Directory? _rootDirectory;
  final _recordings = <File>[];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final dir = Directory(path.join((await getApplicationDocumentsDirectory()).path, 'recordings'));
    if (!dir.existsSync()) {
      await dir.create();
    }

    final recordings = dir.listSync().where((f) => f.path.endsWith('.wav')).toList();
    setState(() {
      _rootDirectory = dir;
      _recordings.addAll(recordings.whereType<File>().toList()..sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync())));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Recorder'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (var i = 0; _recordings.length > i; i++)
                    PlayerTile(
                      backend: widget.audio.backend,
                      outputDevice: widget.audio.outputDevice,
                      file: XFile(_recordings[i].path),
                      manageAudioSession: false,
                    ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          if (_rootDirectory != null)
            _RecorderView(
              audio: widget.audio,
              rootDirectory: _rootDirectory!,
              onRecorded: (path) {
                setState(() {
                  _recordings.add(File(path));
                });
              },
            ),
        ],
      ),
    );
  }
}

class _RecorderView extends StatefulWidget {
  const _RecorderView({
    required this.rootDirectory,
    required this.audio,
    required this.onRecorded,
  });
  final Directory rootDirectory;
  final AudioStateConfigured audio;
  final void Function(String path) onRecorded;

  @override
  State<_RecorderView> createState() => __RecorderViewState();
}

class __RecorderViewState extends State<_RecorderView> {
  String? _recordingFile;
  final _isolate = RecorderIsolate();

  Future<void> _activateAudioSession() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final session = await AudioSession.instance;
      await session.configure(
        AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.defaultToSpeaker | AVAudioSessionCategoryOptions.allowBluetooth,
        ),
      );
      await session.setActive(true);
    }
  }

  @override
  void initState() {
    super.initState();
    _activateAudioSession();
  }

  @override
  void dispose() {
    super.dispose();
    if (_isolate.isLaunched) {
      _isolate.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: ElevatedButton.icon(
          onPressed: () async {
            if (_recordingFile != null) {
              await _isolate.stop();
              widget.onRecorded(_recordingFile!);
              setState(() {
                _recordingFile = null;
              });
            } else {
              await _activateAudioSession();
              final filePath = path.join(widget.rootDirectory.path, '${DateTime.now().toIso8601String()}.wav');
              await _isolate.start(
                backend: widget.audio.backend,
                inputDeviceId: widget.audio.inputDevice?.id,
                path: filePath,
              );
              setState(() {
                _recordingFile = filePath;
              });
            }
          },
          icon: Icon(_recordingFile != null ? Icons.stop_rounded : Icons.mic_rounded),
          label: Text(_recordingFile != null ? 'Stop Recording' : 'Start Recording'),
        ),
      ),
    );
  }
}
