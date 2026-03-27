#include <stdio.h>
#include <string>

namespace PubgOffset {

// ============================================================
// UWorld / ULevel - AIOHeader.hpp: UWorld->PersistentLevel at 0x30
// ============================================================
int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};

int ULevelOffset = 0x30;                    // UWorld::PersistentLevel

namespace ULevelParam {
    int ObjectArrayOffset = 0xA0;            // ULevel::Actors (TArray)
    int ObjectCountOffset = 0xA8;            // ULevel::Actors.Num()
}

// ============================================================
// PlayerController - AIOHeader.hpp: APlayerController structure
// ============================================================
namespace PlayerControllerParam {
    int SelfOffset = 0x4B8;                  // AController::Pawn (APawn*)
    int MouseOffset = 0x6DC;                 // APlayerController::InputYawScale (veya ilgili)
    int CameraManagerOffset = 0x548;         // APlayerController::PlayerCameraManager (APlayerCameraManager*)
    int AngleOffset = 0x558;                 // APlayerController::ControlRotation (FRotator)
    
    namespace CameraManagerParam {
        int PovOffset = 0x10;                // APlayerCameraManager::CameraCache.POV (FMinimalViewInfo)
    }
    
    namespace ControllerFunction {
        int LineOfSightToOffset = 0x780;     // AController::LineOfSightTo fonksiyonu
    }
}

// ============================================================
// Object/Character - AIOHeader.hpp: AActor / ACharacter
// ============================================================
namespace ObjectParam {
    int ClassIdOffset = 0x18;                // UObject::ClassPrivate? (için)
    int ClassNameOffset = 0xC;               // isim için
    
    // Player functions (APawn)
    namespace PlayerFunction {
        int AddControllerYawInputOffset = 0x890;    // APawn::AddControllerYawInput
        int AddControllerRollInputOffset = 0x888;   // APawn::AddControllerRollInput
        int AddControllerPitchInputOffset = 0x898;  // APawn::AddControllerPitchInput
    }
    
    // ============================================================
    // CRITICAL: AIOHeader.hpp'de bu alanlar APlayerState'de
    // Character'den PlayerState'e gitmeniz gerekiyor
    // ============================================================
    int PlayerStateOffset = 0x4D0;           // AActor::PlayerState (APlayerState*)
    
    // Bu alanlar APlayerState'de - AIOHeader.hpp:
    // APlayerState::TeamID = 0x604
    // APlayerState::PlayerName = 0x4B8 (FString)
    // APlayerState::bIsABot = 0x4DC
    // ASTExtraPlayerState::PlayerHealth = 0x1424
    int TeamOffset = 0x604;                  // APlayerState::TeamID
    int NameOffset = 0x4B8;                  // APlayerState::PlayerName (FString*)
    int RobotOffset = 0x4DC;                 // APlayerState::bIsABot (uint8)
    int HealthOffset = 0x1424;               // ASTExtraPlayerState::PlayerHealth
    int HealthMaxOffset = 0x1428;            // ASTExtraPlayerState::PlayerHealthMax
    
    // Character state - AIOHeader.hpp: ACharacter
    int StatusOffset = 0x1058;               // ACharacter::CurrentStates (EPawnState flags)
    int bIsCrouchedOffset = 0x5D4;           // ACharacter::bIsCrouched
    int bIsDeadOffset = 0x5D6;               // ACharacter::bIsDead? (veya EPawnState)
    
    // Movement - AIOHeader.hpp: ACharacter
    int MoveCoordOffset = 0x110;             // ACharacter::ReplicatedMovement (FRepMovement)
    int CoordOffset = 0x208;                 // AActor::RootComponent (USceneComponent*)
    
    namespace CoordParam {
        int HeightOffset = 0x1DC;            // USceneComponent::RelativeLocation.Z? veya bounds
        int CoordOffset = 0x1C8;             // USceneComponent::RelativeLocation
    }
    
    // Mesh - AIOHeader.hpp: ACharacter::Mesh at 0x510
    int MeshOffset = 0x510;                  // ACharacter::Mesh (USkeletalMeshComponent*)
    int boneCountOffset = 0x8D0;             // USkeletalMeshComponent::GetNumBones? (için)
    
    namespace MeshParam {
        int HumanOffset = 0x210;              // USkinnedMeshComponent::CachedBoneSpaceTransforms? (FTransform)
        int BonesOffset = 0xC40;              // USkinnedMeshComponent::CachedComponentSpaceTransforms (TArray<FTransform>)
    }
    
    // Weapon - AIOHeader.hpp: ACharacter->WeaponManager
    int WeaponManagerComponentOffset = 0x25B8;  // ASTExtraCharacter::WeaponManagerComponent
    int WeaponOneOffset = 0x5C8;                // UWeaponManagerComponent::CurrentWeaponReplicated
    
    // Weapon attributes - AIOHeader.hpp: UWeaponEntity
    namespace WeaponParam {
        int MasterOffset = 0x110;               // UWeaponEntity::MasterWeapon
        int ShootModeOffset = 0x10D9;           // UWeaponEntity::ShootMode (uint8)
        int WeaponAttrOffset = 0x1360;          // UWeaponEntity::WeaponAttribute
        
        namespace WeaponAttrParam {
            int BulletSpeedOffset = 0x560;      // UWeaponAttribute::BulletSpeed
            int RecoilOffset = 0xCF0;           // UWeaponAttribute::Recoil
        }
    }
    
    // Firing state - AIOHeader.hpp: ASTExtraBaseCharacter
    int OpenFireOffset = 0x1800;                // ASTExtraBaseCharacter::bIsWeaponFiring
    int OpenTheSightOffset = 0x1134;            // ASTExtraCharacter::bIsGunADS
    
    // Loot box
    int GoodsListOffset = 0x940;                // UActor::GoodsList (TArray)
    
    namespace GoodsListParam {
        int DataBase = 0x38;                    // Her bir item için offset
    }
    
    // Vehicle - AIOHeader.hpp: ASTExtraVehicle
    int VehicleCommonComponentOffset = 0xC00;   // ASTExtraVehicle::VehicleCommonComponent
    int VehicleHPOffset = 0x354;                // UVehicleCommonComponent::Health
    int VehicleHPMaxOffset = 0x350;             // UVehicleCommonComponent::HealthMax
    int VehicleFuelOffset = 0x43C;              // UVehicleCommonComponent::Fuel
    int VehicleFuelMaxOffset = 0x438;           // UVehicleCommonComponent::FuelMax
}

}
