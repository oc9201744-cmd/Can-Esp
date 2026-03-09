//
//  memory_tools.cpp
//  Dolphins
//
//  Created by YuWan on 2023/6/26.
//
#import <string>
#import <dlfcn.h>
#import <stdio.h>
#import <mach/mach.h>
#import <mach-o/dyld.h>
#include "memory_tools.h"

bool MemoryTools::IsValidAddress(uintptr_t addr) {
    return addr > 0x100000000 && addr < 0x2000000000;
}

bool MemoryTools::readMemory(uintptr_t address, size_t size, void *buffer) {
    if (!IsValidAddress(address)) return false;
    vm_size_t vmSize = 0;
    kern_return_t error = vm_read_overwrite(mach_task_self(), (vm_address_t)address, size, (vm_address_t)buffer, &vmSize);
    if (error != KERN_SUCCESS || vmSize != size) {
        return false;
    }
    return true;
}

bool MemoryTools::writeMemory(uintptr_t address, size_t size, void *buffer) {
    if (!IsValidAddress(address)) return false;
    kern_return_t error = vm_write(mach_task_self(), (vm_address_t)address, (vm_offset_t)buffer, (mach_msg_type_number_t)size);
    if (error != KERN_SUCCESS) {
        return false;
    }
    return true;
}

uintptr_t MemoryTools::readPtr(uintptr_t addr) {
    uintptr_t value = 0;
    readMemory(addr, sizeof(uintptr_t), &value);
    return value;
}

int MemoryTools::readInt(uintptr_t addr) {
    int value = 0;
    readMemory(addr, sizeof(int), &value);
    return value;
}

float MemoryTools::readFloat(uintptr_t addr) {
    float value = 0;
    readMemory(addr, sizeof(float), &value);
    return value;
}

void MemoryTools::writePtr(uintptr_t addr, uintptr_t wAddr) {
    writeMemory(addr, sizeof(uintptr_t), &wAddr);
}

void MemoryTools::writeFloat(uintptr_t addr, float value) {
    writeMemory(addr, sizeof(float), &value);
}
