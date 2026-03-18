//
// Created by XBK on 2022/1/16.
//
#include <stdio.h>
#include <string>
namespace PubgOffset {

int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};

namespace PlayerControllerParam {
// ASTExtraPlayerController::STExtraBaseCharacter
int SelfOffset = 0x28D0;
// AController::ControlRotation
int MouseOffset = 0x4e0;
// APlayerController::PlayerCameraManager
int CameraManagerOffset = 0x548;
int AngleOffset = 0x558;

namespace CameraManagerParam {
// APlayerCameraManager::CameraCache + POV
int PovOffset = 0x520 + 0x10;
}

namespace ControllerFunction {
int LineOfSightToOffset = 0x7B0;
}

}

// UWorld::PersistentLevel
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
int AddControllerRollInputOffset  = 0x888;
int AddControllerPitchInputOffset = 0x898;
}

// ASTExtraCharacter::CurrentStates (uint64)
int StatusOffset  = 0x1058;
// AUAECharacter::TeamID
int TeamOffset    = 0x998;
// AUAECharacter::PlayerName
int NameOffset    = 0x960;
// AUAECharacter::bIsAI
int RobotOffset   = 0xa40;
// ASTExtraCharacter::Health
int HpOffset      = 0xe60;
int HpmaxOffset   = 0xe64;
// ASTExtraCharacter::bDead
int DeadOffset    = 0xe7c;

int VehicleCommonComponentOffset = 0xc00;
int VehicleHPOffset              = 0x354;
int VehicleHPMaxOffset           = 0x350;
int VehicleFuelOffset            = 0x43c;
int VehicleFuelMaxOffset         = 0x438;

int MoveCoordOffset = 0x110;
// ACharacter::Mesh
int MeshOffset      = 0x510;
int boneCountOffset = 0x8d0;

namespace MeshParam {
// CachedComponentSpaceTransforms (absolute)
int HumanOffset = 0xC40;
// USkinnedMeshComponent::CachedBoneSpaceTransforms
int BonesOffset = 0x988;
}

// ASTExtraBaseCharacter::bIsWeaponFiring
int OpenFireOffset     = 0x1800;
// ASTExtraCharacter::bIsGunADS
int OpenTheSightOffset = 0x1134;

// ASTExtraBaseCharacter::WeaponManagerComponent
int WeaponManagerComponentOffset = 0x25B8;
// UWeaponManagerComponent::CurrentWeaponReplicated
int WeaponOneOffset              = 0x5C8;

namespace WeaponParam {
int MasterOffset     = 0x110;
// ASTExtraShootWeapon::ShootMode
int ShootModeOffset  = 0x10D9;
// UShootWeaponEntity* ShootWeaponEntityComp
int WeaponAttrOffset = 0x1360;

namespace WeaponAttrParam {
// UShootWeaponEntity::BulletFireSpeed
int BulletSpeedOffset = 0x560;
// UShootWeaponEntity::RecoilKickADS
int RecoilOffset      = 0xcf0;
}
}

// APickUpListWrapperActor::PickUpDataList
int GoodsListOffset = 0x940;
namespace GoodsListParam {
int DataBase = 0x38;
}

// AActor::RootComponent
int CoordOffset = 0x208;

namespace CoordParam {
int HeightOffset = 0x1dc;
int CoordOffset  = 0x1c8;
}

}

}