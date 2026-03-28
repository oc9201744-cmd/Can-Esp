//
// PUBG Mobile Offset Header - FIXED VERSION
// Tüm offsetler AIOHeader.hpp'den doğrulanmıştır
// Son güncelleme: 2025
//

#ifndef PUBG_OFFSET_H
#define PUBG_OFFSET_H

namespace PubgOffset {
    
    //=============================================================================
    // WORLD & LEVEL OFFSETS
    //=============================================================================
    
    // ULevel offset from GWorld
    static constexpr long ULevelOffset = 0x30;
    
    namespace ULevelParam {
        // Actor array ve count
        static constexpr long ObjectArrayOffset = 0xA0;
        static constexpr long ObjectCountOffset = 0xA8;
    }
    
    //=============================================================================
    // PLAYER CONTROLLER OFFSETS
    //=============================================================================
    
    // PlayerController'dan erişim offsetleri
    static constexpr long PlayerControllerOffset[3] = {0x38, 0x0, 0x30};
    
    namespace PlayerControllerParam {
        // Self (controlled pawn) offset
        static constexpr long SelfOffset = 0x4A0;
        
        // Camera Manager offset
        static constexpr long CameraManagerOffset = 0x4B0;
        
        namespace ControllerFunction {
            // LineOfSight function offset (掩体判断)
            static constexpr long LineOfSightToOffset = 0x780;
        }
    }
    
    //=============================================================================
    // OBJECT/ACTOR BASE OFFSETS (Tüm Actor'lar için geçerli)
    //=============================================================================
    
    namespace ObjectParam {
        // Engine temel offsetler
        static constexpr long ClassIdOffset = 0x10;           // Object class ID
        static constexpr long CoordOffset = 0x220;            // RootComponent offset
        
        //=========================================================================
        // CRITICAL: PlayerState Pointer - ASIL VERİ BURADA
        //=========================================================================
        // APawn'dan inherit edilen PlayerState pointer
        // Character + 0x5C0 → PlayerState*
        // PlayerState üzerinden GÜVENİLİR veriler okunur:
        //   - TeamID
        //   - Health
        //   - PlayerUID
        //   - LiveState
        static constexpr long PlayerStateOffset = 0x5C0;
        
        //=========================================================================
        // CHARACTER BODY OFFSETLER (Sadece referans - güvenilmez kimlik için)
        //=========================================================================
        // Bu offsetler character body üzerinde mevcuttur ancak
        // kimlik kontrolü için PlayerState üzerinden okunmalıdır!
        
        // AUAECharacter offsetleri (sadece AI tespiti için kullanılır)
        static constexpr long bIsAIOffset = 0xA40;            // bool (1 byte)
        static constexpr long bIsMLAIOffset = 0xA41;          // bool (1 byte)
        
        // Character body'deki TeamID - GÜVENİLMEZ, sadece fallback
        static constexpr long TeamOffset_Character = 0x998;   // KULLANMA! PlayerState'den oku
        
        // Character body'deki PlayerName - GÜVENİLMEZ
        static constexpr long PlayerNameOffset_Character = 0x960;  // KULLANMA!
        
        //=========================================================================
        // PLAYERSTATE OFFSETLER - ASIL GÜVENİLİR VERİ KAYNAĞI
        //=========================================================================
        
        // AUAEPlayerState offsets (PlayerState + offset)
        namespace PlayerState {
            // Kimlik bilgileri - AUAEPlayerState'den
            static constexpr long TeamIDOffset = 0x700;       // int (4 bytes) - GÜVENİLİR
            static constexpr long PlayerUIDOffset = 0x668;    // FString (16 bytes)
            static constexpr long NationOffset = 0x6F0;       // FString (16 bytes)
            static constexpr long PlayerKeyOffset = 0x660;    // uint32 (4 bytes)
            static constexpr long UIDOffset = 0x6C8;          // uint64 (8 bytes)
            
