#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <dlfcn.h>
#include <stdio.h>
#include "ca_device.h"
#include "ca_defs.h"

static inline ma_result read_ring_buffer(ca_device *pDevice, void *pOutput, ma_uint32 frameCount, ma_uint32 *pFramesRead)
{
    if (pFramesRead != NULL)
    {
        *pFramesRead = 0;
    }

    ma_result result = MA_SUCCESS;
    ma_uint32 bpf = ma_get_bytes_per_frame(pDevice->config.format, pDevice->config.channels);
    ma_uint32 readableFrames = frameCount;
    ma_uint32 framesRead = 0;
    void *pBuffer;

    while (readableFrames > 0)
    {
        ma_uint32 actualRead = readableFrames;
        result = ma_pcm_rb_acquire_read(&pDevice->buffer, &actualRead, &pBuffer);
        if (result != MA_SUCCESS && result != MA_AT_END)
        {
            return result;
        }

        CA_COPY_MEMORY(pOutput + (bpf * framesRead), pBuffer, bpf * actualRead);

        result = ma_pcm_rb_commit_read(&pDevice->buffer, actualRead);
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
    if (pFramesWrite != NULL)
    {
        *pFramesWrite = 0;
    }

    ma_result result = MA_SUCCESS;
    ma_uint32 bpf = ma_get_bytes_per_frame(pDevice->config.format, pDevice->config.channels);
    ma_uint32 writableFrames = frameCount;
    ma_uint32 framesWrite = 0;
    void *pBuffer;

    while (framesWrite < frameCount)
    {
        ma_uint32 actualWrite = writableFrames;
        result = ma_pcm_rb_acquire_write(&pDevice->buffer, &actualWrite, &pBuffer);
        if (result != MA_SUCCESS && result != MA_AT_END)
        {
            return result;
        }

        CA_COPY_MEMORY(pBuffer, pInput + (bpf * framesWrite), bpf * actualWrite);

        result = ma_pcm_rb_commit_write(&pDevice->buffer, actualWrite);
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

static void notification_finalizer(void *pNotification, void *peer)
{
    CA_FREE(pNotification);
}

// notification_callback can be called from another thread.
// So, we have to use a SendPort to communicate with the Dart side.
// https://github.com/flutter/flutter/issues/63255#issuecomment-671216406
static inline void notification_callback(const ma_device_notification *pNotification)
{
    ca_device *pDevice = (ca_device *)pNotification->pDevice->pUserData;
    ca_device_notification notification = {
        .type = pNotification->type,
        .state = ma_device_get_state(pNotification->pDevice),
    };

    if (pDevice->pNotification == NULL)
    {
        ca_device_notification *pCaNotification = ca_malloc(sizeof(ca_device_notification));
        pDevice->pNotification = pCaNotification;
    }

    CA_COPY_MEMORY(pDevice->pNotification, &notification, sizeof(ca_device_notification));

    Dart_CObject cObject = {
        .type = Dart_CObject_kNativePointer,
        .value.as_native_pointer.ptr = (intptr_t)pDevice->pNotification,
        .value.as_native_pointer.size = sizeof(ca_device_notification),
        .value.as_native_pointer.callback = notification_finalizer,
    };
    ca_dart_post_cobject(pDevice->config.notificationPortId, &cObject);
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
        .resampling = ma_resampler_config_init(ma_format_unknown, 0, 0, 0, ma_resample_algorithm_linear),
    };
    return config;
}

ma_result ca_device_init(ca_device *pDevice, ca_device_config config, ma_context *pContext, ma_device_id *pDeviceId)
{
    pDevice->config = config;
    pDevice->pNotification = NULL;

    ma_result result;

    // init: ma_device
    {
        ma_device_config deviceConfig = ma_device_config_init(*(ma_device_type *)&config.type);
        deviceConfig.playback.pDeviceID = pDeviceId;
        deviceConfig.playback.format = config.format;
        deviceConfig.playback.channels = config.channels;
        deviceConfig.playback.channelMixMode = *(ma_channel_mix_mode *)&config.channelMixMode;
        deviceConfig.capture.pDeviceID = pDeviceId;
        deviceConfig.capture.format = config.format;
        deviceConfig.capture.channels = config.channels;
        deviceConfig.capture.channelMixMode = *(ma_channel_mix_mode *)&config.channelMixMode;
        deviceConfig.resampling = config.resampling;
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
            return MA_INVALID_ARGS;
        }

        result = ma_device_init(pContext, &deviceConfig, &pDevice->device);
        if (result != MA_SUCCESS)
        {
            return result;
        }
    }

    // init: ma_pcm_rb
    {
        result = ma_pcm_rb_init(config.format, config.channels, config.bufferFrameSize, NULL, NULL, &pDevice->buffer);
        if (result != MA_SUCCESS)
        {
            ma_device_uninit(&pDevice->device);
            return result;
        }
    }

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

ma_result ca_device_get_device_info(ca_device *pDevice, ma_device_info *pDeviceInfo)
{
    ma_device_info info;
    ma_result result;
    switch (pDevice->config.type)
    {
    case ma_device_type_playback:
        return ma_device_get_info(&pDevice->device, ma_device_type_playback, &info);
    case ma_device_type_capture:
        return ma_device_get_info(&pDevice->device, ma_device_type_capture, &info);
    default:
        return MA_INVALID_ARGS;
    }
}

ma_result ca_device_start(ca_device *pDevice)
{
    return ma_device_start(&pDevice->device);
}

ma_result ca_device_stop(ca_device *pDevice)
{
    return ma_device_stop(&pDevice->device);
}

ma_device_state ca_device_get_state(ca_device *pDevice)
{
    return ma_device_get_state(&pDevice->device);
}

ma_result ca_device_set_volume(ca_device *pDevice, float volume)
{
    return ma_device_set_master_volume(&pDevice->device, volume);
}

ma_result ca_device_get_volume(ca_device *pDevice, float *pVolume)
{
    return ma_device_get_master_volume(&pDevice->device, pVolume);
}

void ca_device_clear_buffer(ca_device *pDevice)
{
    ma_pcm_rb_reset(&pDevice->buffer);
}

int ca_device_available_read(ca_device *pDevice)
{
    return ma_pcm_rb_available_read(&pDevice->buffer);
}

int ca_device_available_write(ca_device *pDevice)
{
    return ma_pcm_rb_available_write(&pDevice->buffer);
}

void ca_device_uninit(ca_device *pDevice)
{
    ma_pcm_rb_uninit(&pDevice->buffer);
    ma_device_uninit(&pDevice->device);
    // NOTE: pDevice->pNotification is freed by notification_finalizer so we don't need to free it here.
}
