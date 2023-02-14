#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"

#include <stdlib.h>
#include <string.h>
#include "device_output.h"

typedef struct {
  ma_format format;
  ma_context context;
  ma_device device;
  ma_pcm_rb buffer;
} device_output_data;

static inline device_output_data* get_data_ptr(device_output* pDevice)
{
  return (device_output_data*)pDevice->pData;
}

device_output_config device_output_config_init(int sampleRate, int channels, int bufferFrameSize)
{
  device_output_config config = {
    .sampleRate = sampleRate,
    .channels = channels,
    .bufferFrameSize = bufferFrameSize
  };
  return config;
}

int device_output_init(device_output* pDevice, device_output_config config)
{
  device_output_data* pData = (device_output_data*)malloc(sizeof(device_output_data));
  pData->format = ma_format_f32;
  pDevice->pData = pData;

  ma_result result;
  {
    ma_context_config contextConfig = ma_context_config_init();
    const ma_backend backends[] = { ma_backend_coreaudio, ma_backend_aaudio };
    result = ma_context_init(backends, 2, &contextConfig, &pData->context);
    if (result != MA_SUCCESS) {
      free(pData);
      return result;
    }
  }

  {
    ma_device_config deviceConfig = ma_device_config_init(ma_device_type_playback);
    result = ma_device_init(&pData->context, &deviceConfig, &pData->device);
    if (result != MA_SUCCESS) {
      ma_context_uninit(&pData->context);
      free(pData);
      return result;
    }
  }

  {
    result = ma_pcm_rb_init(pData->format, config.channels, config.bufferFrameSize, NULL, NULL, &pData->buffer);
    if (result != MA_SUCCESS) {
      ma_device_uninit(&pData->device);
      ma_context_uninit(&pData->context);
      free(pData);
      return result;
    }
  }

  return result;
}

int device_output_write(device_output* pDevice, float* pBuffer, int frameCount)
{
  ma_result result;
  device_output_data* pData = get_data_ptr(pDevice);

  void* pBufferOut;
  ma_uint32 availableSpace = frameCount;
  result = ma_pcm_rb_acquire_write(&pData->buffer, &availableSpace, &pBufferOut);
  if (result != MA_SUCCESS) {
    return result;
  }

  memcpy(pBufferOut, pBuffer, ma_get_bytes_per_frame(pData->format, pDevice->channels) * availableSpace);

  result = ma_pcm_rb_commit_write(&pData->buffer, availableSpace);
  if (result != MA_SUCCESS) {
    return result;
  }

  return result;
}

int device_output_start(device_output* pDevice)
{
  device_output_data* pData = get_data_ptr(pDevice);
  return ma_device_start(&pData->device);
}

int device_output_stop(device_output* pDevice)
{
  device_output_data* pData = get_data_ptr(pDevice);
  return ma_device_stop(&pData->device);
}

int device_output_uninit(device_output* pDevice)
{
  device_output_data* pData = get_data_ptr(pDevice);

  ma_pcm_rb_uninit(&pData->buffer);
  ma_device_uninit(&pData->device);
  ma_result result = ma_context_uninit(&pData->context);

  free(pData);

  return result;
}
