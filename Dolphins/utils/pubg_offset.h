#ifndef PUBG_OFFSET_H
#define PUBG_OFFSET_H

#include <cstdint>

namespace PubgOffset {

// ============ GWORLD / GNAME ============
struct GlobalOffsets {
    static constexpr uintptr_t gobject = 0x10A34E980;
    static constexpr uintptr_t gname_func = 0x104bd8740;
    static constexpr uintptr_t gname_data = 0x10a1178b0;
    static constexpr uintptr_t gworld_func = 0x102A62208;
    static constexpr uintptr_t gworld_data = 0x10A566E00;
};

// ============ PLAYER CONTROLLER ============
struct PlayerControllerOffset {
    static constexpr int offsets[3] = {0x38, 0x78, 0x30};
};

namespace PlayerControllerParam {
    static constexpr int SelfOffset = 0x4b8;                    // kPawn
    static constexpr int MouseOffset = 0x4e0;                   // kControlRotation
    static constexpr int CameraManagerOffset = 0x548;           // kPlayerCameraManager
    static constexpr int AngleOffset = 0x558;
    
    namespace CameraManagerParam {
        static constexpr int PovOffset = 0x10a0;                // kViewTarget (0x10a0 + 0x10 yerine sadece 0x10a0)
    }
    
    namespace ControllerFunction {
        static constexpr int LineOfSightToOffset = 0x7B0;       // kLineOfSightTo
    }
}

// ============ ULEVEL ============
static constexpr int ULevelOffset = 0x30;                       // kPersistentLevel

namespace ULevelParam {
    static constexpr int ObjectArrayOffset = 0xA0;              // kActorList
    static constexpr int ObjectCountOffset = 0xA8;
}

// ============ OBJECT / ACTOR ============
namespace ObjectParam {
    static constexpr int ClassIdOffset = 0x18;
    static constexpr int ClassNameOffset = 0xC;
    
    // Player Info
    static constexpr int NameOffset = 0x960;                    // kPlayerName
    static constexpr int TeamOffset = 0x998;                    // kTeamID
    static constexpr int MyTeamOffset = 0x940;                  // kMyTeam
    static constexpr int RobotOffset = 0xa40;                   // kbIsAI (0xa49 yerine 0xa40)
    static constexpr int MLAIOffset = 0xa41;                    // kbIsMLAI (YENI)
    
    // Health (GUNCELLENMIS)
    static constexpr int HpOffset = 0xe60;                      // kHealth (0xe28 yerine 0xe60)
    static constexpr int HpmaxOffset = 0xe64;                   // kHealthMax (0xe2c yerine 0xe64)
    static constexpr int DeadOffset = 0xe7c;                    // kbDead (0xe44 yerine 0xe7c)
    
    // Status & State
    static constexpr int StatusOffset = 0x1058;                 // kCurrentStates (0x1018 yerine 0x1058)
    static constexpr int NearDeathBreathOffset = 0x1b60;        // kNearDeathBreath
    static constexpr int NearDeatchComponentOffset = 0x1be8;     // kNearDeatchComponent
    
    // Vehicle (GUNCELLENMIS)
    static constexpr int CurrentVehicleOffset = 0xeb0;          // kCurrentVehicle (0xbf0 yerine 0xeb0)
    static constexpr int VehicleCommonComponentOffset = 0xc00;  // kVehicleCommon (0xbf0 yerine 0xc00)
    static constexpr int VehicleHPOffset = 0x354;               // kHP (0x344 yerine 0x354)
    static constexpr int VehicleHPMaxOffset = 0x350;            // kHPMax (0x340 yerine 0x350)
    static constexpr int VehicleFuelOffset = 0x43c;             // kFuel (0x424 yerine 0x43c)
    static constexpr int VehicleFuelMaxOffset = 0x438;          // kFuelMax (0x420 yerine 0x438)
    
    // Mesh & Skeleton
    static constexpr int MeshOffset = 0x510;                    // kMesh
    static constexpr int StaticMeshOffset = 0x988;               // kStaticMesh
    static constexpr int LastRenderTimeOffset = 0x490;          // kLastRenderTime (YENI - visibility check)
    
