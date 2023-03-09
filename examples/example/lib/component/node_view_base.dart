import 'package:coast_audio/coast_audio.dart';
import 'package:flutter/material.dart';

class NodeViewBase extends StatelessWidget {
  const NodeViewBase({
    Key? key,
    required this.node,
    required this.icon,
    required this.children,
    required this.actions,
  }) : super(key: key);
  final IconData? icon;
  final AudioNode node;
  final List<Widget> children;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            if (icon != null)
              Positioned(
                top: 12,
                left: 12,
                bottom: 12,
                child: Icon(icon, size: 18),
              ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  node.runtimeType.toString(),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        const Divider(
          height: 1,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: children,
                ),
              ),
              if (actions.isNotEmpty) ...[
                const Divider(height: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: actions,
                ),
              ] else
                const SizedBox(
                  height: 40,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
