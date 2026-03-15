#include <stdio.h>
#include <string>

namespace PubgOffset {

int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};

namespace PlayerControllerParam {

int SelfOffset = 0x28D0;           // ASTExtraPlayerController::STExtraBaseCharacter [DUMP ✅]
int MouseOffset = 0x4E0;           // AController::ControlRotation [DUMP ✅]
int CameraManagerOffset = 0x548;   // APlayerController::PlayerCameraManager [DUMP ✅]
int AngleOffset = 0x558;           // APlayerController::PlayerCameraManagerClass [DUMP ✅]

namespace CameraManagerParam {
int PovOffset = 0x520 + 0x10;      // FCameraCacheEntry::POV [DUMP ✅]
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

int ClassIdOffset = 0x18;
int ClassNameOffset = 0xC;

namespace PlayerFunction {
int AddControllerYawInputOffset   = 0x890;
int AddControllerRollInputOffset  = 0x898;
int AddControllerPitchInputOffset = 0x888;
}

int StatusOffset = 0x1058;         // STExtraCharacter::CurrentStates uint64 [DUMP ✅]
int TeamOffset = 0x998;            // UAECharacter::TeamID [DUMP ✅]
int NameOffset = 0x960;            // UAECharacter::PlayerName [DUMP ✅]
int RobotOffset = 0xA40;           // UAECharacter::bIsAI [DUMP ✅]
int HpOffset = 0xE60;              // STExtraCharacter::Health [DUMP ✅]
int HpmaxOffset = 0xE64;           // STExtraCharacter::HealthMax [DUMP ✅]
int DeadOffset = 0xE7C;            // STExtraCharacter::bDead [DUMP ✅]

int VehicleCommonComponentOffset = 0xC00;  // STExtraVehicleBase::VehicleCommon [DUMP ✅]
int VehicleHPOffset = 0x354;              // VehicleCommonComponent::Hp [DUMP ✅]
int VehicleHPMaxOffset = 0x350;           // VehicleCommonComponent::HPMax [DUMP ✅]
int VehicleFuelOffset = 0x43C;            // VehicleCommonComponent::Fuel [DUMP ✅]
int VehicleFuelMaxOffset = 0x438;         // VehicleCommonComponent::FuelMax [DUMP ✅]

int MoveCoordOffset = 0x110;       // AActor::ReplicatedMovement [DUMP ✅]
int MeshOffset = 0x510;            // ACharacter::Mesh [DUMP ✅]
int boneCountOffset = 0x8D0;

namespace MeshParam {
int HumanOffset = 0x1B8;           // USkeletalMeshComponent ComponentToWorld (non-SIMD FTransform) [DUMP analysis]
int BonesOffset = 0xC40;           // USkeletalMeshComponent::CachedComponentSpaceTransforms [DUMP ✅]
}

int OpenFireOffset = 0x1800;       // STExtraBaseCharacter::bIsWeaponFiring [DUMP ✅]
int OpenTheSightOffset = 0x3D48;   // STExtraBaseCharacter::bIsOpenWeaponSight [DUMP ✅]

// 4.3: silah 2 adimda okunuyor
// adim 1: character + WeaponManagerComponentOffset -> UCharacterWeaponManagerComponent*
// adim 2: weaponMgr  + WeaponOneOffset             -> ASTExtraWeapon* (CurrentWeaponSimulate)
int WeaponManagerComponentOffset = 0x25B8;  // STExtraBaseCharacter::WeaponManagerComponent [DUMP ✅]
int WeaponOneOffset = 0x05D8;               // UWeaponManagerComponent::CurrentWeaponSimulate [DUMP ✅]

namespace WeaponParam {

int MasterOffset = 0x110;
int ShootModeOffset = 0x10D9;      // STExtraShootWeapon::ShootMode [DUMP ✅]
int WeaponAttrOffset = 0x1360;     // STExtraShootWeapon::ShootWeaponEntityComp [DUMP ✅]

namespace WeaponAttrParam {
int BulletSpeedOffset = 0x560;     // UShootWeaponEntity::BulletFireSpeed [DUMP ✅]
int RecoilOffset = 0xCF0;          // UShootWeaponEntity::RecoilKickADS [DUMP ✅]
}

}

int GoodsListOffset = 0x940;

namespace GoodsListParam {
int DataBase = 0x38;
}

int CoordOffset = 0x208;           // AActor::RootComponent [DUMP ✅]

namespace CoordParam {
int HeightOffset = 0x1EC;          // USceneComponent::RelativeLocation.Z [DUMP ✅]
int CoordOffset = 0x1E4;           // USceneComponent::RelativeLocation [DUMP ✅]
}

}

}
