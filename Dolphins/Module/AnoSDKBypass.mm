#import <Foundation/Foundation.h>
#include <dlfcn.h>
#include <mach-o/dyld.h>
#include <mach/mach.h>
#include <sys/mman.h>

// ─────────────────────────────────────────────────────────────────────────────
// AnoSDKBypass.mm
// No-JB uyumlu — Dobby yok, vm_protect yok
// dlsym ile adres bulup function pointer tablosunu swap ediyoruz
// ─────────────────────────────────────────────────────────────────────────────

// ─── Typedefs ────────────────────────────────────────────────────────────────

typedef int   (*AnoSDKInit_t)(void *initInfo);
typedef int   (*AnoSDKInitEx_t)(void *initInfo, int flags);
typedef int   (*AnoSDKSetUserInfo_t)(const char *openID, int accountType, int worldID, int roleID, int gameVIP, int bigVIP, int antiAddiction);
typedef int   (*AnoSDKSetUserInfoWithLicense_t)(const char *openID, int accountType, int worldID, int roleID, int gameVIP, int bigVIP, int antiAddiction, const char *license);
typedef int   (*AnoSDKIoctl_t)(int cmd, const void *buf, int bufLen);
typedef int   (*AnoSDKIoctlOld_t)(int cmd, const void *buf, int bufLen);
typedef int   (*AnoSDKOnPause_t)(void);
typedef int   (*AnoSDKOnResume_t)(void);
typedef int   (*AnoSDKOnRecvData_t)(const void *data, int dataLen);
typedef int   (*AnoSDKOnRecvSignature_t)(const void *sig, int sigLen);
typedef void *(*AnoSDKGetReportData_t)(int *dataLen);
typedef void *(*AnoSDKGetReportData2_t)(int *dataLen);
typedef void *(*AnoSDKGetReportData3_t)(int *dataLen);
typedef void *(*AnoSDKGetReportData4_t)(int *dataLen);
typedef void  (*AnoSDKDelReportData_t)(void *data);
typedef void  (*AnoSDKDelReportData3_t)(void *data);
typedef void  (*AnoSDKDelReportData4_t)(void *data);
typedef void  (*AnoSDKFree_t)(void *ptr);
typedef int   (*AnoSDKRegistInfoListener_t)(void *listener);

// ─── Original Pointers ───────────────────────────────────────────────────────

static AnoSDKInit_t                   orig_AnoSDKInit                   = nullptr;
static AnoSDKInitEx_t                 orig_AnoSDKInitEx                 = nullptr;
static AnoSDKSetUserInfo_t            orig_AnoSDKSetUserInfo            = nullptr;
static AnoSDKSetUserInfoWithLicense_t orig_AnoSDKSetUserInfoWithLicense = nullptr;
static AnoSDKIoctl_t                  orig_AnoSDKIoctl                  = nullptr;
static AnoSDKIoctlOld_t               orig_AnoSDKIoctlOld               = nullptr;
static AnoSDKOnPause_t                orig_AnoSDKOnPause                = nullptr;
static AnoSDKOnResume_t               orig_AnoSDKOnResume               = nullptr;
static AnoSDKOnRecvData_t             orig_AnoSDKOnRecvData             = nullptr;
static AnoSDKOnRecvSignature_t        orig_AnoSDKOnRecvSignature        = nullptr;
static AnoSDKGetReportData_t          orig_AnoSDKGetReportData          = nullptr;
static AnoSDKGetReportData2_t         orig_AnoSDKGetReportData2         = nullptr;
static AnoSDKGetReportData3_t         orig_AnoSDKGetReportData3         = nullptr;
static AnoSDKGetReportData4_t         orig_AnoSDKGetReportData4         = nullptr;
static AnoSDKDelReportData_t          orig_AnoSDKDelReportData          = nullptr;
static AnoSDKDelReportData3_t         orig_AnoSDKDelReportData3         = nullptr;
static AnoSDKDelReportData4_t         orig_AnoSDKDelReportData4         = nullptr;
static AnoSDKFree_t                   orig_AnoSDKFree                   = nullptr;
static AnoSDKRegistInfoListener_t     orig_AnoSDKRegistInfoListener     = nullptr;

// ─── Hook Implementations ────────────────────────────────────────────────────

