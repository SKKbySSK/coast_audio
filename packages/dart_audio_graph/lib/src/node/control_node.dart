import 'package:dart_audio_graph/dart_audio_graph.dart';

class ControlNode extends AutoFormatSingleInoutNode {
  ControlNode({
    bool isPlaying = true,
    this.fillWhenPaused = false,
  }) : _isPlaying = isPlaying;

  var _isPlaying = false;
  bool get isPlaying => _isPlaying;

  bool fillWhenPaused;

  void play() => _isPlaying = true;

  void pause() => _isPlaying = false;

  @override
  int read(AudioOutputBus outputBus, AcquiredFrameBuffer buffer) {
    if (!_isPlaying) {
      if (fillWhenPaused) {
        buffer.fill(0);
        return buffer.sizeInFrames;
      } else {
        return 0;
      }
    }

    return super.read(outputBus, buffer);
  }
}
