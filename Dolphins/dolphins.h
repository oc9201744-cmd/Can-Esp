//
// dolphins.h - STRUCT DEFINITIONS (COMPILE FIX)
// StaticPlayerData struct'ına yeni alanlar eklendi
//

#ifndef DOLPHINS_H
#define DOLPHINS_H

#include <string>
using namespace std;

// ============================================================================
// STATIC PLAYER DATA STRUCT - UPDATED
// ============================================================================
struct StaticPlayerData {
    uintptr_t addr;           // Character address
    uintptr_t coordAddr;      // Coord component address
    uintptr_t playerState;    // PlayerState pointer (ADDED)
    int team;                 // Team ID
    float health;             // Health value (ADDED)
    float maxHealth;          // Max health (ADDED)
    int robot;                // Is AI/Bot
    string name;              // Player name
    int status;               // Status value
};

// ============================================================================
// STATIC MATERIAL DATA STRUCT
// ============================================================================
struct StaticMaterialData {
    int type;
    int id;
    const char* name;
    uintptr_t addr;
    uintptr_t coordAddr;
};

#endif // DOLPHINS_H