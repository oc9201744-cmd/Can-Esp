#include <stdio.h>
#include <string>

namespace PubgOffset {

// PlayerController chain: gWorld+0x38 -> NetDriver+0x78 -> ServerConnection+0x30 -> LocalPC
int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};

namespace PlayerControllerParam {

int SelfOffset          = 0x28E0;  // kSTBaseCharacter
int MouseOffset         = 0x4e0;   // kControlRotation
int CameraManagerOffset = 0x548;   // kPlayerCameraManager
int AngleOffset         = 0x558;

namespace CameraManagerParam {
int PovOffset = 0x10a0 + 0x10;    // kViewTarget + 0x10
}

namespace ControllerFunction {
int LineOfSightToOffset = 0x7B0;   // kLineOfSightTo
}

}

int ULevelOffset = 0x30;           // kPersistentLevel

namespace ULevelParam {
int ObjectArrayOffset = 0xA0;      // kActorList
int ObjectCountOffset = 0xA8;
}

namespace ObjectParam {

int ClassIdOffset   = 0x18;
int ClassNameOffset = 0xC;

namespace PlayerFunction {
int AddControllerYawInputOffset   = 0x890;  // kYaw
int AddControllerRollInputOffset  = 0x888;  // kRoll
int AddControllerPitchInputOffset = 0x898;  // kPitch (0x888 = typo, keep 0x898)
}

int StatusOffset  = 0x1058;  // kCurrentStates  (was 0x1018)
int TeamOffset    = 0x998;   // kTeamID
int NameOffset    = 0x960;   // kPlayerName
int RobotOffset   = 0xa40;   // kbIsAI (was 0xa49, now CONFIRMED 0xa40)
int HpOffset      = 0xe60;   // kHealth        (was 0xe28)
int HpmaxOffset   = 0xe64;   // kHealthMax      (was 0xe2c)
int DeadOffset    = 0xe7c;   // kbDead          (was 0xe44)

int VehicleCommonComponentOffset = 0xc00;   // kVehicleCommon   (was 0xbf0)
int VehicleHPOffset              = 0x354;   // kHP              (was 0x344)
int VehicleHPMaxOffset           = 0x350;   // kHPMax           (was 0x340)
int VehicleFuelOffset            = 0x43c;   // kFuel            (was 0x424)
int VehicleFuelMaxOffset         = 0x438;   // kFuelMax         (was 0x420)

int MoveCoordOffset = 0x110;  // kRepMovement
int MeshOffset      = 0x510;  // kMesh
int boneCountOffset = 0x8d0;

namespace MeshParam {
int HumanOffset = 0x210;
int BonesOffset = 0x988;      // kStaticMesh
}

int OpenFireOffset     = 0x1800;  // kbIsWeaponFiring  (was 0x1788)
int OpenTheSightOffset = 0x1134;  // kbIsGunADS        (was 0x10e1)

// 4.3 iki kademeli silah okuma:
// selfAddr + WeaponManagerComponentOffset -> WeaponManager*
// WeaponManager* + WeaponOneOffset -> CurrentWeapon*
int WeaponManagerComponentOffset = 0x25B8;  // kWeaponManagerComponent
int WeaponOneOffset              = 0x5C8;   // kCurrentWeaponReplicated (was 0x5D8)

namespace WeaponParam {
int MasterOffset    = 0x110;
int ShootModeOffset = 0x10d9;  // kShootMode (was 0x1089)
int WeaponAttrOffset = 0x12c0;

namespace WeaponAttrParam {
int BulletSpeedOffset = 0x560;  // kBulletFireSpeed
int RecoilOffset      = 0xcf0;  // kRecoilKickADS
}

}

int GoodsListOffset = 0x940;  // kPickUpDataList

namespace GoodsListParam {
int DataBase = 0x38;  // kGoodsID
}

int CoordOffset = 0x208;  // kRootComponent

namespace CoordParam {
int HeightOffset = 0x1dc;  // kCoord (height/Z)
int CoordOffset  = 0x1c8;  // kHeight (XY position)
}

// Bot tespiti offsetleri (4.3 SDK dogrulandi)
int bIsAIOffset   = 0xa40;  // kbIsAI
int bIsMLAIOffset = 0xa41;  // kbIsMLAI

// PlayerState (bot tespiti icin alternatif yol)
int PlayerStateOffset = 0x2308;  // kPlayerState

}

}
