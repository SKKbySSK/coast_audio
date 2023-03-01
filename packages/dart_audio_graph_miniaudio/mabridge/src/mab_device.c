#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"

#include <stdlib.h>
#include <string.h>
#include <assert.h>
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

static inline ma_result read_ring_buffer(mab_device* pDevice, void* pOutput, ma_uint32 frameCount, ma_uint32* pFramesRead) {
  mab_device_data* pData = get_data_ptr(pDevice);
  if (pFramesRead != NULL) {
    *pFramesRead = 0;
  }

  ma_result result = MA_SUCCESS;
  ma_uint32 bpf = ma_get_bytes_per_frame(pData->format, pDevice->channels);
  ma_uint32 readableFrames = frameCount;
  ma_uint32 framesRead = 0;
  void* pBuffer;

  while (readableFrames > 0) {
    ma_uint32 actualRead = readableFrames;
    result = ma_pcm_rb_acquire_read(&pData->buffer, &actualRead, &pBuffer);
    if (result != MA_SUCCESS && result != MA_AT_END) {
      return result;
    }

    MAB_COPY_MEMORY(pOutput + (bpf * framesRead), pBuffer, bpf * actualRead);

    result = ma_pcm_rb_commit_read(&pData->buffer, actualRead);
    if (result != MA_SUCCESS && result != MA_AT_END) {
      return result;
    }

    readableFrames -= actualRead;
    framesRead += actualRead;

    if (actualRead <= 0) {
      break;
    }
  }

  if (pFramesRead != NULL) {
    *pFramesRead = framesRead;
  }

  return result;
}

static inline ma_result write_ring_buffer(mab_device* pDevice, const void* pInput, ma_uint32 frameCount, ma_uint32* pFramesWrite) {
  mab_device_data* pData = get_data_ptr(pDevice);
  if (pFramesWrite != NULL) {
    *pFramesWrite = 0;
  }

  ma_result result = MA_SUCCESS;
  ma_uint32 bpf = ma_get_bytes_per_frame(pData->format, pDevice->channels);
  ma_uint32 writableFrames = frameCount;
  ma_uint32 framesWrite = 0;
  void* pBuffer;

  while (framesWrite < frameCount) {
    ma_uint32 actualWrite = writableFrames;
    result = ma_pcm_rb_acquire_write(&pData->buffer, &actualWrite, &pBuffer);
    if (result != MA_SUCCESS && result != MA_AT_END) {
      return result;
    }

    MAB_COPY_MEMORY(pBuffer, pInput + (bpf * framesWrite), bpf * actualWrite);

    result = ma_pcm_rb_commit_write(&pData->buffer, actualWrite);
    if (result != MA_SUCCESS && result != MA_AT_END) {
      return result;
    }

    writableFrames -= actualWrite;
    framesWrite += actualWrite;

    if (actualWrite <= 0) {
      break;
    }
  }

  if (pFramesWrite != NULL) {
    *pFramesWrite = framesWrite;
  }

  return result;
}

static inline void playback_callback(ma_device* pDevice, void* pOutput, const void* pInput, ma_uint32 frameCount)
{
  mab_device* pDeviceOutput = (mab_device*)pDevice->pUserData;
  ma_result result = read_ring_buffer(pDeviceOutput, pOutput, frameCount, NULL);
  assert(result == MA_SUCCESS || result == MA_AT_END);
}

static inline void capture_callback(ma_device* pDevice, void* pOutput, const void* pInput, ma_uint32 frameCount)
{
  mab_device* pDeviceInput = (mab_device*)pDevice->pUserData;
  ma_result result = write_ring_buffer(pDeviceInput, pInput, frameCount, NULL);
  assert(result == MA_SUCCESS || result == MA_AT_END);
}

mab_device_config mab_device_config_init(mab_device_type type, mab_format format, int sampleRate, int channels, int bufferFrameSize)
{
  mab_device_config config = {
    .type = type,
    .format = format,
    .sampleRate = sampleRate,
    .channels = channels,
    .bufferFrameSize = bufferFrameSize,
    .noFixedSizedCallback = MAB_TRUE,
  };
  return config;
}

mab_result mab_device_init(mab_device* pDevice, mab_device_config config, mab_device_context* pContext, mab_device_id* pDeviceId)
{
  mab_device_data* pData = (mab_device_data*)MAB_MALLOC(sizeof(mab_device_data));
  pData->format = *(ma_format*)&config.format;
  pDevice->pData = pData;
  pDevice->config = config;

  ma_result result;

  // init: ma_device
  {
    ma_device_config deviceConfig = ma_device_config_init(config.type);
    deviceConfig.playback.pDeviceID = (ma_device_id*)pDeviceId;
    deviceConfig.playback.format = pData->format;
    deviceConfig.playback.channels = config.channels;
    deviceConfig.capture.pDeviceID = (ma_device_id*)pDeviceId;
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

mab_result mab_device_capture_read(mab_device* pDevice, float* pBuffer, int frameCount, int* pFramesRead)
{
  return read_ring_buffer(pDevice, pBuffer, frameCount, (ma_uint32*)pFramesRead);
}

mab_result mab_device_playback_write(mab_device* pDevice, const float* pBuffer, int frameCount, int* pFramesWrite)
{
  return write_ring_buffer(pDevice, pBuffer, frameCount, (ma_uint32*)pFramesWrite);
}

mab_result mab_device_get_device_info(mab_device* pDevice, mab_device_info* pDeviceInfo)
{
  mab_device_data* pData = get_data_ptr(pDevice);
  ma_device_info info;
  ma_result result;
  switch (pDevice->config.type)
  {
  case mab_device_type_playback:
    result = ma_device_get_info(&pData->device, ma_device_type_playback, &info);
    break;
  case mab_device_type_capture:
    result = ma_device_get_info(&pData->device, ma_device_type_capture, &info);
    break;
  default:
    return MA_INVALID_ARGS;
  }

  if (result != MA_SUCCESS) {
    return result;
  }

  mab_device_info_init(pDeviceInfo, *(mab_device_id*)&info.id, info.name, info.isDefault);
  return result;
}

mab_result mab_device_start(mab_device* pDevice)
{
  mab_device_data* pData = get_data_ptr(pDevice);
  return ma_device_start(&pData->device);
}

mab_result mab_device_stop(mab_device* pDevice)
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
