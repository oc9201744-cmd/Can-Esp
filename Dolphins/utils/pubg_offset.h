#pragma once

#include <stdio.h>
#include <string>

namespace PubgOffset {

// ==================== GLOBAL OFFSET'LER ====================
// AIOHeader.hpp'den güncel (satır ~17400, 26000, 29900)
namespace Global {
    const long gobject = 0x10A34E980;        // UObject::GObjects (satır ~17400)
    const long gname_func = 0x104BD8740;     // FName::GetNames (satır ~17400)
    const long gname_data = 0x10A1178B0;     // FName::Names (satır ~17400)
    const long gworld_func = 0x102A62208;    // UWorld::GetWorld (satır ~17400)
    const long gworld_data = 0x10A566E00;    // UWorld::GWorld (satır ~17400)
}

// ==================== UWORLD / ULEVEL ====================
// AIOHeader.hpp: UWorld (satır ~37700), ULevel (satır ~26000)
int ULevelOffset = 0x30;                     // UWorld::PersistentLevel

namespace ULevelParam {
    int ObjectArrayOffset = 0xA0;            // ULevel::Actors (TArray<AActor*>)
    int ObjectCountOffset = 0xA8;            // ULevel::Actors.Count
}

// ==================== APLAYERCONTROLLER CHAIN ====================
// AIOHeader.hpp: UNetDriver (satır ~39900), UNetConnection (satır ~39500)
int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};  // NetDriver -> ServerConnection -> PlayerController

namespace PlayerControllerParam {
    int SelfOffset = 0x28E0;                  // Özel - STExtraPlayerController
    int MouseOffset = 0x4E0;                  // APlayerController::ControlRotation
    int CameraManagerOffset = 0x548;          // APlayerController::PlayerCameraManager (satır ~31900)
    int AngleOffset = 0x558;                  // APlayerController::PlayerCameraManagerClass
    
    namespace CameraManagerParam {
        int PovOffset = 0x530;                // APlayerCameraManager::CameraCache.POV (satır ~37700)
    }
    
    namespace ControllerFunction {
        int LineOfSightToOffset = 0x7B0;      // AController::LineOfSightTo (satır ~17500)
    }
}

// ==================== APLAYERSTATE ====================
// AIOHeader.hpp: APlayerState (satır ~32400)
namespace PlayerStateParam {
    int TeamOffset = 0x998;                   // Özel - STExtraPlayerState::TeamID
    int NameOffset = 0x4B8;                  // APlayerState::PlayerName (FString)
    int RobotOffset = 0x4DC;                 // APlayerState::bIsABot (bit 2) (satır ~32400)
    // bIsABot kontrolü: (*(uint8_t*)(PlayerState + 0x4DC) & 0x4) != 0
}

// ==================== APLAYERCHARACTER (ACharacter) ====================
// AIOHeader.hpp: ACharacter (satır ~26600), AActor (satır ~17400)
namespace ObjectParam {
    int ClassIdOffset = 0x18;                // UObject::ClassPrivate
    int ClassNameOffset = 0xC;               // UObject::NamePrivate
    
    namespace PlayerFunction {
        int AddControllerYawInputOffset = 0x890;   // APlayerController::AddYawInput
        int AddControllerRollInputOffset = 0x888;  // APlayerController::AddRollInput
        int AddControllerPitchInputOffset = 0x898; // APlayerController::AddPitchInput
    }
    
    // ACharacter (satır ~26600)
    int StatusOffset = 0x1058;               // Özel - STExtraPlayerCharacter::CurrentStates
    int HpOffset = 0xE60;                    // Özel - STExtraPlayerCharacter::Health
    int HpmaxOffset = 0xE64;                 // Özel - STExtraPlayerCharacter::HealthMax
    int DeadOffset = 0xE7C;                  // Özel - STExtraPlayerCharacter::bDead
    
    // AActor (satır ~17400)
    int MoveCoordOffset = 0x110;             // AActor::ReplicatedMovement
    int MeshOffset = 0x510;                  // ACharacter::Mesh (satır ~26600)
    int boneCountOffset = 0x8D0;             // USkeletalMeshComponent::NumBones
    
