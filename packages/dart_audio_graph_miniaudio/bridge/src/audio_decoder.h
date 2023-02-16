typedef unsigned long long uint64;

typedef struct {
  int sampleRate;
  int channels;
} audio_decoder_config;

audio_decoder_config audio_decoder_config_init(int sampleRate, int channels);

typedef struct {
  int sampleRate;
  int channels;
  void* pData;
} audio_decoder;

int audio_decoder_init_file(audio_decoder* pDecoder, char* pFilePath, audio_decoder_config config);

int audio_decoder_decode(audio_decoder* pDecoder, float* pOutput, uint64 frameCount, uint64* pFramesRead);

int audio_decoder_get_cursor(audio_decoder* pDecoder, uint64* pCursor);

int audio_decoder_set_cursor(audio_decoder* pDecoder, uint64 cursor);

int audio_decoder_get_length(audio_decoder* pDecoder, uint64* pLength);

int audio_decoder_uninit(audio_decoder* pDecoder);
