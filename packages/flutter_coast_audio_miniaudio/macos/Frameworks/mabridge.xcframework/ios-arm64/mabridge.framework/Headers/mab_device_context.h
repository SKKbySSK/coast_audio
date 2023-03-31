#pragma once
#include "mab_enum.h"
#include "mab_types.h"
#include <wchar.h>

typedef struct {
  void* pData;
  void* pMaContext;
  mab_backend backend;
} mab_device_context;

typedef union
{
  wchar_t wasapi[64];             /* WASAPI uses a wchar_t string for identification. */
  char dsound[16];            /* DirectSound uses a GUID for identification. */
  /*UINT_PTR*/ unsigned int winmm;   /* When creating a device, WinMM expects a Win32 UINT_PTR for device identification. In practice it's actually just a UINT. */
  char alsa[256];                 /* ALSA uses a name string for identification. */
  char pulse[256];                /* PulseAudio uses a name string for identification. */
  int jack;                       /* JACK always uses default devices. */
  char coreaudio[256];            /* Core Audio uses a string for identification. */
  char sndio[256];                /* "snd/0", etc. */
  char audio4[256];               /* "/dev/audio", etc. */
  char oss[64];                   /* "dev/dsp0", etc. "dev/dsp" for the default device. */
  int aaudio;                /* AAudio uses a 32-bit integer for identification. */
  unsigned int opensl;               /* OpenSL|ES uses a 32-bit unsigned integer for identification. */
  char webaudio[32];              /* Web Audio always uses default devices for now, but if this changes it'll be a GUID. */
  int nullbackend;                /* The null backend uses an integer for device IDs. */
} mab_device_id;

typedef struct
{
  mab_device_id id;
  char name[256];
  mab_bool isDefault;
} mab_device_info;

void mab_device_info_init(mab_device_info* pInfo, mab_device_id id, char* name, mab_bool isDefault);

mab_result mab_device_context_init(mab_device_context* pContext, mab_backend* pBackends, int backendCount);

mab_result mab_device_context_get_device_count(mab_device_context* pContext, mab_device_type type, int* pCount);

mab_result mab_device_context_get_device_info(mab_device_context* pContext, mab_device_type type, int index, mab_device_info* pInfo);

mab_result mab_device_context_uninit(mab_device_context* pContext);
