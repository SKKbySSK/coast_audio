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
} mab_hpf_config;

mab_hpf_config mab_hpf_config_init(mab_format format, u_int32_t sampleRate, u_int32_t channels, u_int32_t order, double cutoffFrequency);

typedef struct {
  void* pData;
} mab_hpf;

mab_result mab_hpf_init(mab_hpf* pHPF, mab_hpf_config config);

mab_result mab_hpf_process(mab_hpf* pHPF, void* pFramesOut, const void* pFramesIn, u_int64_t frameCount);

mab_result mab_hpf_reinit(mab_hpf* pHPF, mab_hpf_config config);

u_int32_t mab_hpf_get_latency(mab_hpf* pHPF);

void mab_hpf_uninit(mab_hpf* pHPF);
