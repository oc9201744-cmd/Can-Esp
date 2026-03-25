//
//  PubgOffset.h
//  Dolphins
//
//  Updated with AIO Dumper offsets
//

#pragma once
#include <cstdint>

// ========== AIO Dumper GLOBAL POINTERS ==========
#define GNAMES_OFFSET        0x10d4a8ab8      // FNamePool
#define GOBJECTS_OFFSET      0x10a34e980      // FUObjectArray  
#define GENGINE_OFFSET       0x10a565bf0      // UEngine
#define PROCESS_EVENT_OFFSET 0x104d7bfc0      // ProcessEvent

namespace PubgOffset {
    
    // ========== UObject (Base Class) ==========
    namespace UObjectOffsets {
        constexpr uintptr_t ClassPrivate = 0x10;
        constexpr uintptr_t NamePrivate = 0x18;
        constexpr uintptr_t OuterPrivate = 0x20;
        constexpr uintptr_t InternalIndex = 0xc;
    }
    
    // ========== UWorld ==========
    constexpr uintptr_t UWorld_PersistentLevel = 0x38;      // ULevel*
    constexpr uintptr_t UWorld_OwningGameInstance = 0x1a0;  // UGameInstance*
    
    // ========== ULevel ==========
    constexpr uintptr_t ULevel_Actors = 0xa0;               // TArray<AActor*>
    constexpr uintptr_t ULevel_ActorsCount = 0xa8;          // int32
    
    // ========== AActor ==========
    constexpr uintptr_t AActor_RootComponent = 0x1a0;       // USceneComponent*
    constexpr uintptr_t AActor_Location = 0x1a8;            // FVector
    
    // ========== USceneComponent ==========
    constexpr uintptr_t USceneComponent_RelativeLocation = 0x124;   // FVector
    constexpr uintptr_t USceneComponent_ComponentVelocity = 0x140;  // FVector
    
    // ========== APlayerController ==========
    constexpr uintptr_t APlayerController_PlayerCameraManager = 0x4b8;  // APlayerCameraManager*
    constexpr uintptr_t APlayerController_ControlRotation = 0x468;      // FRotator
    
    // ========== APlayerCameraManager ==========
    constexpr uintptr_t APlayerCameraManager_CameraCachePrivate = 0x2c40;  // FCameraCacheEntry
    
    // ========== FCameraCacheEntry / FMinimalViewInfo ==========
    constexpr uintptr_t FCameraCacheEntry_POV = 0x10;        // FMinimalViewInfo
    constexpr uintptr_t FMinimalViewInfo_Location = 0x0;     // FVector
    constexpr uintptr_t FMinimalViewInfo_Rotation = 0xc;     // FRotator
    constexpr uintptr_t FMinimalViewInfo_FOV = 0x18;         // float
    
    // ========== ASTExtraPlayerCharacter (PUBG Player) ==========
    constexpr uintptr_t ASTExtraPlayerCharacter_Health = 0x1138;           // float
    constexpr uintptr_t ASTExtraPlayerCharacter_HealthMax = 0x113c;        // float
    constexpr uintptr_t ASTExtraPlayerCharacter_TeamID = 0x1228;           // int32
    constexpr uintptr_t ASTExtraPlayerCharacter_bIsAI = 0xa40;             // uint8 (bit 0)
    constexpr uintptr_t ASTExtraPlayerCharacter_bIsMLAI = 0xa41;           // uint8 (bit 0)
    constexpr uintptr_t ASTExtraPlayerCharacter_PlayerName = 0xae8;        // FString
    constexpr uintptr_t ASTExtraPlayerCharacter_CurrentWeapon = 0x1160;    // ASTExtraWeapon*
    constexpr uintptr_t ASTExtraPlayerCharacter_Mesh = 0x498;              // USkeletalMeshComponent*
    constexpr uintptr_t ASTExtraPlayerCharacter_Status = 0x9a8;            // ECharacterStatus
    constexpr uintptr_t ASTExtraPlayerCharacter_DeadOffset = 0x117c;       // bool
    constexpr uintptr_t ASTExtraPlayerCharacter_MoveCoord = 0x190;         // FVector (velocity)
    constexpr uintptr_t ASTExtraPlayerCharacter_OpenTheSightOffset = 0xae0; // int32 (aiming)
    constexpr uintptr_t ASTExtraPlayerCharacter_OpenFireOffset = 0xae4;    // int32 (firing)
    
