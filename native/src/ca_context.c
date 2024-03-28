#include "ca_context.h"

ma_result ca_context_init(const ma_backend backends[], ma_uint32 backendCount, const ma_context_config *pConfig, ca_context *pContext)
{
    pContext->pRef = NULL;

    ma_context *pRef = (ma_context *)ma_malloc(sizeof(ma_context), NULL);
    ma_result result = ma_context_init(backends, backendCount, pConfig, pRef);
    if (result != MA_SUCCESS)
    {
        ma_free(pContext, NULL);
        return result;
    }

    pContext->pRef = pRef;
    return MA_SUCCESS;
}

ma_context *ca_context_get_ref(ca_context *pContext)
{
    return (ma_context *)pContext->pRef;
}

ma_result ca_context_uninit(ca_context *pContext)
{
    if (pContext->pRef == NULL)
    {
        return MA_SUCCESS;
    }

    ma_result result = ma_context_uninit(pContext->pRef);
    ma_free(pContext->pRef, NULL);
    pContext->pRef = NULL;

    return result;
}
