#include <stdio.h>
#include <string>

namespace PubgOffset {

// PlayerController zinciri: gWorld+0x38->NetDriver, +0x78->ServerConnection, +0x98->PlayerController, +0x30->LocalPlayerController
int PlayerControllerOffset[4] = {0x38, 0x78, 0x98, 0x30};

namespace PlayerControllerParam {

int SelfOffset = 0x28E0;          // kSTBaseCharacter
int MouseOffset = 0x4e0;          // kControlRotation
int CameraManagerOffset = 0x548;  // kPlayerCameraManager
int AngleOffset = 0x558;

namespace CameraManagerParam {
int PovOffset = 0x520 + 0x10;     // kCameraCache + 0x10
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
int AddControllerYawInputOffset   = 0x890;  // kYaw
int AddControllerRollInputOffset  = 0x888;  // kRoll
int AddControllerPitchInputOffset = 0x888;  // kPitch
}

int StatusOffset = 0x1058;        // kCurrentStates
int TeamOffset = 0x998;           // kTeamID
int NameOffset = 0x960;           // kPlayerName
int RobotOffset = 0xa40;          // kbIsAI (bool 1 byte)
int HpOffset = 0xe60;             // kHealth
int HpmaxOffset = 0xe64;          // kHealthMax
int DeadOffset = 0xe7c;           // kbDead

int VehicleCommonComponentOffset = 0xc00;  // kVehicleCommon
int VehicleHPOffset = 0x354;              // kHP
int VehicleHPMaxOffset = 0x350;           // kHPMax
int VehicleFuelOffset = 0x43c;            // kFuel
int VehicleFuelMaxOffset = 0x438;         // kFuelMax

int MoveCoordOffset = 0x110;      // kRepMovement
int MeshOffset = 0x510;           // kMesh
int boneCountOffset = 0x8d0;

namespace MeshParam {
int HumanOffset = 0x210;
int BonesOffset = 0xC40;
}

int OpenFireOffset = 0x1800;      // kbIsWeaponFiring
int OpenTheSightOffset = 0x1134;  // kbIsGunADS

// silah 2 adimda: character+WeaponManagerComponentOffset -> weaponMgr+WeaponOneOffset -> weapon
int WeaponManagerComponentOffset = 0x25b8;  // kWeaponManagerComponent
int WeaponOneOffset = 0x5c8;               // kCurrentWeaponReplicated

namespace WeaponParam {

int MasterOffset = 0x110;
int ShootModeOffset = 0x10d9;     // kShootMode
int WeaponAttrOffset = 0x1360;    // kShootWeaponEntityComp

namespace WeaponAttrParam {
int BulletSpeedOffset = 0x560;    // kBulletFireSpeed
int RecoilOffset = 0xcf0;         // kRecoilKickADS
}

}

int GoodsListOffset = 0x940;      // kPickUpDataList
namespace GoodsListParam {
int DataBase = 0x38;              // kGoodsID
}

int CoordOffset = 0x208;          // kRootComponent

namespace CoordParam {
int HeightOffset = 0x1dc;         // kCoord
int CoordOffset = 0x1c8;          // kHeight
}

}

}
