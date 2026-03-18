#import <Foundation/Foundation.h>
#include <dlfcn.h>
#include <mach-o/dyld.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include "fishhook.h"

// ─────────────────────────────────────────────────────────────────────────────
// AnoSDKBypass.mm
// Analiz sonucu: AnoSDK raw C socket kullanıyor (socket/connect/send/recv)
// NSURLSession hook işe yaramıyor — connect() hook'layarak bağlantıyı kesiyoruz
// ─────────────────────────────────────────────────────────────────────────────

// ─── Socket tracking ─────────────────────────────────────────────────────────
// AnoSDK'nın açtığı socketleri takip et, onlardan gelen send'leri blokla

#define MAX_BLOCKED_FDS 64
static int  blocked_fds[MAX_BLOCKED_FDS];
static int  blocked_fd_count = 0;

static void block_fd(int fd) {
    if (blocked_fd_count < MAX_BLOCKED_FDS)
        blocked_fds[blocked_fd_count++] = fd;
}

static bool is_blocked_fd(int fd) {
    for (int i = 0; i < blocked_fd_count; i++)
        if (blocked_fds[i] == fd) return true;
    return false;
}

static void unblock_fd(int fd) {
    for (int i = 0; i < blocked_fd_count; i++) {
        if (blocked_fds[i] == fd) {
            blocked_fds[i] = blocked_fds[--blocked_fd_count];
            return;
        }
    }
}

// ─── Original pointers ───────────────────────────────────────────────────────

static int  (*orig_connect)(int, const struct sockaddr *, socklen_t) = nullptr;
static ssize_t (*orig_send)(int, const void *, size_t, int)          = nullptr;
static ssize_t (*orig_recv)(int, void *, size_t, int)                = nullptr;
static int  (*orig_close)(int)                                       = nullptr;
static int  (*orig_socket)(int, int, int)                            = nullptr;

// ─── connect() hook ──────────────────────────────────────────────────────────
// AnoSDK sunucusuna bağlanmaya çalışıyorsa blokla

static int hook_connect(int fd, const struct sockaddr *addr, socklen_t len) {
    if (addr) {
        // IPv4
        if (addr->sa_family == AF_INET) {
            struct sockaddr_in *sin = (struct sockaddr_in *)addr;
            uint16_t port = ntohs(sin->sin_port);
            // AnoSDK port aralıkları: 80, 443, 9999, 8080, 14000-15000 arası
            // cs_80_port string'i de vardı — 80 portunu kullanıyor
            if (port == 80 || port == 443 || port == 9999 ||
                port == 8080 || (port >= 14000 && port <= 15000)) {
                // Bu portta bağlantı girişimini AnoSDK fd olarak işaretle
                // Önce orijinal connect'i dene, başarılı olursa blokla
                int ret = orig_connect(fd, addr, len);
                if (ret == 0) block_fd(fd);
                return ret;
            }
        }
    }
    return orig_connect(fd, addr, len);
}

// ─── send() hook ─────────────────────────────────────────────────────────────
// Bloklu fd'den veri göndermeyi engelle

static ssize_t hook_send(int fd, const void *buf, size_t n, int flags) {
    if (is_blocked_fd(fd)) return (ssize_t)n; // veri gönderilmiş gibi davran
    return orig_send(fd, buf, n, flags);
}

// ─── recv() hook ─────────────────────────────────────────────────────────────

static ssize_t hook_recv(int fd, void *buf, size_t n, int flags) {
    if (is_blocked_fd(fd)) return 0; // bağlantı kapanmış gibi davran
    return orig_recv(fd, buf, n, flags);
}

// ─── close() hook ────────────────────────────────────────────────────────────

static int hook_close(int fd) {
    unblock_fd(fd);
    return orig_close(fd);
}

// ─── dyld image gizleme ──────────────────────────────────────────────────────

static const char *kHidden[] = {
    "Blackshark", "blackshark",
    "TweakInject", "MobileSubstrate",
    "CydiaSubstrate", "substitute",
    nullptr
};

static bool shouldHide(const char *name) {
    if (!name) return false;
    for (int i = 0; kHidden[i]; i++)
        if (strstr(name, kHidden[i])) return true;
    return false;
}

static uint32_t           (*orig_cnt)(void)       = nullptr;
static const char        *(*orig_iname)(uint32_t) = nullptr;
static const mach_header *(*orig_hdr)(uint32_t)   = nullptr;
static intptr_t           (*orig_slide)(uint32_t) = nullptr;

static uint32_t toReal(uint32_t fake) {
    uint32_t total = orig_cnt ? orig_cnt() : _dyld_image_count();
    uint32_t vis = 0;
    for (uint32_t i = 0; i < total; i++) {
        const char *n = orig_iname ? orig_iname(i) : _dyld_get_image_name(i);
        if (shouldHide(n)) continue;
        if (vis == fake) return i;
        vis++;
    }
    return fake;
}

