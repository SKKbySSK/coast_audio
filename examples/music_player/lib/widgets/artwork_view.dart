import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

class ArtworkView extends StatelessWidget {
  const ArtworkView({
    Key? key,
    required this.metadata,
  }) : super(key: key);
  final Metadata? metadata;

  @override
  Widget build(BuildContext context) {
    final image = metadata?.albumArt;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 500,
        height: 500,
        child: image == null ? _buildEmpty() : Image.memory(image, filterQuality: FilterQuality.high),
      ),
    );
  }

  Widget _buildEmpty() {
    return ColoredBox(
      color: Colors.grey.shade700,
      child: const Center(
        child: Icon(
          Icons.audiotrack_outlined,
          size: 300,
        ),
      ),
    );
  }
}
