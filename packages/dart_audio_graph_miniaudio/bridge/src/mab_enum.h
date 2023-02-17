#pragma once

typedef enum
{
  mab_backend_wasapi = 0,
  mab_backend_dsound,
  mab_backend_winmm,
  mab_backend_coreaudio,
  mab_backend_sndio,
  mab_backend_audio4,
  mab_backend_oss,
  mab_backend_pulseaudio,
  mab_backend_alsa,
  mab_backend_jack,
  mab_backend_aaudio,
  mab_backend_opensl,
  mab_backend_webaudio
} mab_backend;

typedef enum
{
  mab_dither_mode_none = 0,
  mab_dither_mode_rectangle,
  mab_dither_mode_triangle
} mab_dither_mode;

typedef enum
{
  mab_channel_mix_mode_rectangular = 0,   /* Simple averaging based on the plane(s) the channel is sitting on. */
  mab_channel_mix_mode_simple,            /* Drop excess channels; zeroed out extra channels. */
  // ma_channel_mix_mode_custom_weights,    /* Use custom weights specified in ma_channel_converter_config. */
} mab_channel_mix_mode;

typedef enum
{
  mab_device_type_playback = 1,
  mab_device_type_capture = 2
} mab_device_type;
