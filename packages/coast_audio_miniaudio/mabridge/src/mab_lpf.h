#pragma once
#include "mab_enum.h"
#include "mab_types.h"
#include "mab_device_context.h"

typedef struct {
  mab_format format;
  int sampleRate;
  int channels;
  int order;
  float cutoffFrequency;
} mab_lpf_config;

mab_lpf_config mab_lpf_config_init(mab_format format, u_int32_t sampleRate, u_int32_t channels, u_int32_t order, double cutoffFrequency);

typedef struct {
  void* pData;
} mab_lpf;

mab_result mab_lpf_init(mab_lpf* pLPF, mab_lpf_config config);

mab_result mab_lpf_process(mab_lpf* pLPF, void* pFramesOut, const void* pFramesIn, u_int64_t frameCount);

mab_result mab_lpf_reinit(mab_lpf* pLPF, mab_lpf_config config);

u_int32_t mab_lpf_get_latency(mab_lpf* pLPF);

void mab_lpf_uninit(mab_lpf* pLPF);
