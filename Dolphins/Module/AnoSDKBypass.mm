#import <Foundation/Foundation.h>
#include <dlfcn.h>
#include <mach-o/dyld.h>
#include "fishhook.h"

// ─── AnoSDK Typedefs ──────────────────────────────────────────────────────────

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

static int hook_AnoSDKInit(void *initInfo)                             { return 0; }
static int hook_AnoSDKInitEx(void *initInfo, int flags)                { return 0; }
static int hook_AnoSDKSetUserInfo(const char *openID, int accountType,
    int worldID, int roleID, int gameVIP, int bigVIP, int antiAddiction){ return 0; }
static int hook_AnoSDKSetUserInfoWithLicense(const char *openID, int accountType,
    int worldID, int roleID, int gameVIP, int bigVIP,
    int antiAddiction, const char *license)                            { return 0; }
static int hook_AnoSDKIoctl(int cmd, const void *buf, int bufLen)      { return 0; }
static int hook_AnoSDKIoctlOld(int cmd, const void *buf, int bufLen)   { return 0; }
static int hook_AnoSDKOnPause(void)                                    { return 0; }
static int hook_AnoSDKOnResume(void)                                   { return 0; }
static int hook_AnoSDKOnRecvData(const void *data, int dataLen)        { return 0; }
static int hook_AnoSDKOnRecvSignature(const void *sig, int sigLen)     { return 0; }
static void *hook_AnoSDKGetReportData(int *dataLen)                    { if (dataLen) *dataLen = 0; return nullptr; }
static void *hook_AnoSDKGetReportData2(int *dataLen)                   { if (dataLen) *dataLen = 0; return nullptr; }
static void *hook_AnoSDKGetReportData3(int *dataLen)                   { if (dataLen) *dataLen = 0; return nullptr; }
static void *hook_AnoSDKGetReportData4(int *dataLen)                   { if (dataLen) *dataLen = 0; return nullptr; }
static void hook_AnoSDKDelReportData(void *data)  { if (orig_AnoSDKDelReportData  && data) orig_AnoSDKDelReportData(data);  }
static void hook_AnoSDKDelReportData3(void *data) { if (orig_AnoSDKDelReportData3 && data) orig_AnoSDKDelReportData3(data); }
static void hook_AnoSDKDelReportData4(void *data) { if (orig_AnoSDKDelReportData4 && data) orig_AnoSDKDelReportData4(data); }
static void hook_AnoSDKFree(void *ptr)            { if (orig_AnoSDKFree && ptr) orig_AnoSDKFree(ptr); }
static int hook_AnoSDKRegistInfoListener(void *listener)               { return 0; }

// ─── Install ─────────────────────────────────────────────────────────────────

void AnoSDKBypassInstall(void) {
    struct rebinding bindings[] = {
        { "AnoSDKInit",                   (void *)hook_AnoSDKInit,                   (void **)&orig_AnoSDKInit                   },
        { "AnoSDKInitEx",                 (void *)hook_AnoSDKInitEx,                 (void **)&orig_AnoSDKInitEx                 },
        { "AnoSDKSetUserInfo",            (void *)hook_AnoSDKSetUserInfo,            (void **)&orig_AnoSDKSetUserInfo            },
        { "AnoSDKSetUserInfoWithLicense", (void *)hook_AnoSDKSetUserInfoWithLicense, (void **)&orig_AnoSDKSetUserInfoWithLicense },
        { "AnoSDKIoctl",                  (void *)hook_AnoSDKIoctl,                  (void **)&orig_AnoSDKIoctl                  },
        { "AnoSDKIoctlOld",               (void *)hook_AnoSDKIoctlOld,               (void **)&orig_AnoSDKIoctlOld               },
        { "AnoSDKOnPause",                (void *)hook_AnoSDKOnPause,                (void **)&orig_AnoSDKOnPause                },
        { "AnoSDKOnResume",               (void *)hook_AnoSDKOnResume,               (void **)&orig_AnoSDKOnResume               },
        { "AnoSDKOnRecvData",             (void *)hook_AnoSDKOnRecvData,             (void **)&orig_AnoSDKOnRecvData             },
        { "AnoSDKOnRecvSignature",        (void *)hook_AnoSDKOnRecvSignature,        (void **)&orig_AnoSDKOnRecvSignature        },
        { "AnoSDKGetReportData",          (void *)hook_AnoSDKGetReportData,          (void **)&orig_AnoSDKGetReportData          },
        { "AnoSDKGetReportData2",         (void *)hook_AnoSDKGetReportData2,         (void **)&orig_AnoSDKGetReportData2         },
        { "AnoSDKGetReportData3",         (void *)hook_AnoSDKGetReportData3,         (void **)&orig_AnoSDKGetReportData3         },
        { "AnoSDKGetReportData4",         (void *)hook_AnoSDKGetReportData4,         (void **)&orig_AnoSDKGetReportData4         },
        { "AnoSDKDelReportData",          (void *)hook_AnoSDKDelReportData,          (void **)&orig_AnoSDKDelReportData          },
        { "AnoSDKDelReportData3",         (void *)hook_AnoSDKDelReportData3,         (void **)&orig_AnoSDKDelReportData3         },
        { "AnoSDKDelReportData4",         (void *)hook_AnoSDKDelReportData4,         (void **)&orig_AnoSDKDelReportData4         },
        { "AnoSDKFree",                   (void *)hook_AnoSDKFree,                   (void **)&orig_AnoSDKFree                   },
        { "AnoSDKRegistInfoListener",     (void *)hook_AnoSDKRegistInfoListener,     (void **)&orig_AnoSDKRegistInfoListener     },
    };
    rebind_symbols(bindings, sizeof(bindings) / sizeof(bindings[0]));
}

// ─── Auto-install ─────────────────────────────────────────────────────────────

@interface AnoSDKBypassLoader : NSObject
@end

@implementation AnoSDKBypassLoader

+ (void)load {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        // Background thread'de çalıştır — +load ana thread'i bloklamamalı
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            // anogs.framework yüklenene kadar bekle
            for (int i = 0; i < 50; i++) {
                uint32_t count = _dyld_image_count();
                for (uint32_t j = 0; j < count; j++) {
                    const char *name = _dyld_get_image_name(j);
                    if (name && strstr(name, "anogs")) {
                        // Framework yüklendi, hook'ları kur
                        dispatch_async(dispatch_get_main_queue(), ^{
                            AnoSDKBypassInstall();
                        });
                        return;
                    }
                }
                // 100ms bekle, tekrar dene
                usleep(100000);
            }
        });
    });
}

@end
