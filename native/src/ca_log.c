#include <string.h>
#include "ca_log.h"

void ca_log_callback(void *pUserData, ma_log_level level, const char *message)
{
    ca_log *pLog = (ca_log *)pUserData;

    ma_mutex_lock(&pLog->lock);
    if (pLog->hasNotification && pLog->messageCount < CA_LOG_MESSAGE_BUFFER_COUNT)
    {
        char *pCopiedMsg = ma_malloc(strlen(message) + 1, NULL);
        strcpy(pCopiedMsg, message);

        ca_log_message logMessage = {
            .level = level,
            .pMessage = pCopiedMsg,
        };

        pLog->messages[pLog->messageCount] = logMessage;
        pLog->messageCount++;

        Dart_CObject notification = {
            .type = Dart_CObject_kInt32,
            .value.as_int32 = pLog->messageCount,
        };
        pLog->notification = notification;

        ca_dart_post_cobject(pLog->portId, &pLog->notification);
    }
    ma_mutex_unlock(&pLog->lock);
}

ma_result ca_log_init(ca_log *pLog)
{
    pLog->portId = 0;
    pLog->hasNotification = MA_FALSE;
    pLog->messageCount = 0;

    for (int i = 0; i < CA_LOG_MESSAGE_BUFFER_COUNT; i++)
    {
        pLog->messages[i].pMessage = NULL;
    }

    ma_result result = ma_log_init(NULL, &pLog->log);
    if (result != MA_SUCCESS)
    {
        return result;
    }

    result = ma_mutex_init(&pLog->lock);
    if (result != MA_SUCCESS)
    {
        ma_log_uninit(&pLog->log);
        return result;
    }

    ma_log_callback callback = ma_log_callback_init(ca_log_callback, pLog);
    return ma_log_register_callback(&pLog->log, callback);
}

ma_log *ca_log_get_ref(ca_log *pLog)
{
    return &pLog->log;
}

void ca_log_get_messages(ca_log *pLog, ca_log_message **ppMessages, ma_uint32 *pCount)
{
    *ppMessages = &pLog->messages[0];
    *pCount = pLog->messageCount > *pCount ? *pCount : pLog->messageCount;
}

void ca_log_release_messages(ca_log *pLog, ma_uint32 count)
{
    ma_mutex_lock(&pLog->lock);

    ma_uint32 freeCount = pLog->messageCount > count ? count : pLog->messageCount;
    for (int i = 0; i < freeCount; i++)
    {
        char *pMessage = (char *)pLog->messages[i].pMessage;
        ma_free(pMessage, NULL);
        pLog->messages[i].pMessage = NULL;
    }

    pLog->messageCount -= freeCount;
    for (int i = 0; i < pLog->messageCount; i++)
    {
        pLog->messages[i] = pLog->messages[i + freeCount];
    }

    ma_mutex_unlock(&pLog->lock);
}

void ca_log_set_notification(ca_log *pLog, Dart_Port_DL portId)
{
    pLog->portId = portId;
    pLog->hasNotification = MA_TRUE;
}

void ca_log_uninit(ca_log *pLog)
{
    ma_mutex_lock(&pLog->lock);
    pLog->portId = 0;
    pLog->hasNotification = MA_FALSE;
    ma_log_uninit(&pLog->log);
    ma_mutex_unlock(&pLog->lock);

    ca_log_release_messages(pLog, pLog->messageCount);

    ma_mutex_uninit(&pLog->lock);
}
