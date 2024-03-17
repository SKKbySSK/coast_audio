import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:coast_audio/coast_audio.dart';
import 'package:coast_audio/experimental.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

sealed class PlayerHostRequest {
  const PlayerHostRequest();
}

class PlayerHostRequestStart extends PlayerHostRequest {
  const PlayerHostRequestStart();
}

class PlayerHostRequestPause extends PlayerHostRequest {
  const PlayerHostRequestPause();
}

class PlayerHostRequestSeek extends PlayerHostRequest {
  const PlayerHostRequestSeek({
    required this.position,
  });
  final AudioTime position;
}

class PlayerHostRequestSetVolume extends PlayerHostRequest {
  const PlayerHostRequestSetVolume({
    required this.volume,
  });
  final double volume;
}

class PlayerHostRequestGetPosition extends PlayerHostRequest {
  const PlayerHostRequestGetPosition();
}

class PlayerHostRequestGetState extends PlayerHostRequest {
  const PlayerHostRequestGetState();
}

class PlayerStateResponse extends Equatable {
  const PlayerStateResponse({
    required this.isPlaying,
    required this.outputFormat,
  });
  final bool isPlaying;
  final AudioFormat outputFormat;

  @override
  List<Object?> get props => [isPlaying, outputFormat.sampleRate, outputFormat.channels, outputFormat.sampleFormat];
}

class PlayerPositionResponse extends Equatable {
  const PlayerPositionResponse({
    required this.position,
    required this.duration,
  });
  final AudioTime position;
  final AudioTime duration;

  @override
  List<Object?> get props => [position, duration];
}

class _PlayerMessage {
  const _PlayerMessage({
    required this.backend,
    required this.outputDeviceId,
    required this.path,
    required this.content,
  });
  final AudioDeviceBackend backend;
  final AudioDeviceId? outputDeviceId;
  final String? path;
  final Uint8List? content;
}

class PlayerIsolate {
  PlayerIsolate();
  final _isolate = AudioIsolate<_PlayerMessage>(_worker);

  bool get isLaunched => _isolate.isLaunched;

  Future<void> launch({
    required AudioDeviceBackend backend,
    required AudioDeviceId? outputDeviceId,
    required String? path,
    required Uint8List? content,
  }) async {
    await _isolate.launch(
      initialMessage: _PlayerMessage(
        backend: backend,
        outputDeviceId: outputDeviceId,
        path: path,
        content: content,
      ),
    );
  }

  Future<void> attach() {
    return _isolate.attach();
  }

  Future<void> shutdown() {
    return _isolate.shutdown();
  }

  Future<void> play() {
    return _isolate.request(const PlayerHostRequestStart());
  }

  Future<void> pause() {
    return _isolate.request(const PlayerHostRequestPause());
  }

  Future<PlayerPositionResponse?> seek(AudioTime position) {
    return _isolate.request(PlayerHostRequestSeek(position: position));
  }

  Future<void> setVolume(double volume) {
    return _isolate.request(PlayerHostRequestSetVolume(volume: volume));
  }

  Future<PlayerStateResponse?> getState() {
    return _isolate.request(const PlayerHostRequestGetState());
  }

  Future<PlayerPositionResponse?> getPosition() {
    return _isolate.request(const PlayerHostRequestGetPosition());
  }

  // The worker function used to initialize the audio player in the isolate
  static Future<void> _worker(dynamic initialMessage, AudioIsolateWorkerMessenger messenger) async {
    AudioResourceManager.isDisposeLogEnabled = true;

    final message = initialMessage as _PlayerMessage;

    // Initialize the audio player with the specified file or buffer
    final AudioInputDataSource dataSource;
    if (message.path != null) {
      dataSource = AudioFileDataSource(file: File(message.path!), mode: FileMode.read);
    } else {
      dataSource = AudioMemoryDataSource(buffer: message.content!);
    }

    final player = AudioPlayer.findDecoder(
      backend: message.backend,
      dataSource: dataSource,
      deviceId: message.outputDeviceId,
    );

    messenger.listenRequest<PlayerHostRequest>(
      (request) {
        switch (request) {
          case PlayerHostRequestStart():
            player.play();
          case PlayerHostRequestPause():
            player.pause();
          case PlayerHostRequestSetVolume():
            player.volume = request.volume;
          case PlayerHostRequestSeek():
            player.position = request.position;
            return player.getPosition();
          case PlayerHostRequestGetState():
            return player.getState();
          case PlayerHostRequestGetPosition():
            return player.getPosition();
        }
      },
    );

    await messenger.listenShutdown(
      (reason, e, stackTrace) async {
        player.dispose();
      },
    );
  }
}

