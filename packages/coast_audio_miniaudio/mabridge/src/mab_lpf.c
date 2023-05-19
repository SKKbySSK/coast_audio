#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"

#include "mab_types.h"
#include "mab_lpf.h"

mab_lpf_config mab_lpf_config_init(mab_format format, u_int32_t sampleRate, u_int32_t channels, u_int32_t order, double cutoffFrequency)
{
  mab_lpf_config config = {
      .format = format,
      .sampleRate = sampleRate,
      .channels = channels,
      .order = order,
      .cutoffFrequency = cutoffFrequency,
  };
  return config;
}

mab_result mab_lpf_init(mab_lpf* pLPF, mab_lpf_config config)
{
  ma_lpf_config maConfig = ma_lpf_config_init(mab_cast(ma_format, config.format), config.channels, config.sampleRate, config.cutoffFrequency, config.order);
  ma_lpf* pData = MAB_MALLOC(sizeof(ma_lpf));

  ma_result result = ma_lpf_init(&maConfig, NULL, pData);
  if (result != MA_SUCCESS) {
    MAB_FREE(pData);
    return mab_cast(mab_result, result);
  }

  pLPF->pData = (void*)pData;
  return mab_cast(mab_result, result);
}

mab_result mab_lpf_process(mab_lpf* pLPF, void* pFramesOut, const void* pFramesIn, u_int64_t frameCount)
{
  ma_result result = ma_lpf_process_pcm_frames((ma_lpf*)pLPF->pData, pFramesOut, pFramesIn, frameCount);
  return mab_cast(mab_result, result);
}

mab_result mab_lpf_reinit(mab_lpf* pLPF, mab_lpf_config config)
{
  ma_lpf_config maConfig = ma_lpf_config_init(mab_cast(ma_format, config.format), config.channels, config.sampleRate, config.cutoffFrequency, config.order);
  ma_result result = ma_lpf_reinit(&maConfig, (ma_lpf*)pLPF->pData);
  return mab_cast(mab_result, result);
}

u_int32_t mab_lpf_get_latency(mab_lpf* pLPF)
{
  return (u_int32_t)ma_lpf_get_latency((ma_lpf*)pLPF->pData);
}

void mab_lpf_uninit(mab_lpf* lpf)
{
  ma_lpf* pMaLPF = (ma_lpf*)lpf->pData;
  ma_lpf_uninit(pMaLPF, NULL);
  MAB_FREE(pMaLPF);
  lpf->pData = NULL;
}
