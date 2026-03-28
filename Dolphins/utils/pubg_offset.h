//
// PUBG Mobile Offset Header - COMPLETE VERSION
// Tüm eksik offsetler eklendi, compile uyumlu
//

#ifndef PUBG_OFFSET_H
#define PUBG_OFFSET_H

namespace PubgOffset {
    
    //=============================================================================
    // WORLD & LEVEL OFFSETS
    //=============================================================================
    
    static constexpr long ULevelOffset = 0x30;
    
    namespace ULevelParam {
        static constexpr long ObjectArrayOffset = 0xA0;
        static constexpr long ObjectCountOffset = 0xA8;
    }
    
    //=============================================================================
    // PLAYER CONTROLLER OFFSETS
    //=============================================================================
    
    static constexpr long PlayerControllerOffset[3] = {0x38, 0x0, 0x30};
    
    namespace PlayerControllerParam {
        static constexpr long SelfOffset = 0x4A0;
        static constexpr long CameraManagerOffset = 0x4B0;
        static constexpr long MouseOffset = 0x4C0;
        
        namespace ControllerFunction {
            static constexpr long LineOfSightToOffset = 0x780;
        }
        
        namespace CameraManagerParam {
            static constexpr long PovOffset = 0x10F0;
        }
    }
    
    //=============================================================================
    // OBJECT/ACTOR BASE OFFSETS
    //=============================================================================
    
    namespace ObjectParam {
        static constexpr long ClassIdOffset = 0x10;
        static constexpr long CoordOffset = 0x220;
        static constexpr long PlayerStateOffset = 0x5C0;
        
        // Character body offsetler
        static constexpr long bIsAIOffset = 0xA40;
        static constexpr long bIsMLAIOffset = 0xA41;
        static constexpr long TeamOffset = 0x998;
        static constexpr long NameOffset = 0x960;
        static constexpr long HpOffset = 0x8B8;
        static constexpr long DeadOffset = 0x8B0;
        static constexpr long StatusOffset = 0x1058;
        static constexpr long ClassNameOffset = 0xC;
        
        // Movement
        static constexpr long MoveCoordOffset = 0x3D0;  // ADDED - movement velocity
        
        // Weapon
        static constexpr long WeaponOneOffset = 0x920;
        
        // Gameplay states
        static constexpr long OpenTheSightOffset = 0x8C0;
        static constexpr long OpenFireOffset = 0x8C4;
        
        // Materials
        static constexpr long GoodsListOffset = 0x5A0;
        
        namespace GoodsListParam {
            static constexpr long DataBase = 0x30;
        }
        
        //=========================================================================
        // PLAYERSTATE OFFSETLER
        //=========================================================================
        namespace PlayerState {
            static constexpr long TeamIDOffset = 0x700;
            static constexpr long PlayerUIDOffset = 0x668;
            static constexpr long NationOffset = 0x6F0;
            static constexpr long PlayerKeyOffset = 0x660;
            static constexpr long UIDOffset = 0x6C8;
            static constexpr long PlayerHealthOffset = 0x1424;
            static constexpr long PlayerHealthMaxOffset = 0x1428;
            static constexpr long LiveStateOffset = 0x13F4;
            static constexpr long CharacterOwnerOffset = 0x1408;
        }
        
        //=========================================================================
        // COORD COMPONENT OFFSETLER
        //=========================================================================
        namespace CoordParam {
            static constexpr long CoordOffset = 0x220;
            static constexpr long HeightOffset = 0x22C;
        }
        
        //=========================================================================
        // MESH & BONE OFFSETLER
        //=========================================================================
        static constexpr long MeshOffset = 0x468;
        
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
            static constexpr long RepMovementOffset = 0x80;
            static constexpr long PitchOffset = 0x8C;
            static constexpr long YawOffset = 0x88;
            static constexpr long RollOffset = 0x90;
        }
        
        //=========================================================================
        // WEAPON PARAM
        //=========================================================================
        namespace WeaponParam {
            static constexpr long MasterOffset = 0x640;
            static constexpr long WeaponIdOffset = 0x7D0;
            static constexpr long ShootModeOffset = 0x7E0;
            static constexpr long WeaponAttrOffset = 0x8A0;  // ADDED - weapon attributes pointer
            
            namespace WeaponAttrParam {
                static constexpr long BulletSpeedOffset = 0x3D8;  // ADDED - bullet velocity
                static constexpr long BulletRangeOffset = 0x3DC;  // ADDED - bullet range
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