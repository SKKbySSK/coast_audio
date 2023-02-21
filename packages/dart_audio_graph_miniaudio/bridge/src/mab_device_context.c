#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"

#include <stdlib.h>
#include <string.h>
#include "mab_device_context.h"

typedef struct {
  ma_context context;
} mab_device_context_data;

static inline mab_device_context_data* get_data_ptr(mab_device_context* pDevice)
{
  return (mab_device_context_data*)pDevice->pData;
}


void mab_device_info_init(mab_device_info* pInfo, mab_device_id id, char* name, mab_bool isDefault)
{
  mab_device_info info = {
    .id = id,
    .isDefault = isDefault,
  };
  strncpy(info.name, name, sizeof(info.name));
  *pInfo = info;
}

int mab_device_context_init(mab_device_context* pContext, mab_backend* pBackends, int backendCount)
{
  mab_device_context_data* pData = (mab_device_context_data*)MA_MALLOC(sizeof(mab_device_context_data));
  pContext->pData = pData;
  pContext->pMaContext = &pData->context;

  ma_result result;
  {
    ma_context_config contextConfig = ma_context_config_init();

    // disable AudioSession management for less complexity
    contextConfig.coreaudio.noAudioSessionActivate = MA_TRUE;
    contextConfig.coreaudio.noAudioSessionDeactivate = MA_TRUE;
    contextConfig.coreaudio.sessionCategory = ma_ios_session_category_none;

    result = ma_context_init((ma_backend*)pBackends, backendCount, &contextConfig, &pData->context);
    if (result != MA_SUCCESS) {
      free(pData);
      return result;
    }
  }

  pContext->backend = pData->context.backend;

  return result;
}

int mab_device_context_get_device_count(mab_device_context* pContext, mab_device_type type, int* pCount)
{
  mab_device_context_data* pData = get_data_ptr(pContext);
  ma_uint32 count = 0;
  ma_result result;
  {
    switch (type) {
    case mab_device_type_playback:
      result = ma_context_get_devices(&pData->context, NULL, &count, NULL, NULL);
      break;
    case mab_device_type_capture:
      result = ma_context_get_devices(&pData->context, NULL, NULL, NULL, &count);
      break;
    default:
      return MA_INVALID_ARGS;
    }
    *pCount = count;
  }

  return result;
}

int mab_device_context_get_device_info(mab_device_context* pContext, mab_device_type type, int index, mab_device_info* pInfo)
{
  mab_device_context_data* pData = get_data_ptr(pContext);
  ma_device_info* pDeviceInfos;
  ma_result result;
  {
    switch (type) {
    case mab_device_type_playback:
      result = ma_context_get_devices(&pData->context, &pDeviceInfos, NULL, NULL, NULL);
      break;
    case mab_device_type_capture:
      result = ma_context_get_devices(&pData->context, NULL, NULL, &pDeviceInfos, NULL);
      break;
    default:
      return MA_INVALID_ARGS;
    }

    ma_device_info* pMaInfo = &pDeviceInfos[index];
    mab_device_info_init(pInfo, *(mab_device_id*)&pMaInfo->id, pMaInfo->name, pMaInfo->isDefault);
  }

  return result;
}

int mab_device_context_uninit(mab_device_context* pContext)
{
  mab_device_context_data* pData = get_data_ptr(pContext);
  ma_result result = ma_context_uninit(&pData->context);
  MA_FREE(pData);
  return result;
}
