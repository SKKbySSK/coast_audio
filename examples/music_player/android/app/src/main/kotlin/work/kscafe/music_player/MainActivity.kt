package work.kscafe.music_player

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import work.kscafe.coast_audio_native_codec.NativeDecoder

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    NativeDecoder.prepare()
  }
}
