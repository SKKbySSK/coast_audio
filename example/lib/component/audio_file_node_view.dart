import 'dart:async';
import 'dart:math';

import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_fft/dart_audio_graph_fft.dart';
import 'package:example/node/audio_file_node.dart';
import 'package:example/painter/fft_painter.dart';
import 'package:example/painter/wave_painter.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class AudioFileNodeView extends StatefulWidget {
  const AudioFileNodeView({
    Key? key,
    required this.filePath,
    required this.format,
    required this.connect,
  }) : super(key: key);
  final String filePath;
  final AudioFormat format;
  final void Function(AudioOutputBus) connect;

  @override
  State<AudioFileNodeView> createState() => _AudioFileNodeViewState();
}

class _AudioFileNodeViewState extends State<AudioFileNodeView> {
  FftResult? _fftResult;
  List<double> _buffer = [];
  late final _ringBuffer = FrameRingBuffer(frames: 512, format: widget.format);
  late final _fftBuffer = AllocatedFrameBuffer(frames: _ringBuffer.capacity, format: widget.format);
  late final _node = AudioFileNode(
    filePath: widget.filePath,
    format: widget.format,
    onFftCompleted: (result) {
      setState(() {
        _fftResult = result;
      });
    },
    onRead: (buffer) {
      _ringBuffer.write(buffer);
      if (_ringBuffer.length == _ringBuffer.capacity) {
        final readFrames = _ringBuffer.read(_fftBuffer);
        setState(() {
          _buffer = _fftBuffer.limit(readFrames).copyFloatList(deinterleave: true).take(readFrames).toList();
        });
      }
    },
  );

  @override
  void initState() {
    super.initState();
    widget.connect(_node.outputBus);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(basename(widget.filePath)),
          const SizedBox(height: 4),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_fftResult != null)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: CustomPaint(
                        painter: FftPainter(_fftResult!, 0, 4000),
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: CustomPaint(
                      painter: WavePainter(_buffer),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const SizedBox(
                width: 30,
                child: Text('Vol'),
              ),
              Expanded(
                child: Slider(
                  value: _node.volume,
                  min: 0,
                  max: 1,
                  onChanged: (vol) {
                    setState(() {
                      _node.volume = vol;
                    });
                  },
                ),
              ),
              SizedBox(
                width: 60,
                child: Text('${(_node.volume * 100).toStringAsPrecision(3)}%'),
              ),
            ],
          ),
          _PositionNode(node: _node, format: widget.format),
          const Divider(),
        ],
      ),
    );
  }
}

class _PositionNode extends StatefulWidget {
  const _PositionNode({
    Key? key,
    required this.node,
    required this.format,
  }) : super(key: key);
  final AudioFileNode node;
  final AudioFormat format;

  @override
  State<_PositionNode> createState() => _PositionNodeState();
}

class _PositionNodeState extends State<_PositionNode> {
  late var cursor = widget.node.cursor;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        cursor = widget.node.cursor;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(AudioTime.fromFrames(frames: widget.node.cursor, format: widget.format).formatMMSS()),
        ),
        Expanded(
          child: Slider(
            value: cursor.toDouble(),
            min: 0,
            max: max(widget.node.length, cursor).toDouble(),
            onChanged: (cursor) {
              setState(() {
                widget.node.cursor = cursor.toInt();
              });
            },
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(AudioTime.fromFrames(frames: widget.node.length, format: widget.format).formatMMSS()),
        ),
      ],
    );
  }
}
