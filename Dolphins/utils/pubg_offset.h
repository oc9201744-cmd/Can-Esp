#include <stdio.h>
#include <string>

namespace PubgOffset {

// UWorld+0x38=NetDriver, NetDriver+0x78=ServerConnection(UNetConnection), ServerConnection+0x30=PlayerController
int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};

namespace PlayerControllerParam {
int SelfOffset          = 0x28D0;  // ASTExtraPlayerController::STExtraBaseCharacter
int MouseOffset         = 0x4e0;   // APlayerController::ControlRotation
int CameraManagerOffset = 0x548;   // APlayerController::PlayerCameraManager
int AngleOffset         = 0x558;

namespace CameraManagerParam {
int PovOffset = 0x520 + 0x10;      // APlayerCameraManager::CameraCache + POV offset
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

int ClassIdOffset   = 0x18;
int ClassNameOffset = 0xC;

namespace PlayerFunction {
int AddControllerYawInputOffset   = 0x890;
int AddControllerRollInputOffset  = 0x898;
int AddControllerPitchInputOffset = 0x888;
}

int StatusOffset = 0x1058;         // ASTExtraCharacter::CurrentStates
int TeamOffset   = 0x998;          // AUAECharacter::TeamID
int NameOffset   = 0x960;          // AUAECharacter::PlayerName (FString)
int RobotOffset  = 0xa40;          // AUAECharacter::bIsAI (1 byte bool)
int HpOffset     = 0xe60;          // ASTExtraCharacter::Health
int HpmaxOffset  = 0xe64;          // ASTExtraCharacter::HealthMax
int DeadOffset   = 0xe7c;          // ASTExtraCharacter::bDead (bit field)

int VehicleCommonComponentOffset = 0xc00;
int VehicleHPOffset              = 0x354;
int VehicleHPMaxOffset           = 0x350;
int VehicleFuelOffset            = 0x43c;
int VehicleFuelMaxOffset         = 0x438;

int MoveCoordOffset  = 0x110;      // kRepMovement
int MeshOffset       = 0x510;      // ACharacter::Mesh
int boneCountOffset  = 0x8d0;

namespace MeshParam {
int HumanOffset = 0x210;
int BonesOffset = 0xC40;           // USkinnedMeshComponent::CachedComponentSpaceTransforms
}

int OpenFireOffset      = 0x1800;  // ASTExtraBaseCharacter::bIsWeaponFiring (bool)
int OpenTheSightOffset  = 0x1134;  // ASTExtraCharacter::bIsGunADS (bool)

// Silah: character+WeaponManagerComponentOffset -> weaponMgr+WeaponOneOffset
int WeaponManagerComponentOffset = 0x25B8;  // ASTExtraBaseCharacter::WeaponManagerComponent
int WeaponOneOffset              = 0x5C8;   // UWeaponManagerComponent::CurrentWeaponReplicated

namespace WeaponParam {
int MasterOffset    = 0x110;
int ShootModeOffset = 0x10D9;
int WeaponAttrOffset = 0x1360;

namespace WeaponAttrParam {
int BulletSpeedOffset = 0x560;
int RecoilOffset      = 0xcf0;
}
}

int GoodsListOffset = 0x940;
namespace GoodsListParam {
int DataBase = 0x38;
}

int CoordOffset = 0x208;           // AActor::RootComponent

namespace CoordParam {
int CoordOffset  = 0x1E4;          // USceneComponent::RelativeLocation (x,y,z)
int HeightOffset = 0x1EC;          // RelativeLocation.z
}

}
}
