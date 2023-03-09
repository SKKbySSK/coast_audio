import 'dart:async';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio_miniaudio/coast_audio_miniaudio.dart';
import 'package:example/component/node_view_base.dart';
import 'package:example/node/player_node.dart';
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

      setState(() {});
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
      case ConverterNode:
        return _buildConverterNodeContent(widget.node as ConverterNode);
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
    final format = node.format;
    return NodeViewBase(
      node: node,
      icon: Icons.merge,
      actions: const [],
      children: [
        _buildTitledData('Inputs', node.inputs.length.toString()),
        _buildTitledData('SampleRate', '${format.sampleRate}Hz'),
        _buildTitledData('Channels', '${format.channels}ch'),
        _buildTitledData('Format', format.sampleFormat.name),
      ],
    );
  }

  Widget _buildDeviceInNodeContent(MabDeviceInputNode node) {
    final deviceInfo = node.device.getDeviceInfo();
    final deviceName = deviceInfo?.name ?? '<NULL>';

    return NodeViewBase(
      node: node,
      icon: Icons.mic,
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              if (node.device.isStarted) {
                node.device.stop();
              } else {
                node.device.start();
              }
            });
          },
          icon: Icon(node.device.isStarted ? Icons.pause_rounded : Icons.play_arrow_rounded),
          iconSize: 32,
          color: Colors.blue,
        ),
        _buildDisposeButton(node, node.device),
      ],
      children: [
        _buildTitledData('Device', deviceName),
        _buildTitledData('Backend', node.device.context.activeBackend.formattedName),
        _buildTitledData('Buffered', '${node.device.availableReadFrames}'),
        _buildTitledData(
          'Free',
          '${node.device.availableWriteFrames}',
          color: node.device.availableWriteFrames == 0 ? Colors.red : Colors.black,
        ),
      ],
    );
  }

  Widget _buildDeviceOutNodeContent(MabDeviceOutputNode node) {
    final deviceInfo = node.device.getDeviceInfo();
    final deviceName = deviceInfo?.name ?? '<NULL>';

    return NodeViewBase(
      node: node,
      icon: Icons.headphones,
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              if (node.device.isStarted) {
                node.device.stop();
              } else {
                node.device.start();
              }
            });
          },
          icon: Icon(node.device.isStarted ? Icons.pause_rounded : Icons.play_arrow_rounded),
          iconSize: 32,
          color: Colors.blue,
        ),
      ],
      children: [
        _buildTitledData('Device', deviceName),
        _buildTitledData('Backend', node.device.context.activeBackend.formattedName),
        _buildTitledData(
          'Buffered',
          '${node.device.availableReadFrames}',
          color: node.device.availableReadFrames == 0 ? Colors.red : Colors.black,
        ),
        _buildTitledData('Free', '${node.device.availableWriteFrames}'),
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

  Widget _buildConverterNodeContent(ConverterNode node) {
    return NodeViewBase(
      node: node,
      icon: Icons.arrow_right_alt_outlined,
      actions: const [],
      children: [
        _buildTitledData('SampleRate', '${node.converter.inputFormat.sampleRate}→${node.converter.outputFormat.sampleRate}'),
        _buildTitledData('Channels', '${node.converter.inputFormat.channels}→${node.converter.outputFormat.channels}'),
        _buildTitledData('SampleFormat', '${node.converter.inputFormat.sampleFormat.name}→${node.converter.outputFormat.sampleFormat.name}'),
        _buildTitledData('Passthrough', '${node.converter.noConversion}'),
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
