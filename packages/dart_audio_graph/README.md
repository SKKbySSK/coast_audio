# Overview

`dart_audio_graph` is a high performance audio processing library written in dart.\
This package aims to provide low-level audio functionalities.

## Audio Format

`AudioFormat` class holds sample rate, channels, sample format.\
Currently, sample format supports only 32bit float format

## Audio Processing

You can use `AudioNode` subclasses to produce, process or consume an audio buffer.\
There are two kinds of nodes are available.

- Data Source Node
    - produces the audio data and write to buffer
    - usually extends the `DataSourceNode` abstract class
- Processor Node
    - manipulate, consume, and/or passthrough the audio buffer to the connected node
    - usually extends the `SingleInOutNode` with `ProcessorNodeMixin`.

For example, `FunctionNode` can produce wave data, which extends the `DataSourceNode`.\
It has one `outputBus` so you can read audio data from it.

Below code generates 48000hz stereo sine wave audio data.
```dart
import 'package:dart_audio_graph/dart_audio_graph.dart';

const format = AudioFormat(sampleRate: 48000, channels: 2);
final functionNode = FunctionNode(
  function: const SineFunction(),
  frequency: 440,
);
final buffer = AllocatedFrameBuffer(
  frames: 1024,
  format: format,
);

// Read to the buffer and returns the number of frames produces
final int framesRead = functionNode.outputBus.read(buffer); 

// Limit the buffer size to framesRead and acquire float list data
buffer.limit(framesRead).acquireFloatListView((audioSampleList) {
  // Do whatever you want!
});

// Dispose the buffer.
buffer.dispose();
```

`dart_audio_graph` has various kinds of [built-in nodes](https://github.com/SKKbySSK/dart_audio_graph/tree/main/packages/dart_audio_graph/lib/src/node)

- GraphNode
- DecoderNode
- ConverterNode
- FunctionNode
- MixerNode
- VolumeNode
- etc

Each node has one or more busses to connect with other nodes.

### GraphNode

Initialize the `GraphNode` class to build your own audio graph.
`GraphNode` have `connect` and `connectEndpoint` methods to connect between node's bus.

#### Example1: Sine wave generation

```dart

```

## Audio Buffer

You can manage audio buffers by using `AllocatedFrameBuffer` class.

`AllocatedFrameBuffer` have `lock` and `unlock` methods to access the `RawFrameBuffer` which contains raw data pointer.
```dart
final buffer = AllocatedFrameBuffer(frames: 1024, format: format);
final rawBuffer = buffer.lock();
// Use the rawBuffer.pBuffer to access the raw audio data.
// Or you can call rawBuffer.asFloatListView() to acquire the view of list data.
rawBuffer.unlock(); // You have to unlock the buffer.
buffer.dispose();
```

`RawFrameBuffer` have `offset` and `limit` methods to retrieve the sub view of `RawFrameBuffer`.
```dart
final buffer = AllocatedFrameBuffer(frames: 1024, format: format);
final rawBuffer = buffer.lock();
final subBuffer1 = rawBuffer.limit(128); // Takes first 128 frames.
final subBuffer2 = rawBuffer.offset(128) // Skips first 128 frames.
rawBuffer.unlock();
buffer.dispose(); // subBuffer1 and subBuffer2 will invalidated too.
```

## Audio Decoder

When you want to read audio data from a file, use the `AudioFileDataSource` class and pass it to the `AudioDecoder` subclasses.\
Currently, this package only provides `WavAudioDecoder` which can read the wav file from the data source.

If you want to read a mp3 or flac file, use the [dart_audio_graph_miniaudio](https://github.com/SKKbySSK/dart_audio_graph/tree/main/packages/dart_audio_graph_miniaudio) package instead.\
It has [MabAudioDecoder](https://github.com/SKKbySSK/dart_audio_graph/blob/main/packages/dart_audio_graph_miniaudio/lib/src/ma_bridge/mab_audio_decoder.dart) class to read audio data from the file.

Then, you can initialize the `DecoderNode` to supply audio data to your graph.
