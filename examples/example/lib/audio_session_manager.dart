import 'package:audio_session/audio_session.dart';

class AudioSessionManager {
  static Future<void> initialize() async {
    _session = await AudioSession.instance;
  }

  static late final AudioSession _session;

  static Future<void> activate() async {
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
