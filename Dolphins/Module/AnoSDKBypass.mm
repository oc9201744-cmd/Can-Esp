#import <Foundation/Foundation.h>
#import <dlfcn.h>      // Bu satır RTLD_NOW, RTLD_GLOBAL ve dlopen'ı tanımlar
#include "dobby.h"

// Eğer hata devam ederse (bazı Theos sürümlerinde gerekebilir):
#ifndef RTLD_NOW
    #define RTLD_NOW 0x2
#endif
#ifndef RTLD_GLOBAL
    #define RTLD_GLOBAL 0x8
#endif


// ─── AnoSDK Function Typedefs ───────────────────────────────────────────────

typedef int  (*AnoSDKInit_t)(void *initInfo);
typedef int  (*AnoSDKInitEx_t)(void *initInfo, int flags);
typedef int  (*AnoSDKSetUserInfo_t)(const char *openID, int accountType, int worldID, int roleID, int gameVIP, int bigVIP, int antiAddiction);
typedef int  (*AnoSDKSetUserInfoWithLicense_t)(const char *openID, int accountType, int worldID, int roleID, int gameVIP, int bigVIP, int antiAddiction, const char *license);
typedef int  (*AnoSDKIoctl_t)(int cmd, const void *buf, int bufLen);
typedef int  (*AnoSDKIoctlOld_t)(int cmd, const void *buf, int bufLen);
typedef int  (*AnoSDKOnPause_t)(void);
typedef int  (*AnoSDKOnResume_t)(void);
typedef int  (*AnoSDKOnRecvData_t)(const void *data, int dataLen);
typedef int  (*AnoSDKOnRecvSignature_t)(const void *sig, int sigLen);
typedef void*(*AnoSDKGetReportData_t)(int *dataLen);
typedef void*(*AnoSDKGetReportData2_t)(int *dataLen);
typedef void*(*AnoSDKGetReportData3_t)(int *dataLen);
typedef void*(*AnoSDKGetReportData4_t)(int *dataLen);
typedef void (*AnoSDKDelReportData_t)(void *data);
typedef void (*AnoSDKDelReportData3_t)(void *data);
typedef void (*AnoSDKDelReportData4_t)(void *data);
typedef void (*AnoSDKFree_t)(void *ptr);
typedef int  (*AnoSDKRegistInfoListener_t)(void *listener);

// ─── Original Function Pointers ─────────────────────────────────────────────

static AnoSDKInit_t                  orig_AnoSDKInit                  = nullptr;
static AnoSDKInitEx_t                orig_AnoSDKInitEx                = nullptr;
static AnoSDKSetUserInfo_t           orig_AnoSDKSetUserInfo           = nullptr;
static AnoSDKSetUserInfoWithLicense_t orig_AnoSDKSetUserInfoWithLicense = nullptr;
static AnoSDKIoctl_t                 orig_AnoSDKIoctl                 = nullptr;
static AnoSDKOnPause_t               orig_AnoSDKOnPause               = nullptr;
static AnoSDKOnResume_t              orig_AnoSDKOnResume              = nullptr;
static AnoSDKOnRecvData_t            orig_AnoSDKOnRecvData            = nullptr;
static AnoSDKOnRecvSignature_t       orig_AnoSDKOnRecvSignature       = nullptr;
static AnoSDKGetReportData_t         orig_AnoSDKGetReportData         = nullptr;
static AnoSDKGetReportData2_t        orig_AnoSDKGetReportData2        = nullptr;
static AnoSDKGetReportData3_t        orig_AnoSDKGetReportData3        = nullptr;
static AnoSDKGetReportData4_t        orig_AnoSDKGetReportData4        = nullptr;
static AnoSDKDelReportData_t         orig_AnoSDKDelReportData         = nullptr;
static AnoSDKDelReportData3_t        orig_AnoSDKDelReportData3        = nullptr;
static AnoSDKDelReportData4_t        orig_AnoSDKDelReportData4        = nullptr;
static AnoSDKFree_t                  orig_AnoSDKFree                  = nullptr;
static AnoSDKRegistInfoListener_t    orig_AnoSDKRegistInfoListener    = nullptr;

