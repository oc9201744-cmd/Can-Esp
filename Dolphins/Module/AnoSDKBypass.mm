#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <objc/runtime.h>
#include <dlfcn.h>
#include <mach-o/dyld.h>
#include "fishhook.h"

// ─────────────────────────────────────────────────────────────────────────────
// AnoSDKBypass.mm
// 1. AnoSDK fonksiyonları → fishhook ile bypass
// 2. PluginTssSDKLifecycle → ObjC swizzle ile durdur (no Dobby)
// 3. AceMsgBoxImp → ban popup'ını gizle
// ─────────────────────────────────────────────────────────────────────────────

// ─── AnoSDK Typedefs ──────────────────────────────────────────────────────────

typedef int   (*AnoSDKInit_t)(void *);
typedef int   (*AnoSDKInitEx_t)(void *, int);
typedef int   (*AnoSDKSetUserInfo_t)(const char *, int, int, int, int, int, int);
typedef int   (*AnoSDKSetUserInfoWithLicense_t)(const char *, int, int, int, int, int, int, const char *);
typedef int   (*AnoSDKIoctl_t)(int, const void *, int);
typedef int   (*AnoSDKIoctlOld_t)(int, const void *, int);
typedef int   (*AnoSDKOnPause_t)(void);
typedef int   (*AnoSDKOnResume_t)(void);
typedef int   (*AnoSDKOnRecvData_t)(const void *, int);
typedef int   (*AnoSDKOnRecvSignature_t)(const void *, int);
typedef void *(*AnoSDKGetReportData_t)(int *);
typedef void *(*AnoSDKGetReportData2_t)(int *);
typedef void *(*AnoSDKGetReportData3_t)(int *);
typedef void *(*AnoSDKGetReportData4_t)(int *);
typedef void  (*AnoSDKDelReportData_t)(void *);
typedef void  (*AnoSDKDelReportData3_t)(void *);
typedef void  (*AnoSDKDelReportData4_t)(void *);
typedef void  (*AnoSDKFree_t)(void *);
typedef int   (*AnoSDKRegistInfoListener_t)(void *);

// ─── Original Pointers ───────────────────────────────────────────────────────

static AnoSDKDelReportData_t  orig_AnoSDKDelReportData  = nullptr;
static AnoSDKDelReportData3_t orig_AnoSDKDelReportData3 = nullptr;
static AnoSDKDelReportData4_t orig_AnoSDKDelReportData4 = nullptr;
static AnoSDKFree_t           orig_AnoSDKFree           = nullptr;

// ─── AnoSDK Hooks ─────────────────────────────────────────────────────────────

static int   h_AnoSDKInit(void *a)                                               { return 0; }
static int   h_AnoSDKInitEx(void *a, int b)                                      { return 0; }
static int   h_AnoSDKSetUserInfo(const char *a, int b, int c, int d, int e, int f, int g) { return 0; }
static int   h_AnoSDKSetUserInfoWithLicense(const char *a, int b, int c, int d, int e, int f, int g, const char *h) { return 0; }
static int   h_AnoSDKIoctl(int a, const void *b, int c)                          { return 0; }
static int   h_AnoSDKIoctlOld(int a, const void *b, int c)                       { return 0; }
static int   h_AnoSDKOnPause(void)                                               { return 0; }
static int   h_AnoSDKOnResume(void)                                              { return 0; }
static int   h_AnoSDKOnRecvData(const void *a, int b)                            { return 0; }
static int   h_AnoSDKOnRecvSignature(const void *a, int b)                       { return 0; }
static void *h_AnoSDKGetReportData(int *l)                                       { if (l) *l = 0; return nullptr; }
static void *h_AnoSDKGetReportData2(int *l)                                      { if (l) *l = 0; return nullptr; }
static void *h_AnoSDKGetReportData3(int *l)                                      { if (l) *l = 0; return nullptr; }
static void *h_AnoSDKGetReportData4(int *l)                                      { if (l) *l = 0; return nullptr; }
static void  h_AnoSDKDelReportData(void *p)  { if (orig_AnoSDKDelReportData  && p) orig_AnoSDKDelReportData(p);  }
static void  h_AnoSDKDelReportData3(void *p) { if (orig_AnoSDKDelReportData3 && p) orig_AnoSDKDelReportData3(p); }
static void  h_AnoSDKDelReportData4(void *p) { if (orig_AnoSDKDelReportData4 && p) orig_AnoSDKDelReportData4(p); }
static void  h_AnoSDKFree(void *p)           { if (orig_AnoSDKFree && p) orig_AnoSDKFree(p); }
static int   h_AnoSDKRegistInfoListener(void *a)                                 { return 0; }

