#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"

#include <stdlib.h>
#include <string.h>
#include "mab_device.h"

typedef struct {
  ma_format format;
  ma_device device;
  ma_pcm_rb buffer;
} mab_device_data;

static inline mab_device_data* get_data_ptr(mab_device* pDevice)
{
  return (mab_device_data*)pDevice->pData;
}

static inline void playback_callback(ma_device* pDevice, void* pOutput, const void* pInput, ma_uint32 frameCount)
{
  mab_device* pDeviceOutput = (mab_device*)pDevice->pUserData;
  mab_device_data* pDeviceOutputData = get_data_ptr(pDeviceOutput);

  ma_uint32 readableFrames = frameCount;
  void* pBuffer;

  ma_result result = ma_pcm_rb_acquire_read(&pDeviceOutputData->buffer, &readableFrames, &pBuffer);
  assert(result == MA_SUCCESS || result == MA_AT_END);

  MA_COPY_MEMORY(pOutput, pBuffer, ma_get_bytes_per_frame(pDeviceOutputData->format, pDeviceOutput->channels) * readableFrames);

  result = ma_pcm_rb_commit_read(&pDeviceOutputData->buffer, readableFrames);
  assert(result == MA_SUCCESS || result == MA_AT_END);
}

static inline void capture_callback(ma_device* pDevice, void* pOutput, const void* pInput, ma_uint32 frameCount)
{
  mab_device* pDeviceInput = (mab_device*)pDevice->pUserData;
  mab_device_data* pDeviceInputData = get_data_ptr(pDeviceInput);

  ma_uint32 writableFrames = frameCount;
  void* pBuffer;

  while (writableFrames > 0)
  {
    ma_result result = ma_pcm_rb_acquire_write(&pDeviceInputData->buffer, &writableFrames, &pBuffer);
    assert(result == MA_SUCCESS || result == MA_AT_END);
    if (writableFrames == 0) {
      break;
    }

    MA_COPY_MEMORY(pBuffer, pInput, ma_get_bytes_per_frame(pDeviceInputData->format, pDeviceInput->channels) * writableFrames);

    result = ma_pcm_rb_commit_write(&pDeviceInputData->buffer, writableFrames);
    assert(result == MA_SUCCESS || result == MA_AT_END);
    writableFrames = frameCount - writableFrames;
  }
}

mab_device_config mab_device_config_init(mab_device_type type, int sampleRate, int channels, int bufferFrameSize)
{
  mab_device_config config = {
    .type = type,
    .sampleRate = sampleRate,
    .channels = channels,
    .bufferFrameSize = bufferFrameSize,
    .noFixedSizedCallback = mab_true,
  };
  return config;
}

int mab_device_init(mab_device* pDevice, mab_device_config config, mab_device_context* pContext)
{
  mab_device_data* pData = (mab_device_data*)malloc(sizeof(mab_device_data));
  pData->format = ma_format_f32;
  pDevice->pData = pData;
  pDevice->config = config;

  ma_result result;

  // init: ma_device
  {
    ma_device_config deviceConfig = ma_device_config_init(config.type);
    deviceConfig.playback.format = pData->format;
    deviceConfig.playback.channels = config.channels;
    deviceConfig.capture.format = pData->format;
    deviceConfig.capture.channels = config.channels;
    deviceConfig.sampleRate = config.sampleRate;
    deviceConfig.noFixedSizedCallback = config.noFixedSizedCallback;
    deviceConfig.pUserData = pDevice;

    switch (config.type)
    {
    case mab_device_type_playback:
      deviceConfig.dataCallback = playback_callback;
      break;
    case mab_device_type_capture:
      deviceConfig.dataCallback = capture_callback;
      break;
    default:
      free(pData);
      return MA_INVALID_ARGS;
    }

    result = ma_device_init((ma_context*)pContext->pMaContext, &deviceConfig, &pData->device);
    if (result != MA_SUCCESS) {
      free(pData);
      return result;
    }
  }

  // init: ma_pcm_rb
  {
    result = ma_pcm_rb_init(pData->format, config.channels, config.bufferFrameSize, NULL, NULL, &pData->buffer);
    if (result != MA_SUCCESS) {
      ma_device_uninit(&pData->device);
      free(pData);
      return result;
    }
  }

  pDevice->sampleRate = pData->device.sampleRate;
  pDevice->channels = pData->device.playback.channels;

  return result;
}

int mab_device_capture_read(mab_device* pDevice, float* pBuffer, int frameCount, int* pFramesRead)
{
  if (pFramesRead != NULL) {
    *pFramesRead = 0;
  }
  ma_result result;
  mab_device_data* pData = get_data_ptr(pDevice);

  void* pBufferIn;
  ma_uint32 readableFrames = frameCount;
  result = ma_pcm_rb_acquire_read(&pData->buffer, &readableFrames, &pBufferIn);
  if (result != MA_SUCCESS && result != MA_AT_END) {
    return result;
  }

  MA_COPY_MEMORY(pBuffer, pBufferIn, ma_get_bytes_per_frame(pData->format, pDevice->channels) * readableFrames);

  result = ma_pcm_rb_commit_read(&pData->buffer, readableFrames);
  if (result != MA_SUCCESS && result != MA_AT_END) {
    return result;
  }

  *pFramesRead = readableFrames;
  return result;
}

int mab_device_playback_write(mab_device* pDevice, float* pBuffer, int frameCount)
{
  ma_result result;
  mab_device_data* pData = get_data_ptr(pDevice);

  void* pBufferOut;
  ma_uint32 writableFrames = frameCount;
  result = ma_pcm_rb_acquire_write(&pData->buffer, &writableFrames, &pBufferOut);
  if (result != MA_SUCCESS) {
    return result;
  }

  MA_COPY_MEMORY(pBufferOut, pBuffer, ma_get_bytes_per_frame(pData->format, pDevice->channels) * writableFrames);

  result = ma_pcm_rb_commit_write(&pData->buffer, writableFrames);
  if (result != MA_SUCCESS) {
    return result;
  }

  return result;
}

int mab_device_start(mab_device* pDevice)
{
  mab_device_data* pData = get_data_ptr(pDevice);
  return ma_device_start(&pData->device);
}

int mab_device_stop(mab_device* pDevice)
{
  mab_device_data* pData = get_data_ptr(pDevice);
  return ma_device_stop(&pData->device);
}

int mab_device_available_read(mab_device* pDevice)
{
  mab_device_data* pData = get_data_ptr(pDevice);
  return ma_pcm_rb_available_read(&pData->buffer);
}

int mab_device_available_write(mab_device* pDevice)
{
  mab_device_data* pData = get_data_ptr(pDevice);
  return ma_pcm_rb_available_write(&pData->buffer);
}

void mab_device_uninit(mab_device* pDevice)
{
  mab_device_data* pData = get_data_ptr(pDevice);

  ma_pcm_rb_uninit(&pData->buffer);
  ma_device_uninit(&pData->device);

  free(pData);
}
