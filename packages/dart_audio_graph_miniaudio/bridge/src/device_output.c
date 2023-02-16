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

static inline void data_callback(ma_device* pDevice, void* pOutput, const void* pInput, ma_uint32 frameCount)
{
  device_output* pDeviceOutput = (device_output*)pDevice->pUserData;
  device_output_data* pDeviceOutputData = get_data_ptr(pDeviceOutput);

  ma_uint32 readableFrames = frameCount;
  void* pBuffer;

  // TODO: handle result
  ma_result result = ma_pcm_rb_acquire_read(&pDeviceOutputData->buffer, &readableFrames, &pBuffer);
  assert(result == MA_SUCCESS || result == MA_AT_END);

  memcpy(pOutput, pBuffer, ma_get_bytes_per_frame(pDeviceOutputData->format, pDeviceOutput->channels) * readableFrames);

  // TODO: handle result
  result = ma_pcm_rb_commit_read(&pDeviceOutputData->buffer, readableFrames);
  assert(result == MA_SUCCESS || result == MA_AT_END);
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

  pDevice->sampleRate = config.sampleRate;
  pDevice->channels = config.channels;
  pDevice->pData = pData;

  ma_result result;

  // init: ma_context
  {
    ma_context_config contextConfig = ma_context_config_init();
    const ma_backend backends[] = { ma_backend_coreaudio, ma_backend_aaudio };
    result = ma_context_init(backends, 2, &contextConfig, &pData->context);
    if (result != MA_SUCCESS) {
      free(pData);
      return result;
    }
  }

  // init: ma_device
  {
    ma_device_config deviceConfig = ma_device_config_init(ma_device_type_playback);
    deviceConfig.playback.format = pData->format;
    deviceConfig.playback.channels = config.channels;
    deviceConfig.sampleRate = config.sampleRate;
    deviceConfig.noFixedSizedCallback = MA_FALSE;
    deviceConfig.dataCallback = data_callback;
    deviceConfig.pUserData = pDevice;

    result = ma_device_init(&pData->context, &deviceConfig, &pData->device);
    if (result != MA_SUCCESS) {
      ma_context_uninit(&pData->context);
      free(pData);
      return result;
    }
  }

  // init: ma_pcm_rb
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
  ma_uint32 writableFrames = frameCount;
  result = ma_pcm_rb_acquire_write(&pData->buffer, &writableFrames, &pBufferOut);
  if (result != MA_SUCCESS) {
    return result;
  }

  memcpy(pBufferOut, pBuffer, ma_get_bytes_per_frame(pData->format, pDevice->channels) * writableFrames);

  result = ma_pcm_rb_commit_write(&pData->buffer, writableFrames);
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

int device_output_available_write(device_output* pDevice)
{
  device_output_data* pData = get_data_ptr(pDevice);
  return ma_pcm_rb_available_write(&pData->buffer);
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
