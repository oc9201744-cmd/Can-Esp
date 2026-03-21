// Dolphins/utils/pubg_offset.h  →  4.3 GL Güncel (Mart 2026)

namespace PubgOffset {

    // GWorld & GName (en kritik)
    inline uintptr_t GWorldFunction   = 0x10282a858;
    inline uintptr_t GWorldData       = 0x10992a6e0;
    inline uintptr_t GNameFunction    = 0x1044dd6ec;
    inline uintptr_t GNameData        = 0x10953ecd0;

    // Ana Chain'ler
    inline uintptr_t ULevelOffset               = 0x38;     // GWorld + this → ULevel
    inline uintptr_t ActorArrayOffset           = 0xA0;     // ULevel + this → Actor Array
    inline uintptr_t ActorCountOffset           = 0xA8;     // ULevel + this → Count

    // PlayerController
    inline uintptr_t PlayerControllerOffset[3] = {0x30, 0x78, 0x98};  // Güncel chain

    // Local Player
    inline uintptr_t LocalPlayerOffset          = 0x30;     // PlayerController + this

    // Self / Pawn
    inline uintptr_t SelfOffset                 = 0x4B8;    // PlayerController + Pawn
    inline uintptr_t MeshOffset                 = 0x510;    // Pawn + Mesh (eski 0x510 hâlâ yakın)
    inline uintptr_t RootComponentOffset        = 0x208;

    // HP & Dead
    inline uintptr_t HealthOffset               = 0xE60;    // Pawn + Health
    inline uintptr_t HealthMaxOffset            = 0xE64;
    inline uintptr_t bDeadOffset                = 0xE7C;    // 1 byte bool

    // Team
    inline uintptr_t TeamOffset                 = 0x940;    // hâlâ çalışıyor ama bazen 0x998 de dene
    inline uintptr_t TeamIDOffset               = 0x998;

    // Camera
    inline uintptr_t CameraManagerOffset        = 0x548;    // PlayerController + CameraManager
    inline uintptr_t POVOffset                  = 0x520;    // CameraManager + POV (MinimalViewInfo)

    // Weapon & Firing
    inline uintptr_t WeaponOffset               = 0x5C8;    // CurrentWeaponReplicated
    inline uintptr_t ShootModeOffset            = 0x10D9;
    inline uintptr_t IsFiringOffset             = 0x1800;
    inline uintptr_t ADSOffset                  = 0x1134;

    // Bone & Skeleton (çok değişti)
    inline uintptr_t BonesOffset                = 0x5A0;    // Mesh + BoneArray (yeni)
    inline uintptr_t BoneOffsetInArray          = 0x30;     // Bone base + index*0x30 + offset

    // LineOfSightTo (fonksiyon)
    inline uintptr_t LineOfSightToOffset        = 0x780;    // Controller vtable içinden

    // Diğer önemli
    inline uintptr_t PlayerNameOffset           = 0x960;
    inline uintptr_t IsBotOffset                = 0xA40;    // kbIsAI
    inline uintptr_t VelocityOffset             = 0x18C;
    inline uintptr_t RelativeLocationOffset     = 0x1E4;
}