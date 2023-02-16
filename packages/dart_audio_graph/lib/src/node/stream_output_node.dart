import 'dart:async';
import 'dart:typed_data';

import 'package:dart_audio_graph/dart_audio_graph.dart';

class StreamOutputNode extends ProcessorNode implements AsyncDisposable {
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
  void process(FrameBuffer buffer) {
    _streamController.sink.add(Uint8List.fromList(buffer.asByteList()));
  }

  @override
  Future<void> dispose() => _streamDisposable.dispose();
}
