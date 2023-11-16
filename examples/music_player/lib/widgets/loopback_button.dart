import 'package:flutter/material.dart';
import 'package:music_player/recorder/audio_recorder.dart';

class LoopbackButton extends StatefulWidget {
  const LoopbackButton({
    Key? key,
    required this.recorder,
  }) : super(key: key);
  final AudioRecorder recorder;

  @override
  State<LoopbackButton> createState() => _LoopbackButtonState();
}

class _LoopbackButtonState extends State<LoopbackButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        setState(() {
          widget.recorder.loopback = !widget.recorder.loopback;
        });
      },
      icon: Icon(
        widget.recorder.loopback ? Icons.volume_up : Icons.volume_off,
        color: widget.recorder.loopback ? Colors.cyan : Colors.grey,
      ),
    );
  }
}
