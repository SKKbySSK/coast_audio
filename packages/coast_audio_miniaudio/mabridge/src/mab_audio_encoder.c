#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"

#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "mab_audio_encoder.h"

typedef struct {
  ma_encoder encoder;
  mab_audio_encoder_write_proc onWrite;
  mab_audio_encoder_seek_proc onSeek;
} mab_audio_encoder_data;

static inline mab_audio_encoder_data* get_data_ptr(mab_audio_encoder* pEncoder)
{
  return (mab_audio_encoder_data*)pEncoder->pData;
}

mab_audio_encoder_config mab_audio_encoder_config_init(mab_encoding_format encodingFormat, mab_format format, int sampleRate, int channels)
{
  mab_audio_encoder_config config = {
    .encodingFormat = encodingFormat,
    .format = format,
    .sampleRate = sampleRate,
    .channels = channels
  };
  return config;
}

ma_result ma_encoder_on_write(ma_encoder* pEncoder, const void* pBufferIn, size_t bytesToWrite, size_t* pBytesWritten) {
  mab_audio_encoder* pAudioEncoder = (mab_audio_encoder*)pEncoder->pUserData;
  mab_audio_encoder_data* pData = get_data_ptr(pAudioEncoder);
  mab_result result = pData->onWrite(pAudioEncoder, pBufferIn, bytesToWrite, pBytesWritten);
  return mab_cast(ma_result, result);
}

mab_result ma_encoder_on_seek(ma_encoder* pEncoder, ma_int64 byteOffset, ma_seek_origin origin) {
  mab_audio_encoder* pAudioEncoder = (mab_audio_encoder*)pEncoder->pUserData;
  mab_audio_encoder_data* pData = get_data_ptr(pAudioEncoder);
  mab_result result = pData->onSeek(pAudioEncoder, byteOffset, mab_cast(mab_seek_origin, origin));
  return mab_cast(ma_result, result);
}

mab_result mab_audio_encoder_init(mab_audio_encoder* pEncoder, mab_audio_encoder_config config, mab_audio_encoder_write_proc onWrite, mab_audio_encoder_seek_proc onSeek, void* pUserData)
{
  mab_audio_encoder_data* pData = (mab_audio_encoder_data*)MAB_MALLOC(sizeof(mab_audio_encoder_data));
  pEncoder->pUserData = pUserData;
  pEncoder->pData = pData;

  pData->onWrite = onWrite;
  pData->onSeek = onSeek;

  ma_result result;
  {
    ma_encoder_config encoderConfig = ma_encoder_config_init(
      mab_cast(ma_encoding_format, config.encodingFormat),
      mab_cast(ma_format, config.format),
      config.channels,
      config.sampleRate
    );

    if (onSeek == NULL) {
      result = ma_encoder_init(ma_encoder_on_write, NULL, pEncoder, &encoderConfig, &pData->encoder);
    }
    else {
      result = ma_encoder_init(ma_encoder_on_write, ma_encoder_on_seek, pEncoder, &encoderConfig, &pData->encoder);
    }
    if (result != MA_SUCCESS) {
      MAB_FREE(pData);
      return result;
    }
  }

  return result;
}

mab_result mab_audio_encoder_init_file(mab_audio_encoder* pEncoder, const char* pFilePath, mab_audio_encoder_config config)
{
  mab_audio_encoder_data* pData = (mab_audio_encoder_data*)MAB_MALLOC(sizeof(mab_audio_encoder_data));
  pEncoder->pData = pData;

  pData->onSeek = NULL;
  pData->onWrite = NULL;

  ma_encoder_config encoderConfig = ma_encoder_config_init(
    mab_cast(ma_encoding_format, config.encodingFormat),
    mab_cast(ma_format, config.format),
    config.channels,
    config.sampleRate
  );

  ma_result result = ma_encoder_init_file(pFilePath, &encoderConfig, &pData->encoder);
  if (result != MA_SUCCESS) {
    MAB_FREE(pData);
    return result;
  }

  return result;
}

mab_result mab_audio_encoder_encode(mab_audio_encoder* pEncoder, const void* pFramesIn, uint64 frameCount, uint64* pFramesWritten)
{
  if (frameCount == 0) {
    if (pFramesWritten != NULL) {
      *pFramesWritten = 0;
    }
    return MA_SUCCESS;
  }

  mab_audio_encoder_data* pData = get_data_ptr(pEncoder);
  return ma_encoder_write_pcm_frames(&pData->encoder, pFramesIn, frameCount, pFramesWritten);
}

void mab_audio_encoder_uninit(mab_audio_encoder* pEncoder)
{
  mab_audio_encoder_data* pData = get_data_ptr(pEncoder);
  ma_encoder_uninit(&pData->encoder);
  MAB_FREE(pData);
}
