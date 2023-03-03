import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_graph_miniaudio/flutter_audio_graph_miniaudio.dart';
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
    if (Platform.isIOS) {
      _observeIosRoute();
    }
    _updateDevices();
  }

  void _observeIosRoute() async {
    AVAudioSession().routeChangeStream.listen((event) {
      _updateDevices();
    });
  }

  void _updateDevices() async {
    if (Platform.isMacOS) {
      _devices
        ..clear()
        ..addAll(MabDeviceContext.sharedInstance.getPlaybackDevices());
      return;
    }

    final session = await AudioSession.instance;
    final devices = await session.getDevices(includeInputs: false);
    _devices
      ..clear()
      ..addAll(
        devices.map(
          (d) {
            switch (MabDeviceContext.sharedInstance.activeBackend) {
              case MabBackend.coreAudio:
                return CoreAudioDevice(id: d.id, name: d.name, isDefault: false);
              case MabBackend.aaudio:
                return AAudioDeviceInfo(id: int.parse(d.id), name: d.name, isDefault: false);
              case MabBackend.openSl:
                return OpenSLDeviceInfo(id: int.parse(d.id), name: d.name, isDefault: false);
            }
          },
        ),
      );
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
            setState(() {});
          },
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}
