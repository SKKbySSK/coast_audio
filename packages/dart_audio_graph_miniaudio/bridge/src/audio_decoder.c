#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"

#include <stdlib.h>
#include <string.h>
#include "audio_decoder.h"

typedef struct {
  ma_format format;
  ma_decoder decoder;
} audio_decoder_data;

static inline audio_decoder_data* get_data_ptr(audio_decoder* pDecoder)
{
  return (audio_decoder_data*)pDecoder->pData;
}

audio_decoder_config audio_decoder_config_init(int sampleRate, int channels) {
  audio_decoder_config config = {
    .sampleRate = sampleRate,
    .channels = channels,
  };
  return config;
}

int audio_decoder_init_file(audio_decoder* pDecoder, char* pFilePath, audio_decoder_config config) {
  audio_decoder_data* pData = (audio_decoder_data*)MA_MALLOC(sizeof(audio_decoder_data));
  pDecoder->pData = pData;
  pData->format = ma_format_f32;

  ma_result result;
  {
    ma_decoder_config decoderConfig = ma_decoder_config_init(pData->format, config.channels, config.sampleRate);
    result = ma_decoder_init_file(pFilePath, &decoderConfig, &pData->decoder);
    if (result != MA_SUCCESS) {
      MA_FREE(pData);
      return result;
    }
  }

  return result;
}

int audio_decoder_decode(audio_decoder* pDecoder, float* pOutput, uint64 frameCount, uint64* pFramesRead) {
  audio_decoder_data* pData = get_data_ptr(pDecoder);
  return ma_decoder_read_pcm_frames(&pData->decoder, pOutput, frameCount, pFramesRead);
}

int audio_decoder_get_cursor(audio_decoder* pDecoder, uint64* pCursor) {
  audio_decoder_data* pData = get_data_ptr(pDecoder);
  return ma_decoder_get_cursor_in_pcm_frames(&pData->decoder, pCursor);
}

int audio_decoder_set_cursor(audio_decoder* pDecoder, uint64 cursor) {
  audio_decoder_data* pData = get_data_ptr(pDecoder);
  return ma_decoder_seek_to_pcm_frame(&pData->decoder, cursor);
}

int audio_decoder_get_length(audio_decoder* pDecoder, uint64* pLength) {
  audio_decoder_data* pData = get_data_ptr(pDecoder);
  return ma_decoder_get_length_in_pcm_frames(&pData->decoder, pLength);
}

int audio_decoder_uninit(audio_decoder* pDecoder) {
  audio_decoder_data* pData = get_data_ptr(pDecoder);
  ma_result result = ma_decoder_uninit(&pData->decoder);
  MA_FREE(pData);
  return result;
}
