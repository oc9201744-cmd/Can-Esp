#include <stdio.h>
#include <string>

/*
 * PUBG Mobile Offsets - Updated from Onur.dylib Analysis
 * 
 * Dylib Info:
 * - Bundle ID: com.tencent.ig (Global/International)
 * - File: Onur.dylib (Mach-O 64-bit ARM64)
 * 
 * Key Symbols Found:
 * - GetGWorld:  0x18F260  (Function)
 * - GWorldNum:  0xBD5BB8  (Global Data)
 * - GetGNames:  0x1F91C   (Function)
 * - GNames:     0xBD5C18  (Global Data)
 * 
 * Special Offsets:
 * - AimBullet_Offset:           0xBD5AB8
 * - AimBullet_Offset2:          0xBD5AC0
 * - ProcessEvent_Offset:        0xBD5AB0
 * - SetControlRotation_Offset:  0xBD5AC8
 */

namespace PubgOffset {

// Player Controller Chain
int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};

namespace PlayerControllerParam {

int SelfOffset = 0x28e0;
int MouseOffset = 0x4e0;
int CameraManagerOffset = 0x548;
int AngleOffset = 0x558;

namespace CameraManagerParam {
int PovOffset = 0x10a0 + 0x10;  // Field of View offset
}

namespace ControllerFunction {
int LineOfSightToOffset = 0x7B0;  // Line of sight check
}

}

// ULevel (World Level)
int ULevelOffset = 0x30;

namespace ULevelParam {
int ObjectArrayOffset = 0xA0;   // Actor array
int ObjectCountOffset = 0xA8;   // Actor count
}

// Object/Actor Parameters
namespace ObjectParam {

int ClassIdOffset = 0x18;
int ClassNameOffset = 0xC;

// Player Input Functions (AddControllerYawInput, etc.)
namespace PlayerFunction {
int AddControllerYawInputOffset = 0x890;    // Horizontal rotation
int AddControllerRollInputOffset = 0x888;   // Roll input
int AddControllerPitchInputOffset = 0x898;  // Vertical rotation
}

// Player Status
int StatusOffset = 0x1018;
int TeamOffset = 0x998;
int NameOffset = 0x960;
int RobotOffset = 0xa49;        // Is bot check
int HpOffset = 0xe28;           // Current HP
int HpmaxOffset = 0xe2c;        // Max HP
int DeadOffset = 0xe44;         // Dead status

// Vehicle Parameters
int VehicleCommonComponentOffset = 0xbf0;
int VehicleHPOffset = 0x344;
int VehicleHPMaxOffset = 0x340;
int VehicleFuelOffset = 0x424;
int VehicleFuelMaxOffset = 0x420;

// Position & Mesh
int MoveCoordOffset = 0x110;
int MeshOffset = 0x510;
int boneCountOffset = 0x8d0;

namespace MeshParam {
int HumanOffset = 0x210;
int BonesOffset = 0x988;        // Bone array for skeleton
}

// Shooting & Aiming
int OpenFireOffset = 0x1788;    // Is firing
int OpenTheSightOffset = 0x10e1; // Is aiming down sights

// Weapon
int WeaponOneOffset = 0x2a30 + 0x20;  // Primary weapon

namespace WeaponParam {

int MasterOffset = 0x110;
int ShootModeOffset = 0x1089;   // Auto/Single/Burst
int WeaponAttrOffset = 0x12c0;  // Weapon attributes

namespace WeaponAttrParam {
int BulletSpeedOffset = 0x560;  // Bullet velocity
int RecoilOffset = 0xcf0;       // Recoil multiplier
}

}

// Inventory/Items
int GoodsListOffset = 0x940;

namespace GoodsListParam {
int DataBase = 0x38;
}

// Coordinates
int CoordOffset = 0x208;

namespace CoordParam {
int HeightOffset = 0x1dc;       // Z-axis height
int CoordOffset = 0x1c8;        // XYZ coordinates
}

}

}
