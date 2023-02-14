
typedef struct {
  int sampleRate;
  int channels;
  int bufferFrameSize;
} device_output_config;

device_output_config device_output_config_init(int sampleRate, int channels, int bufferFrameSize);

typedef struct {
  int sampleRate;
  int channels;
  void* pData;
} device_output;

int device_output_init(device_output* pDevice, device_output_config config);

int device_output_write(device_output* pDevice, float* pBuffer, int frameCount);

int device_output_start(device_output* pDevice);

int device_output_stop(device_output* pDevice);

int device_output_available_write(device_output* pDevice);

int device_output_uninit(device_output* pDevice);
