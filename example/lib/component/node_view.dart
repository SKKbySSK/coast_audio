import 'dart:async';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';
import 'package:example/component/node_view_base.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class NodeView extends StatefulWidget {
  NodeView({
    required this.id,
    required this.node,
    required this.onDispose,
  }) : super(key: ValueKey(id));
  final String id;
  final AudioNode node;
  final void Function(AudioNode node, Disposable? disposable) onDispose;

  @override
  State<NodeView> createState() => _NodeViewState();
}

class _NodeViewState extends State<NodeView> {
  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildNodeView(widget.node),
        ],
      ),
    );
  }

  Widget _buildNodeView(AudioNode node) {
    switch (widget.node.runtimeType) {
      case FunctionNode:
        return _buildFunctionNodeContent(widget.node as FunctionNode);
      case MixerNode:
        return _buildMixerNodeContent(widget.node as MixerNode);
      case MabDeviceInputNode:
        return _buildDeviceInNodeContent(widget.node as MabDeviceInputNode);
      case MabDeviceOutputNode:
        return _buildDeviceOutNodeContent(widget.node as MabDeviceOutputNode);
      case PlayerNode:
        return _buildPlayerNodeContent(widget.node as PlayerNode);
      default:
        return NodeViewBase(
          node: widget.node,
          icon: Icons.question_mark,
          actions: const [],
          children: const [
            Text('Unknown node'),
          ],
        );
    }
  }

  Widget _buildFunctionNodeContent(FunctionNode node) {
    return NodeViewBase(
      node: node,
      icon: Icons.multitrack_audio_outlined,
      actions: [
        _buildDisposeButton(node, null),
      ],
      children: [
        _buildTitledData('Func', node.function.runtimeType.toString().replaceAll('Function', '')),
        _buildTitledData('Freq', '${node.frequency.toInt()}Hz'),
      ],
    );
  }

  Widget _buildMixerNodeContent(MixerNode node) {
    final format = node.currentInputFormat;
    return NodeViewBase(
      node: node,
      icon: Icons.merge,
      actions: const [],
      children: [
        _buildTitledData('Inputs', node.inputs.length.toString()),
        if (format != null) ...[
          _buildTitledData('SampleRate', '${format.sampleRate}Hz'),
          _buildTitledData('Channels', '${format.channels}ch'),
          _buildTitledData('Format', format.sampleFormat.name),
        ],
      ],
    );
  }

  Widget _buildDeviceInNodeContent(MabDeviceInputNode node) {
    return NodeViewBase(
      node: node,
      icon: Icons.mic,
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              if (node.deviceInput.isStarted) {
                node.deviceInput.stop();
              } else {
                node.deviceInput.start();
              }
            });
          },
          icon: Icon(node.deviceInput.isStarted ? Icons.pause_rounded : Icons.play_arrow_rounded),
          iconSize: 32,
          color: Colors.blue,
        ),
        _buildDisposeButton(node, node.deviceInput),
      ],
      children: [
        _buildTitledData('Device', node.deviceInput.deviceInfo.name),
        _buildTitledData('Backend', node.deviceInput.context.activeBackend.name.toUpperCase()),
        _buildTitledData('Buffered', '${node.deviceInput.availableReadFrames}'),
        _buildTitledData(
          'Free',
          '${node.deviceInput.availableWriteFrames}',
          color: node.deviceInput.availableWriteFrames == 0 ? Colors.red : Colors.black,
        ),
      ],
    );
  }

  Widget _buildDeviceOutNodeContent(MabDeviceOutputNode node) {
    return NodeViewBase(
      node: node,
      icon: Icons.headphones,
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              if (node.deviceOutput.isStarted) {
                node.deviceOutput.stop();
              } else {
                node.deviceOutput.start();
              }
            });
          },
          icon: Icon(node.deviceOutput.isStarted ? Icons.pause_rounded : Icons.play_arrow_rounded),
          iconSize: 32,
          color: Colors.blue,
        ),
      ],
      children: [
        _buildTitledData('Device', node.deviceOutput.deviceInfo.name),
        _buildTitledData('Backend', node.deviceOutput.context.activeBackend.name.toUpperCase()),
        _buildTitledData(
          'Buffered',
          '${node.deviceOutput.availableReadFrames}',
          color: node.deviceOutput.availableReadFrames == 0 ? Colors.red : Colors.black,
        ),
        _buildTitledData('Free', '${node.deviceOutput.availableWriteFrames}'),
      ],
    );
  }

  Widget _buildPlayerNodeContent(PlayerNode node) {
    return NodeViewBase(
      node: node,
      icon: Icons.music_note,
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              if (node.isPlaying) {
                node.pause();
              } else {
                node.play();
              }
            });
          },
          icon: Icon(node.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
          iconSize: 32,
          color: Colors.blue,
        ),
        IconButton(
          onPressed: () {
            setState(() {
              node.isLoop = !node.isLoop;
            });
          },
          icon: const Icon(Icons.loop),
          iconSize: 32,
          color: node.isLoop ? Colors.blue : Colors.grey,
        ),
        _buildDisposeButton(node, node.decoder),
      ],
      children: [
        _buildTitledData('File', basename(node.decoder.filePath)),
        _buildTitledData('Cursor', '${node.decoder.cursor}'),
        _buildTitledData('Length', '${node.decoder.length}'),
        _buildTitledData('Position', AudioTime.fromFrames(frames: node.decoder.cursor, format: node.decoder.format).formatHHMMSS()),
        _buildTitledData('Duration', AudioTime.fromFrames(frames: node.decoder.length, format: node.decoder.format).formatHHMMSS()),
      ],
    );
  }

  Widget _buildTitledData(String title, String data, {Color color = Colors.black}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(4),
          child: Text(':'),
        ),
        Expanded(
          child: Text(
            data,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisposeButton(AudioNode node, Disposable? disposable) {
    return IconButton(
      onPressed: () => widget.onDispose(node, disposable),
      color: Colors.red,
      icon: const Icon(Icons.delete_forever_rounded),
    );
  }
}
