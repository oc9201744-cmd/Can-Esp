//
//  pubg_offset.h
//  Dolphins
//

#pragma once
#include <cstdint>

namespace PubgOffset {
    
    // Player Controller offsets array
    constexpr uintptr_t PlayerControllerOffset[] = {0x38, 0x30, 0x690};
    
    // ULevel
    constexpr uintptr_t ULevelOffset = 0x38;
    
    namespace ULevelParam {
        constexpr uintptr_t ObjectArrayOffset = 0xa0;
        constexpr uintptr_t ObjectCountOffset = 0xa8;
    }
    
    namespace ObjectParam {
        constexpr uintptr_t ClassIdOffset = 0x18;
        constexpr uintptr_t NameOffset = 0xae8;
        constexpr uintptr_t TeamOffset = 0x1228;
        constexpr uintptr_t HpOffset = 0x1138;
        constexpr uintptr_t DeadOffset = 0x117c;
        constexpr uintptr_t StatusOffset = 0x9a8;
        constexpr uintptr_t CoordOffset = 0x124;
        constexpr uintptr_t MeshOffset = 0x498;
        constexpr uintptr_t WeaponOneOffset = 0x1160;
        constexpr uintptr_t MoveCoordOffset = 0x190;
        constexpr uintptr_t OpenTheSightOffset = 0xae0;
        constexpr uintptr_t OpenFireOffset = 0xae4;
        constexpr uintptr_t RobotOffset = 0xa40;
        constexpr uintptr_t GoodsListOffset = 0x800;
        constexpr uintptr_t ClassNameOffset = 0x60;
        
        namespace CoordParam {
            constexpr uintptr_t CoordOffset = 0x0;
            constexpr uintptr_t HeightOffset = 0x18;
        }
        
        namespace MeshParam {
            constexpr uintptr_t HumanOffset = 0x240;
            constexpr uintptr_t BonesOffset = 0x7e0;
        }
        
        namespace WeaponParam {
            constexpr uintptr_t MasterOffset = 0x5b8;
            constexpr uintptr_t ShootModeOffset = 0x5d0;
            constexpr uintptr_t WeaponAttrOffset = 0x5c0;
            
            namespace WeaponAttrParam {
                constexpr uintptr_t BulletSpeedOffset = 0x2c;
                constexpr uintptr_t RecoilOffset = 0x30;
            }
        }
        
        namespace PlayerFunction {
            constexpr uintptr_t AddControllerYawInputOffset = 0x6e0;
            constexpr uintptr_t AddControllerRollInputOffset = 0x6f0;
            constexpr uintptr_t AddControllerPitchInputOffset = 0x6e8;
        }
        
        namespace GoodsListParam {
            constexpr uintptr_t DataBase = 0x10;
        }
    }
    
    namespace PlayerControllerParam {
        constexpr uintptr_t SelfOffset = 0x690;
        constexpr uintptr_t CameraManagerOffset = 0x4b8;
        constexpr uintptr_t MouseOffset = 0x460;
        
        namespace CameraManagerParam {
            constexpr uintptr_t PovOffset = 0x2c50;
        }
        
        namespace ControllerFunction {
            constexpr uintptr_t LineOfSightToOffset = 0x780;
        }
    }
    
    // Material types
    constexpr int Rifle = 0;
    constexpr int Sniper = 1;
    constexpr int Missile = 2;
    constexpr int Ammo = 3;
    constexpr int Helmet = 4;
    constexpr int Vest = 5;
    constexpr int Backpack = 6;
    constexpr int Medical = 7;
    constexpr int Airdrop = 8;
    constexpr int Scope = 9;
    constexpr int Muzzle = 10;
    constexpr int Magazine = 11;
    constexpr int Grip = 12;
    constexpr int Warning = 13;
    constexpr int All = 14;
}