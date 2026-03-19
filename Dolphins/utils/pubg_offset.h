//
// Created by XBK on 2022/1/16.
// DYLIB UPDATE: PUBGM Neo XO IOS FREE.dylib (March 2026)
// Verified working offsets from MOD MUNO XO
//
#include <stdio.h>
#include <string>

namespace PubgOffset {

// ============================================
// MAIN PLAYER CONTROLLER OFFSETS
// ============================================

int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};

namespace PlayerControllerParam {
    // DYLIB: STExtraPlayerController::STExtraBaseCharacter pointer
    int SelfOffset = 0x28D0;
    
    // DYLIB: AController::ControlRotation (for mouse input)
    int MouseOffset = 0x4E0;
    
    // DYLIB: APlayerController::PlayerCameraManager
    int CameraManagerOffset = 0x548;
    
    // DYLIB: Camera angle offset
    int AngleOffset = 0x558;

    namespace CameraManagerParam {
        // DYLIB: APlayerCameraManager::CameraCache + POV
        // FMinimalViewInfo structure at offset
        int PovOffset = 0x520 + 0x10; // = 0x530
    }

    namespace ControllerFunction {
        // DYLIB: LineOfSightTo function offset
        int LineOfSightToOffset = 0x7B0;
    }
}

// ============================================
// WORLD/LEVEL OFFSETS
// ============================================

// DYLIB: UWorld::PersistentLevel
int ULevelOffset = 0x30;

namespace ULevelParam {
    // DYLIB: AActor array pointer
    int ObjectArrayOffset = 0xA0;
    
    // DYLIB: Total actor count
    int ObjectCountOffset = 0xA8;
}

// ============================================
// CHARACTER/ACTOR OFFSETS
// ============================================

namespace ObjectParam {
    // DYLIB: Class ID (for class name lookup)
    int ClassIdOffset = 0x18;
    
    // DYLIB: Class name string offset
    int ClassNameOffset = 0xC;

    namespace PlayerFunction {
        // DYLIB: Player movement input functions
        int AddControllerYawInputOffset = 0x890;
        int AddControllerRollInputOffset = 0x888;
        int AddControllerPitchInputOffset = 0x898;
    }

    // ============================================
    // CHARACTER STATE OFFSETS
    // ============================================
    
    // DYLIB: ASTExtraCharacter::CurrentStates (action state)
    int StatusOffset = 0x1058;
    
    // DYLIB: AUAECharacter::TeamID
    int TeamOffset = 0x998;
    
    // DYLIB: AUAECharacter::PlayerName (pointer to string)
    int NameOffset = 0x960;
    
    // DYLIB: ASTExtraCharacter::bIsAI (robot check)
    int RobotOffset = 0xA40;
    
    // DYLIB: ASTExtraCharacter::Health (current HP)
    int HpOffset = 0xE60;
    
    // DYLIB: ASTExtraCharacter::MaxHealth
    int HpmaxOffset = 0xE64;
    
    // DYLIB: ASTExtraCharacter::bDead
    int DeadOffset = 0xE7C;

    // ============================================
    // VEHICLE OFFSETS
    // ============================================
    
    int VehicleCommonComponentOffset = 0xC00;
    int VehicleHPOffset = 0x354;
    int VehicleHPMaxOffset = 0x350;
    int VehicleFuelOffset = 0x43C;
    int VehicleFuelMaxOffset = 0x438;

    // ============================================
    // MESH & BONE OFFSETS
    // ============================================
    
    // DYLIB: ACharacter::Mesh (skeletal mesh component)
    int MeshOffset = 0x510;
    
    // DYLIB: USkinnedMeshComponent bone count
    int BoneCountOffset = 0x8D0;

    namespace MeshParam {
        // DYLIB: CachedComponentSpaceTransforms - absolute bone positions
        // This is the skeleton cache for human characters
        int HumanOffset = 0xC40;
        
        // DYLIB: USkinnedMeshComponent::CachedBoneSpaceTransforms
        // This is the bone transform array
        int BonesOffset = 0x988;
    }

    // ============================================
    // WEAPON & FIRING STATE
    // ============================================
    
