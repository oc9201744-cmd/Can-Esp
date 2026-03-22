# PUBG Mobile Offset Header – Updated with Current Offsets

## File: pubg_offset.h

```cpp
#include <stdio.h>
#include <string>

namespace PubgOffset {

// Global offsets – Updated from provided define values
namespace Global {
    const long gobject = 0x10A34E980;
    const long gname_func = 0x104bd8740;
    const long gname_data = 0x10a1178b0;
    const long gworld_func = 0x102A62208;
    const long gworld_data = 0x10A566E00;
}

// PlayerController chain: NetDriver -> ServerConnection -> PlayerController
int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};

namespace PlayerControllerParam {

int SelfOffset = 0x28E0;          // kSTBaseCharacter
int MouseOffset = 0x4e0;          // kControlRotation
int CameraManagerOffset = 0x548;  // kPlayerCameraManager
int AngleOffset = 0x558;

namespace CameraManagerParam {
int PovOffset = 0x530;            // kCameraCache + 0x10 (0x520 + 0x10)
}

namespace ControllerFunction {
int LineOfSightToOffset = 0x7B0;  // kLineOfSightTo
}

}

int ULevelOffset = 0x30;            // kPersistentLevel

namespace ULevelParam {
int ObjectArrayOffset = 0xA0;       // kActorList
int ObjectCountOffset = 0xA8;       // kActorList + 0x8
}

namespace ObjectParam {

int ClassIdOffset = 0x18;
int ClassNameOffset = 0xC;

namespace PlayerFunction {
int AddControllerYawInputOffset = 0x890;   // kYaw
int AddControllerRollInputOffset = 0x888;  // kRoll
int AddControllerPitchInputOffset = 0x898; // kPitch
}

int StatusOffset = 0x1058;        // kCurrentStates
int TeamOffset = 0x998;           // kTeamID
int NameOffset = 0x960;           // kPlayerName
int RobotOffset = 0xa40;          // kbIsAI
int HpOffset = 0xe60;             // kHealth
int HpmaxOffset = 0xe64;          // kHealthMax
int DeadOffset = 0xe7c;           // kbDead
int NearDeathBreathOffset = 0x1b60;      // kNearDeathBreath
int NearDeathComponentOffset = 0x1be8;   // kNearDeatchComponent

int VehicleCommonComponentOffset = 0xc00;  // kVehicleCommon
int VehicleHPOffset = 0x354;      // kHP
int VehicleHPMaxOffset = 0x350;   // kHPMax
int VehicleFuelOffset = 0x43c;    // kFuel
int VehicleFuelMaxOffset = 0x438; // kFuelMax

int MoveCoordOffset = 0x110;      // kRepMovement
int MeshOffset = 0x510;           // kMesh
int boneCountOffset = 0x8d0;

namespace MeshParam {
int HumanOffset = 0x210;          // kRelativeLocation base
int BonesOffset = 0x988;          // kStaticMesh
}

int OpenFireOffset = 0x1800;      // kbIsWeaponFiring
int OpenTheSightOffset = 0x1134;  // kbIsGunADS

int WeaponManagerComponentOffset = 0x25b8;  // kWeaponManagerComponent
int WeaponOneOffset = 0x5c8;      // kCurrentWeaponReplicated

namespace WeaponParam {
int MasterOffset = 0x110;
int ShootModeOffset = 0x10d9;    // kShootMode
int WeaponAttrOffset = 0x398;     // kShootWeaponEntityComponent

namespace WeaponAttrParam {
int BulletSpeedOffset = 0x560;    // kBulletFireSpeed
int RecoilOffset = 0xcf0;         // kRecoilKickADS
int GameDeviationFactorOffset = 0xc2c;  // kGameDeviationFactor
}
}

int GoodsListOffset = 0x940;      // kPickUpDataList

namespace GoodsListParam {
int DataBase = 0x38;              // kGoodsID
}

int CoordOffset = 0x208;          // kRootComponent

namespace CoordParam {
int HeightOffset = 0x1dc;         // kCoord
int CoordOffset = 0x1e4;          // kRelativeLocation
int RotationOffset = 0x1f0;       // kRelativeRotation
int ScaleOffset = 0x1fc;          // kRelativeScale3D
}

int VelocityOffset = 0x18c;       // kVelocity
int ComponentVelocityOffset = 0x2c0;      // kComponentVelocity
int LastRenderTimeOffset = 0x490;         // kLastRenderTime
int PoseStateOffset = 0x1810;             // kPoseState
int ScopeFovOffset = 0x1c54;              // kScopeFov
int CurrentVehicleOffset = 0xeb0;         // kCurrentVehicle

int PlayerUIDOffset = 0x988;      // kPlayerUID
int NationOffset = 0x970;         // kNation
int WeaponIdOffset = 0x1e0;       // kWeaponId

int ShootWeaponComponentOffset = 0xf30;   // kShootWeaponComponent
int ShootWeaponEntityCompOffset = 0x1360; // kShootWeaponEntityComp

int PickUpAnimOffset = 0x1e28;            // kPickUpAnim
int PressingFireBtnOffset = 0x33d0;       // kPressingFireBtn
int CurrentReloadWeaponOffset = 0x2b58;   // kCurrentReloadWeapon
int CachedBulletTrackComponentOffset = 0xe28;  // kCachedBulletTrackComponent

}

namespace GameStateParam {
int ExtraGameStateOffset = 0x338;         // kpExtraGameState
int AlivePlayerNumOffset = 0xb34;         // kAlivePlayerNum
int PlayerNumOffset = 0x7a8;              // kPlayerNum
int ElapsedSecondsOffset = 0x4a8;         // kelapsedSeconds
int PlayerStateOffset = 0x2308;           // kPlayerState
int KillOffset = 0x6c8;                   // kKill
}

namespace ViewParam {
int TPPOffset = 0x1c50;                   // kTPP
int FPPModeOffset = 0x1c60;               // kFPP
int GameReplayTypeOffset = 0x944;         // kGameReplayType
int SizeXOffset = 0x40;                   // kSizeX
int SizeYOffset = 0x44;                   // kSizeY
int ViewTargetOffset = 0x10a0;            // kViewTarget
}

namespace MapParam {
int BP_MapUIMarkManagerOffset = 0x4270;   // kBP_MapUIMarkManager_C
int TableNameOffset = 0x8a0;              // kTableName
int FPSOffset = 0x1c4;                    // kFPS
}

namespace CharacterParam {
int CharacterOffset = 0x4c8;              // kCharacter
int PawnOffset = 0x4b8;                   // kPawn
int LocalPlayerControllerOffset = 0x30;   // klocalPlayerController
int HiddenOffset = 0xe8;                  // kbHidden
int MyTeamOffset = 0x940;                 // kMyTeam
int PlayerControllerOffsetLegacy = 0x98;  // kPlayerController
int WuhouOffset = 0x190;                  // wuhou
}

}