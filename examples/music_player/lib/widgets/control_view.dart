import 'package:flutter/material.dart';
import 'package:music_player/player/music_player.dart';
import 'package:music_player/widgets/artwork_view.dart';
import 'package:music_player/widgets/position_slider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

class ControlView extends StatelessWidget {
  const ControlView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final player = context.watch<MusicPlayer>();
    final metadata = player.metadata;

    return Column(
      children: [
        Expanded(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(player.isPlaying ? 0 : 16),
            curve: Curves.decelerate,
            child: FittedBox(
              fit: BoxFit.contain,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ArtworkView(metadata: metadata),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const PositionSlider(),
        Text(
          metadata?.trackName ?? path.basename(player.filePath ?? ''),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '${metadata?.albumName ?? ''} - ${metadata?.trackArtistNames?.join(',') ?? ''}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: player.isReady
                  ? () {
                      if (player.isPlaying) {
                        player.pause();
                      } else {
                        player.play();
                      }
                    }
                  : null,
              iconSize: 64,
              icon: Icon(player.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.volume_up_rounded,
              size: 32,
            ),
            Expanded(
              child: Slider(
                value: player.volume,
                onChanged: (volume) {
                  player.volume = volume;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
