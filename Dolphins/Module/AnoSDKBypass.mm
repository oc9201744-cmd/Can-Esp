#import <Foundation/Foundation.h>
#include <dlfcn.h>
#include <mach-o/dyld.h>
#include "dobby.h"

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

static int hook_AnoSDKInit(void *initInfo)                                      { return 0; }
static int hook_AnoSDKInitEx(void *initInfo, int flags)                         { return 0; }
static int hook_AnoSDKSetUserInfo(const char *openID, int accountType,
    int worldID, int roleID, int gameVIP, int bigVIP, int antiAddiction)        { return 0; }
static int hook_AnoSDKSetUserInfoWithLicense(const char *openID, int accountType,
    int worldID, int roleID, int gameVIP, int bigVIP,
    int antiAddiction, const char *license)                                     { return 0; }
static int hook_AnoSDKIoctl(int cmd, const void *buf, int bufLen)               { return 0; }
static int hook_AnoSDKIoctlOld(int cmd, const void *buf, int bufLen)            { return 0; }
static int hook_AnoSDKOnPause(void)                                             { return 0; }
static int hook_AnoSDKOnResume(void)                                            { return 0; }
static int hook_AnoSDKOnRecvData(const void *data, int dataLen)                 { return 0; }
static int hook_AnoSDKOnRecvSignature(const void *sig, int sigLen)              { return 0; }
static void *hook_AnoSDKGetReportData(int *dataLen)                             { if (dataLen) *dataLen = 0; return nullptr; }
static void *hook_AnoSDKGetReportData2(int *dataLen)                            { if (dataLen) *dataLen = 0; return nullptr; }
static void *hook_AnoSDKGetReportData3(int *dataLen)                            { if (dataLen) *dataLen = 0; return nullptr; }
static void *hook_AnoSDKGetReportData4(int *dataLen)                            { if (dataLen) *dataLen = 0; return nullptr; }
static void hook_AnoSDKDelReportData(void *data)  { if (orig_AnoSDKDelReportData  && data) orig_AnoSDKDelReportData(data);  }
static void hook_AnoSDKDelReportData3(void *data) { if (orig_AnoSDKDelReportData3 && data) orig_AnoSDKDelReportData3(data); }
static void hook_AnoSDKDelReportData4(void *data) { if (orig_AnoSDKDelReportData4 && data) orig_AnoSDKDelReportData4(data); }
static void hook_AnoSDKFree(void *ptr)            { if (orig_AnoSDKFree           && ptr)  orig_AnoSDKFree(ptr);            }
static int hook_AnoSDKRegistInfoListener(void *listener)                        { return 0; }

// ─── Helper Macro ─────────────────────────────────────────────────────────────

#define DOBBY_HOOK(handle, symbolName, hookFn, origPtr)          \
    do {                                                          \
        void *_sym = dlsym(handle, "_" #symbolName);             \
        if (!_sym) _sym = dlsym(handle, #symbolName);            \
        if (_sym) DobbyHook(_sym, (void *)(hookFn), (void **)&(origPtr)); \
    } while (0)

// ─── Framework Loader ────────────────────────────────────────────────────────

static void *openAnoFramework(void) {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strstr(name, "anogs")) {
            void *h = dlopen(name, RTLD_NOLOAD | RTLD_LAZY);
            if (h) return h;
        }
    }
    NSString *bundle = [[NSBundle mainBundle] bundlePath];
    NSArray<NSString *> *paths = @[
        [bundle stringByAppendingPathComponent:@"Frameworks/anogs.framework/anogs"],
        [bundle stringByAppendingPathComponent:@"Frameworks/anogs"],
    ];
    for (NSString *path in paths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            void *h = dlopen(path.UTF8String, RTLD_LAZY | RTLD_GLOBAL);
            if (h) return h;
        }
    }
    return nullptr;
}

// ─── Install ─────────────────────────────────────────────────────────────────

void AnoSDKBypassInstall(void) {
    void *handle = openAnoFramework();
    if (!handle) return;

    DOBBY_HOOK(handle, AnoSDKInit,                   hook_AnoSDKInit,                   orig_AnoSDKInit);
    DOBBY_HOOK(handle, AnoSDKInitEx,                 hook_AnoSDKInitEx,                 orig_AnoSDKInitEx);
    DOBBY_HOOK(handle, AnoSDKSetUserInfo,            hook_AnoSDKSetUserInfo,            orig_AnoSDKSetUserInfo);
    DOBBY_HOOK(handle, AnoSDKSetUserInfoWithLicense, hook_AnoSDKSetUserInfoWithLicense, orig_AnoSDKSetUserInfoWithLicense);
    DOBBY_HOOK(handle, AnoSDKIoctl,                  hook_AnoSDKIoctl,                  orig_AnoSDKIoctl);
    DOBBY_HOOK(handle, AnoSDKIoctlOld,               hook_AnoSDKIoctlOld,               orig_AnoSDKIoctlOld);
    DOBBY_HOOK(handle, AnoSDKOnPause,                hook_AnoSDKOnPause,                orig_AnoSDKOnPause);
    DOBBY_HOOK(handle, AnoSDKOnResume,               hook_AnoSDKOnResume,               orig_AnoSDKOnResume);
    DOBBY_HOOK(handle, AnoSDKOnRecvData,             hook_AnoSDKOnRecvData,             orig_AnoSDKOnRecvData);
    DOBBY_HOOK(handle, AnoSDKOnRecvSignature,        hook_AnoSDKOnRecvSignature,        orig_AnoSDKOnRecvSignature);
    DOBBY_HOOK(handle, AnoSDKGetReportData,          hook_AnoSDKGetReportData,          orig_AnoSDKGetReportData);
    DOBBY_HOOK(handle, AnoSDKGetReportData2,         hook_AnoSDKGetReportData2,         orig_AnoSDKGetReportData2);
    DOBBY_HOOK(handle, AnoSDKGetReportData3,         hook_AnoSDKGetReportData3,         orig_AnoSDKGetReportData3);
    DOBBY_HOOK(handle, AnoSDKGetReportData4,         hook_AnoSDKGetReportData4,         orig_AnoSDKGetReportData4);
    DOBBY_HOOK(handle, AnoSDKDelReportData,          hook_AnoSDKDelReportData,          orig_AnoSDKDelReportData);
    DOBBY_HOOK(handle, AnoSDKDelReportData3,         hook_AnoSDKDelReportData3,         orig_AnoSDKDelReportData3);
    DOBBY_HOOK(handle, AnoSDKDelReportData4,         hook_AnoSDKDelReportData4,         orig_AnoSDKDelReportData4);
    DOBBY_HOOK(handle, AnoSDKFree,                   hook_AnoSDKFree,                   orig_AnoSDKFree);
    DOBBY_HOOK(handle, AnoSDKRegistInfoListener,     hook_AnoSDKRegistInfoListener,     orig_AnoSDKRegistInfoListener);
}

// ─── Auto-install ─────────────────────────────────────────────────────────────

@interface AnoSDKBypassLoader : NSObject
@end

@implementation AnoSDKBypassLoader

+ (void)load {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
            dispatch_get_main_queue(),
            ^{ AnoSDKBypassInstall(); }
        );
    });
}

@end