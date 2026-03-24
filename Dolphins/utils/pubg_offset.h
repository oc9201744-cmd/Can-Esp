#pragma once
#include <stdio.h>
#include <string>

namespace PubgOffset {

// ==================== TEMEL OFFSETLER ====================
// UWorld -> OwningGameInstance -> LocalPlayers -> PlayerController
int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};
// UWorld -> PersistentLevel
int ULevelOffset = 0x30;

// ==================== PLAYER CONTROLLER ====================
namespace PlayerControllerParam {
    // APlayerController -> PlayerCameraManager (HPP: 0x548)
    int CameraManagerOffset = 0x548;
    
    // APlayerController -> ControlRotation (HPP: 0x4E0)
    int AngleOffset = 0x4E0;
    
    // APlayerController -> PlayerInput (HPP: 0x5D8)
    int PlayerInputOffset = 0x5D8;
    
    int SelfOffset = 0x28e0;                    // Oyuna özel
    int MouseOffset = 0x4e0;                    // Oyuna özel

    namespace CameraManagerParam {
        // APlayerCameraManager -> CameraCache (HPP: 0x520) + POV (0x10)
        int PovOffset = 0x530;
    }

    namespace ControllerFunction {
        // AController::LineOfSightTo (HPP: 0x10639d184 - RVA)
        int LineOfSightToOffset = 0x7B0;
    }
}

// ==================== ULEVEL ====================
namespace ULevelParam {
    // ULevel -> Actors (HPP: 0xA0)
    int ObjectArrayOffset = 0xA0;
    // TArray<AActor*> Actors -> Count (HPP: 0xA8)
    int ObjectCountOffset = 0xA8;
}

// ==================== UOBJECT ====================
namespace ObjectParam {
    // UObject -> ClassPrivate (HPP: 0x18)
    int ClassIdOffset = 0x18;
    // UClass -> NamePrivate (HPP: UObjectBase'dan miras, 0x28)
    int ClassNameOffset = 0x28;

    // ========== PLAYER FUNCTIONS ==========
    namespace PlayerFunction {
        // APlayerController::AddYawInput (HPP: 0x1064a4b18 - RVA)
        int AddControllerYawInputOffset = 0x890;
        // APlayerController::AddRollInput (HPP: 0x1064a4a94 - RVA)
        int AddControllerRollInputOffset = 0x888;
        // APlayerController::AddPitchInput (HPP: 0x1064a4a10 - RVA)
        int AddControllerPitchInputOffset = 0x898;
    }

    // ========== CHARACTER/PLAYER (OYUNA ÖZEL) ==========
    int StatusOffset = 0x1018;      // Oyuna özel
    int TeamOffset = 0x998;         // Oyuna özel (APlayerState içinde tahmini)
    int NameOffset = 0x960;         // Oyuna özel (APlayerState -> PlayerName: 0x4B8)
    int RobotOffset = 0xa49;        // Oyuna özel (APlayerState -> bIsABot: 0x4DC)
    int HpOffset = 0xe28;           // Oyuna özel
    int HpmaxOffset = 0xe2c;        // Oyuna özel
    int DeadOffset = 0xe44;         // Oyuna özel

    // ========== VEHICLE (OYUNA ÖZEL) ==========
    int VehicleCommonComponentOffset = 0xbf0;    // Oyuna özel
    int VehicleHPOffset = 0x344;                 // Oyuna özel
    int VehicleHPMaxOffset = 0x340;              // Oyuna özel
    int VehicleFuelOffset = 0x424;               // Oyuna özel
    int VehicleFuelMaxOffset = 0x420;            // Oyuna özel

    // ========== MESH & BONES ==========
    // AActor -> RootComponent (HPP: 0x208)
    int MoveCoordOffset = 0x208;
    // ACharacter -> Mesh (HPP: 0x510)
    int MeshOffset = 0x510;
    int boneCountOffset = 0x8d0;                // Oyuna özel

    namespace MeshParam {
        int HumanOffset = 0x210;                // Oyuna özel
        // USkeletalMeshComponent -> GetBoneTransform (HPP: 0x1064dd31c - RVA)
        int BonesOffset = 0x988;
    }

    // ========== WEAPON (OYUNA ÖZEL) ==========
    int OpenFireOffset = 0x1788;
    int OpenTheSightOffset = 0x10e1;
    int WeaponOneOffset = 0x2a30 + 0x20;

    namespace WeaponParam {
        int MasterOffset = 0x110;
        int ShootModeOffset = 0x1089;
        int WeaponAttrOffset = 0x12c0;

        namespace WeaponAttrParam {
            int BulletSpeedOffset = 0x560;
            int RecoilOffset = 0xcf0;
        }
    }

    // ========== INVENTORY (OYUNA ÖZEL) ==========
    int GoodsListOffset = 0x940;

    namespace GoodsListParam {
        int DataBase = 0x38;
    }

    // ========== COORDINATE ==========
    // USceneComponent -> RelativeLocation (HPP: 0x1E4)
    int CoordOffset = 0x1E4;

    namespace CoordParam {
        int HeightOffset = 0x1dc;               // Oyuna özel
        int CoordOffset = 0x1c8;               // Oyuna özel
    }
}

}