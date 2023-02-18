#pragma once
#include "mab_enum.h"
#include "mab_types.h"
#include "mab_device_context.h"

typedef struct {
  mab_device_type type;
  int sampleRate;
  int channels;
  int bufferFrameSize;
  mab_bool noFixedSizedCallback;
} mab_device_config;

mab_device_config mab_device_config_init(mab_device_type type, int sampleRate, int channels, int bufferFrameSize);

typedef struct {
  mab_device_config config;
  int sampleRate;
  int channels;
  void* pData;
} mab_device;

int mab_device_init(mab_device* pDevice, mab_device_config config, mab_device_context* pContext, mab_device_id* pDeviceId);

int mab_device_capture_read(mab_device* pDevice, float* pBuffer, int frameCount, int* pFramesRead);

int mab_device_playback_write(mab_device* pDevice, float* pBuffer, int frameCount);

int mab_device_get_device_info(mab_device* pDevice, mab_device_info* pDeviceInfo);

int mab_device_start(mab_device* pDevice);

int mab_device_stop(mab_device* pDevice);

int mab_device_available_read(mab_device* pDevice);

int mab_device_available_write(mab_device* pDevice);

void mab_device_uninit(mab_device* pDevice);
