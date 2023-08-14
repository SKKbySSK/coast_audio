#pragma once
#include "mab_enum.h"
#include "mab_types.h"

typedef struct {
  mab_encoding_format encodingFormat;
  mab_format format;
  int sampleRate;
  int channels;
} mab_audio_encoder_config;

mab_audio_encoder_config mab_audio_encoder_config_init(mab_encoding_format encodingFormat, mab_format format, int sampleRate, int channels);

typedef struct {
  void* pData;
  void* pUserData;
} mab_audio_encoder;

typedef mab_result(*mab_audio_encoder_write_proc)(mab_audio_encoder* pEncoder, const void* pBufferIn, size_t bytesToWrite, size_t* pBytesWritten);
typedef mab_result(*mab_audio_encoder_seek_proc)(mab_audio_encoder* pEncoder, int64_t byteOffset, mab_seek_origin origin);

mab_result mab_audio_encoder_init(mab_audio_encoder* pEncoder, mab_audio_encoder_config config, mab_audio_encoder_write_proc onWrite, mab_audio_encoder_seek_proc onSeek, void* pUserData);

mab_result mab_audio_encoder_init_file(mab_audio_encoder* pEncoder, const char* pFilePath, mab_audio_encoder_config config);

mab_result mab_audio_encoder_encode(mab_audio_encoder* pEncoder, const void* pFramesIn, uint64 frameCount, uint64* pFramesWritten);

void mab_audio_encoder_uninit(mab_audio_encoder* pEncoder);
