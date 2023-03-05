import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_graph_miniaudio/flutter_audio_graph_miniaudio.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:music_player/main.dart';
import 'package:music_player/player/isolated_player_command.dart';
import 'package:music_player/player/isolated_player_state.dart';
import 'package:music_player/player/music_player.dart';

class _IsolatedPlayerInitialMessage {
  _IsolatedPlayerInitialMessage({
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

void _playerRunner(_IsolatedPlayerInitialMessage message) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(message.rootIsolateToken);
  MabLibrary.initialize();
  MabDeviceContext.enableSharedInstance(backends: backends);

  final sendPort = message.sendPort;

  final player = MusicPlayer(
    format: message.format,
    bufferSize: message.bufferSize,
    onOutput: (buffer) {
      sendPort.send(IsolatedPlayerOutputState(
        buffer.format,
        buffer.sizeInFrames,
        buffer.asUint8ListViewBytes(),
      ));
    },
  );

  void sendState() {
    sendPort.send(
      IsolatedPlayerState(
        format: player.format,
        filePath: player.filePath,
        position: player.position,
        duration: player.duration,
        volume: player.volume,
        isPlaying: player.isPlaying,
        isReady: player.isReady,
      ),
    );
  }

  player.addListener(() {
    sendState();
  });

  final receivePort = ReceivePort();
  message.sendPort.send(receivePort.sendPort);

  final timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
    sendState();
  });

  receivePort.listen((command) async {
    final cmd = command as IsolatedPlayerCommand;
    return cmd.when<FutureOr<void>>(
      open: (filePath) async {
        await player.open(filePath);
        sendPort
          ..send(IsolatedPlayerMetadataState(player.metadata))
          ..send(IsolatedPlayerDeviceState(player.device));
      },
      play: () {
        player.play();
      },
      pause: () {
        player.pause();
      },
      stop: () {
        player.stop();
      },
      setVolume: (v) {
        player.volume = v;
      },
      setPosition: (p) {
        player.position = p;
      },
      setDevice: (d) {
        player.device = d;
        sendPort.send(IsolatedPlayerDeviceState(player.device));
      },
      dispose: () {
        player.stop();
        timer.cancel();
        player.dispose();
        MabDeviceContext.sharedInstance.dispose();
        receivePort.close();
      },
    );
  });
}

class IsolatedMusicPlayer extends ChangeNotifier implements MusicPlayer {
  IsolatedMusicPlayer({
    this.format = const AudioFormat(sampleRate: 48000, channels: 2),
    this.bufferSize = 4096,
    this.onOutput,
  }) {
    Isolate.spawn<_IsolatedPlayerInitialMessage>(
      _playerRunner,
      _IsolatedPlayerInitialMessage(
        format: format,
        bufferSize: bufferSize,
        sendPort: _receivePort.sendPort,
        rootIsolateToken: ServicesBinding.rootIsolateToken!,
      ),
      errorsAreFatal: false,
    ).then((isolate) {});

    _receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort.complete(message);
      } else if (message is IsolatedPlayerState) {
        _lastState = message;
        notifyListeners();
      } else if (message is IsolatedPlayerMetadataState) {
        _metadata = message.metadata;
        notifyListeners();
      } else if (message is IsolatedPlayerDeviceState) {
        _device = message.deviceInfo;
        notifyListeners();
      } else if (message is IsolatedPlayerOutputState) {
        final buffer = AllocatedFrameBuffer(frames: message.sizeInFrames, format: message.format);
        try {
          buffer.acquireBuffer((buffer) {
            final dst = buffer.asUint8ListViewBytes();
            for (var i = 0; message.bufferList.length > i; i++) {
              dst[i] = message.bufferList[i];
            }
            onOutput?.call(buffer);
          });
        } finally {
          buffer.dispose();
        }
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
        sendPort.send(IsolatedPlayerCommand.setDevice(deviceInfo: devices.first));
      } else {
        sendPort.send(IsolatedPlayerCommand.setDevice(deviceInfo: defaultDevices.first));
      }
    });
  }

  final _receivePort = ReceivePort();
  final _sendPort = Completer<SendPort>();

  IsolatedPlayerState? _lastState;
  DeviceInfo? _device;
  Metadata? _metadata;

  @override
  final int bufferSize;

  @override
  void Function(RawFrameBuffer buffer)? onOutput;

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
    _sendPort.future.then((port) => port.send(IsolatedPlayerCommand.setDevice(deviceInfo: device)));
  }

  @override
  set position(AudioTime position) {
    _sendPort.future.then((port) => port.send(IsolatedPlayerCommand.setPosition(position: position)));
  }

  @override
  set volume(double volume) {
    _sendPort.future.then((port) => port.send(IsolatedPlayerCommand.setVolume(volume: volume)));
  }

  @override
  DeviceInfo<dynamic>? get device => _device;

  @override
  AudioTime get position => _lastState?.position ?? AudioTime.zero;

  @override
  double get volume => _lastState?.volume ?? 1;

  @override
  Future<void> open(String filePath) async {
    final sendPort = await _sendPort.future;
    sendPort.send(IsolatedPlayerCommand.open(filePath: filePath));
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
    sendPort.send(const IsolatedPlayerCommand.play());
  }

  @override
  void pause() async {
    final sendPort = await _sendPort.future;
    sendPort.send(const IsolatedPlayerCommand.pause());
  }

  @override
  void stop() async {
    final sendPort = await _sendPort.future;
    sendPort.send(const IsolatedPlayerCommand.stop());
  }

  @override
  void dispose() async {
    super.dispose();
    final sendPort = await _sendPort.future;
    sendPort.send(const IsolatedPlayerCommand.dispose());
    _receivePort.close();
  }
}
