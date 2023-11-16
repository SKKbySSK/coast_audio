import 'package:flutter/material.dart';
import 'package:flutter_coast_audio_miniaudio/flutter_coast_audio_miniaudio.dart';
import 'package:music_player/recorder/audio_recorder.dart';

class RecordButton extends StatelessWidget {
  const RecordButton({
    Key? key,
    required this.recorder,
    required this.onRecord,
    required this.onStop,
  }) : super(key: key);
  final AudioRecorder recorder;
  final VoidCallback onRecord;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: recorder.stateStream,
      initialData: recorder.state,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final isRecording = state == MabAudioRecorderState.recording;
        return GestureDetector(
          onTap: isRecording ? onStop : onRecord,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Visibility(
                  visible: isRecording,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
