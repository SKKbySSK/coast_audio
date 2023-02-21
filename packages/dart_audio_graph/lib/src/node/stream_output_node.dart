import 'dart:async';
import 'dart:typed_data';

import 'package:dart_audio_graph/dart_audio_graph.dart';

class StreamOutputNode extends AutoFormatSingleInoutNode with ProcessorNodeMixin implements AsyncDisposable {
  final _streamController = StreamController<Uint8List>();
  late final _streamDisposable = _streamController.asDisposable();

  Stream<Uint8List> get stream => _streamController.stream;

  @override
  bool get isDisposed => _streamDisposable.isDisposed;

  @override
  bool get isDisposing => _streamDisposable.isDisposing;

  @override
  void throwIfNotAvailable([String? target]) => _streamDisposable.throwIfNotAvailable(target);

  @override
  List<SampleFormat> get supportedSampleFormats => const [
        SampleFormat.int16,
        SampleFormat.uint8,
        SampleFormat.int32,
        SampleFormat.float32,
      ];

  @override
  int process(RawFrameBuffer buffer) {
    _streamController.sink.add(Uint8List.fromList(buffer.asUint8ListViewFrames()));
    return buffer.sizeInFrames;
  }

  @override
  Future<void> dispose() => _streamDisposable.dispose();
}