            // ASTExtraPlayerState offsets (PlayerState + offset)
            static constexpr long PlayerHealthOffset = 0x1424;     // float (4 bytes) - GÜVENİLİR
            static constexpr long PlayerHealthMaxOffset = 0x1428;  // float (4 bytes) - GÜVENİLİR
            static constexpr long LiveStateOffset = 0x13F4;        // uint8 (1 byte)
            static constexpr long CharacterOwnerOffset = 0x1408;   // Pointer to character
        }
        
        //=========================================================================
        // MESH & BONE OFFSETLER
        //=========================================================================
        static constexpr long MeshOffset = 0x468;             // SkeletalMeshComponent*
        
        namespace MeshParam {
            static constexpr long ComponentToWorldOffset = 0x230;  // FTransform
            static constexpr long BoneArrayOffset = 0x7F8;         // TArray<FTransform>
            static constexpr long BoneCountOffset = 0x800;         // Bone count
        }
        
        //=========================================================================
        // ROTATION OFFSETLER - DÜZELTİLDİ
        //=========================================================================
        // RepMovement yapısından (offset 0x80)
        namespace Rotation {
            static constexpr long RepMovementOffset = 0x80;   // Base offset
            static constexpr long PitchOffset = 0x8C;         // Pitch (4 bytes float)
            static constexpr long YawOffset = 0x88;           // Yaw (4 bytes float)  
            static constexpr long RollOffset = 0x90;          // Roll (4 bytes float)
        }
        
        //=========================================================================
        // STATUS & STATE OFFSETLER
        //=========================================================================
        // UYARI: Bu offset belirsiz, doğrulanması gerekiyor
        static constexpr long StatusOffset = 0x1058;          // CurrentStates?
        
        // Dead kontrolü için alternatif
        static constexpr long DeadOffset = 0x8B0;             // bDead flag
        
        //=========================================================================
        // WEAPON PARAM
        //=========================================================================
        namespace WeaponParam {
            static constexpr long MasterOffset = 0x640;       // Owner pointer
            static constexpr long WeaponIdOffset = 0x7D0;     // Weapon ID
        }
        
        //=========================================================================
        // PLAYER FUNCTIONS (Self için)
        //=========================================================================
        namespace PlayerFunction {
            static constexpr long AddControllerYawInputOffset = 0x788;
            static constexpr long AddControllerRollInputOffset = 0x790;
            static constexpr long AddControllerPitchInputOffset = 0x798;
        }
    }
    
    //=============================================================================
    // HELPER FUNCTIONS - DOĞRU OKUMA SIRASI
    //=============================================================================
    
    /*
     * DOĞRU OKUMA AKIŞI:
     * 
     * 1. Character Actor'ü bul (actor list'ten)
     * 2. PlayerState pointer'ını al:
     *    uintptr_t playerState = read<uintptr_t>(character + ObjectParam::PlayerStateOffset);
     * 
     * 3. PlayerState'den güvenilir verileri oku:
     *    int teamID = read<int>(playerState + ObjectParam::PlayerState::TeamIDOffset);
     *    float health = read<float>(playerState + ObjectParam::PlayerState::PlayerHealthOffset);
     *    float maxHealth = read<float>(playerState + ObjectParam::PlayerState::PlayerHealthMaxOffset);
     * 
     * 4. AI kontrolü için character body kullanılabilir:
     *    bool isAI = read<bool>(character + ObjectParam::bIsAIOffset);
     * 
     * 5. Self karşılaştırması için PlayerState UID kullan:
     *    uint64_t selfUID = read<uint64_t>(selfPlayerState + ObjectParam::PlayerState::UIDOffset);
     *    uint64_t entityUID = read<uint64_t>(entityPlayerState + ObjectParam::PlayerState::UIDOffset);
     *    if (selfUID == entityUID) continue; // Skip self
     */
    
} // namespace PubgOffset

#endif // PUBG_OFFSET_H