#import <Foundation/Foundation.h>
#include <mach-o/dyld.h>
#include <mach/mach.h>
#include <string.h>
// JRMemory forward declaration — framework zaten linked
struct AddrRange { uint64_t start; uint64_t end; };
class JRMemoryEngine {
public:
    unsigned int task;
    JRMemoryEngine(unsigned int t);
    void JRWriteMemory(unsigned long long address, void *target, size_t len);
};

// ─────────────────────────────────────────────────────────────────────────────
// AnoSDKBypass.mm — JRMemory ile GOT patch
//
// anogs.framework binary analizinden doğrulanan __la_symbol_ptr offset'leri:
//   _connect → 0x284588
//   _send    → 0x2849a8
//   _recv    → 0x284948
//   _write   → 0x284b58
//
// Strateji: AnoSDK'nın network GOT entry'lerini fake fonksiyonlarla yaz
// → Sunucuya hiçbir şey gidemez → ban raporu iletilemez
// ─────────────────────────────────────────────────────────────────────────────

// Fake network fonksiyonları
static int  fake_connect(int s, const void *addr, unsigned int len)  { return 0; }
static long fake_send(int s, const void *buf, size_t len, int flags) { return (long)len; }
static long fake_recv(int s, void *buf, size_t len, int flags)       { return 0; }
static long fake_write(int fd, const void *buf, size_t nbyte)        { return (long)nbyte; }

void AnoSDKBypassInstall(void) {
    static dispatch_once_t once;
    dispatch_once(&once, ^{

        // anogs.framework base adresini bul
        uintptr_t base = 0;
        uint32_t count = _dyld_image_count();
        for (uint32_t i = 0; i < count; i++) {
            const char *name = _dyld_get_image_name(i);
            if (name && strstr(name, "anogs")) {
                base = (uintptr_t)_dyld_get_image_header(i);
                break;
            }
        }
        if (!base) return;

        // JRMemoryEngine başlat
        JRMemoryEngine mem(mach_task_self());

        // Patch edilecek GOT entry'leri
        // Her biri 8 byte (arm64 pointer size)
        struct { uintptr_t offset; void *fn; } patches[] = {
            { 0x284588, (void *)fake_connect },  // _connect
            { 0x2849a8, (void *)fake_send    },  // _send
            { 0x284948, (void *)fake_recv    },  // _recv
            { 0x284b58, (void *)fake_write   },  // _write
        };

        for (auto &p : patches) {
            void *fnPtr = p.fn;
            mem.JRWriteMemory(base + p.offset, &fnPtr, sizeof(void *));
        }
    });
}

@interface AnoSDKBypassLoader : NSObject
@end
@implementation AnoSDKBypassLoader
+ (void)load {
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)),
        dispatch_get_main_queue(),
        ^{ AnoSDKBypassInstall(); }
    );
}
@end
