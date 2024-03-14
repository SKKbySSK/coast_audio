#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <dlfcn.h>
#include "dart_types.h"
#include "ca_device.h"
#include "ca_defs.h"

typedef void (*Dart_PostCObject_Def)(Dart_Port_DL port_id, Dart_CObject *message);

static Dart_PostCObject_Def Dart_PostCObject = NULL;

void ca_device_dart_configure(void *pDartPostCObject)
{
    Dart_PostCObject = (Dart_PostCObject_Def)pDartPostCObject;
}

typedef struct
{
    ma_context context;
} ca_device_context_data;

typedef struct
{
    ma_format format;
    ma_device device;
    ma_pcm_rb buffer;
} ca_device_data;

static inline ca_device_data *get_device_data(ca_device *pDevice)
{
    return (ca_device_data *)pDevice->pData;
}

static inline ca_device_context_data *get_device_context_data(ca_device_context *pDevice)
{
    return (ca_device_context_data *)pDevice->pData;
}

static inline ma_result read_ring_buffer(ca_device *pDevice, void *pOutput, ma_uint32 frameCount, ma_uint32 *pFramesRead)
{
    ca_device_data *pData = get_device_data(pDevice);
    if (pFramesRead != NULL)
    {
        *pFramesRead = 0;
    }

    ma_result result = MA_SUCCESS;
    ma_uint32 bpf = ma_get_bytes_per_frame(pData->format, pDevice->channels);
    ma_uint32 readableFrames = frameCount;
    ma_uint32 framesRead = 0;
    void *pBuffer;

    while (readableFrames > 0)
    {
        ma_uint32 actualRead = readableFrames;
        result = ma_pcm_rb_acquire_read(&pData->buffer, &actualRead, &pBuffer);
        if (result != MA_SUCCESS && result != MA_AT_END)
        {
            return result;
        }

        CA_COPY_MEMORY(pOutput + (bpf * framesRead), pBuffer, bpf * actualRead);

        result = ma_pcm_rb_commit_read(&pData->buffer, actualRead);
        if (result != MA_SUCCESS && result != MA_AT_END)
        {
            return result;
        }

        readableFrames -= actualRead;
        framesRead += actualRead;

        if (actualRead <= 0)
        {
            break;
        }
    }

    if (pFramesRead != NULL)
    {
        *pFramesRead = framesRead;
    }

    return result;
}

static inline ma_result write_ring_buffer(ca_device *pDevice, const void *pInput, ma_uint32 frameCount, ma_uint32 *pFramesWrite)
{
    ca_device_data *pData = get_device_data(pDevice);
    if (pFramesWrite != NULL)
    {
        *pFramesWrite = 0;
    }

    ma_result result = MA_SUCCESS;
    ma_uint32 bpf = ma_get_bytes_per_frame(pData->format, pDevice->channels);
    ma_uint32 writableFrames = frameCount;
    ma_uint32 framesWrite = 0;
    void *pBuffer;

    while (framesWrite < frameCount)
    {
        ma_uint32 actualWrite = writableFrames;
        result = ma_pcm_rb_acquire_write(&pData->buffer, &actualWrite, &pBuffer);
        if (result != MA_SUCCESS && result != MA_AT_END)
        {
            return result;
        }

        CA_COPY_MEMORY(pBuffer, pInput + (bpf * framesWrite), bpf * actualWrite);

        result = ma_pcm_rb_commit_write(&pData->buffer, actualWrite);
        if (result != MA_SUCCESS && result != MA_AT_END)
        {
            return result;
        }

        writableFrames -= actualWrite;
        framesWrite += actualWrite;

        if (actualWrite <= 0)
        {
            break;
        }
    }

    if (pFramesWrite != NULL)
    {
        *pFramesWrite = framesWrite;
    }

    return result;
}

// notification_callback can be called from another thread.
// So, we have to use a SendPort to communicate with the Dart side.
// https://github.com/flutter/flutter/issues/63255#issuecomment-671216406
static inline void notification_callback(const ma_device_notification *pNotification)
{
    ca_device *pMabDevice = (ca_device *)pNotification->pDevice->pUserData;
    ca_device_data *pData = get_device_data(pMabDevice);
    Dart_CObject cObject = {
        .type = Dart_CObject_kInt32,
        .value.as_int32 = pNotification->type,
    };
    Dart_PostCObject(pMabDevice->config.notificationPortId, &cObject);
}

static inline void playback_callback(ma_device *pDevice, void *pOutput, const void *pInput, ma_uint32 frameCount)
{
    ca_device *pDeviceOutput = (ca_device *)pDevice->pUserData;
    ma_result result = read_ring_buffer(pDeviceOutput, pOutput, frameCount, NULL);
    assert(result == MA_SUCCESS || result == MA_AT_END);
}

