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

int mab_device_context_init(mab_device_context* pContext, mab_backend* pBackends, int backendCount)
{
  mab_device_context_data* pData = (mab_device_context_data*)MA_MALLOC(sizeof(mab_device_context_data));
  pContext->pData = pData;
  pContext->pMaContext = &pData->context;

  ma_result result;
  {
    ma_context_config contextConfig = ma_context_config_init();
    result = ma_context_init((ma_backend*)pBackends, backendCount, &contextConfig, &pData->context);
    if (result != MA_SUCCESS) {
      free(pData);
      return result;
    }
  }

  pContext->backend = pData->context.backend;

  return result;
}

int mab_device_context_uninit(mab_device_context* pContext)
{
  mab_device_context_data* pData = get_data_ptr(pContext);
  ma_result result = ma_context_uninit(&pData->context);
  MA_FREE(pData);
  return result;
}
