import 'dart:io';

import 'package:audio_session/audio_session.dart';

class AudioSessionManager {
  static Future<void> initialize() async {
    _session = await AudioSession.instance;
  }

  static late final AudioSession _session;

  static Future<void> activate() async {
    if (!Platform.isIOS && !Platform.isAndroid) {
      return;
    }

    await _session.configure(
      AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth |
            AVAudioSessionCategoryOptions.allowBluetoothA2dp |
            AVAudioSessionCategoryOptions.allowAirPlay |
            AVAudioSessionCategoryOptions.defaultToSpeaker,
      ),
    );
    await _session.setActive(true, avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none);
  }
}
