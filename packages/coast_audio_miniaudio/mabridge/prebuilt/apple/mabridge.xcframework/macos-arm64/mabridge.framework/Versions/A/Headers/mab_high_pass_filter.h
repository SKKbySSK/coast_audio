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
} mab_high_pass_filter_config;

mab_high_pass_filter_config mab_high_pass_filter_config_init(mab_format format, u_int32_t sampleRate, u_int32_t channels, u_int32_t order, double cutoffFrequency);

typedef struct {
  void* pData;
} mab_high_pass_filter;

mab_result mab_high_pass_filter_init(mab_high_pass_filter* pHPF, mab_high_pass_filter_config config);

mab_result mab_high_pass_filter_process(mab_high_pass_filter* pHPF, void* pFramesOut, const void* pFramesIn, u_int64_t frameCount);

mab_result mab_high_pass_filter_reinit(mab_high_pass_filter* pHPF, mab_high_pass_filter_config config);

u_int32_t mab_high_pass_filter_get_latency(mab_high_pass_filter* pHPF);

void mab_high_pass_filter_uninit(mab_high_pass_filter* pHPF);
