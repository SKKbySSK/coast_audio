#pragma once
#include "mab_enum.h"
#include "mab_types.h"

typedef struct {
  void* pData;
  void* pMaContext;
  mab_backend backend;
} mab_device_context;

int mab_device_context_init(mab_device_context* pContext, mab_backend* pBackends, int backendCount);

int mab_device_context_uninit(mab_device_context* pContext);
