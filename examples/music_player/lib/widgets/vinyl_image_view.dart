import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_coast_audio_miniaudio/flutter_coast_audio_miniaudio.dart';
import 'package:music_player/player/isolated_music_player.dart';
import 'package:provider/provider.dart';

class VinylImageView extends StatefulWidget {
  const VinylImageView({Key? key}) : super(key: key);

  @override
  State<VinylImageView> createState() => _VinylImageViewState();
}

class _VinylImageViewState extends State<VinylImageView> with SingleTickerProviderStateMixin {
  late var _position = context.read<IsolatedMusicPlayer>().position;
  late final _player = context.read<IsolatedMusicPlayer>();
  var _isPanning = false;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      setState(() {
        _position = _player.position;
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = context.select<IsolatedMusicPlayer, Uint8List?>((p) => p.metadata?.albumArt);
    final isPlaying = context.select<IsolatedMusicPlayer, bool>((p) => p.state == MabAudioPlayerState.playing);

    return RepaintBoundary(
      child: LayoutBuilder(builder: (context, constraints) {
        final jacketSize = constraints.maxWidth / 2;
        final vinylRadius = (jacketSize - 20) / 2;
        final additionalWidth = jacketSize * 0.55;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.decelerate,
              width: isPlaying ? (additionalWidth + jacketSize) : jacketSize,
              height: jacketSize,
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _buildVinyl(image, vinylRadius, jacketSize),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: AnimatedOpacity(
                      opacity: _isPanning ? 0.2 : 1,
                      duration: const Duration(milliseconds: 100),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_player.state == MabAudioPlayerState.playing) {
                                _player.pause();
                              } else {
                                _player.play();
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: image == null
                                  ? _buildEmpty(jacketSize)
                                  : Image.memory(
                                      image,
                                      filterQuality: FilterQuality.high,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: AnimatedOpacity(
                              opacity: isPlaying ? 1 : 0,
                              duration: const Duration(milliseconds: 30),
                              child: SizedBox(
                                width: 20,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.black.withOpacity(0.5),
                                        Colors.black.withOpacity(0.1),
                                        Colors.black.withOpacity(0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildVinyl(Uint8List? image, double vinylRadius, double jacketSize) {
    return GestureDetector(
      onPanStart: (_) {
        setState(() {
          _isPanning = true;
        });
      },
      onPanUpdate: (d) => _panHandler(d, vinylRadius),
      onPanEnd: (_) {
        setState(() {
          _isPanning = false;
        });
      },
      child: Transform.rotate(
        angle: 2 * pi * _position.seconds / 4,
        child: SizedBox(
          height: vinylRadius * 2,
          width: vinylRadius * 2,
          child: ClipOval(
            child: ClipPath(
              clipper: VinylInnerClipper(),
              child: ColoredBox(
                color: Colors.black87,
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(1),
                      child: ClipOval(
                        child: SizedBox(
                          height: vinylRadius * 0.9,
                          width: vinylRadius * 0.9,
                          child: image == null
                              ? _buildEmpty(jacketSize)
                              : Transform.scale(
                                  scale: 1.5,
                                  child: Image.memory(
                                    image,
                                    filterQuality: FilterQuality.high,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(double jacketSize) {
    return SizedBox(
      width: jacketSize,
      height: jacketSize,
      child: ColoredBox(
        color: Colors.grey,
        child: AspectRatio(
          aspectRatio: 1,
          child: Center(
            child: Icon(
              Icons.audiotrack_outlined,
              size: jacketSize * 0.4,
            ),
          ),
        ),
      ),
    );
  }

  void _panHandler(DragUpdateDetails d, double vinylRadius) {
    /// Pan location on the wheel
    final onTop = d.localPosition.dy <= vinylRadius;
    final onLeftSide = d.localPosition.dx <= vinylRadius;
    final onRightSide = !onLeftSide;
    final onBottom = !onTop;

    /// Pan movements
    final panUp = d.delta.dy <= 0.0;
    final panLeft = d.delta.dx <= 0.0;
    final panRight = !panLeft;
    final panDown = !panUp;

    /// Absoulte change on axis
    final yChange = d.delta.dy.abs();
    final xChange = d.delta.dx.abs();

    /// Directional change on wheel
    final verticalRotation = (onRightSide && panDown) || (onLeftSide && panUp) ? yChange : yChange * -1;

    final horizontalRotation = (onTop && panRight) || (onBottom && panLeft) ? xChange : xChange * -1;

    // Total computed change
    final rotationalChange = verticalRotation + horizontalRotation;
    final movingCounterClockwise = rotationalChange < 0;

    final move = rotationalChange.abs();
    if (movingCounterClockwise) {
      setState(() {
        _position = AudioTime(max(0, _position.seconds - move / (32 * pi)));
        _player.position = _position;
      });
    } else {
      setState(() {
        _position = AudioTime(max(0, _position.seconds + move / (32 * pi)));
        _player.position = _position;
      });
    }
  }
}

class VinylInnerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width * 0.01,
        ),
      )
      ..addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
