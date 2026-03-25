//
//  pubg_offset.h
//  Dolphins
//

#pragma once
#include <cstdint>

namespace PubgOffset {
    
    constexpr uintptr_t ASTExtraPlayerCharacter_bIsAI = 0xa40;
    constexpr uintptr_t ASTExtraPlayerCharacter_bIsMLAI = 0xa41;
    constexpr uintptr_t ASTExtraPlayerCharacter_TeamID = 0x1228;
    constexpr uintptr_t ASTExtraPlayerCharacter_Health = 0x1138;
    constexpr uintptr_t ASTExtraPlayerCharacter_DeadOffset = 0x117c;
    constexpr uintptr_t ASTExtraPlayerCharacter_PlayerName = 0xae8;
    constexpr uintptr_t ASTExtraPlayerCharacter_Mesh = 0x498;
    constexpr uintptr_t ASTExtraPlayerCharacter_CurrentWeapon = 0x1160;
    constexpr uintptr_t ASTExtraPlayerCharacter_MoveCoord = 0x190;
    constexpr uintptr_t ASTExtraPlayerCharacter_OpenTheSightOffset = 0xae0;
    constexpr uintptr_t ASTExtraPlayerCharacter_OpenFireOffset = 0xae4;
    constexpr uintptr_t ASTExtraPlayerCharacter_Status = 0x9a8;
    
    constexpr uintptr_t USkeletalMeshComponent_ComponentToWorld = 0x240;
    constexpr uintptr_t USkeletalMeshComponent_CachedBoneSpaceTransforms = 0x7e0;
    
    constexpr uintptr_t CoordOffset_Coord = 0x0;
    constexpr uintptr_t CoordOffset_Height = 0x18;
}