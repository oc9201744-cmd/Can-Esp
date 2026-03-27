#include <stdio.h>
#include <string>

namespace PubgOffset {

// PlayerController zinciri: World -> NetDriver -> ServerConnection -> PlayerController -> LocalPlayerController
int PlayerControllerOffset[4] = {0x38, 0x78, 0x98, 0x30};

namespace PlayerControllerParam {
    int SelfOffset          = 0x28E0;  // ASTExtraPlayerController::STExtraBaseCharacter
    int MouseOffset         = 0x4E0;   // ControlRotation
    int CameraManagerOffset = 0x548;   // PlayerCameraManager
    int AngleOffset         = 0x558;
    int PlayerStateOffset   = 0x2308;  // ASTExtraPlayerController::PlayerState

    namespace CameraManagerParam {
        int PovOffset = 0x520 + 0x10;
    }

    namespace ControllerFunction {
        int LineOfSightToOffset = 0x7B0;
    }
}

int ULevelOffset = 0x30;

namespace ULevelParam {
    int ObjectArrayOffset = 0xA0;
    int ObjectCountOffset = 0xA8;
}

namespace ObjectParam {
    int ClassIdOffset   = 0x18;
    int ClassNameOffset = 0xC;

    namespace PlayerFunction {
        int AddControllerYawInputOffset   = 0x890;
        int AddControllerRollInputOffset  = 0x888;
        int AddControllerPitchInputOffset = 0x888;
    }

    int StatusOffset    = 0x1058;  // CurrentStates
    int PlayerStateOffset = 0x2308; // AController::PlayerState -> TeamID buradan
    int TeamOffset      = 0x700;   // AUAEPlayerState::TeamID (PlayerState üzerinden)
    int NameOffset      = 0x960;   // AUAECharacter::PlayerName
    int RobotOffset     = 0xA40;   // AUAECharacter::bIsAI
    int MLAIOffset      = 0xA41;   // AUAECharacter::bIsMLAI
    int HpOffset        = 0xE60;   // ASTExtraCharacter::Health
    int HpmaxOffset     = 0xE64;
    int DeadOffset      = 0xE7C;   // bDead

    int VehicleCommonComponentOffset = 0xC00;
    int VehicleHPOffset              = 0x354;
    int VehicleHPMaxOffset           = 0x350;
    int VehicleFuelOffset            = 0x43C;
    int VehicleFuelMaxOffset         = 0x438;

    int MoveCoordOffset = 0x110;
    int MeshOffset      = 0x510;
    int boneCountOffset = 0x8D0;

    namespace MeshParam {
        int HumanOffset = 0x210;
        int BonesOffset = 0x988;
    }

    int OpenFireOffset     = 0x1800;
    int OpenTheSightOffset = 0x1134;

    int WeaponManagerComponentOffset = 0x25B8;
    int WeaponOneOffset              = 0x5C8;

    namespace WeaponParam {
        int MasterOffset     = 0x110;
        int ShootModeOffset  = 0x10D9;
        int WeaponAttrOffset = 0x398;

        namespace WeaponAttrParam {
            int BulletSpeedOffset = 0x560;
            int RecoilOffset      = 0xCF0;
        }
    }

    int GoodsListOffset = 0x940;

    namespace GoodsListParam {
        int DataBase = 0x38;
    }

    int CoordOffset = 0x208;

    namespace CoordParam {
        int HeightOffset = 0x1C8;
        int CoordOffset  = 0x1E4;
    }
}

}