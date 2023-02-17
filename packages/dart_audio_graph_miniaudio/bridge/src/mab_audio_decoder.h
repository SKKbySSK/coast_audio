#include "mab_enum.h"
#include "mab_types.h"

typedef struct {
  int sampleRate;
  int channels;
  mab_dither_mode ditherMode;
  mab_channel_mix_mode channelMixMode;
} mab_audio_decoder_config;

mab_audio_decoder_config mab_audio_decoder_config_init(int sampleRate, int channels);

typedef struct {
  int sampleRate;
  int channels;
  void* pData;
} mab_audio_decoder;

typedef struct {
  int sampleRate;
  int channels;
  uint64 length;
} mab_audio_decoder_format;

int mab_audio_decoder_get_format(const char* pFilePath, mab_audio_decoder_format* pFormat);

int mab_audio_decoder_init_file(mab_audio_decoder* pDecoder, const char* pFilePath, mab_audio_decoder_config config);

int mab_audio_decoder_decode(mab_audio_decoder* pDecoder, float* pOutput, uint64 frameCount, uint64* pFramesRead);

int mab_audio_decoder_get_cursor(mab_audio_decoder* pDecoder, uint64* pCursor);

int mab_audio_decoder_set_cursor(mab_audio_decoder* pDecoder, uint64 cursor);

int mab_audio_decoder_get_length(mab_audio_decoder* pDecoder, uint64* pLength);

int mab_audio_decoder_uninit(mab_audio_decoder* pDecoder);
