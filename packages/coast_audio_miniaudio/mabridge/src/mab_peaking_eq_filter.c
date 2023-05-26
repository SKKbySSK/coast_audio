#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"

#include "mab_types.h"
#include "mab_peaking_eq_filter.h"

mab_peaking_eq_filter_config mab_peaking_eq_filter_config_init(mab_format format, u_int32_t sampleRate, u_int32_t channels, double gainDb, double q, double frequency)
{
  mab_peaking_eq_filter_config config = {
      .format = format,
      .sampleRate = sampleRate,
      .channels = channels,
      .gainDb = gainDb,
      .q = q,
      .frequency = frequency,
  };
  return config;
}

mab_result mab_peaking_eq_filter_init(mab_peaking_eq_filter* pEQ, mab_peaking_eq_filter_config config)
{
  ma_peak2_config maConfig = ma_peak2_config_init(mab_cast(ma_format, config.format), config.channels, config.sampleRate, config.gainDb, config.q, config.frequency);
  ma_peak2* pData = MAB_MALLOC(sizeof(ma_peak2));
  ma_result result = ma_peak2_init(&maConfig, NULL, pData);
  if (result != MA_SUCCESS) {
    MAB_FREE(pData);
    return result;
  }

  pEQ->pData = pData;
  return MA_SUCCESS;
}

mab_result mab_peaking_eq_filter_process(mab_peaking_eq_filter* pEQ, void* pFramesOut, const void* pFramesIn, u_int64_t frameCount)
{
  ma_peak2 *pData = (ma_peak2*)pEQ->pData;
  return ma_peak2_process_pcm_frames(pData, pFramesOut, pFramesIn, frameCount);
}

mab_result mab_peaking_eq_filter_reinit(mab_peaking_eq_filter* pEQ, mab_peaking_eq_filter_config config)
{
  ma_peak2 *pData = (ma_peak2*)pEQ->pData;
  ma_peak2_config maConfig = ma_peak2_config_init(mab_cast(ma_format, config.format), config.channels, config.sampleRate, config.gainDb, config.q, config.frequency);
  return ma_peak2_reinit(&maConfig, pData);
}

u_int32_t mab_peaking_eq_filter_get_latency(mab_peaking_eq_filter* pEQ)
{
  ma_peak2 *pData = (ma_peak2*)pEQ->pData;
  return ma_peak2_get_latency(pData);
}

void mab_peaking_eq_filter_uninit(mab_peaking_eq_filter* pEQ)
{
  ma_peak2 *pData = (ma_peak2*)pEQ->pData;
  ma_peak2_uninit(pData, NULL);
  MAB_FREE(pData);
  pEQ->pData = NULL;
}
