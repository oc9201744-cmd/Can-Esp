#ifndef dobby_h
#define dobby_h

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// ─── Dobby Hook API ───────────────────────────────────────────────────────────

/**
 * Hook a function at the given address.
 * @param address   Target function address
 * @param replace   Replacement function
 * @param origin    Pointer to store the original function (trampoline)
 * @return 0 on success, non-zero on failure
 */
int DobbyHook(void *address, void *replace, void **origin);

/**
 * Destroy/remove a previously installed hook.
 * @param address   Target function address (same as used in DobbyHook)
 * @return 0 on success, non-zero on failure
 */
int DobbyDestroy(void *address);

/**
 * Get the real address of a symbol (resolves stubs/trampolines).
 * @param image_name  dylib/framework name, or NULL for main binary
 * @param symbol_name Symbol name (with or without leading underscore)
 * @return Resolved address, or NULL if not found
 */
void *DobbySymbolResolver(const char *image_name, const char *symbol_name);

/**
 * Code patch: write arbitrary bytes at the given address.
 * @param address   Target address
 * @param buffer    Bytes to write
 * @param size      Number of bytes
 * @return 0 on success
 */
int DobbyCodePatch(void *address, uint8_t *buffer, uint32_t size);

// ─── Inline Hooking Helpers ───────────────────────────────────────────────────

// Intercept a C symbol by name inside a specific image
// Usage: DobbyInstrument(addr, pre_handler, post_handler)
typedef struct DobbyRegisterContext DobbyRegisterContext;
typedef void (*dobby_instrument_callback_t)(DobbyRegisterContext *ctx, uintptr_t sp);
int DobbyInstrument(void *address, dobby_instrument_callback_t pre_handler);

#ifdef __cplusplus
}
#endif

#endif /* dobby_h */
