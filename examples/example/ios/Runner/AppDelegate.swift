import UIKit
import Flutter
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let mabSymbols = [
      // mab_device.h
      mab_device_config_init,
      mab_device_init,
      mab_device_capture_read,
      mab_device_playback_write,
      mab_device_get_device_info,
      mab_device_start,
      mab_device_stop,
      mab_device_available_read,
      mab_device_available_write,
      mab_device_uninit,
      // mab_audio_decoder.h
      mab_audio_decoder_config_init,
      mab_audio_decoder_get_format,
      mab_audio_decoder_init_file,
      mab_audio_decoder_decode,
      mab_audio_decoder_get_cursor,
      mab_audio_decoder_set_cursor,
      mab_audio_decoder_get_length,
      mab_audio_decoder_uninit,
      // mab_device_context.h
      mab_device_info_init,
      mab_device_context_init,
      mab_device_context_get_device_count,
      mab_device_context_get_device_info,
      mab_device_context_uninit,
    ] as [Any]
    _ = mabSymbols.count
    
    AVAudioSession.sharedInstance().requestRecordPermission({ _ in })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
