#pragma once
#include "dart_types.h"

typedef void (*Dart_PostCObject_Def)(Dart_Port_DL port_id, Dart_CObject *message);

void ca_dart_configure(Dart_PostCObject_Def pDartPostCObject);

void ca_dart_post_cobject(Dart_Port_DL port_id, Dart_CObject *message);
