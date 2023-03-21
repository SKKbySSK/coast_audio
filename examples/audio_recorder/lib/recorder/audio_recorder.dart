import 'package:coast_audio_fft/src/experimental/convolver_node.dart';
import 'package:flutter_coast_audio_miniaudio/flutter_coast_audio_miniaudio.dart';

class AudioRecorder extends MabAudioRecorder {
  static const _convolverNodeId = 'CONVOLVER_NODE';
  static const _delayNodeId = 'DELAY_NODE';

  AudioRecorder({
    super.bufferFrameSize,
    super.format,
    required super.onInput,
    this.impulseResponse,
  });

  MabAudioDecoder? impulseResponse;

  @override
  void connectCaptureToVolume(
    AudioGraphBuilder builder, {
    required String captureNodeId,
    required int captureNodeBusIndex,
    required String volumeNodeId,
    required int volumeNodeBusIndex,
  }) {
    final processorIds = <String>[];
    final processorOutBusses = <int>[];
    final processorInBusses = <int>[];

    processorIds.add(captureNodeId);
    processorOutBusses.add(captureNodeBusIndex);

    builder.addNode(
      id: _delayNodeId,
      node: DelayNode(
        delayFrames: const AudioTime(0.1).computeFrames(format),
        delayStart: false,
        format: format,
        decay: 0.4,
      ),
    );
    processorIds.add(_delayNodeId);
    processorInBusses.add(0);
    processorOutBusses.add(0);

    final ir = impulseResponse;
    if (ir != null) {
      builder.addNode(
        id: _convolverNodeId,
        node: ConvolverNode(
          format: format,
          impulseResponseDecoder: ir,
        ),
      );
      processorIds.add(_convolverNodeId);
      processorInBusses.add(0);
      processorOutBusses.add(0);
    }

    processorIds.add(volumeNodeId);
    processorInBusses.add(volumeNodeBusIndex);

    for (var i = 0; processorIds.length - 1 > i; i++) {
      builder.connect(
        outputNodeId: processorIds[i],
        outputBusIndex: processorOutBusses[i],
        inputNodeId: processorIds[i + 1],
        inputBusIndex: processorInBusses[i],
      );
    }
  }
}