static uint32_t           h_cnt(void)        { uint32_t n=0,t=orig_cnt?orig_cnt():_dyld_image_count(); for(uint32_t i=0;i<t;i++) if(!shouldHide(orig_iname?orig_iname(i):_dyld_get_image_name(i))) n++; return n; }
static const char        *h_iname(uint32_t i){ return orig_iname?orig_iname(toReal(i)):_dyld_get_image_name(i); }
static const mach_header *h_hdr(uint32_t i)  { return orig_hdr?orig_hdr(toReal(i)):_dyld_get_image_header(i); }
static intptr_t           h_slide(uint32_t i){ return orig_slide?orig_slide(toReal(i)):_dyld_get_image_vmaddr_slide(i); }

// ─── AnoSDK API hooks ─────────────────────────────────────────────────────────

static void (*orig_Del)(void *)  = nullptr;
static void (*orig_Del3)(void *) = nullptr;
static void (*orig_Del4)(void *) = nullptr;
static void (*orig_Free)(void *) = nullptr;

static int   h_Init(void *a)                                                                   { return 0; }
static int   h_InitEx(void *a, int b)                                                          { return 0; }
static int   h_SetUserInfo(const char *a,int b,int c,int d,int e,int f,int g)                  { return 0; }
static int   h_SetUserInfoLic(const char *a,int b,int c,int d,int e,int f,int g,const char *h) { return 0; }
static int   h_Ioctl(int a,const void *b,int c)                                                { return 0; }
static int   h_IoctlOld(int a,const void *b,int c)                                             { return 0; }
static int   h_OnPause(void)                                                                   { return 0; }
static int   h_OnResume(void)                                                                  { return 0; }
static int   h_OnRecvData(const void *a,int b)                                                 { return 0; }
static int   h_OnRecvSig(const void *a,int b)                                                  { return 0; }
static void *h_GetReport(int *l)  { if(l)*l=0; return nullptr; }
static void *h_GetReport2(int *l) { if(l)*l=0; return nullptr; }
static void *h_GetReport3(int *l) { if(l)*l=0; return nullptr; }
static void *h_GetReport4(int *l) { if(l)*l=0; return nullptr; }
static void  h_Del(void *p)  { if(orig_Del  &&p) orig_Del(p);  }
static void  h_Del3(void *p) { if(orig_Del3 &&p) orig_Del3(p); }
static void  h_Del4(void *p) { if(orig_Del4 &&p) orig_Del4(p); }
static void  h_Free(void *p) { if(orig_Free &&p) orig_Free(p); }
static int   h_RegListener(void *a) { return 0; }

// ─── Constructor ─────────────────────────────────────────────────────────────

__attribute__((constructor))
static void bypass_init(void) {
    static void *o1,*o2,*o3,*o4,*o5,*o6,*o7,*o8,*o9,*o10,*o11,*o12,*o13,*o14,*o19;

    struct rebinding b[] = {
        // dyld gizleme
        { "_dyld_image_count",            (void *)h_cnt,    (void **)&orig_cnt   },
        { "_dyld_get_image_name",         (void *)h_iname,  (void **)&orig_iname },
        { "_dyld_get_image_header",       (void *)h_hdr,    (void **)&orig_hdr   },
        { "_dyld_get_image_vmaddr_slide", (void *)h_slide,  (void **)&orig_slide },

        // raw socket block
        { "connect", (void *)hook_connect, (void **)&orig_connect },
        { "send",    (void *)hook_send,    (void **)&orig_send    },
        { "recv",    (void *)hook_recv,    (void **)&orig_recv    },
        { "close",   (void *)hook_close,   (void **)&orig_close   },

        // AnoSDK API
        { "AnoSDKInit",                   (void *)h_Init,          &o1  },
        { "AnoSDKInitEx",                 (void *)h_InitEx,        &o2  },
        { "AnoSDKSetUserInfo",            (void *)h_SetUserInfo,   &o3  },
        { "AnoSDKSetUserInfoWithLicense", (void *)h_SetUserInfoLic,&o4  },
        { "AnoSDKIoctl",                  (void *)h_Ioctl,         &o5  },
        { "AnoSDKIoctlOld",               (void *)h_IoctlOld,      &o6  },
        { "AnoSDKOnPause",                (void *)h_OnPause,       &o7  },
        { "AnoSDKOnResume",               (void *)h_OnResume,      &o8  },
        { "AnoSDKOnRecvData",             (void *)h_OnRecvData,    &o9  },
        { "AnoSDKOnRecvSignature",        (void *)h_OnRecvSig,     &o10 },
        { "AnoSDKGetReportData",          (void *)h_GetReport,     &o11 },
        { "AnoSDKGetReportData2",         (void *)h_GetReport2,    &o12 },
        { "AnoSDKGetReportData3",         (void *)h_GetReport3,    &o13 },
        { "AnoSDKGetReportData4",         (void *)h_GetReport4,    &o14 },
        { "AnoSDKDelReportData",          (void *)h_Del,           (void **)&orig_Del  },
        { "AnoSDKDelReportData3",         (void *)h_Del3,          (void **)&orig_Del3 },
        { "AnoSDKDelReportData4",         (void *)h_Del4,          (void **)&orig_Del4 },
        { "AnoSDKFree",                   (void *)h_Free,          (void **)&orig_Free },
        { "AnoSDKRegistInfoListener",     (void *)h_RegListener,   &o19 },
    };
    rebind_symbols(b, sizeof(b)/sizeof(b[0]));
}