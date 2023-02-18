import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_fft/dart_audio_graph_fft.dart';
import 'package:example/node/function_graph_node.dart';
import 'package:example/painter/fft_painter.dart';
import 'package:example/painter/wave_painter.dart';
import 'package:flutter/material.dart';

class FunctionGraphNodeView extends StatefulWidget {
  const FunctionGraphNodeView({
    Key? key,
    required this.function,
    required this.format,
    required this.connect,
  }) : super(key: key);
  final WaveFunction function;
  final AudioFormat format;
  final void Function(AudioOutputBus) connect;

  @override
  State<FunctionGraphNodeView> createState() => _FunctionGraphNodeViewState();
}

class _FunctionGraphNodeViewState extends State<FunctionGraphNodeView> {
  FftResult? _fftResult;
  List<double> _buffer = [];
  late final _ringBuffer = FrameRingBuffer(frames: 512, format: widget.format);
  late final _fftBuffer = AllocatedFrameBuffer(frames: _ringBuffer.capacity, format: widget.format);
  late final _node = FunctionGraphNode(
    function: widget.function,
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
          Text(
            widget.function.toString().replaceAll('Instance of ', '').replaceAll('\'', '').replaceAll('Function', ''),
          ),
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
          Row(
            children: [
              const SizedBox(
                width: 30,
                child: Text('Freq'),
              ),
              Expanded(
                child: Slider(
                  value: _node.frequency,
                  min: 0,
                  max: 2000,
                  onChanged: (freq) {
                    setState(() {
                      _node.frequency = freq;
                    });
                  },
                ),
              ),
              SizedBox(
                width: 60,
                child: Text('${_node.frequency.toStringAsPrecision(4)}Hz'),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
