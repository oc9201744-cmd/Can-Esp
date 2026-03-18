#import <Foundation/Foundation.h>
#include <dlfcn.h>
#include <mach-o/dyld.h>
#include <mach/mach.h>
#include <sys/mman.h>
#include <string.h>

extern "C" {
kern_return_t mach_vm_remap(
    vm_map_t target_task, mach_vm_address_t *target_address,
    mach_vm_size_t size, mach_vm_offset_t mask, int flags,
    vm_map_t src_task, mach_vm_address_t src_address,
    boolean_t copy, vm_prot_t *cur_protection,
    vm_prot_t *max_protection, vm_inherit_t inheritance);
}

static int  fake_connect(int s, const void *addr, unsigned int len)  { return 0; }
static long fake_send(int s, const void *buf, size_t len, int flags) { return (long)len; }
static long fake_recv(int s, void *buf, size_t len, int flags)       { return 0; }
static long fake_write(int fd, const void *buf, size_t nbyte)        { return (long)nbyte; }

static bool patchGOT(uintptr_t gotAddr, void *newFunc) {
    if (!gotAddr || !newFunc) return false;

    vm_size_t  pageSize = vm_page_size;
    uintptr_t  pageAddr = gotAddr & ~(pageSize - 1);
    uintptr_t  pageOff  = gotAddr - pageAddr;
    mach_port_t task    = mach_task_self();

    kern_return_t kr = vm_protect(task, pageAddr, pageSize, false,
                                  VM_PROT_READ | VM_PROT_WRITE);
    if (kr == KERN_SUCCESS) {
        *((void **)gotAddr) = newFunc;
        vm_protect(task, pageAddr, pageSize, false, VM_PROT_READ);
        return true;
    }

    mach_vm_address_t newAddr = 0;
    vm_prot_t cur, max;
    kr = mach_vm_remap(task, &newAddr, pageSize, 0,
                       VM_FLAGS_ANYWHERE | VM_FLAGS_RETURN_DATA_ADDR,
                       task, pageAddr, false, &cur, &max, VM_INHERIT_SHARE);
    if (kr != KERN_SUCCESS) return false;

    kr = vm_protect(task, (vm_address_t)newAddr, pageSize, false,
                    VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    if (kr != KERN_SUCCESS) return false;

    *((void **)(newAddr + pageOff)) = newFunc;
    vm_protect(task, (vm_address_t)newAddr, pageSize, false, VM_PROT_READ);
    return true;
}

void AnoSDKBypassInstall(void) {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        uintptr_t base = 0;
        uint32_t count = _dyld_image_count();
        for (uint32_t i = 0; i < count; i++) {
            const char *name = _dyld_get_image_name(i);
            if (name && strstr(name, "anogs")) {
                base = (uintptr_t)_dyld_get_image_header(i);
                break;
            }
        }
        if (!base) return;

        struct { uintptr_t offset; void *fn; } patches[] = {
            { 0x284588, (void *)fake_connect },
            { 0x2849a8, (void *)fake_send    },
            { 0x284948, (void *)fake_recv    },
            { 0x284b58, (void *)fake_write   },
        };
        for (auto &p : patches)
            patchGOT(base + p.offset, p.fn);
    });
}

@interface AnoSDKBypassLoader : NSObject
@end
@implementation AnoSDKBypassLoader
+ (void)load {
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)),
        dispatch_get_main_queue(),
        ^{ AnoSDKBypassInstall(); }
    );
}
@end