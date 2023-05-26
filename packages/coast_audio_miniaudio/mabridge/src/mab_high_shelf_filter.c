#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"

#include "mab_types.h"
#include "mab_high_shelf_filter.h"

mab_high_shelf_filter_config mab_high_shelf_filter_config_init(mab_format format, u_int32_t sampleRate, u_int32_t channels, double gainDb, double shelfSlope, double frequency)
{
  mab_high_shelf_filter_config config = {
      .format = format,
      .sampleRate = sampleRate,
      .channels = channels,
      .gainDb = gainDb,
      .shelfSlope = shelfSlope,
      .frequency = frequency,
  };
  return config;
}

mab_result mab_high_shelf_filter_init(mab_high_shelf_filter* pHSF, mab_high_shelf_filter_config config)
{
  ma_hishelf2_config maConfig = ma_hishelf2_config_init(mab_cast(ma_format, config.format), config.channels, config.sampleRate, config.gainDb, config.shelfSlope, config.frequency);
  ma_hishelf2* pData = MAB_MALLOC(sizeof(ma_hishelf2));
  ma_result result = ma_hishelf2_init(&maConfig, NULL, pData);
  if (result != MA_SUCCESS) {
    MAB_FREE(pData);
    return result;
  }

  pHSF->pData = pData;
  return MA_SUCCESS;
}

mab_result mab_high_shelf_filter_process(mab_high_shelf_filter* pHSF, void* pFramesOut, const void* pFramesIn, u_int64_t frameCount)
{
  ma_hishelf2 *pData = (ma_hishelf2*)pHSF->pData;
  return ma_hishelf2_process_pcm_frames(pData, pFramesOut, pFramesIn, frameCount);
}

mab_result mab_high_shelf_filter_reinit(mab_high_shelf_filter* pHSF, mab_high_shelf_filter_config config)
{
  ma_hishelf2 *pData = (ma_hishelf2*)pHSF->pData;
  ma_hishelf2_config maConfig = ma_hishelf2_config_init(mab_cast(ma_format, config.format), config.channels, config.sampleRate, config.gainDb, config.shelfSlope, config.frequency);
  return ma_hishelf2_reinit(&maConfig, pData);
}

u_int32_t mab_high_shelf_filter_get_latency(mab_high_shelf_filter* pHSF)
{
  ma_hishelf2 *pData = (ma_hishelf2*)pHSF->pData;
  return ma_hishelf2_get_latency(pData);
}

void mab_high_shelf_filter_uninit(mab_high_shelf_filter* pHSF)
{
  ma_hishelf2 *pData = (ma_hishelf2*)pHSF->pData;
  ma_hishelf2_uninit(pData, NULL);
  MAB_FREE(pData);
  pHSF->pData = NULL;
}
