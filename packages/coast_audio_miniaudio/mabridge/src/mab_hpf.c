#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"

#include "mab_types.h"
#include "mab_hpf.h"

mab_hpf_config mab_hpf_config_init(mab_format format, u_int32_t sampleRate, u_int32_t channels, u_int32_t order, double cutoffFrequency)
{
  mab_hpf_config config = {
      .format = format,
      .sampleRate = sampleRate,
      .channels = channels,
      .order = order,
      .cutoffFrequency = cutoffFrequency,
  };
  return config;
}

mab_result mab_hpf_init(mab_hpf* pHPF, mab_hpf_config config)
{
  ma_hpf_config maConfig = ma_hpf_config_init(mab_cast(ma_format, config.format), config.channels, config.sampleRate, config.cutoffFrequency, config.order);
  ma_hpf* pData = MAB_MALLOC(sizeof(ma_hpf));

  ma_result result = ma_hpf_init(&maConfig, NULL, pData);
  if (result != MA_SUCCESS) {
    MAB_FREE(pData);
    return mab_cast(mab_result, result);
  }

  pHPF->pData = (void*)pData;
  return mab_cast(mab_result, result);
}

mab_result mab_hpf_process(mab_hpf* pHPF, void* pFramesOut, const void* pFramesIn, u_int64_t frameCount)
{
  ma_result result = ma_hpf_process_pcm_frames((ma_hpf*)pHPF->pData, pFramesOut, pFramesIn, frameCount);
  return mab_cast(mab_result, result);
}

mab_result mab_hpf_reinit(mab_hpf* pHPF, mab_hpf_config config)
{
  ma_hpf_config maConfig = ma_hpf_config_init(mab_cast(ma_format, config.format), config.channels, config.sampleRate, config.cutoffFrequency, config.order);
  ma_result result = ma_hpf_reinit(&maConfig, (ma_hpf*)pHPF->pData);
  return mab_cast(mab_result, result);
}

u_int32_t mab_hpf_get_latency(mab_hpf* pHPF)
{
  return (u_int32_t)ma_hpf_get_latency((ma_hpf*)pHPF->pData);
}

void mab_hpf_uninit(mab_hpf* hpf)
{
  ma_hpf* pMahpf = (ma_hpf*)hpf->pData;
  ma_hpf_uninit(pMahpf, NULL);
  MAB_FREE(pMahpf);
  hpf->pData = NULL;
}
