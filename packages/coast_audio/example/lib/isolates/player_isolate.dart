import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:coast_audio/coast_audio.dart';
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

class PlayerHostRequestStats extends PlayerHostRequest {
  const PlayerHostRequestStats();
}

class PlayerStatsResponse {
  const PlayerStatsResponse({
    required this.position,
    required this.duration,
    required this.volume,
    required this.isPlaying,
  });
  final AudioTime position;
  final AudioTime duration;
  final double volume;
  final bool isPlaying;
}

class _PlayerMessage {
  const _PlayerMessage({
    required this.backend,
    required this.outputDeviceId,
    required this.path,
    required this.content,
  });
  final AudioDeviceBackend backend;
  final SerializedAudioDeviceId? outputDeviceId;
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
        outputDeviceId: outputDeviceId?.serialize(),
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

  Future<PlayerStatsResponse?> seek(AudioTime position) {
    return _isolate.request(PlayerHostRequestSeek(position: position));
  }

  Future<PlayerStatsResponse?> setVolume(double volume) {
    return _isolate.request(PlayerHostRequestSetVolume(volume: volume));
  }

  Future<PlayerStatsResponse?> stats() {
    return _isolate.request(const PlayerHostRequestStats());
  }

  // The worker function used to initialize the audio player in the isolate
  static Future<void> _worker(dynamic initialMessage, AudioIsolateWorkerMessenger messenger) async {
    final message = initialMessage as _PlayerMessage;

    // Initialize the audio player with the specified file or buffer
    final AudioInputDataSource dataSource;
    if (message.path != null) {
      dataSource = AudioFileDataSource(file: File(message.path!), mode: FileMode.read);
    } else {
      dataSource = AudioMemoryDataSource(buffer: message.content!);
    }

    final player = AudioPlayer.initialize(
      backend: message.backend,
      dataSource: dataSource,
    );

    await messenger.listen<PlayerHostRequest>(
      (request) {
        switch (request) {
          case PlayerHostRequestStart():
            player.play();
          case PlayerHostRequestPause():
            player.pause();
          case PlayerHostRequestSeek():
            player.position = request.position;
            return player.getStats();
          case PlayerHostRequestSetVolume():
            player.volume = request.volume;
            return player.getStats();
          case PlayerHostRequestStats():
            return player.getStats();
        }
      },
      onShutdown: (reason, e, stackTrace) {
        player.dispose();
      },
    );
  }
}

class AudioPlayer {
  AudioPlayer._init(
    this._bufferFrames,
    this._decoderNode,
    this._clock,
    this._playback,
    this._disposableBag,
  ) {
    _clock.callbacks.add((clock) {
      final readResult = fillBuffer();

      // If the decoder has reached the end of the audio data and the playback device's buffer is empty, stop the playback
      if (readResult.isEnd && _playback.availableReadFrames == 0) {
        pause();
      }
    });
  }

  factory AudioPlayer.initialize({
    required AudioDeviceBackend backend,
    required AudioInputDataSource dataSource,
    AudioDeviceId? deviceId,
  }) {
    final disposableBag = SyncDisposableBag();
    if (dataSource is AudioFileDataSource) {
      disposableBag.add(dataSource);
    }

    // The AudioDeviceContext is used to create the playback device on the specified backend(platform)
    final context = AudioDeviceContext(backends: [backend]);

    // Create a decoder
    final AudioDecoder decoder;
    final DecoderNode decoderNode;
    try {
      decoder = WavAudioDecoder(dataSource: dataSource);
      decoderNode = DecoderNode(decoder: decoder);
    } on Exception catch (e) {
      throw Exception('Failed to decode audio data: $e');
    }

    // Calculate the buffer frame size.
    // If the buffer duration is too short, the audio player will have a high CPU usage and may cause audio stuttering.
    const bufferDuration = AudioTime(0.5);
    final bufferFrameSize = bufferDuration.computeFrames(decoder.outputFormat);

    final playback = PlaybackDevice(
      context: context,
      format: decoder.outputFormat,
      bufferFrameSize: bufferFrameSize,
      deviceId: deviceId,
    );

    return AudioPlayer._init(
      AllocatedAudioFrames(length: bufferFrameSize, format: decoder.outputFormat),
      decoderNode,
      AudioIntervalClock(Duration(milliseconds: bufferDuration.seconds * 1000 ~/ 2)),
      playback,
      disposableBag,
    );
  }

  // The buffer used to store audio data read from the decoder
  final AllocatedAudioFrames _bufferFrames;

  // The decoder node used to decode audio data from the data source
  final DecoderNode _decoderNode;

  // The clock used to schedule audio data reads from the decoder
  final AudioClock _clock;

  // The playback device used to play audio data
  final PlaybackDevice _playback;

  // The disposable bag used to manage the disposal of resources
  final SyncDisposableBag _disposableBag;

  bool get isPlaying => _playback.isStarted;

  double get volume => _playback.volume;

  set volume(double value) {
    _playback.volume = value;
  }

  AudioTime get position {
    final decoder = _decoderNode.decoder;
    return AudioTime.fromFrames(decoder.cursorInFrames - _playback.availableReadFrames, format: decoder.outputFormat);
  }

  set position(AudioTime value) {
    final decoder = _decoderNode.decoder;
    // Set the cursor in the decoder to the specified position
    decoder.cursorInFrames = value.computeFrames(decoder.outputFormat);

    // Clear the playback device's buffer to prevent old audio data from being played
    _playback.clearBuffer();
  }

  // Get the current playback stats for update the UI
  PlayerStatsResponse getStats() {
    final decoder = _decoderNode.decoder;
    return PlayerStatsResponse(
      position: position,
      duration: AudioTime.fromFrames(decoder.lengthInFrames!, format: decoder.outputFormat),
      volume: volume,
      isPlaying: isPlaying,
    );
  }

  // Fill the playback device's buffer with audio data from the decoder
  // The device will consume the buffer while playing
  AudioReadResult fillBuffer() {
    return _bufferFrames.acquireBuffer((buffer) {
      // Get the number of writable frames in the playback device's buffer
      final expectedRead = _playback.availableWriteFrames;

      // Read audio data from the decoder into the temporary buffer
      final readResult = _decoderNode.outputBus.read(buffer.limit(expectedRead));

      // Write the audio data from the temporary buffer into the playback device's buffer
      _playback.write(buffer.limit(readResult.frameCount));

      return readResult;
    });
  }

  void play() {
    // Fill the playback device's buffer with audio data from the decoder before starting playback
    // If the decoder has already reached the end of the audio data, ignore the play request
    final result = fillBuffer();
    if (result.isEnd || result.frameCount == 0) {
      return;
    }

    _playback.start();
    _clock.start();
  }

  void pause() {
    _clock.stop();
    _playback.stop();
  }

  void dispose() {
    _clock.stop();
    _playback.stop();
    _disposableBag.dispose();
  }
}