class AudioPlayer {
  AudioPlayer({
    required this.backend,
    required this.decoder,
    this.bufferDuration = const AudioTime(0.5),
    this.initialDeviceId,
  }) : context = AudioDeviceContext(backends: [backend]) {
    _clock.callbacks.add((clock) {
      final readResult = fillBuffer();

      // If the decoder has reached the end of the audio data and the playback device's buffer is empty, stop the playback
      if (readResult.isEnd && _playback.availableReadFrames == 0) {
        pause();
      }
    });

    _playback.notification.listen((notification) {
      print('[AudioPlayer#${_playback.resourceId}] Notification(type: ${notification.type.name}, state: ${notification.state.name})');
      if (!_playback.isStarted) {
        _clock.stop();
      }
    });
  }

  factory AudioPlayer.findDecoder({
    required AudioDeviceBackend backend,
    required AudioInputDataSource dataSource,
    AudioDeviceId? deviceId,
  }) {
    // Find the decoder
    AudioDecoder decoder;
    try {
      decoder = WavAudioDecoder(dataSource: dataSource);
    } on Exception catch (_) {
      try {
        decoder = MaAudioDecoder(dataSource: dataSource, expectedSampleFormat: SampleFormat.int32);
      } on Exception catch (e) {
        throw Exception('Could not find the decoder.\nInner exception: $e');
      }
    }

    return AudioPlayer(
      backend: backend,
      decoder: decoder,
      initialDeviceId: deviceId,
    );
  }

  final AudioDeviceBackend backend;

  // The AudioDeviceContext is used to create the playback device on the specified backend(platform)
  final AudioDeviceContext context;

  final AudioTime bufferDuration;

  final AudioDeviceId? initialDeviceId;

  // Calculate the buffer frame size.
  // If the buffer duration is too short, the audio player will have a high CPU usage and may cause audio stuttering.
  late final bufferFrameSize = bufferDuration.computeFrames(decoder.outputFormat);

  // The buffer used to store audio data read from the decoder
  late final _bufferFrames = AllocatedAudioFrames(length: bufferFrameSize, format: decoder.outputFormat);

  // The decoder used to decode audio data from the data source
  final AudioDecoder decoder;

  // The clock used to schedule audio data reads from the decoder
  late final _clock = AudioIntervalClock(Duration(milliseconds: (bufferDuration.seconds * 1000 * 0.4).toInt()));

  // The playback device used to play audio data
  late final _playback = context.createPlaybackDevice(
    format: decoder.outputFormat,
    bufferFrameSize: bufferFrameSize,
    deviceId: initialDeviceId,
  );

  bool get isPlaying => _playback.isStarted;

  double get volume => _playback.volume;

  set volume(double value) {
    _playback.volume = value;
  }

  AudioTime get position {
    return AudioTime.fromFrames(decoder.cursorInFrames - _playback.availableReadFrames, format: decoder.outputFormat);
  }

  set position(AudioTime value) {
    // Set the cursor in the decoder to the specified position
    decoder.cursorInFrames = value.computeFrames(decoder.outputFormat);

    // Clear the playback device's buffer to prevent old audio data from being played
    _playback.clearBuffer();
  }

  // Get the current playback state
  PlayerStateResponse getState() {
    return PlayerStateResponse(
      isPlaying: isPlaying,
      outputFormat: decoder.outputFormat,
    );
  }

  PlayerPositionResponse getPosition() {
    return PlayerPositionResponse(
      position: position,
      duration: AudioTime.fromFrames(decoder.lengthInFrames!, format: decoder.outputFormat),
    );
  }

  // Fill the playback device's buffer with audio data from the decoder
  // The device will consume the buffer while playing
  AudioReadResult fillBuffer() {
    return _bufferFrames.acquireBuffer((buffer) {
      // Get the number of writable frames in the playback device's buffer
      final expectedRead = _playback.availableWriteFrames;

      // Read audio data from the decoder into the temporary buffer
      final decodeResult = decoder.decode(destination: buffer.limit(expectedRead));

      // Write the audio data from the temporary buffer into the playback device's buffer
      _playback.write(buffer.limit(decodeResult.frameCount));

      return AudioReadResult(frameCount: decodeResult.frameCount, isEnd: decodeResult.isEnd);
    });
  }

  void play() {
    if (isPlaying) {
      return;
    }

    // Fill the playback device's buffer with audio data from the decoder before starting playback
    fillBuffer();

    // Start the playback device and the clock
    _playback.start();
    _clock.start();
  }

  void pause() {
    _clock.stop();
    _playback.stop(clearBuffer: false);
  }

  void dispose() {
    _clock.stop();
    _playback.stop();
    _clock.callbacks.clear();
  }
}
