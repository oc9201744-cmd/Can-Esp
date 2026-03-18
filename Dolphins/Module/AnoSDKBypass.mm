#import <Foundation/Foundation.h>
#include "fishhook.h"

struct AnoSDKInitInfo {
    int   size_;
    int   game_id_;
    void *tss_sdk_send_data_to_svr;
};

static int fakeSend(void *data, int len) { return 0; }

static int (*orig_Init)(AnoSDKInitInfo *)        = nullptr;
static int (*orig_InitEx)(AnoSDKInitInfo *, int) = nullptr;
static void (*orig_Del)(void *)                  = nullptr;
static void (*orig_Del3)(void *)                 = nullptr;
static void (*orig_Del4)(void *)                 = nullptr;
static void (*orig_Free)(void *)                 = nullptr;

static int h_Init(AnoSDKInitInfo *info) {
    if (info) info->tss_sdk_send_data_to_svr = (void *)fakeSend;
    return orig_Init ? orig_Init(info) : 0;
}
static int h_InitEx(AnoSDKInitInfo *info, int flags) {
    if (info) info->tss_sdk_send_data_to_svr = (void *)fakeSend;
    return orig_InitEx ? orig_InitEx(info, flags) : 0;
}
static int   h_SUI(const char *a,int b,int c,int d,int e,int f,int g)                  { return 0; }
static int   h_SUIL(const char *a,int b,int c,int d,int e,int f,int g,const char *h)   { return 0; }
static int   h_Ioctl(int a, const void *b, int c)                                      { return 0; }
static int   h_IoctlOld(int a, const void *b, int c)                                   { return 0; }
static int   h_Pause(void)                                                             { return 0; }
static int   h_Resume(void)                                                            { return 0; }
static int   h_RecvData(const void *a, int b)                                          { return 0; }
static int   h_RecvSig(const void *a, int b)                                           { return 0; }
static void *h_GRD(int *l)  { if (l) *l = 0; return nullptr; }
static void *h_GRD2(int *l) { if (l) *l = 0; return nullptr; }
static void *h_GRD3(int *l) { if (l) *l = 0; return nullptr; }
static void *h_GRD4(int *l) { if (l) *l = 0; return nullptr; }
static void  h_Del(void *p)  { if (orig_Del  && p) orig_Del(p);  }
static void  h_Del3(void *p) { if (orig_Del3 && p) orig_Del3(p); }
static void  h_Del4(void *p) { if (orig_Del4 && p) orig_Del4(p); }
static void  h_Free(void *p) { if (orig_Free && p) orig_Free(p); }
static int   h_Reg(void *a)  { return 0; }

void AnoSDKBypassInstall(void) {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        static void *_1,*_2,*_3,*_4,*_5,*_6,*_7,*_8,*_9,*_10,*_11,*_12,*_13;
        struct rebinding b[] = {
            {"AnoSDKInit",                   (void*)h_Init,    (void**)&orig_Init  },
            {"AnoSDKInitEx",                 (void*)h_InitEx,  (void**)&orig_InitEx},
            {"AnoSDKSetUserInfo",            (void*)h_SUI,     &_1 },
            {"AnoSDKSetUserInfoWithLicense", (void*)h_SUIL,    &_2 },
            {"AnoSDKIoctl",                  (void*)h_Ioctl,   &_3 },
            {"AnoSDKIoctlOld",               (void*)h_IoctlOld,&_4 },
            {"AnoSDKOnPause",                (void*)h_Pause,   &_5 },
            {"AnoSDKOnResume",               (void*)h_Resume,  &_6 },
            {"AnoSDKOnRecvData",             (void*)h_RecvData,&_7 },
            {"AnoSDKOnRecvSignature",        (void*)h_RecvSig, &_8 },
            {"AnoSDKGetReportData",          (void*)h_GRD,     &_9 },
            {"AnoSDKGetReportData2",         (void*)h_GRD2,    &_10},
            {"AnoSDKGetReportData3",         (void*)h_GRD3,    &_11},
            {"AnoSDKGetReportData4",         (void*)h_GRD4,    &_12},
            {"AnoSDKDelReportData",          (void*)h_Del,     (void**)&orig_Del  },
            {"AnoSDKDelReportData3",         (void*)h_Del3,    (void**)&orig_Del3 },
            {"AnoSDKDelReportData4",         (void*)h_Del4,    (void**)&orig_Del4 },
            {"AnoSDKFree",                   (void*)h_Free,    (void**)&orig_Free },
            {"AnoSDKRegistInfoListener",     (void*)h_Reg,     &_13},
        };
        rebind_symbols(b, sizeof(b)/sizeof(b[0]));
    });
}

@interface AnoSDKBypassLoader : NSObject
@end
@implementation AnoSDKBypassLoader
+ (void)load { AnoSDKBypassInstall(); }
@end