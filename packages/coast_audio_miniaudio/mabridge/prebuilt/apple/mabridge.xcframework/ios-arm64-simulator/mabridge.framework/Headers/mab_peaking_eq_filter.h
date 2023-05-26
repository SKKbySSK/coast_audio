#pragma once
#include "mab_enum.h"
#include "mab_types.h"
#include "mab_device_context.h"

typedef struct {
  mab_format format;
  int sampleRate;
  int channels;
  double gainDb;
  double q;
  double frequency;
} mab_peaking_eq_filter_config;

mab_peaking_eq_filter_config mab_peaking_eq_filter_config_init(mab_format format, u_int32_t sampleRate, u_int32_t channels, double gainDb, double q, double frequency);

typedef struct {
  void* pData;
} mab_peaking_eq_filter;

mab_result mab_peaking_eq_filter_init(mab_peaking_eq_filter* pEQ, mab_peaking_eq_filter_config config);

mab_result mab_peaking_eq_filter_process(mab_peaking_eq_filter* pEQ, void* pFramesOut, const void* pFramesIn, u_int64_t frameCount);

mab_result mab_peaking_eq_filter_reinit(mab_peaking_eq_filter* pEQ, mab_peaking_eq_filter_config config);

u_int32_t mab_peaking_eq_filter_get_latency(mab_peaking_eq_filter* pEQ);

void mab_peaking_eq_filter_uninit(mab_peaking_eq_filter* pEQ);
