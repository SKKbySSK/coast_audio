#pragma once

typedef enum
{
  ca_format_unknown = 0, /* Mainly used for indicating an error, but also used as the default for the output format for decoders. */
  ca_format_u8 = 1,
  ca_format_s16 = 2, /* Seems to be the most widely supported format. */
  ca_format_s24 = 3, /* Tightly packed. 3 bytes per sample. */
  ca_format_s32 = 4,
  ca_format_f32 = 5,
  ca_format_count
} ca_format;

typedef enum
{
  ca_backend_wasapi = 0,
  ca_backend_dsound,
  ca_backend_winmm,
  ca_backend_coreaudio,
  ca_backend_sndio,
  ca_backend_audio4,
  ca_backend_oss,
  ca_backend_pulseaudio,
  ca_backend_alsa,
  ca_backend_jack,
  ca_backend_aaudio,
  ca_backend_opensl,
  ca_backend_webaudio
} ca_backend;

typedef enum
{
  ca_dither_mode_none = 0,
  ca_dither_mode_rectangle,
  ca_dither_mode_triangle
} ca_dither_mode;

typedef enum
{
  ca_channel_mix_mode_rectangular = 0, /* Simple averaging based on the plane(s) the channel is sitting on. */
  ca_channel_mix_mode_simple,          /* Drop excess channels; zeroed out extra channels. */
  // ma_channel_mix_mode_custom_weights,    /* Use custom weights specified in ma_channel_converter_config. */
} ca_channel_mix_mode;

typedef enum
{
  ca_device_type_playback = 1,
  ca_device_type_capture = 2
} ca_device_type;

typedef enum
{
  ca_device_state_uninitialized = 0,
  ca_device_state_stopped = 1,  /* The device's default state after initialization. */
  ca_device_state_started = 2,  /* The device is started and is requesting and/or delivering audio data. */
  ca_device_state_starting = 3, /* Transitioning from a stopped state to started. */
  ca_device_state_stopping = 4  /* Transitioning from a started state to stopped. */
} ca_device_state;

typedef enum
{
  ca_device_notification_type_started,
  ca_device_notification_type_stopped,
  ca_device_notification_type_rerouted,
  ca_device_notification_type_interruption_began,
  ca_device_notification_type_interruption_ended
} ca_device_notification_type;

typedef enum
{
  ca_performance_profile_low_latency = 0,
  ca_performance_profile_conservative
} ca_performance_profile;

typedef enum
{
  ca_seek_origin_start,
  ca_seek_origin_current,
  ca_seek_origin_end /* Not used by decoders. */
} ca_seek_origin;

typedef enum
{
  ca_encoding_format_unknown = 0,
  ca_encoding_format_wav,
  ca_encoding_format_flac,
  ca_encoding_format_mp3,
  ca_encoding_format_vorbis
} ca_encoding_format;
