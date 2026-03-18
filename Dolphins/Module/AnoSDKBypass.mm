#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <objc/runtime.h>
#include <dlfcn.h>
#include <mach-o/dyld.h>
#include "fishhook.h"

// ─────────────────────────────────────────────────────────────────────────────
// AnoSDKBypass.mm
// 1. AnoSDK fonksiyonları → fishhook
// 2. PluginTssSDKLifecycle + AceMsgBoxImp → pure runtime swizzle (linker yok)
// ─────────────────────────────────────────────────────────────────────────────

// ─── AnoSDK Typedefs ──────────────────────────────────────────────────────────

typedef int   (*AnoSDKDelReportData_t)(void *);
typedef int   (*AnoSDKDelReportData3_t)(void *);
typedef int   (*AnoSDKDelReportData4_t)(void *);
typedef void  (*AnoSDKFree_t)(void *);

static AnoSDKDelReportData_t  orig_AnoSDKDelReportData  = nullptr;
static AnoSDKDelReportData3_t orig_AnoSDKDelReportData3 = nullptr;
static AnoSDKDelReportData4_t orig_AnoSDKDelReportData4 = nullptr;
static AnoSDKFree_t           orig_AnoSDKFree           = nullptr;

// ─── AnoSDK Hooks ─────────────────────────────────────────────────────────────

static int   h_AnoSDKInit(void *a)                                                        { return 0; }
static int   h_AnoSDKInitEx(void *a, int b)                                               { return 0; }
static int   h_AnoSDKSetUserInfo(const char *a, int b, int c, int d, int e, int f, int g) { return 0; }
static int   h_AnoSDKSetUserInfoWithLicense(const char *a, int b, int c, int d, int e, int f, int g, const char *h) { return 0; }
static int   h_AnoSDKIoctl(int a, const void *b, int c)                                   { return 0; }
static int   h_AnoSDKIoctlOld(int a, const void *b, int c)                                { return 0; }
static int   h_AnoSDKOnPause(void)                                                        { return 0; }
static int   h_AnoSDKOnResume(void)                                                       { return 0; }
static int   h_AnoSDKOnRecvData(const void *a, int b)                                     { return 0; }
static int   h_AnoSDKOnRecvSignature(const void *a, int b)                                { return 0; }
static void *h_AnoSDKGetReportData(int *l)   { if (l) *l = 0; return nullptr; }
static void *h_AnoSDKGetReportData2(int *l)  { if (l) *l = 0; return nullptr; }
static void *h_AnoSDKGetReportData3(int *l)  { if (l) *l = 0; return nullptr; }
static void *h_AnoSDKGetReportData4(int *l)  { if (l) *l = 0; return nullptr; }
static void  h_AnoSDKDelReportData(void *p)  { if (orig_AnoSDKDelReportData  && p) orig_AnoSDKDelReportData(p);  }
static void  h_AnoSDKDelReportData3(void *p) { if (orig_AnoSDKDelReportData3 && p) orig_AnoSDKDelReportData3(p); }
static void  h_AnoSDKDelReportData4(void *p) { if (orig_AnoSDKDelReportData4 && p) orig_AnoSDKDelReportData4(p); }
static void  h_AnoSDKFree(void *p)           { if (orig_AnoSDKFree && p) orig_AnoSDKFree(p); }
static int   h_AnoSDKRegistInfoListener(void *a) { return 0; }

// ─── fishhook Install ────────────────────────────────────────────────────────

