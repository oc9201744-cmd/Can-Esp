#include <stdio.h>
#include <string>

namespace PubgOffset {

int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};
uintptr_t gObject = 0x10A34E980;  // Global Object pointer

namespace PlayerControllerParam {

int SelfOffset = 0x28e0;
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
int AddControllerYawInputOffset = 0x890;
int AddControllerRollInputOffset = 0x888;
int AddControllerPitchInputOffset = 0x898;
}

int StatusOffset = 0x1018;
int TeamOffset = 0x998;
int NameOffset = 0x960;
int RobotOffset = 0xa40;
int HpOffset = 0xe60;
int HpmaxOffset = 0xe64;
int DeadOffset = 0xe7c;

int VehicleCommonComponentOffset = 0xc00;
int VehicleHPOffset = 0x354;
int VehicleHPMaxOffset = 0x350;
int VehicleFuelOffset = 0x43c;
int VehicleFuelMaxOffset = 0x438;

int MoveCoordOffset = 0x110;
int MeshOffset = 0x510;
int boneCountOffset = 0x8d0;

namespace MeshParam {
int HumanOffset = 0x210;
int BonesOffset = 0x988;
}

int OpenFireOffset = 0x1800;
int OpenTheSightOffset = 0x10e1;

int WeaponOneOffset = 0x2a30 + 0x20;

namespace WeaponParam {

int MasterOffset = 0x110;
int ShootModeOffset = 0x10d9;
int WeaponAttrOffset = 0x12c0;

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