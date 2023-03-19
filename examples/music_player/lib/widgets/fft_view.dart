import 'dart:math';

import 'package:coast_audio_fft/coast_audio_fft.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:music_player/painter/fft_painter.dart';
import 'package:music_player/player/isolated_music_player.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';

class FftView extends StatefulWidget {
  const FftView({Key? key}) : super(key: key);

  @override
  State<FftView> createState() => _FftViewState();
}

class _FftViewState extends State<FftView> with SingleTickerProviderStateMixin {
  final _palette = [Colors.grey.shade300];
  Metadata? _lastMetadata;
  late final Ticker _ticker;
  FftResult? _fftResult;

  late final _player = context.read<IsolatedMusicPlayer>();

  @override
  void initState() {
    super.initState();
    _player.addListener(_playerListener);
    _ticker = createTicker((elapsed) {
      setState(() {
        _fftResult = _player.lastFftResult;
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _player.removeListener(_playerListener);
    super.dispose();
  }

  void _playerListener() async {
    if (_player.metadata == _lastMetadata) {
      return;
    }

    _lastMetadata = _player.metadata;
    final image = _player.metadata?.albumArt;
    if (image != null) {
      final paletteGen = await PaletteGenerator.fromImageProvider(MemoryImage(image));
      setState(() {
        if (paletteGen.lightVibrantColor != null || paletteGen.lightMutedColor != null) {
          _palette
            ..clear()
            ..add((paletteGen.lightVibrantColor ?? paletteGen.lightMutedColor!).color);
          return;
        }

        _palette
          ..clear()
          ..add(paletteGen.paletteColors[Random().nextInt(paletteGen.paletteColors.length)].color);
      });
    } else {
      setState(() {
        _palette
          ..clear()
          ..add(Colors.grey.shade300);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Visibility(
      visible: _fftResult != null,
      child: _fftResult != null
          ? RepaintBoundary(
              child: CustomPaint(
                painter: FftPainter(
                  _fftResult!,
                  10,
                  max(width * 10, 8000),
                  _palette,
                  width ~/ 30,
                ),
              ),
            )
          : const SizedBox(),
    );
  }
}