static void installFishHooks(void) {
    static void *o1,*o2,*o3,*o4,*o5,*o6,*o7,*o8,*o9,*o10,*o11,*o12,*o13,*o14,*o19;

    struct rebinding b[] = {
        { "AnoSDKInit",                   (void *)h_AnoSDKInit,                   &o1  },
        { "AnoSDKInitEx",                 (void *)h_AnoSDKInitEx,                 &o2  },
        { "AnoSDKSetUserInfo",            (void *)h_AnoSDKSetUserInfo,            &o3  },
        { "AnoSDKSetUserInfoWithLicense", (void *)h_AnoSDKSetUserInfoWithLicense, &o4  },
        { "AnoSDKIoctl",                  (void *)h_AnoSDKIoctl,                  &o5  },
        { "AnoSDKIoctlOld",               (void *)h_AnoSDKIoctlOld,               &o6  },
        { "AnoSDKOnPause",                (void *)h_AnoSDKOnPause,                &o7  },
        { "AnoSDKOnResume",               (void *)h_AnoSDKOnResume,               &o8  },
        { "AnoSDKOnRecvData",             (void *)h_AnoSDKOnRecvData,             &o9  },
        { "AnoSDKOnRecvSignature",        (void *)h_AnoSDKOnRecvSignature,        &o10 },
        { "AnoSDKGetReportData",          (void *)h_AnoSDKGetReportData,          &o11 },
        { "AnoSDKGetReportData2",         (void *)h_AnoSDKGetReportData2,         &o12 },
        { "AnoSDKGetReportData3",         (void *)h_AnoSDKGetReportData3,         &o13 },
        { "AnoSDKGetReportData4",         (void *)h_AnoSDKGetReportData4,         &o14 },
        { "AnoSDKDelReportData",          (void *)h_AnoSDKDelReportData,          (void **)&orig_AnoSDKDelReportData  },
        { "AnoSDKDelReportData3",         (void *)h_AnoSDKDelReportData3,         (void **)&orig_AnoSDKDelReportData3 },
        { "AnoSDKDelReportData4",         (void *)h_AnoSDKDelReportData4,         (void **)&orig_AnoSDKDelReportData4 },
        { "AnoSDKFree",                   (void *)h_AnoSDKFree,                   (void **)&orig_AnoSDKFree           },
        { "AnoSDKRegistInfoListener",     (void *)h_AnoSDKRegistInfoListener,     &o19 },
    };
    rebind_symbols(b, sizeof(b) / sizeof(b[0]));
}

// ─── ObjC Runtime Swizzle ────────────────────────────────────────────────────
// Category yok — linker hatası yok
// method_setImplementation ile direkt no-op IMP yazıyoruz

static void noop_1arg(id self, SEL _cmd, id a)         { }
static void noop_2arg(id self, SEL _cmd, id a, id b)   { }

static void installObjCSwizzles(void) {
    // ── PluginTssSDKLifecycle ─────────────────────────────────────────────
    Class tss = NSClassFromString(@"PluginTssSDKLifecycle");
    if (tss) {
        SEL sel1[] = {
            @selector(applicationDidBecomeActive:),
            @selector(applicationWillResignActive:),
            @selector(applicationDidEnterBackground:),
            @selector(applicationWillEnterForeground:),
            @selector(applicationWillTerminate:),
        };
        for (int i = 0; i < 5; i++) {
            Method m = class_getInstanceMethod(tss, sel1[i]);
            if (m) method_setImplementation(m, (IMP)noop_1arg);
        }
        // application:didFinishLaunchingWithOptions: 2 argüman
        Method m2 = class_getInstanceMethod(tss,
            @selector(application:didFinishLaunchingWithOptions:));
        if (m2) method_setImplementation(m2, (IMP)noop_2arg);
    }

    // ── AceMsgBoxImp ─────────────────────────────────────────────────────
    Class box = NSClassFromString(@"AceMsgBoxImp");
    if (box) {
        SEL sel2[] = {
            @selector(showMsgBox:),
            @selector(showAlertView:),
        };
        for (int i = 0; i < 2; i++) {
            Method m = class_getInstanceMethod(box, sel2[i]);
            if (m) method_setImplementation(m, (IMP)noop_1arg);
        }
    }
}

// ─── Main Install ─────────────────────────────────────────────────────────────

void AnoSDKBypassInstall(void) {
    // fishhook anında kur
    installFishHooks();

    // ObjC swizzle — PluginTssSDKLifecycle yüklenince
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (int i = 0; i < 100; i++) {
            if (NSClassFromString(@"PluginTssSDKLifecycle")) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    installObjCSwizzles();
                });
                return;
            }
            usleep(50000);
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
