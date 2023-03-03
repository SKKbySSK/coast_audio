import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_graph_miniaudio/flutter_audio_graph_miniaudio.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:music_player/main.dart';
import 'package:music_player/player/music_player.dart';

class _PlayerMessage {
  _PlayerMessage({
    required this.format,
    required this.bufferSize,
    required this.sendPort,
    required this.rootIsolateToken,
  });
  final AudioFormat format;
  final int bufferSize;
  final SendPort sendPort;
  final RootIsolateToken rootIsolateToken;
}

class _PlayerOpenCommand {
  const _PlayerOpenCommand(this.filePath);
  final String filePath;
}

class _PlayerControlCommand {
  _PlayerControlCommand(this.play, this.volume);
  final bool play;
  final double volume;
}

class _PlayerPositionCommand {
  _PlayerPositionCommand(this.position);
  final AudioTime position;
}

class _PlayerSetDeviceCommand {
  _PlayerSetDeviceCommand(this.deviceInfo);
  final DeviceInfo<dynamic>? deviceInfo;
}

class _PlayerState {
  _PlayerState({
    required this.format,
    required this.filePath,
    required this.position,
    required this.duration,
    required this.volume,
    required this.isReady,
    required this.isPlaying,
  });
  final AudioFormat format;
  final String? filePath;
  final AudioTime position;
  final AudioTime duration;
  final double volume;
  final bool isReady;
  final bool isPlaying;
}

class _PlayerDeviceState {
  _PlayerDeviceState(this.deviceInfo);
  final DeviceInfo<dynamic>? deviceInfo;
}

void _playerRunner(_PlayerMessage message) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(message.rootIsolateToken);
  MabLibrary.initialize();
  MabDeviceContext.enableSharedInstance(backends: backends);

  final sendPort = message.sendPort;

  final player = MusicPlayer(
    format: message.format,
    bufferSize: message.bufferSize,
  );

  void sendState() {
    sendPort.send(
      _PlayerState(
        format: player.format,
        filePath: player.filePath,
        position: player.position,
        duration: player.duration,
        volume: player.volume,
        isReady: player.isReady,
        isPlaying: player.isPlaying,
      ),
    );
  }

  player.addListener(() {
    sendState();
  });

  final receivePort = ReceivePort();
  message.sendPort.send(receivePort.sendPort);

  receivePort.listen((message) async {
    if (message is _PlayerOpenCommand) {
      await player.open(message.filePath);
      sendPort
        ..send(player.metadata)
        ..send(_PlayerDeviceState(player.device));
    } else if (message is _PlayerControlCommand) {
      player.volume = message.volume;
      if (player.isPlaying == message.play) {
        return;
      }
      if (message.play) {
        player.play();
        sendPort.send(_PlayerDeviceState(player.device));
      } else {
        player.pause();
      }
    } else if (message is _PlayerPositionCommand) {
      player.position = message.position;
    } else if (message is _PlayerSetDeviceCommand) {
      player.device = message.deviceInfo;
      sendPort.send(_PlayerDeviceState(message.deviceInfo));
    }
  });

  Timer.periodic(const Duration(milliseconds: 50), (timer) {
    sendState();
  });
}

class IsolatedMusicPlayer extends ChangeNotifier implements MusicPlayer {
  IsolatedMusicPlayer({
    this.format = const AudioFormat(sampleRate: 48000, channels: 2),
    this.bufferSize = 4096,
  }) {
    Isolate.spawn<_PlayerMessage>(
      _playerRunner,
      _PlayerMessage(
        format: format,
        bufferSize: bufferSize,
        sendPort: _receivePort.sendPort,
        rootIsolateToken: ServicesBinding.rootIsolateToken!,
      ),
    ).then((isolate) {});

    _receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort.complete(message);
      } else if (message is _PlayerState) {
        _lastState = message;
        notifyListeners();
      } else if (message is Metadata?) {
        _metadata = message;
        notifyListeners();
      } else if (message is _PlayerDeviceState) {
        _lastDeviceState = message;
        notifyListeners();
      }
    });

    if (Platform.isIOS) {
      _observeIosRoute();
    }
  }

  void _observeIosRoute() async {
    final sendPort = await _sendPort.future;
    final session = AVAudioSession();
    session.routeChangeStream.listen((event) {
      final devices = MabDeviceContext.sharedInstance.getPlaybackDevices();
      final defaultDevices = devices.where((e) => e.isDefault);
      if (defaultDevices.isEmpty) {
        sendPort.send(_PlayerSetDeviceCommand(devices.first));
      } else {
        sendPort.send(_PlayerSetDeviceCommand(defaultDevices.first));
      }
    });
  }

  final _receivePort = ReceivePort();
  final _sendPort = Completer<SendPort>();

  _PlayerState? _lastState;
  _PlayerDeviceState? _lastDeviceState;
  Metadata? _metadata;

  @override
  final int bufferSize;

  @override
  AudioTime get duration => _lastState?.duration ?? AudioTime.zero;

  @override
  String? get filePath => _lastState?.filePath;

  @override
  final AudioFormat format;

  @override
  bool get isPlaying => _lastState?.isPlaying ?? false;

  @override
  bool get isReady => _lastState?.isReady ?? false;

  @override
  Metadata? get metadata => _metadata;

  @override
  set device(DeviceInfo<dynamic>? device) {
    _sendPort.future.then((port) => port.send(_PlayerSetDeviceCommand(device)));
  }

  @override
  set position(AudioTime position) {
    _sendPort.future.then((port) => port.send(_PlayerPositionCommand(position)));
  }

  @override
  set volume(double volume) {
    _sendPort.future.then((port) => port.send(_PlayerControlCommand(_lastState?.isPlaying ?? false, volume)));
  }

  @override
  DeviceInfo<dynamic>? get device {
    return _lastDeviceState?.deviceInfo;
  }

  @override
  AudioTime get position => _lastState?.position ?? AudioTime.zero;

  @override
  double get volume => _lastState?.volume ?? 1;

  @override
  Future<void> open(String filePath) async {
    final sendPort = await _sendPort.future;
    sendPort.send(_PlayerOpenCommand(filePath));
  }

  @override
  void play() async {
    if (Platform.isIOS || Platform.isAndroid) {
      final session = await AudioSession.instance;
      await session.configure(
        const AudioSessionConfiguration(
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
        ),
      );
      await session.setActive(true);
    }

    final sendPort = await _sendPort.future;
    sendPort.send(_PlayerControlCommand(true, volume));
  }

  @override
  void pause() async {
    final sendPort = await _sendPort.future;
    sendPort.send(_PlayerControlCommand(false, volume));
  }

  @override
  void stop() {}
}
