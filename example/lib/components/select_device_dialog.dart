import 'package:coast_audio/coast_audio.dart';
import 'package:flutter/material.dart';

class SelectDeviceDialog extends StatefulWidget {
  const SelectDeviceDialog({
    super.key,
    required this.backend,
    required this.deviceType,
  });
  final AudioDeviceBackend backend;
  final AudioDeviceType deviceType;

  @override
  State<SelectDeviceDialog> createState() => _SelectDeviceDialogState();
}

class _SelectDeviceDialogState extends State<SelectDeviceDialog> {
  late final deviceContext = AudioDeviceContext(backends: [widget.backend]);
  late final devices = deviceContext.getDevices(widget.deviceType);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Select ${widget.deviceType.name} device'),
      children: devices.map((device) {
        return SimpleDialogOption(
          onPressed: () {
            Navigator.of(context).pop(device);
          },
          child: Text(device.name),
        );
      }).toList(),
    );
  }
}
