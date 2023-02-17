import 'package:dart_audio_graph_miniaudio/src/ma_result.dart';

extension MaResultExtension on int {
  void throwMaResultIfNeeded() {
    MaResult(this).throwIfNeeded();
  }

  MaResult toMaResult() {
    return MaResult(this);
  }

  bool toBool() {
    return this == 1;
  }
}

extension MabBoolExtension on bool {
  int toMabBool() {
    return this ? 1 : 0;
  }
}
