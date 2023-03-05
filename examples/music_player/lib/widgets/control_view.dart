import 'package:flutter/material.dart';
import 'package:music_player/player/music_player.dart';
import 'package:music_player/widgets/fft_view.dart';
import 'package:music_player/widgets/position_slider.dart';
import 'package:music_player/widgets/vinyl_image_view.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

class ControlView extends StatelessWidget {
  const ControlView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final player = context.watch<MusicPlayer>();
    final metadata = player.metadata;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ColoredBox(
            color: Colors.grey.shade900,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  child: SizedBox(
                    height: 10,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.center,
                  child: VinylImageView(),
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  right: 0,
                  child: SizedBox(
                    height: 10,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0),
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  left: 0,
                  bottom: 0,
                  right: 0,
                  top: 0,
                  child: IgnorePointer(
                    child: FractionallySizedBox(
                      alignment: Alignment.bottomCenter,
                      heightFactor: 0.5,
                      child: FftView(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
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
          ),
        ),
      ],
    );
  }
}
