import Flutter
import UIKit
import Mabridge

public class FlutterCoastAudioMiniaudioPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_coast_audio_miniaudio", binaryMessenger: registrar.messenger())
    let instance = FlutterCoastAudioMiniaudioPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    instance.preventSymbolStrip()
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result(FlutterMethodNotImplemented)
  }

  // This will preserves all mabridge's symbols when building release mode.
  private func preventSymbolStrip() {
    let mabSymbols = [
        // dart_bridge.h
        dart_bridge_init,
        // mab_device.h
        mab_device_config_init,
        mab_device_init,
        mab_device_capture_read,
        mab_device_playback_write,
        mab_device_get_device_info,
        mab_device_start,
        mab_device_stop,
        mab_device_get_state,
        mab_device_clear_buffer,
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
  }
}
