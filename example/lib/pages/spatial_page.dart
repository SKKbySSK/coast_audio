import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:coast_audio/coast_audio.dart';
import 'package:example/models/audio_state.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SpatialPage extends StatefulWidget {
  const SpatialPage({
    super.key,
    required this.audio,
  });
  final AudioStateConfigured audio;

  @override
  State<SpatialPage> createState() => _SpatialPageState();
}

class _SpatialPageState extends State<SpatialPage> {
  final format = const AudioFormat(sampleRate: 48000, channels: 2);
  late final spatializer = AudioSpatializer(inputFormat: format, outputFormat: format, maxDistance: 20);
  late final listener = AudioSpatializerListener(outputFormat: format)..position = const AudioVector3(0, 3, 0);
  late final deviceContext = AudioDeviceContext(backends: [widget.audio.backend]);
  late final device = deviceContext.createPlaybackDevice(
    format: format,
    bufferFrameSize: const AudioTime(0.1).computeFrames(format),
    deviceId: widget.audio.outputDevice?.id,
  );

  DecoderNode? decoderNode;
  late final spatializerNode = SpatializerNode(spatializer: spatializer, listener: listener);
  late final playbackNode = PlaybackNode(device: device);
  late final Timer timer;

  @override
  void initState() {
    super.initState();
    spatializerNode.outputBus.connect(playbackNode.inputBus);
    timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    playbackNode.device.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spatial Audio'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final file = await openFile();
                  if (file == null) {
                    return;
                  }

                  final decoder = MaAudioDecoder(
                    dataSource: AudioFileDataSource(file: File(file.path), mode: FileMode.read),
                    expectedSampleFormat: format.sampleFormat,
                    expectedChannels: format.channels,
                    expectedSampleRate: format.sampleRate,
                  );
                  final decoderNode = DecoderNode(decoder: decoder);

                  this.decoderNode?.outputBus.disconnect();

                  decoderNode.outputBus.connect(spatializerNode.inputBus);
                  setState(() {
                    this.decoderNode = decoderNode;
                  });
                },
                icon: const Icon(Icons.file_open_rounded),
                label: const Text('Open File'),
              ),
            ),
          ),
          Scrollbar(
            thumbVisibility: true,
            child: SizedBox(
              height: 200,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    children: [
                      _SpatializerOption(
                        name: 'Attenuation Model',
                        child: DropdownButton<AudioAttenuationModel>(
                          items: AudioAttenuationModel.values
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                      e.name,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              spatializer.attenuationModel = value!;
                            });
                          },
                          value: spatializer.attenuationModel,
                        ),
                      ),
                      _SpatializerOption(
                        name: 'Cone Inner Angle',
                        child: Column(
                          children: [
                            Text('${(listener.coneInnerAngleInRadians / pi * 180).toStringAsFixed(1)}°'),
                            Slider(
                              value: clampDouble(listener.coneInnerAngleInRadians, 0, pi * 4),
                              min: 0,
                              max: pi * 4,
                              onChanged: (value) {
                                setState(() {
                                  listener.setCone(innerAngleInRadians: value);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      _SpatializerOption(
                        name: 'Cone Outer Angle',
                        child: Column(
                          children: [
                            Text('${(listener.coneOuterAngleInRadians / pi * 180).toStringAsFixed(1)}°'),
                            Slider(
                              value: clampDouble(listener.coneOuterAngleInRadians, 0, pi * 4),
                              min: 0,
                              max: pi * 4,
                              onChanged: (value) {
                                setState(() {
                                  listener.setCone(outerAngleInRadians: value);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      _SpatializerOption(
                        name: 'Cone Outer Gain',
                        child: Column(
                          children: [
                            Text('${(listener.coneOuterGain * 100).toStringAsFixed(0)}%'),
                            Slider(
                              value: clampDouble(listener.coneOuterGain, 0, 1),
                              min: 0,
                              max: 1,
                              onChanged: (value) {
                                setState(() {
                                  listener.setCone(outerGain: value);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      _SpatializerOption(
                        name: 'Min Gain',
                        child: Column(
                          children: [
                            Text('${(spatializer.minGain * 100).toStringAsFixed(0)}%'),
                            Slider(
                              value: clampDouble(spatializer.minGain, 0, 1),
                              min: 0,
                              max: 1,
                              onChanged: (value) {
                                setState(() {
                                  spatializer.minGain = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      _SpatializerOption(
                        name: 'Max Gain',
                        child: Column(
                          children: [
                            Text('${(spatializer.maxGain * 100).toStringAsFixed(0)}%'),
                            Slider(
                              value: clampDouble(spatializer.maxGain, 0, 1),
                              min: 0,
                              max: 1,
                              onChanged: (value) {
                                setState(() {
                                  spatializer.maxGain = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      _SpatializerOption(
                        name: 'Min Distance',
                        child: Column(
                          children: [
                            Text((spatializer.minDistance).toStringAsFixed(0)),
                            Slider(
                              value: clampDouble(spatializer.minDistance, 0, 50),
                              min: 0,
                              max: 10,
                              onChanged: (value) {
                                setState(() {
                                  spatializer.minDistance = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      _SpatializerOption(
                        name: 'Max Distance',
                        child: Column(
                          children: [
                            Text((spatializer.maxDistance).toStringAsFixed(0)),
                            Slider(
                              value: clampDouble(spatializer.maxDistance, 1, 50),
                              min: 1,
                              max: 50,
                              onChanged: (value) {
                                setState(() {
                                  spatializer.maxDistance = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Center(
              child: _SpatialField(
                spatializer: spatializer,
                listener: listener,
                onSourcePositionChanged: (position) {
                  setState(() {
                    spatializer.position = position;
                  });
                },
                onListenerPositionChanged: (position) {
                  setState(() {
                    listener.position = position;
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Row(
              children: [
                IconButton.outlined(
                  onPressed: () {
                    if (decoderNode == null) {
                      return;
                    }

                    if (playbackNode.device.state == AudioDeviceState.started) {
                      playbackNode.device.stop();
                    } else {
                      playbackNode.device.start();
                      AudioIntervalClock(const AudioTime(0.01)).runWithBuffer(
                        frames: AllocatedAudioFrames(length: 4096, format: format),
                        onTick: (_, buffer) {
                          final result = playbackNode.outputBus.read(buffer);
                          if (result.isEnd) {
                            return false;
                          }

                          if (!playbackNode.device.isStarted) {
                            return false;
                          }

                          return true;
                        },
                      );
                    }
                  },
                  icon: Icon(playbackNode.device.isStarted ? Icons.pause : Icons.play_arrow),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: clampDouble(decoderNode?.decoder.cursorInFrames.toDouble() ?? 0, 0, decoderNode?.decoder.lengthInFrames?.toDouble() ?? 0),
                    min: 0,
                    max: decoderNode?.decoder.lengthInFrames?.toDouble() ?? 0,
                    onChanged: decoderNode == null
                        ? null
                        : (value) {
                            decoderNode?.decoder.cursorInFrames = value.toInt();
                          },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpatializerOption extends StatelessWidget {
  const _SpatializerOption({
    super.key,
    required this.name,
    required this.child,
  });
  final String name;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            name,
            textAlign: TextAlign.center,
          ),
          child,
        ],
      ),
    );
  }
}

class _SpatialField extends StatelessWidget {
  const _SpatialField({
    super.key,
    required this.spatializer,
    required this.listener,
    this.viewportMaxDistance = 25,
    required this.onSourcePositionChanged,
    required this.onListenerPositionChanged,
  });
  final AudioSpatializer spatializer;
  final AudioSpatializerListener listener;
  final double viewportMaxDistance;
  final void Function(AudioVector3 position) onSourcePositionChanged;
  final void Function(AudioVector3 position) onListenerPositionChanged;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.shade900.withOpacity(0.2),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sourceDistance = spatializer.position / viewportMaxDistance;
            final listenerDistance = listener.position / viewportMaxDistance;

            final halfWidth = constraints.maxWidth / 2;
            final halfHeight = constraints.maxHeight / 2;
            final sourceX = halfWidth + sourceDistance.x * halfWidth;
            final sourceY = halfHeight + sourceDistance.y * halfHeight;
            final listenerX = halfWidth + listenerDistance.x * halfWidth;
            final listenerY = halfHeight + listenerDistance.y * halfHeight;

            final maxDistanceRadius = halfWidth * (spatializer.maxDistance / viewportMaxDistance) * 2;
            final minDistanceRadius = halfWidth * (spatializer.minDistance / viewportMaxDistance) * 2;

            return Stack(
              children: [
                Positioned(
                  left: 8,
                  top: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Source: (x: ${spatializer.position.x.toStringAsFixed(1)}, y: ${spatializer.position.y.toStringAsFixed(1)})'),
                      Text('Listener: (x: ${listener.position.x.toStringAsFixed(1)}, y: ${listener.position.y.toStringAsFixed(1)})'),
                    ],
                  ),
                ),
                Positioned(
                  left: sourceX - maxDistanceRadius / 2,
                  top: sourceY - maxDistanceRadius / 2,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.shade800.withOpacity(0.2),
                    ),
                    height: maxDistanceRadius,
                    width: maxDistanceRadius,
                  ),
                ),
                Positioned(
                  left: sourceX - minDistanceRadius / 2,
                  top: sourceY - minDistanceRadius / 2,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.shade800.withOpacity(0.2),
                    ),
                    height: minDistanceRadius,
                    width: minDistanceRadius,
                  ),
                ),
                Positioned(
                  left: sourceX - 16,
                  top: sourceY - 16,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      onSourcePositionChanged(spatializer.position + AudioVector3(details.delta.dx / halfWidth * viewportMaxDistance, details.delta.dy / halfHeight * viewportMaxDistance, 0));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.shade800,
                      ),
                      height: 32,
                      width: 32,
                      child: const Icon(
                        Icons.speaker,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: listenerX - 16,
                  top: listenerY - 16,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      onListenerPositionChanged(listener.position + AudioVector3(details.delta.dx / halfWidth * viewportMaxDistance, details.delta.dy / halfHeight * viewportMaxDistance, 0));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.shade800,
                      ),
                      height: 32,
                      width: 32,
                      child: const Icon(
                        Icons.person,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: listenerX - 12,
                  top: listenerY - 32,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      onListenerPositionChanged(listener.position + AudioVector3(details.delta.dx / halfWidth * viewportMaxDistance, details.delta.dy / halfHeight * viewportMaxDistance, 0));
                    },
                    child: const Icon(
                      Icons.arrow_drop_up_outlined,
                      size: 24,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
