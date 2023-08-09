#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"

#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "mab_audio_converter.h"

mab_audio_converter_config mab_audio_converter_config_init(mab_format formatIn, mab_format formatOut, int sampleRateIn, int sampleRateOut, int channelsIn, int channelsOut)
{
  ma_data_converter_config defaultConfig = ma_data_converter_config_init_default();
  mab_audio_converter_config config = {
    .input = {
      .format = formatIn,
      .sampleRate = sampleRateIn,
      .channels = channelsIn,
    },
    .output = {
      .format = formatOut,
      .sampleRate = sampleRateOut,
      .channels = channelsOut,
    },
    .ditherMode = mab_cast(mab_dither_mode, defaultConfig.ditherMode),
    .channelMixMode = mab_cast(mab_channel_mix_mode, defaultConfig.channelMixMode),
  };
  return config;
}

mab_result mab_audio_converter_init(mab_audio_converter* pConverter, mab_audio_converter_config config)
{
  ma_data_converter* pMaConverter = MAB_MALLOC(sizeof(ma_data_converter));

  ma_data_converter_config maConfig = ma_data_converter_config_init(mab_cast(ma_format, config.input.format), mab_cast(ma_format, config.output.format), config.input.channels, config.output.channels, config.input.sampleRate, config.output.sampleRate);
  ma_result result = ma_data_converter_init(&maConfig, NULL, pMaConverter);
  if (result != MA_SUCCESS) {
    MAB_FREE(pMaConverter);
    return result;
  }

  pConverter->pData = pMaConverter;
  return MA_SUCCESS;
}

mab_result mab_audio_converter_process_pcm_frames(mab_audio_converter* pConverter, const void* pFramesIn, uint64* pFrameCountIn, void* pFramesOut, uint64* pFrameCountOut)
{
  ma_data_converter* pMaConverter = (ma_data_converter*)pConverter->pData;
  return ma_data_converter_process_pcm_frames(pMaConverter, pFramesIn, pFrameCountIn, pFramesOut, pFrameCountOut);
}

uint64 mab_audio_converter_get_input_latency(mab_audio_converter* pConverter)
{
  ma_data_converter* pMaConverter = (ma_data_converter*)pConverter->pData;
  return ma_data_converter_get_input_latency(pMaConverter);
}

uint64 mab_audio_converter_get_output_latency(mab_audio_converter* pConverter)
{
  ma_data_converter* pMaConverter = (ma_data_converter*)pConverter->pData;
  return ma_data_converter_get_output_latency(pMaConverter);
}

mab_result mab_audio_converter_get_required_input_frame_count(const mab_audio_converter* pConverter, uint64 outputFrameCount, uint64* pInputFrameCount)
{
  ma_data_converter* pMaConverter = (ma_data_converter*)pConverter->pData;
  return ma_data_converter_get_required_input_frame_count(pMaConverter, outputFrameCount, pInputFrameCount);
}

mab_result mab_audio_converter_get_expected_output_frame_count(const mab_audio_converter* pConverter, uint64 inputFrameCount, uint64* pOutputFrameCount)
{
  ma_data_converter* pMaConverter = (ma_data_converter*)pConverter->pData;
  return ma_data_converter_get_expected_output_frame_count(pMaConverter, inputFrameCount, pOutputFrameCount);
}

mab_result mab_audio_converter_reset(mab_audio_converter* pConverter)
{
  ma_data_converter* pMaConverter = (ma_data_converter*)pConverter->pData;
  return ma_data_converter_reset(pMaConverter);
}

void mab_audio_converter_uninit(mab_audio_converter* pConverter)
{
  ma_data_converter* pMaConverter = (ma_data_converter*)pConverter->pData;
  ma_data_converter_uninit(pMaConverter, NULL);
  MAB_FREE(pMaConverter);
  pConverter->pData = NULL;
}