// ─── ObjC Swizzle Helper ──────────────────────────────────────────────────────

static void swizzle(Class cls, SEL original, SEL replacement) {
    Method origMethod = class_getInstanceMethod(cls, original);
    Method replMethod = class_getInstanceMethod(cls, replacement);
    if (origMethod && replMethod)
        method_exchangeImplementations(origMethod, replMethod);
}

static void swizzleClass(Class cls, SEL original, SEL replacement) {
    Method origMethod = class_getClassMethod(cls, original);
    Method replMethod = class_getClassMethod(cls, replacement);
    if (origMethod && replMethod)
        method_exchangeImplementations(origMethod, replMethod);
}

// ─── PluginTssSDKLifecycle Swizzle ───────────────────────────────────────────
// AceTss lifecycle metodlarını no-op yap

@interface PluginTssSDKLifecycle : NSObject
@end

@interface PluginTssSDKLifecycle (Bypass)
- (void)bypass_applicationDidFinishLaunching:(id)app options:(id)opts;
- (void)bypass_applicationDidBecomeActive:(id)app;
- (void)bypass_applicationWillResignActive:(id)app;
- (void)bypass_applicationDidEnterBackground:(id)app;
- (void)bypass_applicationWillEnterForeground:(id)app;
- (void)bypass_applicationWillTerminate:(id)app;
@end

@implementation PluginTssSDKLifecycle (Bypass)

- (void)bypass_applicationDidFinishLaunching:(id)app options:(id)opts { /* no-op */ }
- (void)bypass_applicationDidBecomeActive:(id)app                     { /* no-op */ }
- (void)bypass_applicationWillResignActive:(id)app                    { /* no-op */ }
- (void)bypass_applicationDidEnterBackground:(id)app                  { /* no-op */ }
- (void)bypass_applicationWillEnterForeground:(id)app                 { /* no-op */ }
- (void)bypass_applicationWillTerminate:(id)app                       { /* no-op */ }

@end

// ─── AceMsgBoxImp Swizzle ────────────────────────────────────────────────────
// Ban/uyarı popup'larını gizle

@interface AceMsgBoxImp : NSObject
@end

@interface AceMsgBoxImp (Bypass)
- (void)bypass_showMsgBox:(id)msg;
- (void)bypass_showAlertView:(id)msg;
@end

@implementation AceMsgBoxImp (Bypass)
- (void)bypass_showMsgBox:(id)msg    { /* no-op */ }
- (void)bypass_showAlertView:(id)msg { /* no-op */ }
@end

// ─── Swizzle Install ─────────────────────────────────────────────────────────

static void installObjCSwizzles(void) {
    Class tssClass = NSClassFromString(@"PluginTssSDKLifecycle");
    if (tssClass) {
        swizzle(tssClass,
            @selector(application:didFinishLaunchingWithOptions:),
            @selector(bypass_applicationDidFinishLaunching:options:));
        swizzle(tssClass,
            @selector(applicationDidBecomeActive:),
            @selector(bypass_applicationDidBecomeActive:));
        swizzle(tssClass,
            @selector(applicationWillResignActive:),
            @selector(bypass_applicationWillResignActive:));
        swizzle(tssClass,
            @selector(applicationDidEnterBackground:),
            @selector(bypass_applicationDidEnterBackground:));
        swizzle(tssClass,
            @selector(applicationWillEnterForeground:),
            @selector(bypass_applicationWillEnterForeground:));
        swizzle(tssClass,
            @selector(applicationWillTerminate:),
            @selector(bypass_applicationWillTerminate:));
    }

    Class aceBox = NSClassFromString(@"AceMsgBoxImp");
    if (aceBox) {
        swizzle(aceBox, @selector(showMsgBox:),    @selector(bypass_showMsgBox:));
        swizzle(aceBox, @selector(showAlertView:), @selector(bypass_showAlertView:));
    }
}

