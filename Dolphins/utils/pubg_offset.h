//
// PUBG Mobile Offset Header - REAL OFFSETS FROM USER
// Based on actual game offsets
//

#ifndef PUBG_OFFSET_H
#define PUBG_OFFSET_H

namespace PubgOffset {
    
    //=============================================================================
    // WORLD & LEVEL OFFSETS
    //=============================================================================
    
    static constexpr long ULevelOffset = 0x30;  // kPersistentLevel
    
    namespace ULevelParam {
        static constexpr long ObjectArrayOffset = 0xA0;  // kActorList
        static constexpr long ObjectCountOffset = 0xA8;
    }
    
    //=============================================================================
    // PLAYER CONTROLLER OFFSETS
    //=============================================================================
    
    static constexpr long PlayerControllerOffset[3] = {0x38, 0x0, 0x30};  // kNetDriver -> klocalPlayerController
    
    namespace PlayerControllerParam {
        static constexpr long SelfOffset = 0x4b8;           // kPawn
        static constexpr long CameraManagerOffset = 0x548;  // kPlayerCameraManager
        static constexpr long MouseOffset = 0x4e0;          // kControlRotation
        
        namespace ControllerFunction {
            static constexpr long LineOfSightToOffset = 0x7B0;  // kLineOfSightTo
        }
        
        namespace CameraManagerParam {
            static constexpr long PovOffset = 0x10a0;  // kViewTarget
        }
    }
    
    //=============================================================================
    // OBJECT/ACTOR BASE OFFSETS
    //=============================================================================
    
    namespace ObjectParam {
        static constexpr long ClassIdOffset = 0x10;
        static constexpr long CoordOffset = 0x208;          // kRootComponent
        static constexpr long PlayerStateOffset = 0x2308;   // kPlayerState - REAL OFFSET!
        
        // Character body offsetler - THESE ARE CORRECT!
        static constexpr long bIsAIOffset = 0xa40;          // kbIsAI
        static constexpr long bIsMLAIOffset = 0xa41;        // kbIsMLAI
        static constexpr long TeamOffset = 0x998;           // kTeamID
        static constexpr long NameOffset = 0x960;           // kPlayerName
        static constexpr long HpOffset = 0xe60;             // kHealth
        static constexpr long HpMaxOffset = 0xe64;          // kHealthMax
        static constexpr long DeadOffset = 0xe7c;           // kbDead
        static constexpr long StatusOffset = 0x1058;        // kCurrentStates
        static constexpr long ClassNameOffset = 0xC;
        static constexpr long PlayerUIDOffset = 0x988;      // kPlayerUID
        
        // Movement
        static constexpr long MoveCoordOffset = 0x18c;      // kVelocity
        
        // Weapon
        static constexpr long WeaponOneOffset = 0x5c8;      // kCurrentWeaponReplicated
        
        // Gameplay states
        static constexpr long OpenTheSightOffset = 0x1134;  // kbIsGunADS
        static constexpr long OpenFireOffset = 0x1800;      // kbIsWeaponFiring
        
        // Materials
        static constexpr long GoodsListOffset = 0x940;      // kPickUpDataList
        
        namespace GoodsListParam {
            static constexpr long DataBase = 0x30;
        }
        
        //=========================================================================
        // PLAYERSTATE OFFSETLER (from kPlayerState base)
        //=========================================================================
        namespace PlayerState {
            static constexpr long TeamIDOffset = 0x998;      // Same as character
            static constexpr long PlayerUIDOffset = 0x988;   // Same as character
            static constexpr long NationOffset = 0x970;      // kNation
            static constexpr long PlayerKeyOffset = 0x660;
            static constexpr long UIDOffset = 0x988;         // kPlayerUID
            static constexpr long PlayerHealthOffset = 0xe60; // Same as character
            static constexpr long PlayerHealthMaxOffset = 0xe64; // Same as character
            static constexpr long LiveStateOffset = 0xe7c;   // kbDead
            static constexpr long CharacterOwnerOffset = 0x4c8; // kCharacter
        }
        
        //=========================================================================
        // COORD COMPONENT OFFSETLER
        //=========================================================================
        namespace CoordParam {
            static constexpr long CoordOffset = 0x1dc;       // kCoord
            static constexpr long HeightOffset = 0x1c8;      // kHeight
        }
        
        //=========================================================================
        // MESH & BONE OFFSETLER
        //=========================================================================
        static constexpr long MeshOffset = 0x510;            // kMesh
        
        namespace MeshParam {
            static constexpr long ComponentToWorldOffset = 0x230;
            static constexpr long BoneArrayOffset = 0x7F8;
            static constexpr long BoneCountOffset = 0x800;
            static constexpr long HumanOffset = 0x230;
            static constexpr long BonesOffset = 0x7F8;
        }
        
        //=========================================================================
        // ROTATION OFFSETLER
        //=========================================================================
        namespace Rotation {
            static constexpr long RepMovementOffset = 0x110;  // kRepMovement
            static constexpr long PitchOffset = 0x888;        // kPitch
            static constexpr long YawOffset = 0x890;          // kYaw
            static constexpr long RollOffset = 0x888;         // kRoll
        }
        
        //=========================================================================
        // WEAPON PARAM
        //=========================================================================
        namespace WeaponParam {
            static constexpr long MasterOffset = 0x640;
            static constexpr long WeaponIdOffset = 0x1e0;            // kWeaponId
            static constexpr long ShootModeOffset = 0x10d9;          // kShootMode
            static constexpr long WeaponAttrOffset = 0x8a0;          // kTableName
            
            namespace WeaponAttrParam {
                static constexpr long BulletSpeedOffset = 0x560;     // kBulletFireSpeed
                static constexpr long RecoilOffset = 0xcf0;          // kRecoilKickADS
            }
        }
        
        //=========================================================================
        // PLAYER FUNCTIONS
        //=========================================================================
        namespace PlayerFunction {
            static constexpr long AddControllerYawInputOffset = 0x788;
            static constexpr long AddControllerRollInputOffset = 0x790;
            static constexpr long AddControllerPitchInputOffset = 0x798;
        }
    }
    
} // namespace PubgOffset

#endif // PUBG_OFFSET_H