static inline void capture_callback(ma_device *pDevice, void *pOutput, const void *pInput, ma_uint32 frameCount)
{
    ca_device *pDeviceInput = (ca_device *)pDevice->pUserData;
    ma_result result = write_ring_buffer(pDeviceInput, pInput, frameCount, NULL);
    assert(result == MA_SUCCESS || result == MA_AT_END);
}

ca_device_config ca_device_config_init(ma_device_type type, ma_format format, int sampleRate, int channels, int bufferFrameSize, int64_t notificationPortId)
{
    ca_device_config config = {
        .type = type,
        .format = format,
        .sampleRate = sampleRate,
        .channels = channels,
        .bufferFrameSize = bufferFrameSize,
        .noFixedSizedCallback = MA_TRUE,
        .notificationPortId = notificationPortId,
        .channelMixMode = ma_channel_mix_mode_rectangular,
        .performanceProfile = ma_performance_profile_low_latency,
    };
    return config;
}

ma_result ca_device_init(ca_device *pDevice, ca_device_config config, ca_device_context *pContext, ca_device_id *pDeviceId)
{
    ca_device_data *pData = (ca_device_data *)ca_malloc(sizeof(ca_device_data));
    pData->format = *(ma_format *)&config.format;
    pDevice->pData = pData;
    pDevice->config = config;

    ma_result result;

    // init: ma_device
    {
        ma_device_config deviceConfig = ma_device_config_init(*(ma_device_type *)&config.type);
        deviceConfig.playback.pDeviceID = (ma_device_id *)pDeviceId;
        deviceConfig.playback.format = pData->format;
        deviceConfig.playback.channels = config.channels;
        deviceConfig.playback.channelMixMode = *(ma_channel_mix_mode *)&config.channelMixMode;
        deviceConfig.capture.pDeviceID = (ma_device_id *)pDeviceId;
        deviceConfig.capture.format = pData->format;
        deviceConfig.capture.channels = config.channels;
        deviceConfig.capture.channelMixMode = *(ma_channel_mix_mode *)&config.channelMixMode;
        deviceConfig.sampleRate = config.sampleRate;
        deviceConfig.noFixedSizedCallback = config.noFixedSizedCallback;
        deviceConfig.pUserData = pDevice;
        deviceConfig.notificationCallback = notification_callback;
        deviceConfig.performanceProfile = *(ma_performance_profile *)&config.performanceProfile;

        switch (config.type)
        {
        case ma_device_type_playback:
            deviceConfig.dataCallback = playback_callback;
            break;
        case ma_device_type_capture:
            deviceConfig.dataCallback = capture_callback;
            break;
        default:
            CA_FREE(pData);
            return MA_INVALID_ARGS;
        }

        result = ma_device_init((ma_context *)pContext->pMaContext, &deviceConfig, &pData->device);
        if (result != MA_SUCCESS)
        {
            CA_FREE(pData);
            return result;
        }
    }

    // init: ma_pcm_rb
    {
        result = ma_pcm_rb_init(pData->format, config.channels, config.bufferFrameSize, NULL, NULL, &pData->buffer);
        if (result != MA_SUCCESS)
        {
            ma_device_uninit(&pData->device);
            CA_FREE(pData);
            return result;
        }
    }

    pDevice->sampleRate = pData->device.sampleRate;
    pDevice->channels = pData->device.playback.channels;

    return result;
}

ma_result ca_device_capture_read(ca_device *pDevice, float *pBuffer, int frameCount, int *pFramesRead)
{
    return read_ring_buffer(pDevice, pBuffer, frameCount, (ma_uint32 *)pFramesRead);
}

ma_result ca_device_playback_write(ca_device *pDevice, const float *pBuffer, int frameCount, int *pFramesWrite)
{
    return write_ring_buffer(pDevice, pBuffer, frameCount, (ma_uint32 *)pFramesWrite);
}

ma_result ca_device_get_device_info(ca_device *pDevice, ca_device_info *pDeviceInfo)
{
    ca_device_data *pData = get_device_data(pDevice);
    ma_device_info info;
    ma_result result;
    switch (pDevice->config.type)
    {
    case ma_device_type_playback:
        result = ma_device_get_info(&pData->device, ma_device_type_playback, &info);
        break;
    case ma_device_type_capture:
        result = ma_device_get_info(&pData->device, ma_device_type_capture, &info);
        break;
    default:
        return MA_INVALID_ARGS;
    }

    if (result != MA_SUCCESS)
    {
        return result;
    }

    ca_device_info_init(pDeviceInfo, *(ca_device_id *)&info.id, info.name, info.isDefault);
    return result;
}

ma_result ca_device_start(ca_device *pDevice)
{
    ca_device_data *pData = get_device_data(pDevice);
    return ma_device_start(&pData->device);
}

