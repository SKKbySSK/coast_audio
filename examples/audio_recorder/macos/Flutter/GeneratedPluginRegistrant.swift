//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import audio_service
import audio_session
import flutter_coast_audio_miniaudio
import flutter_media_metadata
import path_provider_foundation
import sqflite

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  AudioServicePlugin.register(with: registry.registrar(forPlugin: "AudioServicePlugin"))
  AudioSessionPlugin.register(with: registry.registrar(forPlugin: "AudioSessionPlugin"))
  FlutterCoastAudioMiniaudioPlugin.register(with: registry.registrar(forPlugin: "FlutterCoastAudioMiniaudioPlugin"))
  FlutterMediaMetadataPlugin.register(with: registry.registrar(forPlugin: "FlutterMediaMetadataPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  SqflitePlugin.register(with: registry.registrar(forPlugin: "SqflitePlugin"))
}
