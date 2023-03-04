import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:music_player/player/music_player.dart';
import 'package:provider/provider.dart';

class ArtworkImageView extends StatelessWidget {
  const ArtworkImageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final image = context.select<MusicPlayer, Uint8List?>((p) => p.metadata?.albumArt);
    final isPlaying = context.select<MusicPlayer, bool>((p) => p.isPlaying);

    return SizedBox(
      height: 500,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(isPlaying ? 0 : 16),
        curve: Curves.decelerate,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ColoredBox(
              color: Colors.grey.shade700,
              child: image == null ? _buildEmpty() : Image.memory(image, filterQuality: FilterQuality.high),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const AspectRatio(
      aspectRatio: 1,
      child: Center(
        child: Icon(
          Icons.audiotrack_outlined,
          size: 300,
        ),
      ),
    );
  }
}
