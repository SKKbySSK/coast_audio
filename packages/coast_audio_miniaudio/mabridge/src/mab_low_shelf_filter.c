#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"

#include "mab_types.h"
#include "mab_low_shelf_filter.h"

mab_low_shelf_filter_config mab_low_shelf_filter_config_init(mab_format format, u_int32_t sampleRate, u_int32_t channels, double gainDb, double shelfSlope, double frequency)
{
  mab_low_shelf_filter_config config = {
      .format = format,
      .sampleRate = sampleRate,
      .channels = channels,
      .gainDb = gainDb,
      .shelfSlope = shelfSlope,
      .frequency = frequency,
  };
  return config;
}

mab_result mab_low_shelf_filter_init(mab_low_shelf_filter* pLSF, mab_low_shelf_filter_config config)
{
  ma_loshelf2_config maConfig = ma_loshelf2_config_init(mab_cast(ma_format, config.format), config.channels, config.sampleRate, config.gainDb, config.shelfSlope, config.frequency);
  ma_loshelf2* pData = MAB_MALLOC(sizeof(ma_loshelf2));
  ma_result result = ma_loshelf2_init(&maConfig, NULL, pData);
  if (result != MA_SUCCESS) {
    MAB_FREE(pData);
    return result;
  }

  pLSF->pData = pData;
  return MA_SUCCESS;
}

mab_result mab_low_shelf_filter_process(mab_low_shelf_filter* pLSF, void* pFramesOut, const void* pFramesIn, u_int64_t frameCount)
{
  ma_loshelf2 *pData = (ma_loshelf2*)pLSF->pData;
  return ma_loshelf2_process_pcm_frames(pData, pFramesOut, pFramesIn, frameCount);
}

mab_result mab_low_shelf_filter_reinit(mab_low_shelf_filter* pLSF, mab_low_shelf_filter_config config)
{
  ma_loshelf2 *pData = (ma_loshelf2*)pLSF->pData;
  ma_loshelf2_config maConfig = ma_loshelf2_config_init(mab_cast(ma_format, config.format), config.channels, config.sampleRate, config.gainDb, config.shelfSlope, config.frequency);
  return ma_loshelf2_reinit(&maConfig, pData);
}

u_int32_t mab_low_shelf_filter_get_latency(mab_low_shelf_filter* pLSF)
{
  ma_loshelf2 *pData = (ma_loshelf2*)pLSF->pData;
  return ma_loshelf2_get_latency(pData);
}

void mab_low_shelf_filter_uninit(mab_low_shelf_filter* pLSF)
{
  ma_loshelf2 *pData = (ma_loshelf2*)pLSF->pData;
  ma_loshelf2_uninit(pData, NULL);
  MAB_FREE(pData);
  pLSF->pData = NULL;
}