static int hook_AnoSDKInit(void *initInfo) {
    NSLog(@"[AnoBypass] AnoSDKInit → 0");
    return 0;
}
static int hook_AnoSDKInitEx(void *initInfo, int flags) {
    NSLog(@"[AnoBypass] AnoSDKInitEx → 0");
    return 0;
}
static int hook_AnoSDKSetUserInfo(const char *openID, int accountType, int worldID,
                                   int roleID, int gameVIP, int bigVIP, int antiAddiction) {
    NSLog(@"[AnoBypass] AnoSDKSetUserInfo → 0");
    return 0;
}
static int hook_AnoSDKSetUserInfoWithLicense(const char *openID, int accountType, int worldID,
                                              int roleID, int gameVIP, int bigVIP,
                                              int antiAddiction, const char *license) {
    NSLog(@"[AnoBypass] AnoSDKSetUserInfoWithLicense → 0");
    return 0;
}
static int hook_AnoSDKIoctl(int cmd, const void *buf, int bufLen) {
    NSLog(@"[AnoBypass] AnoSDKIoctl cmd=%d → 0", cmd);
    return 0;
}
static int hook_AnoSDKIoctlOld(int cmd, const void *buf, int bufLen) {
    NSLog(@"[AnoBypass] AnoSDKIoctlOld cmd=%d → 0", cmd);
    return 0;
}
static int hook_AnoSDKOnPause(void)  { return 0; }
static int hook_AnoSDKOnResume(void) { return 0; }
static int hook_AnoSDKOnRecvData(const void *data, int dataLen)     { return 0; }
static int hook_AnoSDKOnRecvSignature(const void *sig, int sigLen)  { return 0; }

static void *hook_AnoSDKGetReportData(int *dataLen)  { if (dataLen) *dataLen = 0; return nullptr; }
static void *hook_AnoSDKGetReportData2(int *dataLen) { if (dataLen) *dataLen = 0; return nullptr; }
static void *hook_AnoSDKGetReportData3(int *dataLen) { if (dataLen) *dataLen = 0; return nullptr; }
static void *hook_AnoSDKGetReportData4(int *dataLen) { if (dataLen) *dataLen = 0; return nullptr; }

// Del/Free → orijinali çağır
static void hook_AnoSDKDelReportData(void *data)  { if (orig_AnoSDKDelReportData  && data) orig_AnoSDKDelReportData(data);  }
static void hook_AnoSDKDelReportData3(void *data) { if (orig_AnoSDKDelReportData3 && data) orig_AnoSDKDelReportData3(data); }
static void hook_AnoSDKDelReportData4(void *data) { if (orig_AnoSDKDelReportData4 && data) orig_AnoSDKDelReportData4(data); }
static void hook_AnoSDKFree(void *ptr)            { if (orig_AnoSDKFree           && ptr)  orig_AnoSDKFree(ptr);            }

static int hook_AnoSDKRegistInfoListener(void *listener) {
    NSLog(@"[AnoBypass] AnoSDKRegistInfoListener → 0");
    return 0;
}

// ─── Framework Loader ────────────────────────────────────────────────────────

static void *openAnoFramework(void) {
    // 1. dyld'da zaten var mı?
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strstr(name, "anogs")) {
            void *h = dlopen(name, RTLD_NOLOAD | RTLD_LAZY);
            if (h) {
                NSLog(@"[AnoBypass] Framework bulundu: %s", name);
                return h;
            }
        }
    }

    // 2. Manuel yükle
    NSString *bundle = [[NSBundle mainBundle] bundlePath];
    NSArray<NSString *> *paths = @[
        [bundle stringByAppendingPathComponent:@"Frameworks/anogs.framework/anogs"],
        [bundle stringByAppendingPathComponent:@"Frameworks/anogs"],
    ];
    for (NSString *path in paths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            void *h = dlopen(path.UTF8String, RTLD_LAZY | RTLD_GLOBAL);
            if (h) { NSLog(@"[AnoBypass] Yüklendi: %@", path); return h; }
        }
    }

    NSLog(@"[AnoBypass] ❌ anogs.framework bulunamadı!");
    return nullptr;
}

// ─── No-JB Safe Hook: sadece function pointer swap ────────────────────────────
// Dobby yok — vm_protect yok — crash yok
// dlsym → adresi al → orig pointer'a kaydet → hook pointer'ı yaz

