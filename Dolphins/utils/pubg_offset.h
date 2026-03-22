#include <stdio.h>
#include <string>

namespace PubgOffset {

// PlayerController chain: NetDriver -> ServerConnection -> PlayerController
int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};

namespace PlayerControllerParam {

int SelfOffset = 0x28E0;          // kSTBaseCharacter
int MouseOffset = 0x4E0;          // AController_ControlRotation
int CameraManagerOffset = 0x548;  // APlayerController_PlayerCameraManager
int AngleOffset = 0x558;

namespace CameraManagerParam {
int PovOffset = 0x530;            // APlayerCameraManager_CameraCacheEntry + 0x10
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
int TeamOffset = 0x998;           // AUAECharacter_TeamID
int NameOffset = 0x960;           // AUAECharacter_PlayerName
int HpOffset = 0xE60;             // ASTExtraCharacter_Health
int HpmaxOffset = 0xE64;          // ASTExtraCharacter_HealthMax
int DeadOffset = 0xE7C;           // ASTExtraCharacter_bDead

int MoveCoordOffset = 0x110;      // kRepMovement
int MeshOffset = 0x510;           // ACharacter_Mesh

namespace MeshParam {
int HumanOffset = 0x210;          // USceneComponent_RelativeLocation
int BonesOffset = 0x990;          // AStaticMeshComponent_StaticMesh (MinLOD)
}

int OpenFireOffset = 0x1800;      // bIsWeaponFiring
int OpenTheSightOffset = 0x1134;  // bIsGunADS

int WeaponManagerComponentOffset = 0x25B8;   // ASTExtraBaseCharacter_WeaponManagerComponent
int WeaponOneOffset = 0x5C8;                 // UWeaponManagerComponent_CurrentWeaponReplicated

namespace WeaponParam {
int MasterOffset = 0x110;
int ShootModeOffset = 0x10D9;    // kShootMode
int WeaponAttrOffset = 0x1360;   // ASTExtraShootWeapon_ShootWeaponEntityComp

namespace WeaponAttrParam {
int BulletSpeedOffset = 0x560;   // UShootWeaponEntity_BulletFireSpeed
int RecoilOffset = 0xCF0;        // RecoilKickADS
}
}

int CoordOffset = 0x208;          // AActor_RootComponent

namespace CoordParam {
int HeightOffset = 0x1DC;         // kCoord
int CoordOffset = 0x1E4;          // USceneComponent_RelativeLocation
}

}

}
