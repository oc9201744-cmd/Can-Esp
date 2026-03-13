#include <stdio.h>
#include <string>

namespace PubgOffset {

int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};

namespace PlayerControllerParam {

int SelfOffset = 0x28D0; // v3.6 için güncellendi (Eski: 0x28e0)
int MouseOffset = 0x4e0;
int CameraManagerOffset = 0x548;
int AngleOffset = 0x558;

namespace CameraManagerParam {
int PovOffset = 0x10a0 + 0x10;
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

// --- v3.6 GÜNCEL BÖLÜM ---
int StatusOffset = 0x065C;       // Eski: 0x1018 (Yeni: Health/Can)
int StatusOffset_State = 0x2B78; // EKSİKTİ, EKLENDİ (Yeni: Durum)
int HpOffset = 0x065C;           // Eski: 0xe28
int HpmaxOffset = 0xE64;         // Eski: 0xe2c
int DeadOffset = 0xE7C;          // Eski: 0xe44
// -------------------------

int TeamOffset = 0x998;
int NameOffset = 0x960;
int RobotOffset = 0xA40;         // Eski: 0xa49

int VehicleCommonComponentOffset = 0xC00; // Eski: 0xbf0
int VehicleHPOffset = 0x354;              // Eski: 0x344
int VehicleHPMaxOffset = 0x350;           // Eski: 0x340
int VehicleFuelOffset = 0x43C;            // Eski: 0x424
int VehicleFuelMaxOffset = 0x438;         // Eski: 0x420

int MoveCoordOffset = 0x158;     // Eski: 0x110 (Kayma sorununun ana sebebi)
int MeshOffset = 0x510;
int boneCountOffset = 0x0840;    // Eski: 0x8d0

namespace MeshParam {
int HumanOffset = 0x210;
int BonesOffset = 0x02B8;        // Eski: 0x988 (İskelet bozukluğunun sebebi)
}

int OpenFireOffset = 0x1800;     // Eski: 0x1788
int OpenTheSightOffset = 0x3D48; // Eski: 0x10e1

// Silah ofsetleri v3.6 yapısına göre güncellendi
int WeaponOneOffset = 0x1990;    // WeaponManagerComponent (Genel yapı)

namespace WeaponParam {
int MasterOffset = 0x110;
int ShootModeOffset = 0x1089;
int WeaponAttrOffset = 0x12c0;

namespace WeaponAttrParam {
int BulletSpeedOffset = 0x560;
int RecoilOffset = 0xcf0;
}
}

int GoodsListOffset = 0x940;

namespace GoodsListParam {
int DataBase = 0x38;
}

int CoordOffset = 0x208;

namespace CoordParam {
int HeightOffset = 0x1dc;
int CoordOffset = 0x158;         // Eski: 0x1c8 (MoveCoord ile aynı olmalı)
}

}

}
