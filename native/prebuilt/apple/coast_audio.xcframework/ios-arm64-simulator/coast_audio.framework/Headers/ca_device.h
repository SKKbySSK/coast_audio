#include <stdint.h>
#include "ca_dart.h"
#include "miniaudio.h"

typedef struct ca_device_notification
{
    ma_device_notification_type type;
    ma_device_state state;
} ca_device_notification;

typedef struct
{
    ma_device_type type;
    ma_format format;
    int sampleRate;
    int channels;
    int bufferFrameSize;
    ma_bool8 noFixedSizedCallback;
    int64_t notificationPortId;
    ma_channel_mix_mode channelMixMode;
    ma_performance_profile performanceProfile;
    ma_resampler_config resampling;
} ca_device_config;

ca_device_config ca_device_config_init(ma_device_type type, ma_format format, int sampleRate, int channels, int bufferFrameSize, int64_t notificationPortId);

typedef struct ca_device
{
    ca_device_config config;
    ca_device_notification *pNotification;
    ma_device device;
    ma_pcm_rb buffer;
} ca_device;

ma_result ca_device_init(ca_device *pDevice, ca_device_config config, ma_context *pContext, ma_device_id *pDeviceId);

ma_result ca_device_capture_read(ca_device *pDevice, float *pBuffer, int frameCount, int *pFramesRead);

ma_result ca_device_playback_write(ca_device *pDevice, const float *pBuffer, int frameCount, int *pFramesWrite);

ma_result ca_device_get_device_info(ca_device *pDevice, ma_device_info *pDeviceInfo);

ma_result ca_device_set_volume(ca_device *pDevice, float volume);

ma_result ca_device_get_volume(ca_device *pDevice, float *pVolume);

ma_result ca_device_start(ca_device *pDevice);

ma_result ca_device_stop(ca_device *pDevice);

ma_device_state ca_device_get_state(ca_device *pDevice);

void ca_device_clear_buffer(ca_device *pDevice);

int ca_device_available_read(ca_device *pDevice);

int ca_device_available_write(ca_device *pDevice);

void ca_device_uninit(ca_device *pDevice);
