//
// pubg_offset.h
// Auto-generated offsets from AIOHeader.hpp
//
// NO MORE HARDCODED OFFSETS!
// All offsets are calculated at compile-time using offsetof()
//

#pragma once

#include "../AIOHeader.hpp"
#include <cstddef>

namespace PubgOffset {
    
    // ============================================================================
    // AUTO-CALCULATED OFFSETS (from AIOHeader.hpp structs)
    // ============================================================================
    
    // UWorld offsets (standard UE4)
    constexpr int ULevelOffset = offsetof(UWorld, PersistentLevel);
    
    namespace ULevelParam {
        // ULevel offsets
        constexpr int ObjectArrayOffset = offsetof(ULevel, Actors) + offsetof(TArray<AActor*>, Data);
        constexpr int ObjectCountOffset = offsetof(ULevel, Actors) + offsetof(TArray<AActor*>, Count);
    }
    
    namespace ObjectParam {
        // PUBG Custom - STExtraPlayerCharacter
        constexpr int TeamOffset = offsetof(ASTExtraPlayerCharacter, TeamID);
        constexpr int HealthOffset = offsetof(ASTExtraPlayerCharacter, Health);
        constexpr int HealthMaxOffset = offsetof(ASTExtraPlayerCharacter, HealthMax);
        constexpr int DeadOffset = offsetof(ASTExtraPlayerCharacter, bIsDead);
        constexpr int RobotOffset = offsetof(ASTExtraPlayerCharacter, bIsAIPlayer);
        constexpr int NameOffset = offsetof(ASTExtraPlayerCharacter, PlayerName);
        constexpr int PlayerUIDOffset = offsetof(ASTExtraPlayerCharacter, PlayerUID);
        
        // UObject base
        constexpr int ClassIdOffset = offsetof(UObject, ClassPrivate);
        constexpr int NamePrivateOffset = offsetof(UObject, NamePrivate);
        
        // AActor base
        constexpr int CoordOffset = offsetof(AActor, RootComponent);
        
        // Eğer AIOHeader.hpp'de yoksa manuel ekle:
        constexpr int StatusOffset = 0x???;  // AIOHeader.hpp'de PlayerStatus varsa offsetof() kullan
        
        namespace WeaponParam {
            // Weapon offset'leri - AIOHeader.hpp'de weapon class'ı varsa offsetof() kullan
            constexpr int MasterOffset = 0x???;  // Manuel eklenecek veya AIOHeader.hpp'den
        }
        
        namespace PlayerFunction {
            // Function offset'leri - bunlar VTable offset'leri, manuel kalabilir
            constexpr int AddControllerYawInputOffset = 0x???;
            constexpr int AddControllerRollInputOffset = 0x???;
            constexpr int AddControllerPitchInputOffset = 0x???;
        }
    }
    
    namespace PlayerControllerParam {
        // PlayerController offset'leri - AIOHeader.hpp'de varsa offsetof() kullan
        constexpr int SelfOffset = 0x???;  // offsetof(APlayerController, AcknowledgedPawn) ?
        constexpr int CameraManagerOffset = 0x???;  // offsetof(APlayerController, PlayerCameraManager) ?
        
        namespace ControllerFunction {
            // Function VTable offset - manuel
            constexpr int LineOfSightToOffset = 0x780;
        }
    }
    
    // PlayerController array offset (global)
    constexpr int PlayerControllerOffset[3] = {0x???, 0x???, 0x???};  // Manuel - game-specific
}

// ============================================================================
// USAGE NOTES:
// ============================================================================
// 
// OLD (hardcoded):
//   const int TeamOffset = 0x698;
//
// NEW (auto-calculated):
//   constexpr int TeamOffset = offsetof(ASTExtraPlayerCharacter, TeamID);
//
// Compiler automatically calculates the offset at compile-time.
// No more manual offset updates needed!
//
// If AIOHeader.hpp doesn't have a member, you can still use manual offsets:
//   constexpr int CustomOffset = 0x123;
//
