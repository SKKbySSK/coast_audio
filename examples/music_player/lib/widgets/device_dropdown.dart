import 'package:flutter/material.dart';
import 'package:flutter_coast_audio_miniaudio/flutter_coast_audio_miniaudio.dart';
import 'package:music_player/player/music_player.dart';
import 'package:provider/provider.dart';

class DeviceDropdown extends StatefulWidget {
  const DeviceDropdown({super.key});

  @override
  State<DeviceDropdown> createState() => _DeviceDropdownState();
}

class _DeviceDropdownState extends State<DeviceDropdown> {
  final _devices = <DeviceInfo<dynamic>>[];

  @override
  void initState() {
    super.initState();
    context.read<MusicPlayer>().onRerouted = _updateDevices;
    _updateDevices();
  }

  void _updateDevices() async {
    final devices = await MabDeviceContext.sharedInstance.getAllDevices(MabDeviceType.playback);
    setState(() {
      _devices
        ..clear()
        ..addAll(devices);
    });
  }

  @override
  Widget build(BuildContext context) {
    final device = context.select<MusicPlayer, DeviceInfo<dynamic>?>((p) => p.device);
    final dropdownItems = _devices.map((e) => DropdownMenuItem<DeviceInfo<dynamic>>(value: e, child: Text(e.name))).toList();

    return Row(
      children: [
        const Icon(Icons.speaker),
        const SizedBox(width: 8),
        DropdownButton<DeviceInfo<dynamic>>(
          items: dropdownItems,
          value: _devices.contains(device) ? device : null,
          onChanged: (device) {
            context.read<MusicPlayer>().device = device;
          },
        ),
        IconButton(
          onPressed: () {
            _updateDevices();
          },
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}
