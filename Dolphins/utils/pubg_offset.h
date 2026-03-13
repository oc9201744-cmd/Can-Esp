#include <stdio.h>
#include <string>

namespace PubgOffset {

int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};

namespace PlayerControllerParam {

int SelfOffset = 0x28D0;
int MouseOffset = 0x4e0;
int CameraManagerOffset = 0x548;
int AngleOffset = 0x558;

namespace CameraManagerParam {
int PovOffset = 0x10a0 + 0x10;
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

int StatusOffset = 0x065C; // Health (Can)
int StatusOffset_State = 0x2B78; // HealthStatus (Durum)
int TeamOffset = 0x998;
int NameOffset = 0x960;
int RobotOffset = 0xA40;
int HpOffset = 0xE60;
int HpmaxOffset = 0xE64;
int DeadOffset = 0xE7C;

int VehicleCommonComponentOffset = 0xC00;
int VehicleHPOffset = 0x354;
int VehicleHPMaxOffset = 0x350;
int VehicleFuelOffset = 0x43C;
int VehicleFuelMaxOffset = 0x438;

int MoveCoordOffset = 0x110;
int MeshOffset = 0x510;
int boneCountOffset = 0x0840;

namespace MeshParam {
int HumanOffset = 0x210;
int BonesOffset = 0x02B8;
}

int OpenFireOffset = 0x1800;
int OpenTheSightOffset = 0x3D48;

// 4.3: silah 2 adimda okunuyor
// adim 1: character + WeaponManagerComponentOffset -> UCharacterWeaponManagerComponent*
// adim 2: weaponMgr  + WeaponOneOffset             -> ASTExtraWeapon* (CurrentWeaponSimulate)
int WeaponManagerComponentOffset = 0x25B8;
int WeaponOneOffset = 0x05D8;

namespace WeaponParam {

int MasterOffset = 0x110;
int ShootModeOffset = 0x10D9;
int WeaponAttrOffset = 0x1360;

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
int HeightOffset = 0x1EC;
int CoordOffset = 0x158;
}

}

}