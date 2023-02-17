import UIKit
import Flutter
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let preserved = [
      mab_device_config_init,
      mab_audio_decoder_config_init
    ] as [Any]
    debugPrint(preserved.count)
    
    AVAudioSession.sharedInstance().requestRecordPermission({ _ in })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
