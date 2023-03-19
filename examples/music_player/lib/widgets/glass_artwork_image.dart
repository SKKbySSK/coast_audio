import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:music_player/player/isolated_music_player.dart';
import 'package:provider/provider.dart';

class GlassArtworkImage extends StatefulWidget {
  const GlassArtworkImage({Key? key}) : super(key: key);

  @override
  State<GlassArtworkImage> createState() => _GlassArtworkImageState();
}

class _GlassArtworkImageState extends State<GlassArtworkImage> with SingleTickerProviderStateMixin {
  late final _player = context.read<IsolatedMusicPlayer>();
  var _useFirstImage = true;
  Uint8List? _image1;
  Uint8List? _image2;
  final _image1Key = const ValueKey('Image1');
  final _image2Key = const ValueKey('Image2');
  late final _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

  @override
  void initState() {
    super.initState();
    _player.addListener(_onPlayerUpdated);
    _image1 = _player.metadata?.albumArt;
  }

  @override
  void dispose() {
    _player.removeListener(_onPlayerUpdated);
    _controller.dispose();
    super.dispose();
  }

  void _onPlayerUpdated() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    final image = _player.metadata?.albumArt;

    if (_useFirstImage) {
      if (image == _image1) {
        return;
      }
    } else {
      if (image == _image2) {
        return;
      }
    }

    setState(() {
      _useFirstImage = !_useFirstImage;
      if (_useFirstImage) {
        _image1 = image;
      } else {
        _image2 = image;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          _buildImage(_useFirstImage ? _image1 : _image2),
          AnimatedOpacity(
            key: _image1Key,
            opacity: _useFirstImage ? 1 : 0,
            duration: const Duration(milliseconds: 1500),
            child: _buildImage(_image1),
          ),
          AnimatedOpacity(
            key: _image2Key,
            opacity: _useFirstImage ? 0 : 1,
            duration: const Duration(milliseconds: 1500),
            child: _buildImage(_image2),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(Uint8List? image) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (image != null)
          Image.memory(
            image,
            fit: BoxFit.cover,
          ),
        if (image != null)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child: ColoredBox(
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ),
      ],
    );
  }
}
