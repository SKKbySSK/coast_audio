#pragma once

#if __APPLE__
#define MA_NO_RUNTIME_LINKING
#endif

#define MA_NO_NODE_GRAPH
#define MA_NO_RESOURCE_MANAGER
#define MA_NO_ENGINE

#include "miniaudio.h"
#include "ca_dart.h"
#include "ca_context.h"
#include "ca_device.h"
#include "ca_log.h"

void coast_audio_get_version(char *pMajor, char *pMinor, char *pPatch);
