#include <stdio.h>
#include <string>

namespace PubgOffset {

namespace Global {
    const long gobject = 0x10A34E980;
    const long gname_func = 0x104bd8740;
    const long gname_data = 0x10a1178b0;
    const long gworld_func = 0x102A62208;
    const long gworld_data = 0x10A566E00;
}

int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};

namespace PlayerControllerParam {
    int SelfOffset = 0x28E0;
    int MouseOffset = 0x4e0;
    int CameraManagerOffset = 0x548;
    int AngleOffset = 0x558;
    
    namespace CameraManagerParam {
        int PovOffset = 0x530;
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
    int ClassIdOffset = 0x18;
    int ClassNameOffset = 0xC;
    
    namespace PlayerFunction {
        int AddControllerYawInputOffset = 0x890;
        int AddControllerRollInputOffset = 0x888;
        int AddControllerPitchInputOffset = 0x898;
    }
    
    int StatusOffset = 0x1058;
    int TeamOffset = 0x998;
    int NameOffset = 0x960;
    int HpOffset = 0xe60;
    int HpmaxOffset = 0xe64;
    int DeadOffset = 0xe7c;
    
    int MoveCoordOffset = 0x110;
    int MeshOffset = 0x510;
    
    namespace MeshParam {
        int HumanOffset = 0x210;
        int BonesOffset = 0x988;
    }
    
    int OpenFireOffset = 0x1800;
    int OpenTheSightOffset = 0x1134;
    
    int WeaponManagerComponentOffset = 0x25b8;
    int WeaponOneOffset = 0x5c8;
    
    namespace WeaponParam {
        int MasterOffset = 0x110;
        int ShootModeOffset = 0x10d9;
        int WeaponAttrOffset = 0x398;
        
        namespace WeaponAttrParam {
            int BulletSpeedOffset = 0x560;
            int RecoilOffset = 0xcf0;
        }
    }
    
    int CoordOffset = 0x208;
    
    namespace CoordParam {
        int HeightOffset = 0x1dc;
        int CoordOffset = 0x1e4;
    }
}
}