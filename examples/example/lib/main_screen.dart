import 'package:dart_audio_graph/dart_audio_graph.dart';
import 'package:dart_audio_graph_miniaudio/dart_audio_graph_miniaudio.dart';
import 'package:example/component/add_mixer_input_dialog.dart';
import 'package:example/component/node_view.dart';
import 'package:example/component/wave_view.dart';
import 'package:flutter/material.dart';
import 'package:graphite/graphite.dart';

class GraphiteAudioNodeInput<T extends AudioNode> {
  static var _id = 0;
  GraphiteAudioNodeInput(this.node, this.connectedInputs) : id = (_id++).toString();
  final String id;
  final T node;
  final List<GraphiteAudioNodeInput> connectedInputs;

  NodeInput toNodeInput() => NodeInput(id: id, next: connectedInputs.map((e) => EdgeInput(outcome: e.id)).toList());
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _inputFormat = const AudioFormat(sampleRate: 48000, channels: 2);
  final _outputFormat = const AudioFormat(sampleRate: 48000, channels: 2);
  late final _output = AudioOutput.latency(
    outputBus: _graphNode.outputBus,
    format: _outputFormat,
    latency: const Duration(milliseconds: 25),
    onOutput: (buffer) {
      _ringBuffer.write(buffer);
      setState(() {
        _waveBuffer.acquireBuffer((buffer) {
          _ringBuffer.peek(buffer);
        });
        _fftBuffer.acquireBuffer((buffer) {
          _ringBuffer.read(buffer);
        });
      });
    },
  );

  late final _ringBuffer = FrameRingBuffer(frames: 1024, format: _outputFormat);
  late final _waveBuffer = AllocatedFrameBuffer(frames: _ringBuffer.capacity, format: _outputFormat, fillZero: true);
  late final _fftBuffer = AllocatedFrameBuffer(frames: _ringBuffer.capacity, format: _outputFormat, fillZero: true);

  final _mixerInputNodes = <GraphiteAudioNodeInput>[];
  late final _mixerNode = GraphiteAudioNodeInput(MixerNode(format: _inputFormat, isClampEnabled: true), [_converterNode]);
  late final _converterNode = GraphiteAudioNodeInput(ConverterNode(converter: AudioFormatConverter(inputFormat: _inputFormat, outputFormat: _outputFormat)), [_deviceOutputNode]);
  late final _deviceOutputNode = GraphiteAudioNodeInput(
    MabDeviceOutputNode(
      deviceOutput: MabDeviceOutput(
        context: MabDeviceContext.sharedInstance,
        format: _outputFormat,
        bufferFrameSize: 2048,
        noFixedSizedCallback: false,
      ),
    ),
    [],
  );
  final _graphNode = GraphNode();

  @override
  void initState() {
    super.initState();
    _graphNode.connect(_mixerNode.node.outputBus, _converterNode.node.inputBus);
    _graphNode.connect(_converterNode.node.outputBus, _deviceOutputNode.node.inputBus);
    _graphNode.connectEndpoint(_deviceOutputNode.node.outputBus);
    _deviceOutputNode.node.deviceOutput.start();
  }

  @override
  Widget build(BuildContext context) {
    final inputList = <GraphiteAudioNodeInput>[
      ..._mixerInputNodes,
      _mixerNode,
      _converterNode,
      _deviceOutputNode,
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Dart Audio Graph')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ColoredBox(
                color: Colors.grey.shade300,
                child: DirectGraph(
                  list: inputList.map((e) => e.toNodeInput()).toList()
                    ..add(NodeInput(
                      id: 'add',
                      next: [EdgeInput(outcome: _mixerNode.id)],
                      size: const NodeSize(width: 100, height: 100),
                    )),
                  orientation: MatrixOrientation.Horizontal,
                  defaultCellSize: const Size(240, 230),
                  cellPadding: const EdgeInsets.all(16),
                  nodeBuilder: (context, input) {
                    if (input.id == 'add') {
                      return _buildAddNode();
                    }
                    return NodeView(
                      id: input.id,
                      onDispose: (node, disposable) {
                        final inputBus = node.outputs[0].connectedBus!;
                        _graphNode.disconnect(node.outputs[0]);
                        _mixerNode.node.removeInputBus(inputBus);

                        setState(() {
                          _mixerInputNodes.removeWhere((n) => n.node == node);
                        });

                        if (disposable is SyncDisposable) {
                          disposable.dispose();
                        }
                        if (disposable is AsyncDisposable) {
                          disposable.dispose();
                        }
                      },
                      node: inputList.firstWhere((e) => e.id == input.id).node,
                    );
                  },
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Output (Wave Buffer)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: WaveView(buffer: _waveBuffer),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Clock',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Interval: ${_output.interval.inMilliseconds}ms'),
                          const SizedBox(width: 8),
                          Text('Elapsed: ${_output.elapsed.seconds.toInt()}s'),
                        ],
                      )
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (_output.isStarted) {
                          _output.stop();
                        } else {
                          _output.start();
                        }
                      });
                    },
                    icon: Icon(_output.isStarted ? Icons.pause_circle : Icons.play_circle),
                    iconSize: 32,
                    color: Colors.blue,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAddNode() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AddMixerInputDialog(
              format: _inputFormat,
              onSelect: (node) {
                setState(
                  () {
                    _mixerInputNodes.add(GraphiteAudioNodeInput(node, [_mixerNode]));
                    _graphNode.connect(node.outputs[0], _mixerNode.node.appendInputBus());
                  },
                );
              },
            );
          },
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.add_circle,
              size: 32,
              color: Colors.blue,
            ),
            SizedBox(height: 4),
            Text(
              'Add',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
