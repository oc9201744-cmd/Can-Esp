#include <stdio.h>
#include <string>

namespace PubgOffset {

int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};

namespace PlayerControllerParam {

int SelfOffset = 0x28D0;          // ASTExtraPlayerController::STExtraBaseCharacter
int MouseOffset = 0x4e0;
int CameraManagerOffset = 0x548;
int AngleOffset = 0x558;

namespace CameraManagerParam {
int PovOffset = 0x520 + 0x10;     // APlayerCameraManager::CameraCache + POV
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
int AddControllerRollInputOffset  = 0x888;
int AddControllerPitchInputOffset = 0x898;
}

int StatusOffset  = 0x1058;       // ASTExtraCharacter::CurrentStates (uint64)
int TeamOffset    = 0x998;        // AUAECharacter::TeamID
int NameOffset    = 0x960;        // AUAECharacter::PlayerName (FString.data)
int RobotOffset   = 0xa40;        // AUAECharacter::bIsAI
int HpOffset      = 0xe60;        // ASTExtraCharacter::Health
int HpmaxOffset   = 0xe64;        // ASTExtraCharacter::HealthMax
int DeadOffset    = 0xe7c;        // ASTExtraCharacter::bDead

int VehicleCommonComponentOffset = 0xc00;
int VehicleHPOffset              = 0x354;
int VehicleHPMaxOffset           = 0x350;
int VehicleFuelOffset            = 0x43c;
int VehicleFuelMaxOffset         = 0x438;

int MoveCoordOffset = 0x110;
int MeshOffset      = 0x510;      // ACharacter::Mesh
int boneCountOffset = 0x8d0;

namespace MeshParam {
int HumanOffset = 0x210;
int BonesOffset = 0x988;          // USkinnedMeshComponent::CachedComponentSpaceTransforms
}

int OpenFireOffset     = 0x1800;  // ASTExtraBaseCharacter::bIsWeaponFiring
int OpenTheSightOffset = 0x1134;  // ASTExtraCharacter::bIsGunADS

// Silah: character + WeaponManagerComponentOffset -> mgr + WeaponOneOffset -> weapon
int WeaponManagerComponentOffset = 0x25B8;
int WeaponOneOffset              = 0x5C8;  // UWeaponManagerComponent::CurrentWeaponReplicated

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

int CoordOffset = 0x208;          // AActor::RootComponent

namespace CoordParam {
int HeightOffset = 0x1dc;
int CoordOffset  = 0x1c8;
}

}

}
