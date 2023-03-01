import 'dart:io';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';
import 'package:example/node/player_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class AddMixerInputDialog extends StatefulWidget {
  const AddMixerInputDialog({
    Key? key,
    required this.format,
    required this.onSelect,
  }) : super(key: key);
  final AudioFormat format;
  final void Function(AudioNode node) onSelect;

  @override
  State<AddMixerInputDialog> createState() => _AddMixerInputDialogState();
}

class _AddMixerInputDialogState extends State<AddMixerInputDialog> {
  final _audioFiles = const [
    'sample1.mp3',
    'sample2.mp3',
    'sample1.flac',
    'sample1.wav',
  ];
  final _exportedAudioFiles = [];

  late final _inputDevices = MabDeviceContext.sharedInstance.enumerateCaptureDevices();

  late final _gen1 = Map<String, AudioNode Function()>.fromEntries(_inputDevices.map(
    (e) => MapEntry(
      'MabDeviceInputNode:${e.name}',
      () => MabDeviceInputNode(
        device: MabDeviceInput(
          context: MabDeviceContext.sharedInstance,
          format: widget.format,
          bufferFrameSize: 2048,
          noFixedSizedCallback: true,
          deviceId: e.id,
        ),
      ),
    ),
  ));

  late final _gen2 = Map<String, AudioNode Function()>.fromEntries(
    _audioFiles.map(
      (f) => MapEntry(
        'PlayerNode:$f',
        () {
          final path = _exportedAudioFiles[_audioFiles.indexOf(f)];
          final node = PlayerNode(filePath: path, format: widget.format);
          return node;
        },
      ),
    ),
  );

  late final _gen3 = <String, AudioNode Function()>{
    'FunctionNode:Sine': () => FunctionNode(function: const SineFunction(), format: widget.format, frequency: 440),
    'FunctionNode:Cosine': () => FunctionNode(function: const CosineFunction(), format: widget.format, frequency: 440),
    'FunctionNode:Square': () => FunctionNode(function: const SquareFunction(), format: widget.format, frequency: 440),
    'FunctionNode:Triangle': () => FunctionNode(function: const TriangleFunction(), format: widget.format, frequency: 440),
  };

  @override
  void initState() {
    super.initState();
    _exportAudioFiles();
  }

  @override
  void dispose() {
    super.dispose();
    for (var e in _inputDevices) {
      e.dispose();
    }
  }

  void _exportAudioFiles() async {
    for (var file in _audioFiles) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = path.join(directory.path, file);
      final data = await rootBundle.load('assets/$file');
      await File(filePath).writeAsBytes(data.buffer.asUint8List());
      _exportedAudioFiles.add(filePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final generators = [_gen1, _gen2, _gen3];

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 600,
          maxWidth: 600,
          minHeight: 200,
          minWidth: 300,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 16, left: 16, bottom: 8, right: 16),
              child: Text(
                'Add Mixer Input',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: generators.length,
                itemBuilder: (context, index) {
                  final genSection = generators[index];
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var gen in genSection.entries)
                        ListTile(
                          title: Text(gen.key.split(':')[1]),
                          subtitle: Text(gen.key.split(':')[0]),
                          onTap: () {
                            widget.onSelect(gen.value());
                            Navigator.of(context).maybePop();
                          },
                        ),
                      const Divider(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