    namespace MeshParam {
        static constexpr int HumanOffset = 0x210;               // kRootComponent + offset
        static constexpr int BonesOffset = 0x988;                // kStaticMesh (bone array burada)
    }
    
    // Movement
    static constexpr int MoveCoordOffset = 0x110;               // kRepMovement
    static constexpr int CoordOffset = 0x208;                   // kRootComponent
    static constexpr int VelocityOffset = 0x18c;               // kVelocity
    
    namespace CoordParam {
        static constexpr int HeightOffset = 0x1c8;              // kHeight (0x1dc yerine 0x1c8)
        static constexpr int CoordOffset = 0x1c8;               // kCoord (aynı)
    }
    
    // Weapon (GUNCELLENMIS)
    static constexpr int WeaponManagerComponentOffset = 0x25b8;   // kWeaponManagerComponent (0x2a50 yerine 0x25b8)
    static constexpr int CurrentWeaponReplicatedOffset = 0x5c8; // kCurrentWeaponReplicated (0x12c0 yerine 0x5c8)
    static constexpr int ShootWeaponEntityComponentOffset = 0x398; // kShootWeaponEntityComponent (YENI)
    
    static constexpr int OpenFireOffset = 0x1800;             // kbIsWeaponFiring (0x1788 yerine 0x1800)
    static constexpr int OpenTheSightOffset = 0x1134;         // kbIsGunADS (0x10e1 yerine 0x1134)
    static constexpr int PoseStateOffset = 0x1810;            // kPoseState
    static constexpr int ScopeFovOffset = 0x1c54;               // kScopeFov
    
    namespace WeaponParam {
        static constexpr int MasterOffset = 0x110;
        static constexpr int ShootModeOffset = 0x10d9;        // kShootMode (0x1089 yerine 0x10d9)
        static constexpr int WeaponAttrOffset = 0xf30;          // kShootWeaponComponent (0x12c0 yerine 0xf30)
        
        namespace WeaponAttrParam {
            static constexpr int BulletSpeedOffset = 0x560;     // kBulletFireSpeed
            static constexpr int RecoilOffset = 0xcf0;          // kRecoilKickADS
        }
    }
    
    // Pickup/Items
    static constexpr int PickUpDataListOffset = 0x940;          // kPickUpDataList
    static constexpr int GoodsIDOffset = 0x38;                  // kGoodsID
    
    namespace GoodsListParam {
        static constexpr int DataBase = 0x38;
    }
    
    // Camera
    static constexpr int CameraCacheOffset = 0x520;             // kCameraCache
    static constexpr int SizeXOffset = 0x40;                  // kSizeX
    static constexpr int SizeYOffset = 0x44;                  // kSizeY
    
    // Player State
    static constexpr int PlayerStateOffset = 0x2308;           // kPlayerState
    static constexpr int KillOffset = 0x6c8;                    // kKill
    
    // View Settings
    static constexpr int TPPCameraOffset = 0x1c50;             // kTPP
    static constexpr int FPPCameraOffset = 0x1c60;              // kFPP
    
    // Rotation
    static constexpr int YawOffset = 0x890;                   // kYaw
    static constexpr int RollOffset = 0x888;                  // kRoll
    static constexpr int PitchOffset = 0x888;                 // kPitch (kRoll ile aynı)
    
    namespace PlayerFunction {
        static constexpr int AddControllerYawInputOffset = 0x890;   // kYaw
        static constexpr int AddControllerRollInputOffset = 0x888;  // kRoll
        static constexpr int AddControllerPitchInputOffset = 0x898; // Yeni
    }
}

// ============ EXTRA GAME STATE ============
struct GameStateOffsets {
    static constexpr int BP_MapUIMarkManager_C = 0x4270;
    static constexpr int pExtraGameState = 0x338;
    static constexpr int AlivePlayerNum = 0xb34;
    static constexpr int PlayerNum = 0x7a8;
    static constexpr int elapsedSeconds = 0x4a8;
    static constexpr int GameReplayType = 0x944;
    static constexpr int FPS = 0x1c4;
};

} // namespace PubgOffset

#endif // PUBG_OFFSET_H
