//
// dolphins.h - FIXED VERSION
// Function declarations ONLY - NO struct definitions
//

#ifndef DOLPHINS_H
#define DOLPHINS_H

#include <vector>
#include "CustomStrcut.h"  // FIXED - Dolphins/ prefix removed

using namespace std;

// ============================================================================
// FUNCTION DECLARATIONS
// ============================================================================

// Main data reading functions
void *readStaticData(void *);
void *silenceAimbot(void *);
void readFrameData(ImVec2 screenSize, vector<PlayerData> &playerDataList, vector<MaterialData> &materialDataList);

// Helper functions
char *getPlayerName(uintptr_t addr);
char *getClassName(int classId);
ImVec3 getBone(uintptr_t human, uintptr_t bones, int part);
bool getBone2d(MinimalViewInfo pov, ImVec2 screen, uintptr_t human, uintptr_t bones, int part, ImVec2 &buf);
bool isCoordVisibility(ImVec3 coord);
bool isOnSmoke(ImVec3 coord);

// NOTE: All struct definitions are in CustomStrcut.h
// DO NOT define structs here to avoid redefinition errors!

#endif // DOLPHINS_H