import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.title,
    required this.body,
    this.isMicRequired = false,
    required this.onTap,
  });
  final String title;
  final String body;
  final bool isMicRequired;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      child: Card(
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.all(12),
        child: InkWell(
          onTap: () async {
            if (isMicRequired && (Platform.isIOS || Platform.isAndroid)) {
              final permission = await Permission.microphone.request();
              if (permission.isDenied) {
                if (!context.mounted) {
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Microphone permission is required')));
                return;
              }
            }
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        body,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
