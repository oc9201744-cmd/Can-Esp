#pragma once

#include <mach/mach.h>
#include <mach-o/dyld.h>
#include <string>
#include <vector>
#include <cstdint>
#include <cstring>

// ─────────────────────────────────────────────────────────────────────────────
// KittyMemory — no-JB uyumlu runtime memory patch
// mach_vm_remap kullanır → vm_protect gerekmez → no-JB crash yok
// ─────────────────────────────────────────────────────────────────────────────

extern "C" kern_return_t mach_vm_remap(
    vm_map_t target_task, mach_vm_address_t *target_address,
    mach_vm_size_t size, mach_vm_offset_t mask, int flags,
    vm_map_t src_task, mach_vm_address_t src_address,
    boolean_t copy, vm_prot_t *cur_protection,
    vm_prot_t *max_protection, vm_inherit_t inheritance);

extern "C" kern_return_t mach_vm_write(
    vm_map_t target_task, mach_vm_address_t address,
    vm_offset_t data, mach_msg_type_number_t dataCnt);

extern "C" kern_return_t mach_vm_protect(
    vm_map_t target_task, mach_vm_address_t address,
    mach_vm_size_t size, boolean_t set_maximum, vm_prot_t new_protection);

namespace KittyMemory {

// ASLR slide — anogs.framework için
static uintptr_t getSlide(const char *imageName = nullptr) {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (!name) continue;
        if (imageName) {
            if (strstr(name, imageName))
                return (uintptr_t)_dyld_get_image_vmaddr_slide(i);
        } else {
            // Ana binary
            if (strstr(name, "/private/var/containers") || strstr(name, "/var/containers"))
                return (uintptr_t)_dyld_get_image_vmaddr_slide(i);
        }
    }
    return (uintptr_t)_dyld_get_image_vmaddr_slide(0);
}

// Memory patch: mach_vm_remap ile yazılabilir kopya oluştur, sonra yaz
static bool patch(uintptr_t addr, const void *bytes, size_t size) {
    if (!addr || !bytes || size == 0) return false;

    mach_port_t task = mach_task_self();
    vm_size_t pageSize = vm_page_size;

    // Sayfa hizalı adres
    uintptr_t pageAddr = addr & ~(pageSize - 1);
    uintptr_t pageOff  = addr - pageAddr;
    vm_size_t  mapSize = ((pageOff + size + pageSize - 1) & ~(pageSize - 1));

    // Yazılabilir sayfa oluştur
    mach_vm_address_t newAddr = 0;
    vm_prot_t curProt, maxProt;

    kern_return_t kr = mach_vm_remap(
        task, &newAddr, mapSize, 0,
        VM_FLAGS_ANYWHERE | VM_FLAGS_RETURN_DATA_ADDR,
        task, pageAddr,
        false, &curProt, &maxProt,
        VM_INHERIT_SHARE);

    if (kr != KERN_SUCCESS) return false;

    // Yazma izni ver
    kr = mach_vm_protect(task, newAddr, mapSize, false,
                         VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    if (kr != KERN_SUCCESS) { vm_deallocate(task, newAddr, mapSize); return false; }

    // Byte'ları yaz
    memcpy(reinterpret_cast<void *>(newAddr + pageOff), bytes, size);

    // Execute izni ver
    kr = mach_vm_protect(task, newAddr, mapSize, false,
                         VM_PROT_READ | VM_PROT_EXECUTE);
    if (kr != KERN_SUCCESS) { vm_deallocate(task, newAddr, mapSize); return false; }

    return true;
}

// ARM64 NOP: 1F 20 03 D5
static const uint8_t NOP[4]  = { 0x1F, 0x20, 0x03, 0xD5 };

// ARM64 return 0: MOV W0,#0 + RET
static const uint8_t RET0[8] = {
    0x00, 0x00, 0x80, 0x52,  // MOV W0, #0
    0xC0, 0x03, 0x5F, 0xD6   // RET
};

// ARM64 return nullptr (X0=0): MOV X0,#0 + RET
static const uint8_t RETNULL[8] = {
    0x00, 0x00, 0x80, 0xD2,  // MOV X0, #0
    0xC0, 0x03, 0x5F, 0xD6   // RET
};

// Kolaylık fonksiyonları
static bool patchRet0(uintptr_t addr)    { return patch(addr, RET0,    sizeof(RET0));    }
static bool patchRetNull(uintptr_t addr) { return patch(addr, RETNULL, sizeof(RETNULL)); }
static bool patchNop(uintptr_t addr)     { return patch(addr, NOP,     sizeof(NOP));     }

} // namespace KittyMemory