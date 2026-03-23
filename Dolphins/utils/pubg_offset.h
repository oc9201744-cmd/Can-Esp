// pubg_offset.h
#ifndef pubg_offset_h
#define pubg_offset_h

#import <mach-o/dyld.h>
#import <mach-o/loader.h>
#include <stdio.h>
#include <string.h>

namespace PubgOffset {

// ---------- Pattern tarama yardımcıları ----------
static uintptr_t FindPattern(uintptr_t start, uintptr_t length, const unsigned char *pattern, const char *mask) {
    size_t patternLen = strlen(mask);
    for (uintptr_t i = start; i < start + length - patternLen; i++) {
        bool found = true;
        for (size_t j = 0; j < patternLen; j++) {
            if (mask[j] == 'x' && *(unsigned char*)(i + j) != pattern[j]) {
                found = false;
                break;
            }
        }
        if (found) return i;
    }
    return 0;
}

static void GetTextSegment(uintptr_t *base, uintptr_t *size) {
    const struct mach_header_64 *header = (struct mach_header_64*)_dyld_get_image_header(0);
    if (!header) return;
    uintptr_t loadCmd = (uintptr_t)header + sizeof(struct mach_header_64);
    for (uint32_t i = 0; i < header->ncmds; i++) {
        struct load_command *cmd = (struct load_command*)loadCmd;
        if (cmd->cmd == LC_SEGMENT_64) {
            struct segment_command_64 *seg = (struct segment_command_64*)cmd;
            if (strcmp(seg->segname, "__TEXT") == 0) {
                *base = seg->vmaddr + _dyld_get_image_vmaddr_slide(0);
                *size = seg->vmsize;
                return;
            }
        }
        loadCmd += cmd->cmdsize;
    }
    *base = 0; *size = 0;
}

// ---------- bIsAI offsetini dinamik bul ----------
static uint32_t FindAIOffset() {
    uintptr_t base, size;
    GetTextSegment(&base, &size);
    if (!base) return 0xA40; // fallback

    // Pattern: strb w8, [x9, #0xA40]  -> 39 01 09 39
    unsigned char pattern1[] = {0x39, 0x01, 0x09, 0x39};
    const char *mask1 = "xxxx";
    uintptr_t addr = FindPattern(base, size, pattern1, mask1);
    if (addr) return 0xA40;

    // Alternatif: 0xA48 için 39 01 0C 39
    unsigned char pattern2[] = {0x39, 0x01, 0x0C, 0x39};
    const char *mask2 = "xxxx";   // mask2 tanımlandı
    addr = FindPattern(base, size, pattern2, mask2);
    if (addr) return 0xA48;

    return 0xA40; // varsayılan
}

static uint32_t g_aiOffset = 0;
static inline uint32_t GetAIOffset() {
    if (g_aiOffset == 0) g_aiOffset = FindAIOffset();
    return g_aiOffset;
}

// ---------- Sabit offsetler (4.3 için doğru) ----------
int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};

namespace PlayerControllerParam {
    int SelfOffset = 0x28e0;
    int MouseOffset = 0x4e0;
    int CameraManagerOffset = 0x548;
    int AngleOffset = 0x558;

    namespace CameraManagerParam {
        int PovOffset = 0x10a0 + 0x10;
    }

    namespace ControllerFunction {
        int LineOfSightToOffset = 0x7B0;
    }
}

int ULevelOffset = 0x30;

namespace ULevelParam {
    int ObjectArrayOffset = 0xA0;
    int ObjectCountOffset = 0xA8;
}

namespace ObjectParam {
    // Dinamik AI offset
    static inline int RobotOffset() { return GetAIOffset(); }

    // Statik offsetler (4.3)
    int ClassIdOffset = 0x18;
    int ClassNameOffset = 0xC;
    int TeamOffset = 0x998;
    int NameOffset = 0x960;
    int HpOffset = 0xe28;
    int HpmaxOffset = 0xe2c;
    int DeadOffset = 0xe44;
    int StatusOffset = 0x1018;
    int MoveCoordOffset = 0x110;
    int MeshOffset = 0x510;
    int OpenFireOffset = 0x1788;
    int OpenTheSightOffset = 0x10e1;
    int WeaponOneOffset = 0x2a30 + 0x20;
    int CoordOffset = 0x208;

    namespace CoordParam {
        int HeightOffset = 0x1dc;
        int CoordOffset = 0x1c8;
    }

    namespace MeshParam {
        int HumanOffset = 0x210;
        int BonesOffset = 0x990;          // Skeleton için doğru
    }

    namespace PlayerFunction {
        int AddControllerYawInputOffset = 0x890;
        int AddControllerRollInputOffset = 0x888;
        int AddControllerPitchInputOffset = 0x898;
    }

    namespace WeaponParam {
        int MasterOffset = 0x110;
        int ShootModeOffset = 0x1089;
        int WeaponAttrOffset = 0x12c0;

        namespace WeaponAttrParam {
            int BulletSpeedOffset = 0x560;
            int RecoilOffset = 0xcf0;
        }
    }

    int GoodsListOffset = 0x940;
    namespace GoodsListParam {
        int DataBase = 0x38;
    }
}

} // namespace PubgOffset

#endif /* pubg_offset_h */