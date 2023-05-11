# Overview

`coast_audio` is a high performance audio processing library written in dart.\
This package aims to provide low-level audio functionalities.

## Features

- Format Management
  - Channel Converter
  - Sample Format Converter
- Audio Buffer
- Ring Buffer
- Encoding and Decoding
- Wave Generation
  - Sine
  - Triangle
  - Square
  - Sawtooth
- Effects
  - Delay
  - Mixer
  - Volume

## Audio Format

`AudioFormat` contains sample rate, channels, sample format information.\
You may usually use this class to allocate audio buffers or provide information to audio nodes.

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
import 'package:coast_audio/coast_audio.dart';

const format = AudioFormat(sampleRate: 48000, channels: 2); // sampleFormat is float32 by default.
final functionNode = FunctionNode(
  function: const SineFunction(),
  frequency: 440,
);
final frames = AllocatedAudioFrames(
  length: 1024,
  format: format,
);

// Read to the buffer and access the audio data in 32bit floating point format.
frames.acquireBuffer((buffer) {
  final framesRead = functionNode.outputBus.read(buffer);
  final floatList = buffer.limit(framesRead).asFloatListView();
  // Do whatever you want!
});

// Dispose the buffer.
frames.dispose();
```

`coast_audio` has various kinds of [built-in nodes](https://github.com/SKKbySSK/coast_audio/tree/main/packages/coast_audio/lib/src/node).\
Each node has one or more busses to connect with other nodes.

### GraphNode

To build your own audio graph, use the `GraphNode` class.\
`GraphNode` has `connect` and `connectEndpoint` methods to connect between node's bus.

#### Example: mixing multiple nodes and write to wav file

See the [example code](https://github.com/SKKbySSK/coast_audio/blob/main/examples/audio_graph_demo/bin/audio_graph_demo.dart).

## Audio Buffer

### AudioFrames

By using `AudioFrames` subclasses, you can manage audio buffers easily.\
In most cases, you should use the `AllocatedAudioFrames` class.

`AudioFrames` have `lock` and `unlock` methods to access the `AudioBuffer` which contains the pointer to raw audio data.
```dart
final frames = AllocatedAudioFrames(length: 1024, format: format);
final buffer = frames.lock();
try {
  // Use the buffer.pBuffer to access the raw audio data.
  // Or you can call buffer.asFloatListView() to acquire the view of list data.
} finally {
  frames.unlock();
}
frames.dispose();
```

Or you can use `acquireBuffer` to lock & unlock audio buffer automatically.
```dart
frames.acquireBuffer((niffer) {
  // frames will be unlocked when the callback method is finished.
});
```

`AudioBuffer` has `offset` and `limit` methods to retrieve the sub view of `AudioBuffer`.
```dart
final frames = AllocatedAudioFrames(length: 1024, format: format);
final buffer = frames.lock();
final subBuffer1 = buffer.limit(128); // Takes first 128 frames.
final subBuffer2 = buffer.offset(128); // Skips first 128 frames.
frames.unlock();
frames.dispose(); // subBuffer1 and subBuffer2 will be invalidated too.
```

### RingBuffer

`coast_audio` provides ring buffer implementations.\
You can use the `FrameRingBuffer` to manage audio frames, or use the `RingBuffer` to manage data in binary format.

## Audio Decoder

When you want to read audio data from a file, use the `AudioFileDataSource` class and pass it to the `AudioDecoder` subclasses.\
Currently, this package only provides `WavAudioDecoder` which can decode wav audio data from the data source.

```dart
final dataSource = AudioFileDataSource(file: File('test.wav'), mode: FileMode.read);
final decoder = WavAudioDecoder(dataSource: dataSource);

final frames = AllocatedAudioFrames(length: 512, format: decoder.format);
frames.acquireBuffer((buffer) {
  final result = decoder.decode(destination: buffer);
  final readBuffer = buffer.limit(result.frames);
  // `readBuffer` is now contains decoded audio data.
});
frames.dispose();
dataSource.dispose();
```

If you want to read a mp3 or flac file, use the [coast_audio_miniaudio](https://github.com/SKKbySSK/coast_audio/tree/main/packages/coast_audio_miniaudio) package instead.\
It has [MabAudioDecoder](https://github.com/SKKbySSK/coast_audio/blob/main/packages/coast_audio_miniaudio/lib/src/ma_bridge/mab_audio_decoder.dart) class to read audio data from files.

Then, you can initialize the `DecoderNode` to decode audio data in real-time.
