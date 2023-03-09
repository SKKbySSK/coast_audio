import 'package:coast_audio/coast_audio.dart';

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
  List<SampleFormat> get supportedSampleFormats => const [
        SampleFormat.int16,
        SampleFormat.uint8,
        SampleFormat.int32,
        SampleFormat.float32,
      ];

  @override
  int read(AudioOutputBus outputBus, RawFrameBuffer buffer) {
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
