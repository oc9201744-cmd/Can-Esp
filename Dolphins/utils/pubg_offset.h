#pragma once

namespace PubgOffset {
    // Senin orijinal offset'ler
    inline uintptr_t GWorldFunction = 0x10282a858;
    inline uintptr_t GWorldData     = 0x10992a6e0;
    inline uintptr_t GNameFunction  = 0x1044dd6ec;
    inline uintptr_t GNameData      = 0x10953ecd0;

    inline uintptr_t PlayerControllerOffset[3] = {0x30, 0x78, 0x98};

    inline uintptr_t ULevelOffset          = 0x38;
    inline uintptr_t ActorArrayOffset      = 0xA0;
    inline uintptr_t ActorCountOffset      = 0xA8;

    inline uintptr_t SelfOffset            = 0x4B8;
    inline uintptr_t CameraManagerOffset   = 0x548;
    inline uintptr_t LineOfSightToOffset   = 0x780;  // Vtable offset

    inline uintptr_t CoordOffset           = 0x208;
    inline uintptr_t ClassIdOffset         = 0x18;
    inline uintptr_t HpOffset              = 0xE60;
    inline uintptr_t DeadOffset            = 0xE7C;
    inline uintptr_t TeamOffset            = 0x940;
    inline uintptr_t NameOffset            = 0x960;
    inline uintptr_t RobotOffset           = 0xA40;
    inline uintptr_t StatusOffset          = 0x1058;
    inline uintptr_t MeshOffset            = 0x510;
    inline uintptr_t BonesOffset           = 0x5A0;

    inline uintptr_t AddControllerYawInputOffset   = 0x780;
    inline uintptr_t AddControllerRollInputOffset  = 0x788;
    inline uintptr_t AddControllerPitchInputOffset = 0x790;

    inline uintptr_t WeaponOneOffset       = 0x5C8;
    inline uintptr_t OpenTheSightOffset    = 0x1134;
    inline uintptr_t OpenFireOffset        = 0x1800;
    inline uintptr_t ShootModeOffset       = 0x10D9;
    inline uintptr_t WeaponAttrOffset      = 0x398;
    inline uintptr_t BulletSpeedOffset     = 0x560;
    inline uintptr_t RecoilOffset          = 0xCF0;
    inline uintptr_t MoveCoordOffset       = 0x18C;

    // Hata verenler için eklenenler (4.3 GL)
    inline uintptr_t PovOffset             = 0xAA0;  // CameraManager + POV struct
    inline uintptr_t ControlRotationOffset = 0x4D8;  // Mouse yerine yaw/pitch/roll

    inline uintptr_t HeightOffset          = 0x160;  // Coord + Z height

    inline uintptr_t GoodsListOffset       = 0x8F0;
    namespace GoodsListParam {
        inline uintptr_t DataBase          = 0x18;
    }
}
