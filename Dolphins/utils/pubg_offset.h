#pragma once
#include <cstdint>
#include <cstddef>

namespace Memory {

// Bu fonksiyonların implementasyonu projede bulunmalı
uintptr_t GetModuleBase(const char* moduleName);
uintptr_t PatternScan(uintptr_t base, size_t size, const char* pattern, const char* mask);

}

namespace PubgOffset {

struct Offsets {
    uintptr_t PlayerController;
    uintptr_t Self;
    uintptr_t Mouse;
    uintptr_t CameraManager;
    uintptr_t Angle;
    uintptr_t ULevel;
    uintptr_t ObjectArray;
    uintptr_t ObjectCount;
    uintptr_t Mesh;
    uintptr_t Bones;
    uintptr_t WeaponAttr;
    uintptr_t Hp;
    uintptr_t Team;
};

inline Offsets Data;

inline void Initialize(uintptr_t base) {

    Data.PlayerController = Memory::PatternScan(
        base, 0x5000000,
        "\x48\x8B\x00\x00\x00\x00\x48\x85",
        "xx????xx"
    );

    Data.Self  = Data.PlayerController + 0x28e0;
    Data.Mouse = Data.PlayerController + 0x4e0;

    Data.CameraManager = Memory::PatternScan(
        base, 0x5000000,
        "\x40\x53\x48\x83\xEC",
        "xxxxx"
    );

    Data.Angle = Data.CameraManager + 0x558;

    Data.ULevel = Memory::PatternScan(
        base, 0x5000000,
        "\x48\x8B\x0D\x00\x00\x00\x00\x48\x8B",
        "xxx????xx"
    );

    Data.ObjectArray = Data.ULevel + 0xA0;
    Data.ObjectCount = Data.ULevel + 0xA8;

    Data.Mesh = Memory::PatternScan(
        base, 0x5000000,
        "\x48\x8B\x89\x00\x00\x00\x00\x48\x85",
        "xxx????xx"
    );

    Data.Bones = Data.Mesh + 0x988;

    Data.WeaponAttr = Memory::PatternScan(
        base, 0x5000000,
        "\x48\x8B\x81\x00\x00\x00\x00\x48\x8B",
        "xxx????xx"
    );

    Data.Hp   = 0xE28;
    Data.Team = 0x998;
}

}