// ─── fishhook Install ────────────────────────────────────────────────────────

static void installFishHooks(void) {
    static AnoSDKInit_t                   o1  = nullptr;
    static AnoSDKInitEx_t                 o2  = nullptr;
    static AnoSDKSetUserInfo_t            o3  = nullptr;
    static AnoSDKSetUserInfoWithLicense_t o4  = nullptr;
    static AnoSDKIoctl_t                  o5  = nullptr;
    static AnoSDKIoctlOld_t               o6  = nullptr;
    static AnoSDKOnPause_t                o7  = nullptr;
    static AnoSDKOnResume_t               o8  = nullptr;
    static AnoSDKOnRecvData_t             o9  = nullptr;
    static AnoSDKOnRecvSignature_t        o10 = nullptr;
    static AnoSDKGetReportData_t          o11 = nullptr;
    static AnoSDKGetReportData2_t         o12 = nullptr;
    static AnoSDKGetReportData3_t         o13 = nullptr;
    static AnoSDKGetReportData4_t         o14 = nullptr;
    static AnoSDKRegistInfoListener_t     o19 = nullptr;

    struct rebinding b[] = {
        { "AnoSDKInit",                   (void *)h_AnoSDKInit,                   (void **)&o1  },
        { "AnoSDKInitEx",                 (void *)h_AnoSDKInitEx,                 (void **)&o2  },
        { "AnoSDKSetUserInfo",            (void *)h_AnoSDKSetUserInfo,            (void **)&o3  },
        { "AnoSDKSetUserInfoWithLicense", (void *)h_AnoSDKSetUserInfoWithLicense, (void **)&o4  },
        { "AnoSDKIoctl",                  (void *)h_AnoSDKIoctl,                  (void **)&o5  },
        { "AnoSDKIoctlOld",               (void *)h_AnoSDKIoctlOld,               (void **)&o6  },
        { "AnoSDKOnPause",                (void *)h_AnoSDKOnPause,                (void **)&o7  },
        { "AnoSDKOnResume",               (void *)h_AnoSDKOnResume,               (void **)&o8  },
        { "AnoSDKOnRecvData",             (void *)h_AnoSDKOnRecvData,             (void **)&o9  },
        { "AnoSDKOnRecvSignature",        (void *)h_AnoSDKOnRecvSignature,        (void **)&o10 },
        { "AnoSDKGetReportData",          (void *)h_AnoSDKGetReportData,          (void **)&o11 },
        { "AnoSDKGetReportData2",         (void *)h_AnoSDKGetReportData2,         (void **)&o12 },
        { "AnoSDKGetReportData3",         (void *)h_AnoSDKGetReportData3,         (void **)&o13 },
        { "AnoSDKGetReportData4",         (void *)h_AnoSDKGetReportData4,         (void **)&o14 },
        { "AnoSDKDelReportData",          (void *)h_AnoSDKDelReportData,          (void **)&orig_AnoSDKDelReportData  },
        { "AnoSDKDelReportData3",         (void *)h_AnoSDKDelReportData3,         (void **)&orig_AnoSDKDelReportData3 },
        { "AnoSDKDelReportData4",         (void *)h_AnoSDKDelReportData4,         (void **)&orig_AnoSDKDelReportData4 },
        { "AnoSDKFree",                   (void *)h_AnoSDKFree,                   (void **)&orig_AnoSDKFree           },
        { "AnoSDKRegistInfoListener",     (void *)h_AnoSDKRegistInfoListener,     (void **)&o19 },
    };
    rebind_symbols(b, sizeof(b) / sizeof(b[0]));
}

// ─── Main Install ─────────────────────────────────────────────────────────────

void AnoSDKBypassInstall(void) {
    // 1. fishhook — anında kur (GOT tablosu)
    installFishHooks();

    // 2. ObjC swizzle — framework yüklenince kur
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (int i = 0; i < 100; i++) {
            if (NSClassFromString(@"PluginTssSDKLifecycle")) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    installObjCSwizzles();
                });
                return;
            }
            usleep(50000); // 50ms
        }
    });
}

// ─── Auto-install ─────────────────────────────────────────────────────────────

@interface AnoSDKBypassLoader : NSObject
@end

@implementation AnoSDKBypassLoader

+ (void)load {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        AnoSDKBypassInstall();
    });
}

@end