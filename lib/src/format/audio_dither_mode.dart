import '../interop/internal/generated/bindings.dart';

enum AudioDitherMode {
  none(ma_dither_mode.ma_dither_mode_none),
  rectangle(ma_dither_mode.ma_dither_mode_rectangle),
  triangle(ma_dither_mode.ma_dither_mode_triangle);

  const AudioDitherMode(this.maValue);
  final int maValue;
}
