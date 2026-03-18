#import <Foundation/Foundation.h>
#include "KittyMemory.hpp"

// ─────────────────────────────────────────────────────────────────────────────
// AnoSDKBypass.mm — KittyMemory ile
// Offset'ler binary analizinden doğrulandı (anogs.framework)
// RET0 = MOV W0,#0 + RET → fonksiyon 0 döner, hiçbir şey yapmaz
// ─────────────────────────────────────────────────────────────────────────────

// Verified offsets from export trie:
#define OFF_AnoSDKInit                   0xf0fd0
#define OFF_AnoSDKInitEx                 0xf0ffc
#define OFF_AnoSDKSetUserInfo            0xf1000
#define OFF_AnoSDKSetUserInfoWithLicense 0xf104c
#define OFF_AnoSDKOnPause                0xf109c
#define OFF_AnoSDKOnResume               0xf10bc
#define OFF_AnoSDKGetReportData          0xf10dc
#define OFF_AnoSDKDelReportData          0xf10f8
#define OFF_AnoSDKGetReportData2         0xf1174
#define OFF_AnoSDKFree                   0xf1170
#define OFF_AnoSDKIoctlOld               0xf1168
#define OFF_AnoSDKIoctl                  0xf116c
#define OFF_AnoSDKOnRecvData             0xf1114
#define OFF_AnoSDKGetReportData3         0xf1178
#define OFF_AnoSDKDelReportData3         0xf117c
#define OFF_AnoSDKGetReportData4         0xf1180
#define OFF_AnoSDKDelReportData4         0xf1184
#define OFF_AnoSDKOnRecvSignature        0xf1188
#define OFF_AnoSDKRegistInfoListener     0xf118c

void AnoSDKBypassInstall(void) {
    static dispatch_once_t once;
    dispatch_once(&once, ^{

        // anogs.framework ASLR slide
        uintptr_t slide = KittyMemory::getSlide("anogs");

        // int dönen fonksiyonlar → RET0 (return 0)
        uintptr_t intFuncs[] = {
            OFF_AnoSDKInit,
            OFF_AnoSDKInitEx,
            OFF_AnoSDKSetUserInfo,
            OFF_AnoSDKSetUserInfoWithLicense,
            OFF_AnoSDKOnPause,
            OFF_AnoSDKOnResume,
            OFF_AnoSDKDelReportData,
            OFF_AnoSDKDelReportData3,
            OFF_AnoSDKDelReportData4,
            OFF_AnoSDKIoctlOld,
            OFF_AnoSDKIoctl,
            OFF_AnoSDKOnRecvData,
            OFF_AnoSDKOnRecvSignature,
            OFF_AnoSDKRegistInfoListener,
        };

        for (uintptr_t off : intFuncs)
            KittyMemory::patchRet0(slide + off);

        // void* dönen fonksiyonlar → RETNULL (return nullptr)
        uintptr_t ptrFuncs[] = {
            OFF_AnoSDKGetReportData,
            OFF_AnoSDKGetReportData2,
            OFF_AnoSDKGetReportData3,
            OFF_AnoSDKGetReportData4,
        };

        for (uintptr_t off : ptrFuncs)
            KittyMemory::patchRetNull(slide + off);

        // AnoSDKFree — NOP yap (memory'yi serbest bırakmak için orijinali çağır olmaz,
        // çünkü zaten bypass yapıyoruz ve GetReportData nullptr dönüyor)
        KittyMemory::patchNop(slide + OFF_AnoSDKFree);
    });
}

@interface AnoSDKBypassLoader : NSObject
@end

@implementation AnoSDKBypassLoader
+ (void)load {
    AnoSDKBypassInstall();
}
@end