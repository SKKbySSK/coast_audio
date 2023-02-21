# Overview

`dart_audio_graph` is a high performance audio processing library written in dart.\
This package aims to provide low-level audio functionalities.

## Audio Format

`AudioFormat` contains sample rate, channels, sample format information.
You may usually use this class to allocate audio buffer or provide information to audio nodes.

## Audio Processing

You can use `AudioNode` subclasses to produce or process an audio buffer.\
There are two kinds of nodes are available.

- Data Source Node
    - produces the audio data and write to buffer
    - usually extends the `DataSourceNode` abstract class
- Processor Node
    - manipulate, consume, and/or passthrough the audio buffer to the connected node
    - usually extends the `SingleInOutNode` with `ProcessorNodeMixin`.

For example, `FunctionNode` can produce wave data based on the supplied function, which extends the `DataSourceNode`.\
It has one `outputBus` so you can read audio data from it.

Below code generates 48000hz stereo sine wave.
```dart
import 'package:dart_audio_graph/dart_audio_graph.dart';

const format = AudioFormat(sampleRate: 48000, channels: 2); // sampleFormat is float32 by default.
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

To build your own audio graph, use the `GraphNode` class.\
`GraphNode` have `connect` and `connectEndpoint` methods to connect between node's bus.

#### Example: Wave Volume Control

This example generates sine wave and applies volume 50%.

```dart
final graphNode = GraphNode();
final sineNode = FunctionNode(function: const SineFunction(), format: format, frequency: 440);
final sineVolumeNode = VolumeNode(volume: 0.5);

// FunctionNode(Sine) -> VolumeNode
graphNode.connect(sineNode.outputBus, sineVolumeNode.inputBus);

// VolumeNode -> GraphNode's Endpoint
graphNode.connectEndpoint(sineVolumeNode.outputBus);

// Read to your buffer. (Returned value has how many frames written to your buffer)
final framesRead = graphNode.outputBus.read(buffer);
final readBuffer = buffer.limit(framesRead);
```

## Audio Buffer

You can manage audio buffers by using `AllocatedFrameBuffer` class.

`AllocatedFrameBuffer` have `lock` and `unlock` methods to access the `RawFrameBuffer` which contains raw data pointer.
```dart
final buffer = AllocatedFrameBuffer(frames: 1024, format: format);
final rawBuffer = buffer.lock();
try {
  // Use the rawBuffer.pBuffer to access the raw audio data.
  // Or you can call rawBuffer.asFloatListView() to acquire the view of list data.
} finally {
  rawBuffer.unlock();
}
buffer.dispose();
```

Or you can use acquireBuffer to lock & unlock audio buffer automatically.
```dart
buffer.acquireBuffer((rawBuffer) {
  // buffer will be unlocked when the callback method is finished.
});
```

`RawFrameBuffer` have `offset` and `limit` methods to retrieve the sub view of `RawFrameBuffer`.
```dart
final buffer = AllocatedFrameBuffer(frames: 1024, format: format);
final rawBuffer = buffer.lock();
final subBuffer1 = rawBuffer.limit(128); // Takes first 128 frames.
final subBuffer2 = rawBuffer.offset(128); // Skips first 128 frames.
rawBuffer.unlock();
buffer.dispose(); // subBuffer1 and subBuffer2 will invalidated too.
```

## Audio Decoder

When you want to read audio data from a file, use the `AudioFileDataSource` class and pass it to the `AudioDecoder` subclasses.\
Currently, this package only provides `WavAudioDecoder` which can read the wav file from the data source.

If you want to read a mp3 or flac file, use the [dart_audio_graph_miniaudio](https://github.com/SKKbySSK/dart_audio_graph/tree/main/packages/dart_audio_graph_miniaudio) package instead.\
It has [MabAudioDecoder](https://github.com/SKKbySSK/dart_audio_graph/blob/main/packages/dart_audio_graph_miniaudio/lib/src/ma_bridge/mab_audio_decoder.dart) class to read audio data from the file.

Then, you can initialize the `DecoderNode` to supply audio data to your audio graph.
