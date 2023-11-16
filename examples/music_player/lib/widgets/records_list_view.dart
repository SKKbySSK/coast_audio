import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_coast_audio_miniaudio/flutter_coast_audio_miniaudio.dart';
import 'package:music_player/recorder/record_repository.dart';
import 'package:path/path.dart';

class RecordsListView extends StatefulWidget {
  const RecordsListView({
    Key? key,
    required this.repository,
    required this.recording,
  }) : super(key: key);
  final RecordRepository repository;
  final File? recording;

  @override
  State<RecordsListView> createState() => _RecordsListViewState();
}

class _RecordsListViewState extends State<RecordsListView> {
  final List<File> _records = [];
  final _player = MabAudioPlayer();
  File? _playing;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _updateRecords();

    _player.stateStream.listen((state) {
      setState(() {
        _isPlaying = state == MabAudioPlayerState.playing;

        if (state == MabAudioPlayerState.finished) {
          _playing = null;
          _player.stop();
        }
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _updateRecords() async {
    final records = await widget.repository.getRecords();
    setState(() {
      _records
        ..clear()
        ..addAll(records);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_records.isEmpty) {
      return const Center(
        child: Text('No Record'),
      );
    }

    return ListView.separated(
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final isRecording = widget.recording?.path == _records[index].path;
        return ListTile(
          title: Text(basename(_records[index].path)),
          trailing: IconButton(
            icon: Icon((_isPlaying && _records[index] == _playing) ? Icons.pause_rounded : Icons.play_arrow_rounded),
            onPressed: isRecording
                ? null
                : () async {
                    final record = _records[index];
                    if (record != _playing) {
                      await _player.stop();
                      final dataSource = AudioFileDataSource(file: record, mode: FileMode.read);
                      final decoder = MabAudioDecoder(
                        dataSource: dataSource,
                        outputFormat: _player.format,
                      );
                      await _player.open(decoder, dataSource);
                      _playing = record;
                      _isPlaying = false;
                    }

                    if (_isPlaying) {
                      await _player.stop();
                      setState(() {
                        _playing = null;
                      });
                    } else {
                      _player.play();
                    }
                  },
          ),
        );
      },
      separatorBuilder: (_, __) => const Divider(),
    );
  }
}
