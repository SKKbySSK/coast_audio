#pragma once
#include "mab_enum.h"
#include "mab_types.h"

typedef struct {
  struct {
    mab_format format;
    int sampleRate;
    int channels;
  } input;
  struct {
    mab_format format;
    int sampleRate;
    int channels;
  } output;
  mab_dither_mode ditherMode;
  mab_channel_mix_mode channelMixMode;
} mab_audio_converter_config;

mab_audio_converter_config mab_audio_converter_config_init(mab_format formatIn, mab_format formatOut, int sampleRateIn, int sampleRateOut, int channelsIn, int channelsOut);

typedef struct {
  mab_audio_converter_config config;
  void* pData;
} mab_audio_converter;

mab_result mab_audio_converter_init(mab_audio_converter* pConverter, mab_audio_converter_config config);

mab_result mab_audio_converter_process_pcm_frames(mab_audio_converter* pConverter, const void* pFramesIn, uint64* pFrameCountIn, void* pFramesOut, uint64* pFrameCountOut);

uint64 mab_audio_converter_get_input_latency(mab_audio_converter* pConverter);

uint64 mab_audio_converter_get_output_latency(mab_audio_converter* pConverter);

mab_result mab_audio_converter_get_required_input_frame_count(const mab_audio_converter* pConverter, uint64 outputFrameCount, uint64* pInputFrameCount);

mab_result mab_audio_converter_get_expected_output_frame_count(const mab_audio_converter* pConverter, uint64 inputFrameCount, uint64* pOutputFrameCount);

mab_result mab_audio_converter_reset(mab_audio_converter* pConverter);

void mab_audio_converter_uninit(mab_audio_converter* pConverter);
