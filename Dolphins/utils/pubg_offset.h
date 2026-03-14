#include <stdio.h>
#include <string>

namespace PubgOffset {

int PlayerControllerOffset[3] = {0x470, 0x48, 0x30};

namespace PlayerControllerParam {

int SelfOffset = 0x28d0;
int MouseOffset = 0x4e0;
int CameraManagerOffset = 0x548;
int AngleOffset = 0x558;

namespace CameraManagerParam {
int PovOffset = 0x520 + 0x10;
}

namespace ControllerFunction {
int LineOfSightToOffset = 0x7B0;
}

}

int ULevelOffset = 0x30;

namespace ULevelParam {
int ObjectArrayOffset = 0x28;
int ObjectCountOffset = 0x30;
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
int TeamOffset = 0x1150;
int NameOffset = 0x15C8;
int RobotOffset = 0x4968;
int HpOffset = 0xe60;
int HpmaxOffset = 0xe64;
int DeadOffset = 0xe7c;

int VehicleCommonComponentOffset = 0xbf0;
int VehicleHPOffset = 0x344;
int VehicleHPMaxOffset = 0x340;
int VehicleFuelOffset = 0x424;
int VehicleFuelMaxOffset = 0x420;

int MoveCoordOffset = 0x518;
int MeshOffset = 0x510;
int boneCountOffset = 0x8d0;

namespace MeshParam {
int HumanOffset = 0xc40;
int BonesOffset = 0x988;
}

int OpenFireOffset = 0x1788;
int OpenTheSightOffset = 0x10e1;

int WeaponOneOffset = 0x25B8;

namespace WeaponParam {

int MasterOffset = 0x5C8;
int ShootModeOffset = 0x1089;
int WeaponAttrOffset = 0x12c0;

namespace WeaponAttrParam {
int BulletSpeedOffset = 0x560;
int RecoilOffset = 0xcf0;
}

}

int GoodsListOffset = 0x2EF8;

namespace GoodsListParam {
int DataBase = 0x490;
}

int CoordOffset = 0x208;

namespace CoordParam {
int HeightOffset = 0x1ec;
int CoordOffset = 0x1e4;
}

}

}
