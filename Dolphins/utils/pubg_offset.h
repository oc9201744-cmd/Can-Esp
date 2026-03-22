#ifndef PUBG_OFFSET_H
#define PUBG_OFFSET_H

#include <cstdint>

namespace PubgOffset {

// ============ PLAYER CONTROLLER ============
int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};

namespace PlayerControllerParam {
    int SelfOffset = 0x28e0;
    int MouseOffset = 0x4e0;
    int CameraManagerOffset = 0x548;
    int AngleOffset = 0x558;
    
    namespace CameraManagerParam {
        int PovOffset = 0x10a0 + 0x10;  // 0x10b0
    }
    
    namespace ControllerFunction {
        int LineOfSightToOffset = 0x7B0;
    }
}

// ============ ULEVEL ============
int ULevelOffset = 0x30;

namespace ULevelParam {
    int ObjectArrayOffset = 0xA0;
    int ObjectCountOffset = 0xA8;
}

// ============ OBJECT / ACTOR ============
namespace ObjectParam {
    int ClassIdOffset = 0x18;
    int ClassNameOffset = 0xC;
    
    namespace PlayerFunction {
        int AddControllerYawInputOffset = 0x890;
        int AddControllerRollInputOffset = 0x888;
        int AddControllerPitchInputOffset = 0x898;
    }
    
    // Player Info
    int StatusOffset = 0x1018;
    int TeamOffset = 0x998;
    int NameOffset = 0x960;
    int RobotOffset = 0xa49;        // Bot check
    int HpOffset = 0xe28;           // Health
    int HpmaxOffset = 0xe2c;        // Max Health
    int DeadOffset = 0xe44;         // Dead flag
    
    // Vehicle
    int VehicleCommonComponentOffset = 0xbf0;
    int VehicleHPOffset = 0x344;
    int VehicleHPMaxOffset = 0x340;
    int VehicleFuelOffset = 0x424;
    int VehicleFuelMaxOffset = 0x420;
    
    // Movement
    int MoveCoordOffset = 0x110;
    int MeshOffset = 0x510;
    int boneCountOffset = 0x8d0;
    
    namespace MeshParam {
        int HumanOffset = 0x210;
        int BonesOffset = 0x988;
    }
    
    // Weapon
    int OpenFireOffset = 0x1788;
    int OpenTheSightOffset = 0x10e1;
    int WeaponOneOffset = 0x2a30 + 0x20;  // 0x2a50
    
    namespace WeaponParam {
        int MasterOffset = 0x110;
        int ShootModeOffset = 0x1089;
        int WeaponAttrOffset = 0x12c0;
        
        namespace WeaponAttrParam {
            int BulletSpeedOffset = 0x560;
            int RecoilOffset = 0xcf0;
        }
    }
    
    // Items
    int GoodsListOffset = 0x940;
    
    namespace GoodsListParam {
        int DataBase = 0x38;
    }
    
    // Coordinates
    int CoordOffset = 0x208;
    
    namespace CoordParam {
        int HeightOffset = 0x1dc;
        int CoordOffset = 0x1c8;
    }
}

} // namespace PubgOffset

#endif // PUBG_OFFSET_H
