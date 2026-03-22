//
//  Dolphins.h
//  Dolphins
//
//  Created by XBK on 2022/4/24.
//  Updated for PUBG Mobile 4.3 - Non-Jailbreak
//

#ifndef DOLPHINS_H
#define DOLPHINS_H

#include "Dolphins/imgui/imgui.h"
#include <vector>
#include <string>
#include <cstdint>

// ============ FORWARD DECLARATIONS (module_tools.h'den gelenler) ============
// Bu yapılar module_tools.h'de tanımlı, burada sadece forward declare ediyoruz

struct ImVec2;
struct ImVec3;
struct ImVec4;
struct Ue4Transform;
struct Ue4Matrix;
struct MinimalViewInfo;
struct BonesData;
struct StaticPlayerData;
struct StaticMaterialData;
struct PlayerData;
struct MaterialData;
struct MaterialStruct;

// ============ EXTERN DECLARATIONS ============
// Global değişkenler ve fonksiyonlar

// calcTextSize fonksiyonu için
float calcTextSize(const char* text);

// ============ THREAD FUNCTIONS ============

// Static data thread - reads game objects every 4 seconds
void *readStaticData(void *arg);

// Frame data function - called every frame for ESP
void readFrameData(ImVec2 screenSize, 
                   std::vector<PlayerData> &playerDataList, 
                   std::vector<MaterialData> &materialDataList);

// Aimbot thread - runs at 60fps (16666us sleep)
void *silenceAimbot(void *arg);

// ============ UTILITY FUNCTIONS ============

// Visibility check using LineOfSightTo
bool isCoordVisibility(ImVec3 coord);

// Smoke check
bool isOnSmoke(ImVec3 coord);

// Get player name from memory
char* getPlayerName(uintptr_t addr);

// Get UE4 class name from class ID
char* getClassName(int classId);

// Get status name from status ID
const char* getStatusName(int statusId);

// ============ BONE FUNCTIONS ============

// Get 3D bone position
ImVec3 getBone(uintptr_t human, uintptr_t bones, int part);

// Get 2D screen bone position (returns true if on screen)
bool getBone2d(MinimalViewInfo pov, 
               ImVec2 screen, 
               uintptr_t human, 
               uintptr_t bones, 
               int part, 
               ImVec2 &buf);

// ============ MATH HELPERS (Inline) ============

// 3D distance calculation
inline float get3dDistance(ImVec3 from, ImVec3 to, float divide = 1.0f);

// 2D distance calculation  
inline float get2dDistance(ImVec2 screen, ImVec2 pos);

// World to screen conversion
ImVec2 worldToScreen(ImVec3 worldPos, MinimalViewInfo pov, ImVec2 screenSize);

// Rotate angle calculation
float rotateAngle(ImVec3 self, ImVec3 target);

// Rotate coordinate for radar
ImVec2 rotateCoord(float angle, ImVec2 coord);

// Get angle difference for aimbot
float getAngleDifference(float target, float current);

// Change sign (helper for aimbot)
float change(float val);

// Transform to matrix conversion
Ue4Matrix transformToMatrix(Ue4Transform transform);

// Matrix multiplication
Ue4Matrix matrixMulti(Ue4Matrix m1, Ue4Matrix m2);

// Matrix to vector conversion
ImVec3 matrixToVector(Ue4Matrix matrix);

// ============ ITEM CLASSIFICATION ============

// Check if class name is a weapon/item
MaterialStruct isWeapon(const char* className);
MaterialStruct isMaterial(const char* className);
MaterialStruct isBoxMaterial(int goodsId);
bool isRecycled(const char* className);

#endif // DOLPHINS_H
