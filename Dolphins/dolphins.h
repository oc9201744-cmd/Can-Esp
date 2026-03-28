//
// dolphins.h - MINIMAL VERSION
// Forward declarations only - includes handled elsewhere
//

#ifndef DOLPHINS_H
#define DOLPHINS_H

#include <vector>
#include "Dolphins/imgui/imgui.h"

using namespace std;

// Forward declarations for structs (defined in CustomStrcut.h)
struct PlayerData;
struct MaterialData;
struct MinimalViewInfo;

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

// NOTE: Full struct definitions are in CustomStrcut.h
// This file uses forward declarations to avoid include issues

#endif // DOLPHINS_H