#include <stdio.h>
#include <string>

namespace PubgOffset {

namespace Global {
    const long gobject     = 0x10A34E980;
    const long gname_func  = 0x104BD8740;
    const long gname_data  = 0x10A1178B0;
    const long gworld_func = 0x102A62208;
    const long gworld_data = 0x10A566E00;
}

int PlayerControllerOffset[4] = {0x38, 0x78, 0x98, 0x30};

namespace PlayerControllerParam {
    int SelfOffset          = 0x28E0;
    int MouseOffset         = 0x4E0;
    int CameraManagerOffset = 0x548;
    int AngleOffset         = 0x558;

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

    int StatusOffset  = 0x1058;
    int TeamOffset    = 0x998;
    int NameOffset    = 0x960;
    int RobotOffset   = 0xA40;
    int HpOffset      = 0xE60;
    int HpmaxOffset   = 0xE64;
    int DeadOffset    = 0xE7C;

    int VehicleCommonComponentOffset = 0xC00;
    int VehicleHPOffset     = 0x354;
    int VehicleHPMaxOffset  = 0x350;
    int VehicleFuelOffset   = 0x43C;
    int VehicleFuelMaxOffset = 0x438;

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
    int WeaponOneOffset = 0x5C8;

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
