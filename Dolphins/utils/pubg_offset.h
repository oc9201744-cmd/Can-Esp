#pragma once

#include <stdio.h>
#include <string>

namespace PubgOffset {

// ==================== GLOBAL OFFSET'LER ====================
namespace Global {
    const long gobject = 0x10A34E980;
    const long gname_func = 0x104BD8740;
    const long gname_data = 0x10A1178B0;
    const long gworld_func = 0x102A62208;
    const long gworld_data = 0x10A566E00;
}

// ==================== UWORLD / ULEVEL ====================
int ULevelOffset = 0x30;

namespace ULevelParam {
    int ObjectArrayOffset = 0xA0;
    int ObjectCountOffset = 0xA8;
}

// ==================== APLAYERCONTROLLER CHAIN ====================
int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};

namespace PlayerControllerParam {
    int SelfOffset = 0x28E0;
    int MouseOffset = 0x4E0;
    int CameraManagerOffset = 0x548;
    int AngleOffset = 0x558;
    
    namespace CameraManagerParam {
        int PovOffset = 0x530;
    }
    
    namespace ControllerFunction {
        int LineOfSightToOffset = 0x7B0;
    }
}

// ==================== APLAYERSTATE ====================
// Kodda ObjectParam kullanıldığı için buraya ekliyoruz
namespace ObjectParam {
    // PlayerState offset'leri (kodda ObjectParam içinde aranıyor)
    int TeamOffset = 0x998;        // Takım ID'si
    int NameOffset = 0x4B8;        // Oyuncu adı
    int RobotOffset = 0x4DC;       // Bot mu? (bit 2)
    
    // ACharacter offset'leri
    int ClassIdOffset = 0x18;
    int ClassNameOffset = 0xC;
    
    namespace PlayerFunction {
        int AddControllerYawInputOffset = 0x890;
        int AddControllerRollInputOffset = 0x888;
        int AddControllerPitchInputOffset = 0x898;
    }
    
    int StatusOffset = 0x1058;
    int HpOffset = 0xE60;
    int HpmaxOffset = 0xE64;
    int DeadOffset = 0xE7C;
    
    int MoveCoordOffset = 0x110;
    int MeshOffset = 0x510;
    int boneCountOffset = 0x8D0;
    
    namespace MeshParam {
        int BonesOffset = 0xC40;
        int HumanOffset = 0x1E4;   // Geri eklendi! (USceneComponent::RelativeLocation)
    }
    
    // Silah (Weapon)
    int OpenFireOffset = 0x1800;
    int OpenTheSightOffset = 0x1134;
    int WeaponManagerComponentOffset = 0x25B8;
    int WeaponOneOffset = 0x5C8;
    
    namespace WeaponParam {
        int MasterOffset = 0x110;
        int ShootModeOffset = 0x10D9;
        int WeaponAttrOffset = 0x398;
        
        namespace WeaponAttrParam {
            int BulletSpeedOffset = 0x560;
            int RecoilOffset = 0xCF0;
        }
    }
    
    // Araç (Vehicle)
    int VehicleCommonComponentOffset = 0xC00;
    int VehicleHPOffset = 0x354;
    int VehicleHPMaxOffset = 0x350;
    int VehicleFuelOffset = 0x43C;
    int VehicleFuelMaxOffset = 0x438;
    
    // Eşya
    int GoodsListOffset = 0x940;
    
    namespace GoodsListParam {
        int DataBase = 0x38;
    }
    
    // RootComponent
    int CoordOffset = 0x208;
    
    namespace CoordParam {
        int CoordOffset = 0x1E4;        // USceneComponent::RelativeLocation
        int HeightOffset = 0x1E4;       // Geri eklendi! (CoordOffset ile aynı)
    }
}

// ==================== BONE OFFSET'LERİ ====================
namespace BoneOffsets {
    const int BoneTransformArray = 0xC40;
    const int TransformSize = 0x30;
    const int TranslationOffset = 0x10;
    
    const int HeadBone = 108;
    const int NeckBone = 107;
    const int ChestBone = 6;
    const int PelvisBone = 1;
}

// ==================== FSTRUCT YAPILARI ====================
struct FVector {
    float X, Y, Z;
};

struct FRotator {
    float Pitch, Yaw, Roll;
};

struct FQuat {
    float X, Y, Z, W;
};

struct FTransform {
    FQuat Rotation;
    FVector Translation;
    char Pad[4];
    FVector Scale3D;
};

// ==================== UTILITY FUNCTIONS ====================
inline bool IsPlayerBot(uintptr_t PlayerState) {
    if (!PlayerState) return false;
    uint8_t flags = *(uint8_t*)(PlayerState + ObjectParam::RobotOffset);
    return (flags & 0x4) != 0;
}

inline FVector GetBonePosition(uintptr_t BoneArray, int BoneIndex) {
    uintptr_t Bone = BoneArray + (BoneIndex * BoneOffsets::TransformSize);
    FVector Pos;
    Pos.X = *(float*)(Bone + BoneOffsets::TranslationOffset);
    Pos.Y = *(float*)(Bone + BoneOffsets::TranslationOffset + 4);
    Pos.Z = *(float*)(Bone + BoneOffsets::TranslationOffset + 8);
    return Pos;
}

}