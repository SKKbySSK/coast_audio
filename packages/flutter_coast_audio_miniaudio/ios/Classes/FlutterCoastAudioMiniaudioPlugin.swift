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
    case "get_devices":
      let type = MabDeviceType(rawValue: call.arguments as! Int)!
      getDevices(result: result, type: type)
    case "get_input_latency":
      result(Double(AVAudioSession.sharedInstance().inputLatency))
    case "get_output_latency":
      result(Double(AVAudioSession.sharedInstance().outputLatency))
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func getDevices(result: @escaping FlutterResult, type: MabDeviceType) {
    let session = AVAudioSession.sharedInstance()
    let audioPorts: [AVAudioSessionPortDescription]
    switch type {
    case .playback:
      audioPorts = session.currentRoute.outputs
    case .capture:
      audioPorts = session.availableInputs ?? []
    }
    
    let devices = audioPorts.map({ d in
      return CoreAudioDeviceInfo(
        id: d.uid,
        name: d.portName,
        isDefault: false
      )
    }).map({ d in
      return [
        "id": d.id,
        "name": d.name,
        "is_default": d.isDefault
      ] as [String: Any]
    })
    
    result(devices)
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
        mab_audio_decoder_get_info,
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

private enum MabDeviceType: Int {
  case playback = 1
  case capture = 2
}

private struct CoreAudioDeviceInfo {
  let id: String
  let name: String
  let isDefault: Bool
}
