import 'package:coast_audio/ca_device/bindings.dart';

enum AudioDitherMode {
  none(ca_dither_mode.ca_dither_mode_none),
  rectangle(ca_dither_mode.ca_dither_mode_triangle),
  triangle(ca_dither_mode.ca_dither_mode_triangle);

  const AudioDitherMode(this.caValue);
  final int caValue;
}