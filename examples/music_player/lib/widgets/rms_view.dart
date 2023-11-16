import 'package:flutter/material.dart';
import 'package:flutter_coast_audio_miniaudio/flutter_coast_audio_miniaudio.dart';
import 'package:music_player/painter/rms_painter.dart';
import 'package:music_player/recorder/audio_recorder.dart';

class RmsView extends StatefulWidget {
  const RmsView({
    Key? key,
    required this.recorder,
    required this.maxRmsLength,
  }) : super(key: key);
  final AudioRecorder recorder;
  final int maxRmsLength;

  @override
  State<RmsView> createState() => _RmsViewState();
}

class _RmsViewState extends State<RmsView> {
  final _rmsList = <double>[];

  @override
  void initState() {
    super.initState();
    widget.recorder.rmsStream.listen((rms) {
      setState(() {
        _rmsList.add(rms);
        if (_rmsList.length > widget.maxRmsLength) {
          _rmsList.removeRange(0, _rmsList.length - widget.maxRmsLength);
        }
      });
    });

    widget.recorder.stateStream.listen((state) {
      if (state == MabAudioRecorderState.recording) {
        setState(() {
          _rmsList.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RmsPainter(_rmsList, widget.maxRmsLength),
    );
  }
}
