#include "dart_api_dl.h"

int dart_bridge_init(void* pData) {
  return (int)Dart_InitializeApiDL(pData);
}