// ─── Hook Implementations ────────────────────────────────────────────────────

static int hook_AnoSDKInit(void *initInfo) {
    NSLog(@"[AnoBypass] AnoSDKInit hooked → returning 0");
    return 0;
}

static int hook_AnoSDKInitEx(void *initInfo, int flags) {
    NSLog(@"[AnoBypass] AnoSDKInitEx hooked → returning 0");
    return 0;
}

static int hook_AnoSDKSetUserInfo(const char *openID, int accountType, int worldID, int roleID, int gameVIP, int bigVIP, int antiAddiction) {
    NSLog(@"[AnoBypass] AnoSDKSetUserInfo hooked → returning 0");
    return 0;
}

static int hook_AnoSDKSetUserInfoWithLicense(const char *openID, int accountType, int worldID, int roleID, int gameVIP, int bigVIP, int antiAddiction, const char *license) {
    NSLog(@"[AnoBypass] AnoSDKSetUserInfoWithLicense hooked → returning 0");
    return 0;
}

static int hook_AnoSDKIoctl(int cmd, const void *buf, int bufLen) {
    NSLog(@"[AnoBypass] AnoSDKIoctl cmd=%d hooked → returning 0", cmd);
    return 0;
}

static int hook_AnoSDKOnPause(void) {
    NSLog(@"[AnoBypass] AnoSDKOnPause hooked → returning 0");
    return 0;
}

static int hook_AnoSDKOnResume(void) {
    NSLog(@"[AnoBypass] AnoSDKOnResume hooked → returning 0");
    return 0;
}

static int hook_AnoSDKOnRecvData(const void *data, int dataLen) {
    NSLog(@"[AnoBypass] AnoSDKOnRecvData hooked → returning 0");
    return 0;
}

static int hook_AnoSDKOnRecvSignature(const void *sig, int sigLen) {
    NSLog(@"[AnoBypass] AnoSDKOnRecvSignature hooked → returning 0");
    return 0;
}

static void *hook_AnoSDKGetReportData(int *dataLen) {
    NSLog(@"[AnoBypass] AnoSDKGetReportData hooked → returning nullptr");
    if (dataLen) *dataLen = 0;
    return nullptr;
}

static void *hook_AnoSDKGetReportData2(int *dataLen) {
    if (dataLen) *dataLen = 0;
    return nullptr;
}

static void *hook_AnoSDKGetReportData3(int *dataLen) {
    if (dataLen) *dataLen = 0;
    return nullptr;
}

static void *hook_AnoSDKGetReportData4(int *dataLen) {
    if (dataLen) *dataLen = 0;
    return nullptr;
}

static void hook_AnoSDKDelReportData(void *data)  { /* no-op */ }
static void hook_AnoSDKDelReportData3(void *data) { /* no-op */ }
static void hook_AnoSDKDelReportData4(void *data) { /* no-op */ }
static void hook_AnoSDKFree(void *ptr)            { /* no-op */ }

static int hook_AnoSDKRegistInfoListener(void *listener) {
    NSLog(@"[AnoBypass] AnoSDKRegistInfoListener hooked → returning 0");
    return 0;
}

// ─── Helper Macro ────────────────────────────────────────────────────────────