    // USkeletalMeshComponent (satır ~27200)
    namespace MeshParam {
        int BonesOffset = 0xC40;              // USkeletalMeshComponent::CachedComponentSpaceTransforms
        // Her transform 48 byte (0x30)
        // Translation = Bone + 0x10 (12 bytes)
    }
    
    // Silah (Weapon)
    int OpenFireOffset = 0x1800;             // Özel - STExtraWeapon::bIsFiring
    int OpenTheSightOffset = 0x1134;         // Özel - STExtraWeapon::bIsADS
    int WeaponManagerComponentOffset = 0x25B8; // Özel - STExtraPlayerCharacter::WeaponManagerComponent
    int WeaponOneOffset = 0x5C8;              // Özel - STExtraWeaponManagerComponent::CurrentWeaponReplicated
    
    // Araç (Vehicle)
    int VehicleCommonComponentOffset = 0xC00; // Özel - STExtraPlayerCharacter::VehicleCommonComponent
    int VehicleHPOffset = 0x354;              // Özel - STExtraVehicle::HP
    int VehicleHPMaxOffset = 0x350;           // Özel - STExtraVehicle::HPMax
    int VehicleFuelOffset = 0x43C;            // Özel - STExtraVehicle::Fuel
    int VehicleFuelMaxOffset = 0x438;         // Özel - STExtraVehicle::FuelMax
    
    // Eşya (Pickup)
    int GoodsListOffset = 0x940;              // Özel - STExtraPlayerCharacter::PickUpDataList
    
    namespace GoodsListParam {
        int DataBase = 0x38;                 // FItemDefineID::ID
    }
    
    // RootComponent (USceneComponent) (satır ~15900)
    int CoordOffset = 0x208;                 // AActor::RootComponent
    
    namespace CoordParam {
        int CoordOffset = 0x1E4;             // USceneComponent::RelativeLocation (satır ~15900)
    }
}

// ==================== USKELETALMESHCOMPONENT BONE OFFSET'LERİ ====================
// AIOHeader.hpp satır ~27200
namespace BoneOffsets {
    const int BoneTransformArray = 0xC40;     // CachedComponentSpaceTransforms (TArray<FTransform>)
    const int TransformSize = 0x30;           // sizeof(FTransform) = 48 bytes
    const int TranslationOffset = 0x10;       // FTransform::Translation (FVector)
    
    // Ana bone index'leri (test edilmesi gerekiyor)
    const int HeadBone = 108;                 // Head bone index
    const int NeckBone = 107;                 // Neck bone index  
    const int ChestBone = 6;                  // Chest bone index
    const int PelvisBone = 1;                 // Pelvis bone index
}

// ==================== FSTRUCT YAPILARI ====================
// AIOHeader.hpp satır ~850, 890, 1190
struct FVector {
    float X;  // 0x0
    float Y;  // 0x4
    float Z;  // 0x8
};

struct FRotator {
    float Pitch;  // 0x0
    float Yaw;    // 0x4
    float Roll;   // 0x8
};

struct FQuat {
    float X;  // 0x0
    float Y;  // 0x4
    float Z;  // 0x8
    float W;  // 0xC
};

struct FTransform {
    FQuat Rotation;     // 0x00 (16 bytes)
    FVector Translation;// 0x10 (12 bytes)
    char Pad[4];        // 0x1C (4 bytes padding)
    FVector Scale3D;    // 0x20 (12 bytes)
};  // Toplam 0x30 (48 bytes)

// ==================== UTILITY ====================
// Bot kontrolü için helper
inline bool IsPlayerBot(uintptr_t PlayerState) {
    if (!PlayerState) return false;
    uint8_t flags = *(uint8_t*)(PlayerState + PlayerStateParam::RobotOffset);
    return (flags & 0x4) != 0;  // bIsABot bit 2'de
}

// Bone pozisyonu alma
inline FVector GetBonePosition(uintptr_t BoneArray, int BoneIndex) {
    uintptr_t Bone = BoneArray + (BoneIndex * BoneOffsets::TransformSize);
    FVector Pos;
    Pos.X = *(float*)(Bone + BoneOffsets::TranslationOffset);
    Pos.Y = *(float*)(Bone + BoneOffsets::TranslationOffset + 4);
    Pos.Z = *(float*)(Bone + BoneOffsets::TranslationOffset + 8);
    return Pos;
}

}