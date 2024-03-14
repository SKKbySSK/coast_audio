#include <stddef.h>
#include <stdlib.h>
#include <string.h>

static inline void *ca_malloc(size_t sz)
{
#ifdef CA_WIN32
    return HeapAlloc(GetProcessHeap(), 0, (sz));
#else
    return malloc((sz));
#endif
}

#ifndef CA_REALLOC
#ifdef CA_WIN32
#define CA_REALLOC(p, sz) (((sz) > 0) ? ((p) ? HeapReAlloc(GetProcessHeap(), 0, (p), (sz)) : HeapAlloc(GetProcessHeap(), 0, (sz))) : ((VOID *)(size_t)(HeapFree(GetProcessHeap(), 0, (p)) & 0)))
#else
#define CA_REALLOC(p, sz) realloc((p), (sz))
#endif
#endif

#ifndef CA_FREE
#ifdef CA_WIN32
#define CA_FREE(p) HeapFree(GetProcessHeap(), 0, (p))
#else
#define CA_FREE(p) free((p))
#endif
#endif

static inline void ca_zero_memory_default(void *p, size_t sz)
{
#ifdef CA_WIN32
    ZeroMemory(p, sz);
#else
    if (sz > 0)
    {
        memset(p, 0, sz);
    }
#endif
}

#ifndef CA_ZERO_MEMORY
#define CA_ZERO_MEMORY(p, sz) ca_zero_memory_default((p), (sz))
#endif

#ifndef CA_COPY_MEMORY
#ifdef CA_WIN32
#define CA_COPY_MEMORY(dst, src, sz) CopyMemory((dst), (src), (sz))
#else
#define CA_COPY_MEMORY(dst, src, sz) memcpy((dst), (src), (sz))
#endif
#endif

#ifndef CA_MOVE_MEMORY
#ifdef CA_WIN32
#define CA_MOVE_MEMORY(dst, src, sz) MoveMemory((dst), (src), (sz))
#else
#define CA_MOVE_MEMORY(dst, src, sz) memmove((dst), (src), (sz))
#endif
#endif

#ifndef CA_ASSERT
#ifdef CA_WIN32
#define CA_ASSERT(condition) assert(condition)
#else
#define CA_ASSERT(condition) assert(condition)
#endif
#endif

#define CA_ZERO_OBJECT(p) CA_ZERO_MEMORY((p), sizeof(*(p)))

#define ca_countof(x) (sizeof(x) / sizeof(x[0]))
#define ca_max(x, y) (((x) > (y)) ? (x) : (y))
#define ca_min(x, y) (((x) < (y)) ? (x) : (y))
#define ca_abs(x) (((x) > 0) ? (x) : -(x))
#define ca_clamp(x, lo, hi) (ca_max(lo, ca_min(x, hi)))
#define ca_offset_ptr(p, offset) (((ca_uint8 *)(p)) + (offset))
#define ca_align(x, a) ((x + (a - 1)) & ~(a - 1))
#define ca_align_64(x) ca_align(x, 8)
#define ca_cast(type, value) *(type *)&value