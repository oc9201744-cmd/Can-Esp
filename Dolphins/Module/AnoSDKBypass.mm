#import <Foundation/Foundation.h>
#include <dlfcn.h>
#include <mach-o/dyld.h>
#include <string.h>
#include "fishhook.h"

// ─────────────────────────────────────────────────────────────────────────────
// AnoSDKBypass.mm
// Sorun: black_module_macho dylib ismimizi görüyor → ban
// Çözüm: __attribute__((constructor)) ile AnoSDK'dan ÖNCE
//         _dyld_image_count / _dyld_get_image_name hook'la → dylib'i gizle
// ─────────────────────────────────────────────────────────────────────────────

// ─── Gizlenecek dylib isimleri ───────────────────────────────────────────────
// Kendi tweak adını buraya yaz
static const char *kHidden[] = {
    "Blackshark",
    "blackshark",
    "TweakInject",
    "MobileSubstrate",
    "CydiaSubstrate",
    "substitute",
    nullptr
};

static bool shouldHide(const char *name) {
    if (!name) return false;
    for (int i = 0; kHidden[i]; i++)
        if (strstr(name, kHidden[i])) return true;
    return false;
}

// ─── dyld Hook originals ──────────────────────────────────────────────────────

static uint32_t           (*orig_image_count)(void)                   = nullptr;
static const char        *(*orig_image_name)(uint32_t)                = nullptr;
static const mach_header *(*orig_image_header)(uint32_t)              = nullptr;
static intptr_t           (*orig_image_slide)(uint32_t)               = nullptr;

// fake index → real index (gizli image'leri atla)
static uint32_t toReal(uint32_t fake) {
    uint32_t real = orig_image_count();
    uint32_t vis = 0;
    for (uint32_t i = 0; i < real; i++) {
        if (shouldHide(orig_image_name(i))) continue;
        if (vis == fake) return i;
        vis++;
    }
    return fake;
}

static uint32_t hook_image_count(void) {
    if (!orig_image_count) return _dyld_image_count();
    uint32_t n = 0;
    uint32_t real = orig_image_count();
    for (uint32_t i = 0; i < real; i++)
        if (!shouldHide(orig_image_name(i))) n++;
    return n;
}

static const char *hook_image_name(uint32_t idx) {
    if (!orig_image_name) return _dyld_get_image_name(idx);
    return orig_image_name(toReal(idx));
}

static const mach_header *hook_image_header(uint32_t idx) {
    if (!orig_image_header) return _dyld_get_image_header(idx);
    return orig_image_header(toReal(idx));
}

static intptr_t hook_image_slide(uint32_t idx) {
    if (!orig_image_slide) return _dyld_get_image_vmaddr_slide(idx);
    return orig_image_slide(toReal(idx));
}

// ─── AnoSDK Hooks ─────────────────────────────────────────────────────────────

static void (*orig_Del)(void *)  = nullptr;
static void (*orig_Del3)(void *) = nullptr;
static void (*orig_Del4)(void *) = nullptr;
static void (*orig_Free)(void *) = nullptr;

static int   h_Init(void *a)                                                        { return 0; }
static int   h_InitEx(void *a, int b)                                               { return 0; }
static int   h_SetUserInfo(const char *a,int b,int c,int d,int e,int f,int g)       { return 0; }
static int   h_SetUserInfoLic(const char *a,int b,int c,int d,int e,int f,int g,const char *h) { return 0; }
static int   h_Ioctl(int a, const void *b, int c)                                   { return 0; }
static int   h_IoctlOld(int a, const void *b, int c)                                { return 0; }
static int   h_OnPause(void)                                                        { return 0; }
static int   h_OnResume(void)                                                       { return 0; }
static int   h_OnRecvData(const void *a, int b)                                     { return 0; }
static int   h_OnRecvSig(const void *a, int b)                                      { return 0; }
static void *h_GetReport(int *l)  { if (l) *l = 0; return nullptr; }
static void *h_GetReport2(int *l) { if (l) *l = 0; return nullptr; }
static void *h_GetReport3(int *l) { if (l) *l = 0; return nullptr; }
static void *h_GetReport4(int *l) { if (l) *l = 0; return nullptr; }
static void  h_Del(void *p)  { if (orig_Del  && p) orig_Del(p);  }
static void  h_Del3(void *p) { if (orig_Del3 && p) orig_Del3(p); }
static void  h_Del4(void *p) { if (orig_Del4 && p) orig_Del4(p); }
static void  h_Free(void *p) { if (orig_Free && p) orig_Free(p); }
static int   h_RegListener(void *a) { return 0; }

// ─── __attribute__((constructor)) ───────────────────────────────────────────
// dyld'dan da önce çalışır — AnoSDK init olmadan dylib gizlenir

__attribute__((constructor))
static void earlyHide(void) {
    // Önce dyld hook'larını kur (dylib gizleme)
    struct rebinding dyld_hooks[] = {
        { "_dyld_image_count",            (void *)hook_image_count,  (void **)&orig_image_count  },
        { "_dyld_get_image_name",         (void *)hook_image_name,   (void **)&orig_image_name   },
        { "_dyld_get_image_header",       (void *)hook_image_header, (void **)&orig_image_header },
        { "_dyld_get_image_vmaddr_slide", (void *)hook_image_slide,  (void **)&orig_image_slide  },
    };
    rebind_symbols(dyld_hooks, 4);

    // AnoSDK hook'larını da kur
    static void *o1,*o2,*o3,*o4,*o5,*o6,*o7,*o8,*o9,*o10,*o11,*o12,*o13,*o14,*o19;
    struct rebinding ano_hooks[] = {
        { "AnoSDKInit",                   (void *)h_Init,         &o1  },
        { "AnoSDKInitEx",                 (void *)h_InitEx,       &o2  },
        { "AnoSDKSetUserInfo",            (void *)h_SetUserInfo,  &o3  },
        { "AnoSDKSetUserInfoWithLicense", (void *)h_SetUserInfoLic, &o4 },
        { "AnoSDKIoctl",                  (void *)h_Ioctl,        &o5  },
        { "AnoSDKIoctlOld",               (void *)h_IoctlOld,     &o6  },
        { "AnoSDKOnPause",                (void *)h_OnPause,      &o7  },
        { "AnoSDKOnResume",               (void *)h_OnResume,     &o8  },
        { "AnoSDKOnRecvData",             (void *)h_OnRecvData,   &o9  },
        { "AnoSDKOnRecvSignature",        (void *)h_OnRecvSig,    &o10 },
        { "AnoSDKGetReportData",          (void *)h_GetReport,    &o11 },
        { "AnoSDKGetReportData2",         (void *)h_GetReport2,   &o12 },
        { "AnoSDKGetReportData3",         (void *)h_GetReport3,   &o13 },
        { "AnoSDKGetReportData4",         (void *)h_GetReport4,   &o14 },
        { "AnoSDKDelReportData",          (void *)h_Del,          (void **)&orig_Del  },
        { "AnoSDKDelReportData3",         (void *)h_Del3,         (void **)&orig_Del3 },
        { "AnoSDKDelReportData4",         (void *)h_Del4,         (void **)&orig_Del4 },
        { "AnoSDKFree",                   (void *)h_Free,         (void **)&orig_Free },
        { "AnoSDKRegistInfoListener",     (void *)h_RegListener,  &o19 },
    };
    rebind_symbols(ano_hooks, 20);
}