    // ========== USkeletalMeshComponent ==========
    constexpr uintptr_t USkeletalMeshComponent_ComponentToWorld = 0x240;   // FTransform
    constexpr uintptr_t USkeletalMeshComponent_BoneSpaceTransforms = 0x7d0; // TArray<FTransform>
    constexpr uintptr_t USkeletalMeshComponent_CachedBoneSpaceTransforms = 0x7e0; // TArray<FTransform>
    constexpr uintptr_t USkeletalMeshComponent_MeshOffset = 0x2b0;         // UObject*
    
    // ========== Bone Indexes (PUBG) ==========
    constexpr int Bone_Root = 0;
    constexpr int Bone_Pelvis = 1;
    constexpr int Bone_Spine = 2;
    constexpr int Bone_Spine1 = 3;
    constexpr int Bone_Neck = 4;
    constexpr int Bone_Head = 5;
    constexpr int Bone_LeftShoulder = 11;
    constexpr int Bone_LeftElbow = 12;
    constexpr int Bone_LeftWrist = 13;
    constexpr int Bone_RightShoulder = 32;
    constexpr int Bone_RightElbow = 33;
    constexpr int Bone_RightWrist = 34;
    constexpr int Bone_LeftThigh = 52;
    constexpr int Bone_LeftKnee = 53;
    constexpr int Bone_LeftAnkle = 54;
    constexpr int Bone_RightThigh = 56;
    constexpr int Bone_RightKnee = 57;
    constexpr int Bone_RightAnkle = 58;
    
    // ========== ASTExtraWeapon ==========
    constexpr uintptr_t ASTExtraWeapon_WeaponInfo = 0x5b8;    // FWeaponInfo
    constexpr uintptr_t ASTExtraWeapon_WeaponAttr = 0x5c0;    // UWeaponAttribute*
    constexpr uintptr_t ASTExtraWeapon_ShootMode = 0x5d0;     // int32 (1024 = auto)
    
    // ========== UWeaponAttribute ==========
    constexpr uintptr_t UWeaponAttribute_BulletSpeed = 0x2c;   // float
    constexpr uintptr_t UWeaponAttribute_Recoil = 0x30;        // float (recoil intensity)
    
    // ========== ASTExtraVehicle ==========
    constexpr uintptr_t ASTExtraVehicle_Health = 0x10f8;       // float
    
    // ========== ASTExtraPickupWrapper (Item) ==========
    constexpr uintptr_t ASTExtraPickupWrapper_ItemID = 0x2d8;  // int32
    constexpr uintptr_t ASTExtraPickupWrapper_Count = 0x2dc;   // int32
    
    // ========== Player Controller Functions ==========
    namespace PlayerControllerFunction {
        constexpr uintptr_t LineOfSightTo = 0x780;            // bool (*)(AActor*, FVector, bool)
        constexpr uintptr_t AddControllerYawInput = 0x6e0;    // void (*)(float)
        constexpr uintptr_t AddControllerPitchInput = 0x6e8;  // void (*)(float)
        constexpr uintptr_t AddControllerRollInput = 0x6f0;   // void (*)(float)
    }
    
    // ========== Player Controller Offsets ==========
    constexpr uintptr_t PlayerController_SelfOffset = 0x690;      // APawn*
    constexpr uintptr_t PlayerController_CameraManager = 0x4b8;   // APlayerCameraManager*
    constexpr uintptr_t PlayerController_MouseOffset = 0x460;     // FRotator (control rotation)
    constexpr uintptr_t PlayerController_PlayerState = 0x3f8;     // APlayerState*
    
    // ========== Player State ==========
    constexpr uintptr_t PlayerState_PlayerName = 0x3a8;           // FString
    
    // ========== Coordinate Offset ==========
    constexpr uintptr_t CoordOffset_Coord = 0x0;                  // FVector
    constexpr uintptr_t CoordOffset_Height = 0x18;                // float (capsule height)
    
    // ========== Material / Item Types ==========
    enum MaterialType {
        Rifle = 0,
        Sniper = 1,
        Missile = 2,
        Ammo = 3,
        Helmet = 4,
        Vest = 5,
        Backpack = 6,
        Medical = 7,
        Airdrop = 8,
        Scope = 9,
        Muzzle = 10,
        Magazine = 11,
        Grip = 12,
        Warning = 13,
        All = 14
    };
}