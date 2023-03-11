#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"

#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "mab_audio_decoder.h"

typedef struct {
  ma_format format;
  ma_decoder decoder;
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

mab_result mab_audio_decoder_get_format(const char* pFilePath, mab_audio_decoder_format* pFormat)
{
  MAB_ZERO_OBJECT(pFormat);

  ma_decoder decoder;
  ma_result result;
  {
    result = ma_decoder_init_file(pFilePath, NULL, &decoder);
    if (result != MA_SUCCESS) {
      return result;
    }
  }

  pFormat->channels = decoder.outputChannels;
  pFormat->sampleRate = decoder.outputSampleRate;

  {
    result = ma_decoder_get_length_in_pcm_frames(&decoder, &pFormat->length);
    if (result != MA_SUCCESS) {
      return result;
    }
  }

  return ma_decoder_uninit(&decoder);
}

mab_result mab_audio_decoder_init_file(mab_audio_decoder* pDecoder, const char* pFilePath, mab_audio_decoder_config config) {
  mab_audio_decoder_data* pData = (mab_audio_decoder_data*)MAB_MALLOC(sizeof(mab_audio_decoder_data));
  pDecoder->pData = pData;
  pData->format = *(ma_format*)&config.format;

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
