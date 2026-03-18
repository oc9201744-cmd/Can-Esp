#ifndef dobby_h
#define dobby_h

#include <stdint.h>
#include <stdbool.h>

#if defined(__APPLE__)
#include <mach/mach_types.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

// ─── DobbyHook ───────────────────────────────────────────────────────────────
// Hook a function at address, replace with fake_func, save original to orig_func
// Returns 0 on success
int DobbyHook(void *address, void *fake_func, void **orig_func);

// ─── DobbyDestroy ────────────────────────────────────────────────────────────
// Remove a previously installed hook
// Returns 0 on success
int DobbyDestroy(void *address);

// ─── DobbySymbolResolver ─────────────────────────────────────────────────────
// Resolve a symbol address by image name and symbol name
// Pass NULL for image_name to search all images
void *DobbySymbolResolver(const char *image_name, const char *symbol_name);

// ─── DobbyImportTableReplace ─────────────────────────────────────────────────
// Replace an imported symbol in the GOT/PLT of a specific image
// Returns 0 on success
int DobbyImportTableReplace(char *image_name, char *symbol_name, void *fake_func, void **orig_func);

// ─── DobbyCodePatch ──────────────────────────────────────────────────────────
// Write raw bytes to an address (handles memory protection)
// Returns 0 on success
int DobbyCodePatch(void *address, uint8_t *buffer, uint32_t size);

// ─── Register Context ────────────────────────────────────────────────────────
// Used with DobbyInstrument for pre/post call monitoring

#if defined(__arm64__) || defined(__aarch64__)
typedef struct {
    uint64_t x[29]; // x0 - x28
    uint64_t fp;    // x29
    uint64_t lr;    // x30
    uint64_t sp;
    uint64_t pc;
    union {
        __uint128_t q[32];
        double      d[32];
        float       s[32];
    } fp_regs;
} DobbyRegisterContext;

#define DOBBY_REG_CTX_GET_PARAM(ctx, index) ((ctx)->x[(index)])
#define DOBBY_REG_CTX_SET_PARAM(ctx, index, val) ((ctx)->x[(index)] = (uint64_t)(val))
#define DOBBY_REG_CTX_GET_RETURN(ctx) ((ctx)->x[0])
#define DOBBY_REG_CTX_SET_RETURN(ctx, val) ((ctx)->x[0] = (uint64_t)(val))

#elif defined(__arm__)
typedef struct {
    uint32_t r[13]; // r0-r12
    uint32_t sp;
    uint32_t lr;
    uint32_t pc;
} DobbyRegisterContext;

#define DOBBY_REG_CTX_GET_PARAM(ctx, index) ((ctx)->r[(index)])
#define DOBBY_REG_CTX_SET_PARAM(ctx, index, val) ((ctx)->r[(index)] = (uint32_t)(val))
#define DOBBY_REG_CTX_GET_RETURN(ctx) ((ctx)->r[0])
#define DOBBY_REG_CTX_SET_RETURN(ctx, val) ((ctx)->r[0] = (uint32_t)(val))

#elif defined(__x86_64__)
typedef struct {
    uint64_t rax, rbx, rcx, rdx;
    uint64_t rbp, rsp, rsi, rdi;
    uint64_t r8, r9, r10, r11, r12, r13, r14, r15;
    uint64_t rip, rflags;
} DobbyRegisterContext;

#define DOBBY_REG_CTX_GET_PARAM(ctx, index) \
    (index == 0 ? (ctx)->rdi : index == 1 ? (ctx)->rsi : \
     index == 2 ? (ctx)->rdx : index == 3 ? (ctx)->rcx : \
     index == 4 ? (ctx)->r8  : (ctx)->r9)
#define DOBBY_REG_CTX_SET_RETURN(ctx, val) ((ctx)->rax = (uint64_t)(val))
#define DOBBY_REG_CTX_GET_RETURN(ctx) ((ctx)->rax)

#elif defined(__i386__)
typedef struct {
    uint32_t eax, ebx, ecx, edx;
    uint32_t ebp, esp, esi, edi;
    uint32_t eip, eflags;
} DobbyRegisterContext;

#define DOBBY_REG_CTX_SET_RETURN(ctx, val) ((ctx)->eax = (uint32_t)(val))
#define DOBBY_REG_CTX_GET_RETURN(ctx) ((ctx)->eax)
#endif

// ─── DobbyInstrument ─────────────────────────────────────────────────────────
// Install a pre-call monitor at address (no replacement, just observe)
typedef void (*dobby_instrument_callback_t)(DobbyRegisterContext *ctx, uintptr_t sp);
int DobbyInstrument(void *address, dobby_instrument_callback_t pre_handler);

// ─── Utility Macros ──────────────────────────────────────────────────────────

#if defined(__arm64__) || defined(__aarch64__)
// Strip PAC from a pointer (arm64e)
#define arm64e_pac_strip(ptr) \
    __asm__ volatile("xpaclri" ::: "lr"); \
    (ptr) = (__typeof__(ptr))__builtin_arm_rsr64("lr");
#endif

// Convenience macro: declare hook with named orig pointer
#define HOOK_TRAMPOLINE(ret, name, ...)                                         \
    typedef ret (*name##_func_t)(__VA_ARGS__);                                  \
    static name##_func_t orig_##name = NULL;                                    \
    static ret fake_##name(__VA_ARGS__);                                        \
    static void install_hook_##name(void *sym_addr) {                           \
        DobbyHook(sym_addr, (void *)fake_##name, (void **)&orig_##name);        \
    }                                                                            \
    static ret fake_##name(__VA_ARGS__)

#ifdef __cplusplus
}
#endif

#endif /* dobby_h */
