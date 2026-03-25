#include <stdio.h>
#include <string>

namespace PubgOffset {

int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};

namespace PlayerControllerParam {

int SelfOffset = 0x28e0;
int MouseOffset = 0x4e0;
int CameraManagerOffset = 0x548;
int AngleOffset = 0x558;

namespace CameraManagerParam {
int PovOffset = 0x530;  // AIOHeader: APlayerCameraManager::CameraCache.POV (0x520 + 0x10)
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

// ============ GÜNCELLENEN OFFSET'LER ============
int StatusOffset = 0x1058;      // Özel - STExtraPlayerCharacter::CurrentStates
int TeamOffset = 0x998;         // APlayerState::TeamID (doğru)
int NameOffset = 0x4B8;         // APlayerState::PlayerName (AIOHeader'dan - 0x960 değil!)
int RobotOffset = 0x4DC;        // APlayerState::bIsABot bit 2 (AIOHeader'dan - 0xa49 değil!)
int HpOffset = 0xE60;           // STExtraPlayerCharacter::Health (AIOHeader'dan)
int HpmaxOffset = 0xE64;        // STExtraPlayerCharacter::HealthMax
int DeadOffset = 0xE7C;         // STExtraPlayerCharacter::bDead

// Araç offset'leri
int VehicleCommonComponentOffset = 0xC00;   // STExtraPlayerCharacter::VehicleCommonComponent
int VehicleHPOffset = 0x354;                // STExtraVehicle::HP
int VehicleHPMaxOffset = 0x350;             // STExtraVehicle::HPMax
int VehicleFuelOffset = 0x43C;              // STExtraVehicle::Fuel
int VehicleFuelMaxOffset = 0x438;           // STExtraVehicle::FuelMax

int MoveCoordOffset = 0x110;
int MeshOffset = 0x510;                     // ACharacter::Mesh
int boneCountOffset = 0x8d0;

namespace MeshParam {
int HumanOffset = 0x1E4;                    // USceneComponent::RelativeLocation (AIOHeader'dan - 0x210 değil!)
int BonesOffset = 0xC40;                    // USkeletalMeshComponent::CachedComponentSpaceTransforms (AIOHeader'dan - 0x988 değil!)
}

int OpenFireOffset = 0x1800;                // STExtraWeapon::bIsFiring
int OpenTheSightOffset = 0x1134;            // STExtraWeapon::bIsADS

int WeaponOneOffset = 0x5C8;                // STExtraWeaponManagerComponent::CurrentWeaponReplicated

namespace WeaponParam {

int MasterOffset = 0x110;
int ShootModeOffset = 0x10D9;               // STExtraWeapon::ShootMode
int WeaponAttrOffset = 0x398;               // STExtraWeapon::ShootWeaponEntityComponent

namespace WeaponAttrParam {
int BulletSpeedOffset = 0x560;              // USTExtraShootWeaponEntityComponent::BulletFireSpeed
int RecoilOffset = 0xCF0;                   // USTExtraShootWeaponEntityComponent::RecoilKickADS
}

}

int GoodsListOffset = 0x940;                // STExtraPlayerCharacter::PickUpDataList

namespace GoodsListParam {
int DataBase = 0x38;                        // FItemDefineID::ID
}

int CoordOffset = 0x208;                    // AActor::RootComponent

namespace CoordParam {
int HeightOffset = 0x1E4;                   // USceneComponent::RelativeLocation.Z
int CoordOffset = 0x1E4;                    // USceneComponent::RelativeLocation
}

}

// ============ YARDIMCI FONKSİYON (Bot kontrolü için) ============
inline bool IsPlayerBot(uintptr_t PlayerState) {
    if (!PlayerState) return false;
    uint8_t flags = *(uint8_t*)(PlayerState + ObjectParam::RobotOffset);
    return (flags & 0x4) != 0;  // bIsABot bit 2'de
}

}