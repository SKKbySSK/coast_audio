import Flutter
import UIKit
import Mabridge
import AVFoundation

public class FlutterCoastAudioMiniaudioPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_coast_audio_miniaudio", binaryMessenger: registrar.messenger())
    let instance = FlutterCoastAudioMiniaudioPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    instance.preventSymbolStrip()
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "get_input_latency":
      result(Double(AVAudioSession.sharedInstance().inputLatency))
    case "get_output_latency":
      result(Double(AVAudioSession.sharedInstance().outputLatency))
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // This will preserves all mabridge's symbols when building release mode.
  private func preventSymbolStrip() {
    let mabSymbols = [
      // mab_audio_encoder.h
      mab_audio_encoder_config_init,
      mab_audio_encoder_init,
      mab_audio_encoder_init_file,
      mab_audio_encoder_encode,
      mab_audio_encoder_uninit,
      

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
      

      // mab_low_shelf_filter.h
      mab_low_shelf_filter_config_init,
      mab_low_shelf_filter_init,
      mab_low_shelf_filter_process,
      mab_low_shelf_filter_reinit,
      mab_low_shelf_filter_get_latency,
      mab_low_shelf_filter_uninit,
      

      // mab_high_pass_filter.h
      mab_high_pass_filter_config_init,
      mab_high_pass_filter_init,
      mab_high_pass_filter_process,
      mab_high_pass_filter_reinit,
      mab_high_pass_filter_get_latency,
      mab_high_pass_filter_uninit,
      

      // mab_high_shelf_filter.h
      mab_high_shelf_filter_config_init,
      mab_high_shelf_filter_init,
      mab_high_shelf_filter_process,
      mab_high_shelf_filter_reinit,
      mab_high_shelf_filter_get_latency,
      mab_high_shelf_filter_uninit,
      

      // mab_peaking_eq_filter.h
      mab_peaking_eq_filter_config_init,
      mab_peaking_eq_filter_init,
      mab_peaking_eq_filter_process,
      mab_peaking_eq_filter_reinit,
      mab_peaking_eq_filter_get_latency,
      mab_peaking_eq_filter_uninit,
      

      // mab_audio_converter.h
      mab_audio_converter_config_init,
      mab_audio_converter_init,
      mab_audio_converter_process_pcm_frames,
      mab_audio_converter_get_input_latency,
      mab_audio_converter_get_output_latency,
      mab_audio_converter_get_required_input_frame_count,
      mab_audio_converter_get_expected_output_frame_count,
      mab_audio_converter_reset,
      mab_audio_converter_uninit,
      

      // mab_audio_decoder.h
      mab_audio_decoder_config_init,
      mab_audio_decoder_get_info,
      mab_audio_decoder_init,
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
      

      // mab_low_pass_filter.h
      mab_low_pass_filter_config_init,
      mab_low_pass_filter_init,
      mab_low_pass_filter_process,
      mab_low_pass_filter_reinit,
      mab_low_pass_filter_get_latency,
      mab_low_pass_filter_uninit
    ] as [Any]
    _ = mabSymbols.count
  }
}

private enum MabDeviceType: Int {
  case playback = 1
  case capture = 2
}

private struct CoreAudioDeviceInfo {
  let id: String
  let name: String
  let isDefault: Bool
}
