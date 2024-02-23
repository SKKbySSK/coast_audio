#pragma once
#include <wchar.h>
#include <stdint.h>
#include "ca_enum.h"
#include "ca_types.h"
#include "ca_device.h"

typedef struct
{
  void *pData;
  void *pMaContext;
  ca_backend backend;
} ca_device_context;

typedef union
{
  wchar_t wasapi[64];              /* WASAPI uses a wchar_t string for identification. */
  char dsound[16];                 /* DirectSound uses a GUID for identification. */
  /*UINT_PTR*/ unsigned int winmm; /* When creating a device, WinMM expects a Win32 UINT_PTR for device identification. In practice it's actually just a UINT. */
  char alsa[256];                  /* ALSA uses a name string for identification. */
  char pulse[256];                 /* PulseAudio uses a name string for identification. */
  int jack;                        /* JACK always uses default devices. */
  char coreaudio[256];             /* Core Audio uses a string for identification. */
  char sndio[256];                 /* "snd/0", etc. */
  char audio4[256];                /* "/dev/audio", etc. */
  char oss[64];                    /* "dev/dsp0", etc. "dev/dsp" for the default device. */
  int aaudio;                      /* AAudio uses a 32-bit integer for identification. */
  unsigned int opensl;             /* OpenSL|ES uses a 32-bit unsigned integer for identification. */
  char webaudio[32];               /* Web Audio always uses default devices for now, but if this changes it'll be a GUID. */
  int nullbackend;                 /* The null backend uses an integer for device IDs. */
} ca_device_id;

typedef struct
{
  ca_device_id id;
  char name[256];
  ca_bool isDefault;
} ca_device_info;

typedef struct ca_device ca_device;

typedef struct
{
  ca_device_notification_type type;
} ca_device_notification;

typedef void (*ca_device_notification_proc)(ca_device *pDevice, ca_device_notification notification);

typedef struct
{
  ca_device_type type;
  ca_format format;
  int sampleRate;
  int channels;
  int bufferFrameSize;
  ca_bool noFixedSizedCallback;
  int64_t notificationPortId;
  ca_channel_mix_mode channelMixMode;
  ca_performance_profile performanceProfile;
} ca_device_config;

ca_device_config ca_device_config_init(ca_device_type type, ca_format format, int sampleRate, int channels, int bufferFrameSize, int64_t notificationPortId);

typedef struct ca_device
{
  ca_device_config config;
  int sampleRate;
  int channels;
  void *pData;
} ca_device;

void ca_device_dart_configure(void *pDartPostCObject);

void ca_device_info_init(ca_device_info *pInfo, ca_device_id id, char *name, ca_bool isDefault);

ca_result ca_device_context_init(ca_device_context *pContext, ca_backend *pBackends, int backendCount);

ca_result ca_device_context_get_device_count(ca_device_context *pContext, ca_device_type type, int *pCount);

ca_result ca_device_context_get_device_info(ca_device_context *pContext, ca_device_type type, int index, ca_device_info *pInfo);

ca_result ca_device_context_uninit(ca_device_context *pContext);

ca_result ca_device_init(ca_device *pDevice, ca_device_config config, ca_device_context *pContext, ca_device_id *pDeviceId);

ca_result ca_device_capture_read(ca_device *pDevice, float *pBuffer, int frameCount, int *pFramesRead);

ca_result ca_device_playback_write(ca_device *pDevice, const float *pBuffer, int frameCount, int *pFramesWrite);

ca_result ca_device_get_device_info(ca_device *pDevice, ca_device_info *pDeviceInfo);

ca_result ca_device_start(ca_device *pDevice);

ca_result ca_device_stop(ca_device *pDevice);

ca_device_state ca_device_get_state(ca_device *pDevice);

void ca_device_clear_buffer(ca_device *pDevice);

int ca_device_available_read(ca_device *pDevice);

int ca_device_available_write(ca_device *pDevice);

void ca_device_uninit(ca_device *pDevice);
