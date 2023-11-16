import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:audio_session/audio_session.dart';
import 'package:coast_audio_fft/coast_audio_fft.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_coast_audio_miniaudio/flutter_coast_audio_miniaudio.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:music_player/main.dart';
import 'package:music_player/player/isolated_player_command.dart';
import 'package:music_player/player/isolated_player_state.dart';
import 'package:music_player/player/music_player.dart';

class _IsolatedPlayerInitialMessage {
  _IsolatedPlayerInitialMessage({
    required this.format,
    required this.fftBufferSize,
    required this.sendPort,
    required this.rootIsolateToken,
  });
  final AudioFormat format;
  final int fftBufferSize;
  final SendPort sendPort;
  final RootIsolateToken rootIsolateToken;
}

void _playerRunner(_IsolatedPlayerInitialMessage message) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(message.rootIsolateToken);
  MabLibrary.initialize();
  MabDeviceContext.enableSharedInstance(backends: backends);

  final sendPort = message.sendPort;

  late final VoidCallback sendState;

  late final MusicPlayer player;
  try {
    player = MusicPlayer(
      format: message.format,
      fftSize: message.fftBufferSize,
      onFftCompleted: (result) async {
        sendPort.send(IsolatedPlayerFftCompletedState(result));
      },
      onRerouted: () {
        sendPort.send(IsolatedPlayerReroutedState(player.device));
      },
      onOutput: (_, __) {
        sendState();
      },
    );
  } on Object catch (e) {
    debugPrint(e.toString());
    rethrow;
  }

  sendState = () {
    sendPort.send(
      IsolatedPlayerState(
        format: player.format,
        name: player.name,
        canSeek: player.canSeek,
        position: player.position,
        duration: player.duration,
        volume: player.volume,
        state: player.state,
      ),
    );
  };

  player.stateStream.listen((_) {
    sendState();
  });

  player.notificationStream.listen((_) {
    sendState();
  });

  final receivePort = ReceivePort();
  message.sendPort.send(receivePort.sendPort);

  receivePort.listen((command) async {
    final cmd = command as IsolatedPlayerCommand;
    return cmd.when<FutureOr<void>>(
      openFile: (filePath) async {
        await player.openFile(File(filePath));
        sendPort
          ..send(IsolatedPlayerMetadataState(player.metadata))
          ..send(IsolatedPlayerDeviceState(player.device));
        sendState();
      },
      openBuffer: (buffer) async {
        await player.openBuffer(buffer);
        sendPort
          ..send(IsolatedPlayerMetadataState(player.metadata))
          ..send(IsolatedPlayerDeviceState(player.device));
        sendState();
      },
      openHttpUrl: (url) async {
        await player.openHttpUrl(Uri.parse(url));
        sendPort
          ..send(IsolatedPlayerMetadataState(player.metadata))
          ..send(IsolatedPlayerDeviceState(player.device));
        sendState();
      },
      play: () {
        player.play();
        sendState();
      },
      pause: () {
        player.pause();
        sendState();
      },
      stop: () {
        player.stop();
        sendState();
      },
      setVolume: (v) {
        player.volume = v;
        sendState();
      },
      setPosition: (p) {
        player.position = p;
        sendState();
      },
      setDevice: (d) {
        player.device = d;
        sendPort.send(IsolatedPlayerDeviceState(player.device));
        sendState();
      },
      dispose: () {
        player.stop();
        player.dispose();
        MabDeviceContext.sharedInstance.dispose();
        receivePort.close();
      },
    );
  });
}

class IsolatedMusicPlayer extends ChangeNotifier {
  IsolatedMusicPlayer({
    required this.format,
    int fftBufferSize = 512,
    this.onFftCompleted,
    this.onRerouted,
  }) {
    Isolate.spawn<_IsolatedPlayerInitialMessage>(
      _playerRunner,
      _IsolatedPlayerInitialMessage(
        format: format,
        fftBufferSize: fftBufferSize,
        sendPort: _receivePort.sendPort,
        rootIsolateToken: ServicesBinding.rootIsolateToken!,
      ),
      errorsAreFatal: false,
    );

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
      } else if (message is IsolatedPlayerReroutedState) {
        onRerouted?.call();
        _device = message.deviceInfo;
        notifyListeners();
      } else if (message is IsolatedPlayerFftCompletedState) {
        _lastFftResult = message.result;
        notifyListeners();

        onFftCompleted?.call(message.result);
      }
    });
  }

  final _receivePort = ReceivePort();
  final _sendPort = Completer<SendPort>();

  IsolatedPlayerState? _lastState;
  DeviceInfo? _device;
  FftResult? _lastFftResult;
  Metadata? _metadata;

  FftCompletedCallback? onFftCompleted;

  VoidCallback? onRerouted;

  FftResult? get lastFftResult => _lastFftResult;

  AudioTime? get duration => _lastState?.duration;

  String? get name => _lastState?.name;

  final AudioFormat format;

  Metadata? get metadata => _metadata;

  set device(DeviceInfo<dynamic>? device) {
    _sendPort.future.then((port) => port.send(IsolatedPlayerCommand.setDevice(deviceInfo: device)));
  }

  set position(AudioTime position) {
    _sendPort.future.then((port) => port.send(IsolatedPlayerCommand.setPosition(position: position)));
  }

  set volume(double volume) {
    _sendPort.future.then((port) => port.send(IsolatedPlayerCommand.setVolume(volume: volume)));
  }

  DeviceInfo<dynamic>? get device => _device;

  bool get canSeek => _lastState?.canSeek ?? false;

  AudioTime get position => _lastState?.position ?? AudioTime.zero;

  double get volume => _lastState?.volume ?? 1;

  MabAudioPlayerState get state => _lastState?.state ?? MabAudioPlayerState.stopped;

  Future<void> openFile(String filePath) async {
    final sendPort = await _sendPort.future;
    sendPort.send(IsolatedPlayerCommand.openFile(filePath: filePath));
  }

  Future<void> openBuffer(List<int> buffer) async {
    final sendPort = await _sendPort.future;
    sendPort.send(IsolatedPlayerCommand.openBuffer(buffer: buffer));
  }

  Future<void> openHttpUrl(String url) async {
    final sendPort = await _sendPort.future;
    sendPort.send(IsolatedPlayerCommand.openHttpUrl(url: url));
  }

  Future<void> play() async {
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

  Future<void> pause() async {
    final sendPort = await _sendPort.future;
    sendPort.send(const IsolatedPlayerCommand.pause());
  }

  Future<void> stop() async {
    final sendPort = await _sendPort.future;
    sendPort.send(const IsolatedPlayerCommand.stop());
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    final sendPort = await _sendPort.future;
    sendPort.send(const IsolatedPlayerCommand.dispose());
    _receivePort.close();
  }
}
