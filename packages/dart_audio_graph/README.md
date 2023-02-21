# Overview

`dart_audio_graph` is a high performance audio processing library written in dart.
This package aims to provide low-level audio functionalities such as format, buffer, and time management.

## Audio Format

`AudioFormat` class holds sample rate, channels, sample format.
Currently, sample format supports only 32bit float format

## Audio Processing

You can use `AudioNode` subclasses to produce, process or consume an audio buffer.
There are two kinds of nodes are available.

- Data Source Node
    - produces the audio data and write to buffer
    - usually extends the `DataSourceNode` abstract class
- Processor Node
    - manipulate, consume, and/or passthrough the audio buffer to connected node
    - usually mixins the `ProcessorNodeMixin`

For example, `FunctionNode` can produce wave data, which extends the `DataSourceNode`.
It has one `outputBus` so that you can read audio data from it.

Below code generates 48000hz stereo sine wave audio data.
```dart
import 'package:dart_audio_graph/dart_audio_graph.dart';

const format = AudioFormat(sampleRate: 48000, channels: 2);
final functionNode = FunctionNode(
  function: const SineFunction(),
  frequency: 440,
);
final buffer = FrameBuffer.allocate(
  frames: 1024,
  format: format,
);

final int framesRead = functionNode.outputBus.read(buffer); // Read to the buffer and returns the number of frames produces
buffer.limit(framesRead).acquireFloatListView((audioSampleList) {
  // Do whatever you want!
});
buffer.dispose(); // You have to dispose the buffer. Memory leaks otherwise.
```

`dart_audio_graph` provides following nodes.

- GraphNode
- FunctionNode
- MixerNode
- VolumeNode
- etc

Each node has one or more busses to connect with other nodes.

Use the `GraphNode` to implement node graph based audio processing.
`GraphNode` has `connect` and `connectEndpoint`.

## Buffer

You can manage audio buffers by using `AllocatedFrameBuffer` class.

`FrameBuffer` have `acquire` methods to access the audio buffer in various ways.
```dart
final buffer = AllocatedFrameBuffer(frames: 1024, format: format);
buffer.acquireBuffer((Pointer<Uint8> pBuffer) {
  // pBuffer is an actual internal buffer of FrameBuffer class.
  // Use with caution because you can crash the app easily when buffer overrun or something like that.
})
buffer.acquireFloatListView((Float32List floatList) {
  // floatList is a view of internal buffer.
  // Internal buffer reflects the changes if you modify the floatList.
});
buffer.dispose();
```

Also, `FrameBuffer` have `offset` and `limit` methods to retrieve the sub view of `FrameBuffer`.
```dart
final buffer = AllocatedFrameBuffer(frames: 1024, format: format);
final subBuffer1 = buffer.limit(128); // Take first 128 frames.
final subBuffer2 = buffer.offset(128) // Skip first 128 frames.
buffer.dispose(); // subBuffer1 and subBuffer2 will invalidated too.
```
