package com.example.flutter_coast_audio_miniaudio

import android.content.Context
import android.content.pm.PackageManager
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterCoastAudioMiniaudioPlugin */
class FlutterCoastAudioMiniaudioPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_coast_audio_miniaudio")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    // From doc: https://developer.android.com/ndk/guides/audio/audio-latency
    when (call.method) {
      "get_input_latency" -> {
        if (context.packageManager.hasSystemFeature(PackageManager.FEATURE_AUDIO_PRO)) {
          result.success(0.010)
        } else {
          result.success(null)
        }
      }
      "get_output_latency" -> {
        if (context.packageManager.hasSystemFeature(PackageManager.FEATURE_AUDIO_PRO)) {
          result.success(0.010)
        } else if (context.packageManager.hasSystemFeature(PackageManager.FEATURE_AUDIO_LOW_LATENCY)) {
          result.success(0.045)
        } else {
          result.success(null)
        }
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