ma_result ca_device_stop(ca_device *pDevice)
{
    ca_device_data *pData = get_device_data(pDevice);
    return ma_device_stop(&pData->device);
}

ma_device_state ca_device_get_state(ca_device *pDevice)
{
    ca_device_data *pData = get_device_data(pDevice);
    ma_device_state state = ma_device_get_state(&pData->device);
    return *(ma_device_state *)&state;
}

ma_result ca_device_set_volume(ca_device *pDevice, float volume)
{
    ca_device_data *pData = get_device_data(pDevice);
    return ma_device_set_master_volume(&pData->device, volume);
}

ma_result ca_device_get_volume(ca_device *pDevice, float *pVolume)
{
    ca_device_data *pData = get_device_data(pDevice);
    return ma_device_get_master_volume(&pData->device, pVolume);
}

void ca_device_clear_buffer(ca_device *pDevice)
{
    ca_device_data *pData = get_device_data(pDevice);
    ma_pcm_rb_reset(&pData->buffer);
}

int ca_device_available_read(ca_device *pDevice)
{
    ca_device_data *pData = get_device_data(pDevice);
    return ma_pcm_rb_available_read(&pData->buffer);
}

int ca_device_available_write(ca_device *pDevice)
{
    ca_device_data *pData = get_device_data(pDevice);
    return ma_pcm_rb_available_write(&pData->buffer);
}

void ca_device_uninit(ca_device *pDevice)
{
    ca_device_data *pData = get_device_data(pDevice);

    ma_pcm_rb_uninit(&pData->buffer);
    ma_device_uninit(&pData->device);

    CA_FREE(pData);
}

void ca_device_info_init(ca_device_info *pInfo, ca_device_id id, char *name, ma_bool8 isDefault)
{
    ca_device_info info = {
        .id = id,
        .isDefault = isDefault,
    };
    strncpy(info.name, name, sizeof(info.name));
    *pInfo = info;
}

ma_result ca_device_context_init(ca_device_context *pContext, ma_backend *pBackends, int backendCount)
{
    ca_device_context_data *pData = (ca_device_context_data *)ca_malloc(sizeof(ca_device_context_data));
    pContext->pData = pData;
    pContext->pMaContext = &pData->context;

    ma_result result;
    {
        ma_context_config contextConfig = ma_context_config_init();

        // disable AudioSession management for less complexity
        contextConfig.coreaudio.noAudioSessionActivate = MA_TRUE;
        contextConfig.coreaudio.noAudioSessionDeactivate = MA_TRUE;
        contextConfig.coreaudio.sessionCategory = ma_ios_session_category_none;

        result = ma_context_init((ma_backend *)pBackends, backendCount, &contextConfig, &pData->context);
        if (result != MA_SUCCESS)
        {
            CA_FREE(pData);
            return result;
        }
    }

    pContext->backend = *(ma_backend *)&pData->context.backend;

    return result;
}

ma_result ca_device_context_get_device_count(ca_device_context *pContext, ma_device_type type, int *pCount)
{
    ca_device_context_data *pData = get_device_context_data(pContext);
    ma_uint32 count = 0;
    ma_result result;
    {
        switch (type)
        {
        case ma_device_type_playback:
            result = ma_context_get_devices(&pData->context, NULL, &count, NULL, NULL);
            break;
        case ma_device_type_capture:
            result = ma_context_get_devices(&pData->context, NULL, NULL, NULL, &count);
            break;
        default:
            return MA_INVALID_ARGS;
        }
        *pCount = count;
    }

    return result;
}

ma_result ca_device_context_get_device_info(ca_device_context *pContext, ma_device_type type, int index, ca_device_info *pInfo)
{
    ca_device_context_data *pData = get_device_context_data(pContext);
    ma_device_info *pDeviceInfos;
    ma_result result;
    {
        switch (type)
        {
        case ma_device_type_playback:
            result = ma_context_get_devices(&pData->context, &pDeviceInfos, NULL, NULL, NULL);
            break;
        case ma_device_type_capture:
            result = ma_context_get_devices(&pData->context, NULL, NULL, &pDeviceInfos, NULL);
            break;
        default:
            return MA_INVALID_ARGS;
        }

        ma_device_info *pMaInfo = &pDeviceInfos[index];
        ca_device_info_init(pInfo, *(ca_device_id *)&pMaInfo->id, pMaInfo->name, pMaInfo->isDefault);
    }

    return result;
}

ma_result ca_device_context_uninit(ca_device_context *pContext)
{
    ca_device_context_data *pData = get_device_context_data(pContext);
    ma_result result = ma_context_uninit(&pData->context);
    CA_FREE(pData);
    return result;
}