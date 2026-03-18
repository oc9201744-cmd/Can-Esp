#import <Foundation/Foundation.h>
#include <dlfcn.h>
#include <mach-o/dyld.h>
#include "fishhook.h"

static void (*orig_Del)(void *)  = nullptr;
static void (*orig_Del3)(void *) = nullptr;
static void (*orig_Del4)(void *) = nullptr;
static void (*orig_Free)(void *) = nullptr;

static int   h_Init(void *a)                                                               { return 0; }
static int   h_InitEx(void *a, int b)                                                      { return 0; }
static int   h_SetUserInfo(const char *a,int b,int c,int d,int e,int f,int g)              { return 0; }
static int   h_SetUserInfoLic(const char *a,int b,int c,int d,int e,int f,int g,const char *h) { return 0; }
static int   h_Ioctl(int a, const void *b, int c)                                          { return 0; }
static int   h_IoctlOld(int a, const void *b, int c)                                       { return 0; }
static int   h_OnPause(void)                                                               { return 0; }
static int   h_OnResume(void)                                                              { return 0; }
static int   h_OnRecvData(const void *a, int b)                                            { return 0; }
static int   h_OnRecvSig(const void *a, int b)                                             { return 0; }
static void *h_GetReport(int *l)  { if (l) *l = 0; return nullptr; }
static void *h_GetReport2(int *l) { if (l) *l = 0; return nullptr; }
static void *h_GetReport3(int *l) { if (l) *l = 0; return nullptr; }
static void *h_GetReport4(int *l) { if (l) *l = 0; return nullptr; }
static void  h_Del(void *p)  { if (orig_Del  && p) orig_Del(p);  }
static void  h_Del3(void *p) { if (orig_Del3 && p) orig_Del3(p); }
static void  h_Del4(void *p) { if (orig_Del4 && p) orig_Del4(p); }
static void  h_Free(void *p) { if (orig_Free && p) orig_Free(p); }
static int   h_RegListener(void *a) { return 0; }

@interface AnoSDKBypassLoader : NSObject
@end

@implementation AnoSDKBypassLoader

+ (void)load {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        static void *o1,*o2,*o3,*o4,*o5,*o6,*o7,*o8,*o9,*o10,*o11,*o12,*o13,*o14,*o19;
        struct rebinding b[] = {
            { "AnoSDKInit",                   (void *)h_Init,           &o1  },
            { "AnoSDKInitEx",                 (void *)h_InitEx,         &o2  },
            { "AnoSDKSetUserInfo",            (void *)h_SetUserInfo,    &o3  },
            { "AnoSDKSetUserInfoWithLicense", (void *)h_SetUserInfoLic, &o4  },
            { "AnoSDKIoctl",                  (void *)h_Ioctl,          &o5  },
            { "AnoSDKIoctlOld",               (void *)h_IoctlOld,       &o6  },
            { "AnoSDKOnPause",                (void *)h_OnPause,        &o7  },
            { "AnoSDKOnResume",               (void *)h_OnResume,       &o8  },
            { "AnoSDKOnRecvData",             (void *)h_OnRecvData,     &o9  },
            { "AnoSDKOnRecvSignature",        (void *)h_OnRecvSig,      &o10 },
            { "AnoSDKGetReportData",          (void *)h_GetReport,      &o11 },
            { "AnoSDKGetReportData2",         (void *)h_GetReport2,     &o12 },
            { "AnoSDKGetReportData3",         (void *)h_GetReport3,     &o13 },
            { "AnoSDKGetReportData4",         (void *)h_GetReport4,     &o14 },
            { "AnoSDKDelReportData",          (void *)h_Del,  (void **)&orig_Del  },
            { "AnoSDKDelReportData3",         (void *)h_Del3, (void **)&orig_Del3 },
            { "AnoSDKDelReportData4",         (void *)h_Del4, (void **)&orig_Del4 },
            { "AnoSDKFree",                   (void *)h_Free, (void **)&orig_Free },
            { "AnoSDKRegistInfoListener",     (void *)h_RegListener,    &o19 },
        };
        rebind_symbols(b, sizeof(b) / sizeof(b[0]));
    });
}

@end