    // DYLIB: ASTExtraBaseCharacter::bIsWeaponFiring
    int OpenFireOffset = 0x1800;
    
    // DYLIB: ASTExtraCharacter::bIsGunADS (aiming down sights)
    int OpenTheSightOffset = 0x1134;

    // ============================================
    // WEAPON MANAGEMENT
    // ============================================
    
    // DYLIB: ASTExtraBaseCharacter::WeaponManagerComponent
    int WeaponManagerComponentOffset = 0x25B8;
    
    // DYLIB: UWeaponManagerComponent::CurrentWeaponReplicated
    int WeaponOneOffset = 0x5C8;

    namespace WeaponParam {
        // DYLIB: Weapon master/owner pointer
        int MasterOffset = 0x110;
        
        // DYLIB: ASTExtraShootWeapon::ShootMode (semi/full auto)
        int ShootModeOffset = 0x10D9;
        
        // DYLIB: UShootWeaponEntity component
        int WeaponAttrOffset = 0x1360;

        namespace WeaponAttrParam {
            // DYLIB: UShootWeaponEntity::BulletFireSpeed
            int BulletSpeedOffset = 0x560;
            
            // DYLIB: UShootWeaponEntity::RecoilKickADS
            int RecoilOffset = 0xCF0;
        }
    }

    // ============================================
    // ITEMS/LOOT BOX OFFSETS
    // ============================================
    
    // DYLIB: APickUpListWrapperActor::PickUpDataList
    int GoodsListOffset = 0x940;
    
    namespace GoodsListParam {
        // Offset for each item in goods list
        int DataBase = 0x38;
    }

    // ============================================
    // MOVEMENT & COORDINATES
    // ============================================
    
    // DYLIB: AActor::RootComponent
    int RootComponentOffset = 0x208;
    
    // DYLIB: Character movement velocity
    int MoveCoordOffset = 0x110;
    
    // DYLIB: Actor location
    int CoordOffset = 0x208;

    namespace CoordParam {
        // DYLIB: Actor Z coordinate (height)
        int HeightOffset = 0x1DC;
        
        // DYLIB: Actor X, Y, Z coordinates (FVector)
        int CoordOffset = 0x1C8;
    }
}

// ============================================
// BONE IDs (HUMAN SKELETON STRUCTURE)
// ============================================
// These are indices into the bone array for different body parts

namespace BoneIds {
    // DYLIB: Main skeleton bones
    int Pelvis = 0;           // Root bone
    int LeftHip = 4;
    int LeftKnee = 5;
    int LeftAnkle = 6;
    int Spine = 7;            // Chest/torso
    int RightHip = 8;
    int Head = 9;             // HEAD - Most important for aimbot
    int LeftShoulder = 10;
    int LeftElbow = 11;
    int LeftWrist = 12;
    int RightShoulder = 14;
    int RightElbow = 15;
    int RightWrist = 16;
    int RightKnee = 22;
    int RightAnkle = 23;
}

// ============================================
// BOT DETECTION CLASSES
// ============================================

namespace BotDetectionClasses {
    // DYLIB verified bot class names for 4.3 version
    const char* BOT_CLASSES[] = {
        "NewFakePlayerAIPawn",
        "BP_FakePlayer",
        "FakePlayer_AIPawn",
        "FakePlayerAIPawn",
        "_PlayerPawn_TPlanAI_C",
        "AIPawn",
        "AICharacter"
    };
    
    const int BOT_CLASS_COUNT = 7;
}

// ============================================
// HELPER FUNCTIONS
// ============================================

inline bool isValidAddress(uintptr_t addr) {
    return addr > 0x100000 && addr < 0x10000000000UL;
}

inline bool isValidOffset(int offset) {
    return offset >= 0 && offset < 0x10000;
}

} // namespace PubgOffset

// ============================================
// COMPATIBILITY WITH OLDER CODE
// ============================================
// If other files use old namespace structure, add compatibility layer here

namespace ObjectParam = PubgOffset::ObjectParam;
namespace PlayerControllerParam = PubgOffset::PlayerControllerParam;
namespace ULevelParam = PubgOffset::ULevelParam;
namespace BoneIds = PubgOffset::BoneIds;