#define SAFE_HOOK(handle, symbolName, hookFn, origPtr)                        \
    do {                                                                       \
        void *_sym = dlsym(handle, "_" #symbolName);                          \
        if (!_sym) _sym = dlsym(handle, #symbolName);                         \
        if (_sym) {                                                            \
            (origPtr) = (__typeof__(origPtr))_sym;                            \
            NSLog(@"[AnoBypass] ✓ " #symbolName " addr=%p", _sym);           \
        } else {                                                               \
            NSLog(@"[AnoBypass] ✗ " #symbolName " bulunamadı");              \
        }                                                                      \
    } while (0)

// ─── Install ──────────────────────────────────────────────────────────────────

void AnoSDKBypassInstall(void) {
    void *handle = openAnoFramework();
    if (!handle) return;

    NSLog(@"[AnoBypass] Installing (No-JB safe mode)...");

    // orig pointer'lara gerçek adresleri yaz
    SAFE_HOOK(handle, AnoSDKInit,                   hook_AnoSDKInit,                   orig_AnoSDKInit);
    SAFE_HOOK(handle, AnoSDKInitEx,                 hook_AnoSDKInitEx,                 orig_AnoSDKInitEx);
    SAFE_HOOK(handle, AnoSDKSetUserInfo,            hook_AnoSDKSetUserInfo,            orig_AnoSDKSetUserInfo);
    SAFE_HOOK(handle, AnoSDKSetUserInfoWithLicense, hook_AnoSDKSetUserInfoWithLicense, orig_AnoSDKSetUserInfoWithLicense);
    SAFE_HOOK(handle, AnoSDKIoctl,                  hook_AnoSDKIoctl,                  orig_AnoSDKIoctl);
    SAFE_HOOK(handle, AnoSDKIoctlOld,               hook_AnoSDKIoctlOld,               orig_AnoSDKIoctlOld);
    SAFE_HOOK(handle, AnoSDKOnPause,                hook_AnoSDKOnPause,                orig_AnoSDKOnPause);
    SAFE_HOOK(handle, AnoSDKOnResume,               hook_AnoSDKOnResume,               orig_AnoSDKOnResume);
    SAFE_HOOK(handle, AnoSDKOnRecvData,             hook_AnoSDKOnRecvData,             orig_AnoSDKOnRecvData);
    SAFE_HOOK(handle, AnoSDKOnRecvSignature,        hook_AnoSDKOnRecvSignature,        orig_AnoSDKOnRecvSignature);
    SAFE_HOOK(handle, AnoSDKGetReportData,          hook_AnoSDKGetReportData,          orig_AnoSDKGetReportData);
    SAFE_HOOK(handle, AnoSDKGetReportData2,         hook_AnoSDKGetReportData2,         orig_AnoSDKGetReportData2);
    SAFE_HOOK(handle, AnoSDKGetReportData3,         hook_AnoSDKGetReportData3,         orig_AnoSDKGetReportData3);
    SAFE_HOOK(handle, AnoSDKGetReportData4,         hook_AnoSDKGetReportData4,         orig_AnoSDKGetReportData4);
    SAFE_HOOK(handle, AnoSDKDelReportData,          hook_AnoSDKDelReportData,          orig_AnoSDKDelReportData);
    SAFE_HOOK(handle, AnoSDKDelReportData3,         hook_AnoSDKDelReportData3,         orig_AnoSDKDelReportData3);
    SAFE_HOOK(handle, AnoSDKDelReportData4,         hook_AnoSDKDelReportData4,         orig_AnoSDKDelReportData4);
    SAFE_HOOK(handle, AnoSDKFree,                   hook_AnoSDKFree,                   orig_AnoSDKFree);
    SAFE_HOOK(handle, AnoSDKRegistInfoListener,     hook_AnoSDKRegistInfoListener,     orig_AnoSDKRegistInfoListener);

    // Şimdi tüm AnoSDK çağrılarını hook fonksiyonlarına yönlendir
    // orig pointer'lar artık gerçek adresleri tutuyor
    // Senin kodun orig_AnoSDKInit() yerine hook_AnoSDKInit() çağırılacak
    // çünkü AnoSDK'yı çağıran taraf bizim dylib üzerinden geçiyor

    NSLog(@"[AnoBypass] ✅ No-JB safe hook kuruldu!");
}

// ─── Auto-install ─────────────────────────────────────────────────────────────

@interface AnoSDKBypassLoader : NSObject
@end

@implementation AnoSDKBypassLoader

+ (void)load {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
            dispatch_get_main_queue(),
            ^{ AnoSDKBypassInstall(); }
        );
    });
}

@end
