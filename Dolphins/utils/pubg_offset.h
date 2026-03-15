#include <stdio.h>
#include <string>

namespace PubgOffset {

int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};

namespace PlayerControllerParam {

int SelfOffset = 0x28D0;           // 4.3 [DUMP]
int MouseOffset = 0x4e0;
int CameraManagerOffset = 0x548;
int AngleOffset = 0x558;

namespace CameraManagerParam {
int PovOffset = 0x520 + 0x10;     // 4.3 [DUMP] CameraCache::POV
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

int StatusOffset = 0x1058;         // 4.3 [DUMP] CurrentStates uint64
int TeamOffset = 0x998;
int NameOffset = 0x960;
int RobotOffset = 0xA40;           // 4.3 [DUMP]
int HpOffset = 0xE60;              // 4.3 [DUMP]
int HpmaxOffset = 0xE64;           // 4.3 [DUMP]
int DeadOffset = 0xE7C;            // 4.3 [DUMP]

int VehicleCommonComponentOffset = 0xC00;  // 4.3 [DUMP]
int VehicleHPOffset = 0x354;              // 4.3 [DUMP]
int VehicleHPMaxOffset = 0x350;           // 4.3 [DUMP]
int VehicleFuelOffset = 0x43C;            // 4.3 [DUMP]
int VehicleFuelMaxOffset = 0x438;         // 4.3 [DUMP]

int MoveCoordOffset = 0x110;
int MeshOffset = 0x510;
int boneCountOffset = 0x8d0;

namespace MeshParam {
int HumanOffset = 0x210;           // AYNI
int BonesOffset = 0xC40;           // 4.3 [DUMP] CachedComponentSpaceTransforms
}

int OpenFireOffset = 0x1800;       // 4.3 [DUMP]
int OpenTheSightOffset = 0x3D48;   // 4.3 [DUMP]

// 4.3: silah 2 adimda okunuyor
// adim 1: character + WeaponManagerComponentOffset -> UCharacterWeaponManagerComponent*
// adim 2: weaponMgr + WeaponOneOffset              -> ASTExtraWeapon* CurrentWeaponSimulate
int WeaponManagerComponentOffset = 0x25B8;  // 4.3 [DUMP]
int WeaponOneOffset = 0x05D8;               // 4.3 [DUMP]

namespace WeaponParam {

int MasterOffset = 0x110;
int ShootModeOffset = 0x10D9;      // 4.3 [DUMP]
int WeaponAttrOffset = 0x1360;     // 4.3 [DUMP] ShootWeaponEntityComp

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
int HeightOffset = 0x1dc;          // AYNI - calisiyor
int CoordOffset = 0x1c8;           // AYNI - calisiyor
}

}

}