#define HOOK_SYMBOL(frameworkHandle, symbolName, hookFn, origPtr)             \
    do {                                                                        \
        void *sym = dlsym(frameworkHandle, #symbolName);                       \
        if (sym) {                                                             \
            DobbyHook(sym, (void *)(hookFn), (void **)&(origPtr));            \
            NSLog(@"[AnoBypass] Hooked: " #symbolName);                       \
        } else {                                                               \
            NSLog(@"[AnoBypass] Symbol not found: " #symbolName);             \
        }                                                                      \
    } while (0)

// ─── Install All Hooks ───────────────────────────────────────────────────────

void AnoSDKBypassInstall(void) {
    // Framework'ü yükle
    NSString *frameworkPath = [[NSBundle mainBundle]
        pathForResource:@"anogs"
                 ofType:nil
            inDirectory:@"Frameworks/anogs.framework"];

    if (!frameworkPath) {
        // Alternatif yol
        frameworkPath = [[[NSBundle mainBundle] bundlePath]
            stringByAppendingPathComponent:@"Frameworks/anogs.framework/anogs"];
    }

    void *handle = dlopen(frameworkPath.UTF8String, RTLD_NOW | RTLD_GLOBAL);
    if (!handle) {
        // Zaten yüklüyse mevcut handle'ı al
        handle = dlopen(NULL, RTLD_NOW);
        NSLog(@"[AnoBypass] Using default handle");
    }

    if (!handle) {
        NSLog(@"[AnoBypass] ERROR: Could not open anogs framework: %s", dlerror());
        return;
    }

    NSLog(@"[AnoBypass] Installing AnoSDK hooks...");

    HOOK_SYMBOL(handle, AnoSDKInit,                   hook_AnoSDKInit,                   orig_AnoSDKInit);
    HOOK_SYMBOL(handle, AnoSDKInitEx,                 hook_AnoSDKInitEx,                 orig_AnoSDKInitEx);
    HOOK_SYMBOL(handle, AnoSDKSetUserInfo,            hook_AnoSDKSetUserInfo,            orig_AnoSDKSetUserInfo);
    HOOK_SYMBOL(handle, AnoSDKSetUserInfoWithLicense, hook_AnoSDKSetUserInfoWithLicense, orig_AnoSDKSetUserInfoWithLicense);
    HOOK_SYMBOL(handle, AnoSDKIoctl,                  hook_AnoSDKIoctl,                  orig_AnoSDKIoctl);
    HOOK_SYMBOL(handle, AnoSDKOnPause,                hook_AnoSDKOnPause,                orig_AnoSDKOnPause);
    HOOK_SYMBOL(handle, AnoSDKOnResume,               hook_AnoSDKOnResume,               orig_AnoSDKOnResume);
    HOOK_SYMBOL(handle, AnoSDKOnRecvData,             hook_AnoSDKOnRecvData,             orig_AnoSDKOnRecvData);
    HOOK_SYMBOL(handle, AnoSDKOnRecvSignature,        hook_AnoSDKOnRecvSignature,        orig_AnoSDKOnRecvSignature);
    HOOK_SYMBOL(handle, AnoSDKGetReportData,          hook_AnoSDKGetReportData,          orig_AnoSDKGetReportData);
    HOOK_SYMBOL(handle, AnoSDKGetReportData2,         hook_AnoSDKGetReportData2,         orig_AnoSDKGetReportData2);
    HOOK_SYMBOL(handle, AnoSDKGetReportData3,         hook_AnoSDKGetReportData3,         orig_AnoSDKGetReportData3);
    HOOK_SYMBOL(handle, AnoSDKGetReportData4,         hook_AnoSDKGetReportData4,         orig_AnoSDKGetReportData4);
    HOOK_SYMBOL(handle, AnoSDKDelReportData,          hook_AnoSDKDelReportData,          orig_AnoSDKDelReportData);
    HOOK_SYMBOL(handle, AnoSDKDelReportData3,         hook_AnoSDKDelReportData3,         orig_AnoSDKDelReportData3);
    HOOK_SYMBOL(handle, AnoSDKDelReportData4,         hook_AnoSDKDelReportData4,         orig_AnoSDKDelReportData4);
    HOOK_SYMBOL(handle, AnoSDKFree,                   hook_AnoSDKFree,                   orig_AnoSDKFree);
    HOOK_SYMBOL(handle, AnoSDKRegistInfoListener,     hook_AnoSDKRegistInfoListener,     orig_AnoSDKRegistInfoListener);

    NSLog(@"[AnoBypass] All hooks installed!");
}

// ─── Auto-install via +load ──────────────────────────────────────────────────
// İstersen bunu AppDelegate'den manuel çağırabilirsin,
// ya da aşağıdaki +load ile otomatik yüklenir.

@interface AnoSDKBypassLoader : NSObject
@end

@implementation AnoSDKBypassLoader

+ (void)load {
    // Biraz bekleyerek framework'ün yüklenmesini garanti et
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        AnoSDKBypassInstall();
    });
}

@end
