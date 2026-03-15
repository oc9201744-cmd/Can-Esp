#include <stdio.h>
#include <string>

namespace PubgOffset {

int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};

namespace PlayerControllerParam {

int SelfOffset = 0x28D0;           // 4.3 SDK: STExtraBaseCharacter ptr
int MouseOffset = 0x4e0;
int CameraManagerOffset = 0x548;
int AngleOffset = 0x558;

namespace CameraManagerParam {
int PovOffset = 0x520 + 0x10;     // 4.3 SDK: CameraCache::POV
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

int StatusOffset = 0x1058;         // 4.3 SDK: CurrentStates
int TeamOffset = 0x998;            // 4.3 SDK: TeamID
int NameOffset = 0x960;            // 4.3 SDK: PlayerName
int RobotOffset = 0xA40;           // 4.3 SDK: bIsAI (AUAECharacter)
int HpOffset = 0xE60;              // 4.3 SDK: Health
int HpmaxOffset = 0xE64;           // 4.3 SDK: HealthMax
int DeadOffset = 0xE7C;            // 4.3 SDK: bDead

int VehicleCommonComponentOffset = 0xC00;  // 4.3 SDK
int VehicleHPOffset = 0x354;
int VehicleHPMaxOffset = 0x350;
int VehicleFuelOffset = 0x43C;
int VehicleFuelMaxOffset = 0x438;

int MoveCoordOffset = 0x110;
int MeshOffset = 0x510;
int boneCountOffset = 0x8d0;

namespace MeshParam {
int HumanOffset = 0x210;
int BonesOffset = 0xC40;           // 4.3 SDK: CachedComponentSpaceTransforms
}

int OpenFireOffset = 0x1800;       // 4.3 SDK: bIsWeaponFiring
int OpenTheSightOffset = 0x3D48;   // 4.3 SDK: bIsOpenWeaponSight

// 4.3: 2 adimli okuma
// Adim 1: character + WeaponManagerComponentOffset -> UCharacterWeaponManagerComponent*
// Adim 2: weaponMgr + WeaponOneOffset -> ASTExtraWeapon* CurrentWeaponSimulate
int WeaponManagerComponentOffset = 0x25B8;  // 4.3 SDK
int WeaponOneOffset = 0x05D8;               // 4.3 SDK: CurrentWeaponSimulate

namespace WeaponParam {

int MasterOffset = 0x110;
int ShootModeOffset = 0x10D9;      // 4.3 SDK
int WeaponAttrOffset = 0x1360;     // 4.3 SDK: ShootWeaponEntityComp

namespace WeaponAttrParam {
int BulletSpeedOffset = 0x560;
int RecoilOffset = 0xcf0;
}

}

int GoodsListOffset = 0x940;

namespace GoodsListParam {
int DataBase = 0x38;
}

int CoordOffset = 0x208;

namespace CoordParam {
int HeightOffset = 0x1dc;
int CoordOffset = 0x1c8;
}

}

}
