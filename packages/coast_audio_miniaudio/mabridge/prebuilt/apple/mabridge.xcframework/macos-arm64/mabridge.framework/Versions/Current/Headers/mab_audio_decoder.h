#pragma once
#include "mab_enum.h"
#include "mab_types.h"

typedef struct {
  mab_format format;
  int sampleRate;
  int channels;
  mab_dither_mode ditherMode;
  mab_channel_mix_mode channelMixMode;
  mab_encoding_format encodingFormat;
} mab_audio_decoder_config;

mab_audio_decoder_config mab_audio_decoder_config_init(mab_format format, int sampleRate, int channels);

typedef struct {
  int sampleRate;
  int channels;
  void* pData;
  void* pUserData;
} mab_audio_decoder;

typedef struct {
  mab_format format;
  int sampleRate;
  int channels;
  uint64 length;
} mab_audio_decoder_info;

typedef mab_result(*mab_audio_decoder_read_proc)(mab_audio_decoder* pDecoder, void* pBufferOut, size_t bytesToRead, size_t* pBytesRead);
typedef mab_result(*mab_audio_decoder_seek_proc)(mab_audio_decoder* pDecoder, int64_t byteOffset, mab_seek_origin origin);

mab_result mab_audio_decoder_get_info(const char* pFilePath, mab_audio_decoder_info* pInfo);

mab_result mab_audio_decoder_init(mab_audio_decoder* pDecoder, mab_audio_decoder_config config, mab_audio_decoder_read_proc onRead, mab_audio_decoder_seek_proc onSeek, void* pUserData);

mab_result mab_audio_decoder_init_file(mab_audio_decoder* pDecoder, const char* pFilePath, mab_audio_decoder_config config);

mab_result mab_audio_decoder_decode(mab_audio_decoder* pDecoder, void* pFramesOut, uint64 frameCount, uint64* pFramesRead);

mab_result mab_audio_decoder_get_cursor(mab_audio_decoder* pDecoder, uint64* pCursor);

mab_result mab_audio_decoder_set_cursor(mab_audio_decoder* pDecoder, uint64 cursor);

mab_result mab_audio_decoder_get_length(mab_audio_decoder* pDecoder, uint64* pLength);

mab_result mab_audio_decoder_uninit(mab_audio_decoder* pDecoder);
