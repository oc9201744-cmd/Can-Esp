#include <stdio.h>
#include <string>

namespace PubgOffset {

// UObjectArray -> ObjObjects (TUObjectArray)
// FUObjectItem::Object = 0x0, Size = 0x18
int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};

namespace PlayerControllerParam {

// UObject: ClassPrivate = 0x10, NamePrivate = 0x18, OuterPrivate = 0x20
// UStruct: SuperStruct = 0x30, Children = 0x38, PropertiesSize = 0x40
// UFunction: EFunctionFlags = 0x88, NumParams = 0x8c, ParamSize = 0x8e, Func = 0xb0
int SelfOffset = 0x28D0;          // ASTExtraPlayerController::STExtraBaseCharacter (güncel kalabilir)
int MouseOffset = 0x4e0;
int CameraManagerOffset = 0x548;  // APlayerController::PlayerCameraManager
int AngleOffset = 0x558;

namespace CameraManagerParam {
// APlayerCameraManager::CameraCache (UCameraCacheEntry) + POV (FMinimalViewInfo)
// FMinimalViewInfo: Location = 0x0, Rotation = 0x18, FOV = 0x24
int PovOffset = 0x520 + 0x10;     // CameraCache + POV offset
}

namespace ControllerFunction {
// UFunction::Func = 0xb0 (Offsets.hpp'den)
int LineOfSightToOffset = 0x7B0;  // Virtual function index * 8 (güncel kalabilir)
}

}

// UWorld::PersistentLevel = 0x30 (genellikle)
int ULevelOffset = 0x30;

namespace ULevelParam {
// TUObjectArray: Objects = 0x0, NumElements = 0xc
int ObjectArrayOffset = 0xA0;     // ULevel::Actors (TArray<AActor*>)
int ObjectCountOffset = 0xA8;     // TArray::Num
}

namespace ObjectParam {

// UObject: ClassPrivate = 0x10, NamePrivate = 0x18
// FName: ComparisonIndex = 0x0, Number = 0x4, Size = 0x8
int ClassIdOffset = 0x18;         // UObject::ClassPrivate (0x10) -> UClass::Name (0x18)
int ClassNameOffset = 0xC;        // FNameEntry::Name = 0xc

namespace PlayerFunction {
// APlayerController virtual functions
int AddControllerYawInputOffset   = 0x890;  // Virtual index * 8
int AddControllerRollInputOffset  = 0x888;
int AddControllerPitchInputOffset = 0x898;
}

// ASTExtraCharacter offsets (dump'taki yapılara göre ayarlandı)
int StatusOffset  = 0x1058;       // ASTExtraCharacter::CurrentStates (uint64)
int TeamOffset    = 0x998;        // AUAECharacter::TeamID (int32)
int NameOffset    = 0x960;        // AUAECharacter::PlayerName (FString)
                                  // FString: Data = 0x0, Num = 0x8, Max = 0xc
int RobotOffset   = 0xa40;        // AUAECharacter::bIsAI (bool)
int HpOffset      = 0xe60;        // ASTExtraCharacter::Health (float)
int HpmaxOffset   = 0xe64;        // ASTExtraCharacter::HealthMax (float)
int DeadOffset    = 0xe7c;        // ASTExtraCharacter::bDead (bool)

// ACharacter::CharacterMovement = 0x4c0 (tipik)
// UVehicleCommonComponent
int VehicleCommonComponentOffset = 0xc00;
int VehicleHPOffset              = 0x354;  // UVehicleCommonComponent::Health
int VehicleHPMaxOffset           = 0x350;  // UVehicleCommonComponent::HealthMax
int VehicleFuelOffset            = 0x43c;  // UVehicleCommonComponent::Fuel
int VehicleFuelMaxOffset         = 0x438;  // UVehicleCommonComponent::FuelMax

// UCharacterMovementComponent
int MoveCoordOffset = 0x110;      // UCharacterMovementComponent::Velocity (FVector)

// ACharacter::Mesh = 0x510 (USkeletalMeshComponent*)
int MeshOffset      = 0x510;
int boneCountOffset = 0x8d0;      // USkeletalMeshComponent::Bones (TArray)

namespace MeshParam {
// USkeletalMeshComponent::SkeletalMesh + offsets
int HumanOffset = 0x210;          // USkeletalMesh::Skeleton
// USkinnedMeshComponent::CachedComponentSpaceTransforms (TArray<FTransform>)
int BonesOffset = 0x988;          // CachedComponentSpaceTransforms
}

// ASTExtraBaseCharacter::bIsWeaponFiring
int OpenFireOffset     = 0x1800;
// ASTExtraCharacter::bIsGunADS  
int OpenTheSightOffset = 0x1134;

// UWeaponManagerComponent
int WeaponManagerComponentOffset = 0x25B8;  // ASTExtraBaseCharacter::WeaponManagerComponent
int WeaponOneOffset              = 0x5C8;   // UWeaponManagerComponent::CurrentWeaponReplicated

namespace WeaponParam {
int MasterOffset    = 0x110;      // ASTExtraWeapon::WeaponOwner
int ShootModeOffset = 0x10D9;     // ASTExtraWeapon::ShootMode (uint8)
int WeaponAttrOffset = 0x1360;    // ASTExtraWeapon::WeaponAttr

namespace WeaponAttrParam {
int BulletSpeedOffset = 0x560;    // WeaponAttr::BulletSpeed
int RecoilOffset      = 0xcf0;    // WeaponAttr::RecoilInfo
}
}

// UGoodsListComponent
int GoodsListOffset = 0x940;      // AUAECharacter::GoodsListComponent
namespace GoodsListParam {
int DataBase = 0x38;              // TArray base
}

// AActor::RootComponent = 0x200 (USceneComponent*)
int CoordOffset = 0x208;          // RootComponent

namespace CoordParam {
// USceneComponent::RelativeLocation, RelativeRotation
int HeightOffset = 0x1dc;         // RelativeLocation.Z (FVector Z offset: 0x8)
int CoordOffset  = 0x1c8;         // RelativeLocation (FVector: X=0x0, Y=0x4, Z=0x8)
}

}

}
