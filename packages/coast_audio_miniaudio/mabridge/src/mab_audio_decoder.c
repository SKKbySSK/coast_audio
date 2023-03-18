#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"

#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "mab_audio_decoder.h"

typedef struct {
  ma_format format;
  ma_decoder decoder;
  mab_audio_decoder_read_proc onRead;
  mab_audio_decoder_seek_proc onSeek;
} mab_audio_decoder_data;

static inline mab_audio_decoder_data* get_data_ptr(mab_audio_decoder* pDecoder)
{
  return (mab_audio_decoder_data*)pDecoder->pData;
}

mab_audio_decoder_config mab_audio_decoder_config_init(mab_format format, int sampleRate, int channels) {
  mab_audio_decoder_config config = {
    .format = format,
    .sampleRate = sampleRate,
    .channels = channels,
    .ditherMode = mab_dither_mode_none,
    .channelMixMode = mab_channel_mix_mode_rectangular,
  };
  return config;
}

mab_result mab_audio_decoder_get_info(const char* pFilePath, mab_audio_decoder_info* pInfo)
{
  MAB_ZERO_OBJECT(pInfo);

  ma_decoder decoder;
  ma_result result;
  {
    result = ma_decoder_init_file(pFilePath, NULL, &decoder);
    if (result != MA_SUCCESS) {
      return result;
    }
  }

  pInfo->format = *(mab_format*)&decoder.outputFormat;
  pInfo->channels = decoder.outputChannels;
  pInfo->sampleRate = decoder.outputSampleRate;

  {
    result = ma_decoder_get_length_in_pcm_frames(&decoder, &pInfo->length);
    if (result != MA_SUCCESS) {
      return result;
    }
  }

  return ma_decoder_uninit(&decoder);
}

ma_result ma_decoder_on_read(ma_decoder* pDecoder, void* pBufferOut, size_t bytesToRead, size_t* pBytesRead) {
  mab_audio_decoder* pAudioDecoder = (mab_audio_decoder*)pDecoder->pUserData;
  mab_audio_decoder_data* pData = get_data_ptr(pAudioDecoder);
  mab_result result = pData->onRead(pAudioDecoder, pBufferOut, bytesToRead, pBytesRead);
  return *(ma_result*)&result;
}

mab_result mab_decoder_on_seek(ma_decoder* pDecoder, ma_int64 byteOffset, ma_seek_origin origin) {
  mab_audio_decoder* pAudioDecoder = (mab_audio_decoder*)pDecoder->pUserData;
  mab_audio_decoder_data* pData = get_data_ptr(pAudioDecoder);
  mab_result result = pData->onSeek(pAudioDecoder, byteOffset, *(mab_seek_origin*)&origin);
  return *(ma_result*)&result;
}

mab_result mab_audio_decoder_init(mab_audio_decoder* pDecoder, mab_audio_decoder_config config, mab_audio_decoder_read_proc onRead, mab_audio_decoder_seek_proc onSeek, void* pUserData) {
  mab_audio_decoder_data* pData = (mab_audio_decoder_data*)MAB_MALLOC(sizeof(mab_audio_decoder_data));
  pDecoder->pUserData = pUserData;
  pDecoder->pData = pData;

  pData->format = *(ma_format*)&config.format;
  pData->onRead = onRead;
  pData->onSeek = onSeek;

  ma_result result;
  {
    ma_decoder_config decoderConfig = ma_decoder_config_init(pData->format, config.channels, config.sampleRate);
    decoderConfig.channelMixMode = *(ma_channel_mix_mode*)&config.channelMixMode;
    decoderConfig.ditherMode = *(ma_dither_mode*)&config.ditherMode;

    if (onSeek == NULL) {
      result = ma_decoder_init(ma_decoder_on_read, NULL, pDecoder, &decoderConfig, &pData->decoder);
    } else {
      result = ma_decoder_init(ma_decoder_on_read, mab_decoder_on_seek, pDecoder, &decoderConfig, &pData->decoder);
    }
    if (result != MA_SUCCESS) {
      MAB_FREE(pData);
      return result;
    }
  }

  return result;
}

mab_result mab_audio_decoder_init_file(mab_audio_decoder* pDecoder, const char* pFilePath, mab_audio_decoder_config config) {
  mab_audio_decoder_data* pData = (mab_audio_decoder_data*)MAB_MALLOC(sizeof(mab_audio_decoder_data));
  pDecoder->pUserData = NULL;
  pDecoder->pData = pData;

  pData->format = *(ma_format*)&config.format;
  pData->onRead = NULL;
  pData->onSeek = NULL;

  ma_result result;
  {
    ma_decoder_config decoderConfig = ma_decoder_config_init(pData->format, config.channels, config.sampleRate);
    decoderConfig.channelMixMode = *(ma_channel_mix_mode*)&config.channelMixMode;
    decoderConfig.ditherMode = *(ma_dither_mode*)&config.ditherMode;

    result = ma_decoder_init_file(pFilePath, &decoderConfig, &pData->decoder);
    if (result != MA_SUCCESS) {
      MAB_FREE(pData);
      return result;
    }
  }

  return result;
}

mab_result mab_audio_decoder_decode(mab_audio_decoder* pDecoder, float* pOutput, uint64 frameCount, uint64* pFramesRead) {
  // ma_decoder_read_pcm_frames failes if frameCount == 0
  if (frameCount == 0) {
    if (pFramesRead != NULL) {
      *pFramesRead = 0;
    }
    return MA_SUCCESS;
  }

  mab_audio_decoder_data* pData = get_data_ptr(pDecoder);
  return ma_decoder_read_pcm_frames(&pData->decoder, pOutput, frameCount, pFramesRead);
}

mab_result mab_audio_decoder_get_cursor(mab_audio_decoder* pDecoder, uint64* pCursor) {
  mab_audio_decoder_data* pData = get_data_ptr(pDecoder);
  return ma_decoder_get_cursor_in_pcm_frames(&pData->decoder, pCursor);
}

mab_result mab_audio_decoder_set_cursor(mab_audio_decoder* pDecoder, uint64 cursor) {
  mab_audio_decoder_data* pData = get_data_ptr(pDecoder);
  return ma_decoder_seek_to_pcm_frame(&pData->decoder, cursor);
}

mab_result mab_audio_decoder_get_length(mab_audio_decoder* pDecoder, uint64* pLength) {
  mab_audio_decoder_data* pData = get_data_ptr(pDecoder);
  return ma_decoder_get_length_in_pcm_frames(&pData->decoder, pLength);
}

mab_result mab_audio_decoder_uninit(mab_audio_decoder* pDecoder) {
  mab_audio_decoder_data* pData = get_data_ptr(pDecoder);
  ma_result result = ma_decoder_uninit(&pData->decoder);
  MAB_FREE(pData);
  return result;
}
