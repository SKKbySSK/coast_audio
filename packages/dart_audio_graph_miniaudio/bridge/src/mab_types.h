#pragma once

typedef int mab_result;

typedef int mab_bool;
#define MAB_TRUE 1
#define MAB_FALSE 0

typedef unsigned long long uint64;

#ifndef MAB_MALLOC
#ifdef MAB_WIN32
#define MAB_MALLOC(sz) HeapAlloc(GetProcessHeap(), 0, (sz))
#else
#define MAB_MALLOC(sz) malloc((sz))
#endif
#endif

#ifndef MAB_REALLOC
#ifdef MAB_WIN32
#define MAB_REALLOC(p, sz) (((sz) > 0) ? ((p) ? HeapReAlloc(GetProcessHeap(), 0, (p), (sz)) : HeapAlloc(GetProcessHeap(), 0, (sz))) : ((VOID*)(size_t)(HeapFree(GetProcessHeap(), 0, (p)) & 0)))
#else
#define MAB_REALLOC(p, sz) realloc((p), (sz))
#endif
#endif

#ifndef MAB_FREE
#ifdef MAB_WIN32
#define MAB_FREE(p) HeapFree(GetProcessHeap(), 0, (p))
#else
#define MAB_FREE(p) free((p))
#endif
#endif

static inline void mab_zero_memory_default(void* p, size_t sz)
{
#ifdef MAB_WIN32
  ZeroMemory(p, sz);
#else
  if (sz > 0) {
    memset(p, 0, sz);
  }
#endif
}

#ifndef MAB_ZERO_MEMORY
#define MAB_ZERO_MEMORY(p, sz) mab_zero_memory_default((p), (sz))
#endif

#ifndef MAB_COPY_MEMORY
#ifdef MAB_WIN32
#define MAB_COPY_MEMORY(dst, src, sz) CopyMemory((dst), (src), (sz))
#else
#define MAB_COPY_MEMORY(dst, src, sz) memcpy((dst), (src), (sz))
#endif
#endif

#ifndef MAB_MOVE_MEMORY
#ifdef MAB_WIN32
#define MAB_MOVE_MEMORY(dst, src, sz) MoveMemory((dst), (src), (sz))
#else
#define MAB_MOVE_MEMORY(dst, src, sz) memmove((dst), (src), (sz))
#endif
#endif

#ifndef MAB_ASSERT
#ifdef MAB_WIN32
#define MAB_ASSERT(condition) assert(condition)
#else
#define MAB_ASSERT(condition) assert(condition)
#endif
#endif

#define MAB_ZERO_OBJECT(p) MAB_ZERO_MEMORY((p), sizeof(*(p)))

#define mab_countof(x)               (sizeof(x) / sizeof(x[0]))
#define mab_max(x, y)                (((x) > (y)) ? (x) : (y))
#define mab_min(x, y)                (((x) < (y)) ? (x) : (y))
#define mab_abs(x)                   (((x) > 0) ? (x) : -(x))
#define mab_clamp(x, lo, hi)         (mab_max(lo, mab_min(x, hi)))
#define mab_offset_ptr(p, offset)    (((mab_uint8*)(p)) + (offset))
#define mab_align(x, a)              ((x + (a-1)) & ~(a-1))
#define mab_align_64(x)              mab_align(x, 8)
