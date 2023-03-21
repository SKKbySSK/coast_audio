import 'dart:io';

import 'package:audio_recorder/recorder/audio_recorder.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_coast_audio_miniaudio/flutter_coast_audio_miniaudio.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final sourceFormat = const AudioFormat(sampleRate: 48000, channels: 1);
  final bufferFrameSize = 65536 * 4;
  late final outputFormat = sourceFormat.copyWith(sampleFormat: SampleFormat.int16);
  late final converter = AudioFormatConverter(inputFormat: sourceFormat, outputFormat: outputFormat);
  late final recorder = AudioRecorder(
    format: sourceFormat,
    bufferFrameSize: bufferFrameSize,
    onInput: (time, buffer, isEnd) {
      final converted = AllocatedAudioFrame(frames: buffer.sizeInFrames, format: outputFormat);
      converted.acquireBuffer((convertedBuffer) {
        converter.convert(bufferOut: convertedBuffer, bufferIn: buffer);
        encoder?.encode(convertedBuffer);
      });
      converted.dispose();
    },
  );
  final file = File('record.wav');
  AudioFileDataSource? dataSource;
  WavAudioEncoder? encoder;

  @override
  void initState() {
    super.initState();
    recorder.stateStream.listen((state) {
      switch (state) {
        case MabAudioRecorderState.recording:
          if (file.existsSync()) {
            file.deleteSync();
          }

          dataSource = AudioFileDataSource(file: file, mode: FileMode.write);
          encoder = WavAudioEncoder(dataSource: dataSource!, format: outputFormat);
          encoder!.start();
          debugPrint('recorder started: ${file.absolute.path}');
          break;
        case MabAudioRecorderState.stopped:
          encoder?.stop();
          dataSource?.dispose();
          encoder = null;
          break;
        case MabAudioRecorderState.paused:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Recorder'),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.any,
                allowMultiple: false,
                allowCompression: false,
              );

              if (result == null) {
                return;
              }

              final filePath = result.files.single.path!;

              recorder.impulseResponse?.dispose();
              recorder.impulseResponse = MabAudioDecoder(
                dataSource: AudioFileDataSource(file: File(filePath), mode: FileMode.read),
                format: sourceFormat,
              );
            },
            icon: const Icon(Icons.multitrack_audio),
          ),
        ],
      ),
      body: Center(
        child: IconButton(
          onPressed: () async {
            if (recorder.state == MabAudioRecorderState.recording) {
              await recorder.stop();
            } else {
              await recorder.prepare();
              recorder.start();
            }
          },
          iconSize: 42,
          icon: const Icon(
            Icons.circle,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
