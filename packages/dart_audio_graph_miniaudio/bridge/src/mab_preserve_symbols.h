#pragma once
#include "mab_device_context.h"
#include "mab_device.h"
#include "mab_audio_decoder.h"
#include "mab_types.h"
#include "mab_enum.h"

void* _mab_symbols[] = {
  // mab_device_context
  mab_device_context_init,
  mab_device_context_uninit,

  // mab_device
  mab_device_config_init,
  mab_device_init,
  mab_device_available_read,
  mab_device_available_write,
  mab_device_capture_read,
  mab_device_playback_write,
  mab_device_start,
  mab_device_stop,
  mab_device_uninit,

  // mab_audio_decoder
  mab_audio_decoder_config_init,
  mab_audio_decoder_init_file,
  mab_audio_decoder_decode,
  mab_audio_decoder_get_cursor,
  mab_audio_decoder_get_length,
  mab_audio_decoder_get_format,
  mab_audio_decoder_set_cursor,
  mab_audio_decoder_uninit,
};

void mab_preserve_symbols() {
  (void)_mab_symbols;
}
