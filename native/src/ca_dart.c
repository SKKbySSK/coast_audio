#include <stdlib.h>
#include "ca_dart.h"

static Dart_PostCObject_Def post_cobject_ref = NULL;

void ca_dart_configure(Dart_PostCObject_Def pDartPostCObject)
{
    post_cobject_ref = pDartPostCObject;
}

void ca_dart_post_cobject(Dart_Port_DL port_id, Dart_CObject *message)
{
    if (post_cobject_ref != NULL)
    {
        post_cobject_ref(port_id, message);
    }
}
