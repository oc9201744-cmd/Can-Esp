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

// ============ FORWARD DECLARATIONS ============
struct PlayerData;
struct MaterialData;
struct StaticPlayerData;
struct StaticMaterialData;
struct BonesData;
struct MinimalViewInfo;
struct Ue4Transform;
struct Ue4Matrix;

// ============ IMGUI HELPERS ============
// calcTextSize fonksiyonu için forward decl
float calcTextSize(const char* text);

// ============ DATA STRUCTURES ============

// 2D Vector
struct ImVec2 {
    float x, y;
    ImVec2() : x(0), y(0) {}
    ImVec2(float _x, float _y) : x(_x), y(_y) {}
};

// 3D Vector
struct ImVec3 {
    float x, y, z;
    ImVec3() : x(0), y(0), z(0) {}
    ImVec3(float _x, float _y, float _z) : x(_x), y(_y), z(_z) {}
};

// 4D Vector (Quaternion)
struct ImVec4 {
    float x, y, z, w;
    ImVec4() : x(0), y(0), z(0), w(0) {}
    ImVec4(float _x, float _y, float _z, float _w) : x(_x), y(_y), z(_z), w(_w) {}
};

// ============ UE4 STRUCTS ============

// UE4 Transform (48 bytes per bone)
struct Ue4Transform {
    ImVec4 rotation;        // +0x0 (16 bytes)
    ImVec3 translation;     // +0x10 (12 bytes)
    ImVec3 scale3d;         // +0x20 (12 bytes)
    // Padding to 48 bytes
};

// UE4 4x4 Matrix
struct Ue4Matrix {
    float m[4][4];
};

// Camera POV Info
struct MinimalViewInfo {
    ImVec3 location;        // Camera location
    ImVec3 rotation;        // Camera rotation
    float fov;              // Field of view
};

// ============ BONE DATA ============

struct BonesData {
    ImVec2 head = ImVec2(0, 0);
    ImVec2 pit = ImVec2(0, 0);          // Chest/Gogus
    ImVec2 pelvis = ImVec2(0, 0);       // Pelvis
    ImVec2 lcollar = ImVec2(0, 0);      // Left collar (sol omuz)
    ImVec2 rcollar = ImVec2(0, 0);      // Right collar (sag omuz)
    ImVec2 lelbow = ImVec2(0, 0);       // Left elbow (sol dirsek)
    ImVec2 relbow = ImVec2(0, 0);       // Right elbow (sag dirsek)
    ImVec2 lwrist = ImVec2(0, 0);       // Left wrist (sol bilek)
    ImVec2 rwrist = ImVec2(0, 0);       // Right wrist (sag bilek)
    ImVec2 lthigh = ImVec2(0, 0);       // Left thigh (sol kalca)
    ImVec2 rthigh = ImVec2(0, 0);       // Right thigh (sag kalca)
    ImVec2 lknee = ImVec2(0, 0);        // Left knee (sol diz)
    ImVec2 rknee = ImVec2(0, 0);        // Right knee (sag diz)
    ImVec2 lankle = ImVec2(0, 0);       // Left ankle (sol ayak)
    ImVec2 rankle = ImVec2(0, 0);       // Right ankle (sag ayak)
};

// ============ STATIC DATA (Thread-safe) ============

struct StaticPlayerData {
    uintptr_t addr = 0;                 // Object address
    uintptr_t coordAddr = 0;            // Coordinate component address
    int team = 0;                       // Team ID
    std::string name = "";              // Player name
    int robot = 0;                      // 0 = Real Player, 1 = Bot/AI (kbIsAI || kbIsMLAI)
    float hp = 0.0f;                    // Health (0-100)
    int status = 0;                     // Player status (enum)
};

struct StaticMaterialData {
    int type = 0;                       // MaterialType enum
    int id = 0;                         // Item ID
    std::string name = "";              // Item name
    uintptr_t addr = 0;                 // Object address
    uintptr_t coordAddr = 0;            // Coordinate component address
};

// ============ FRAME DATA (Per-frame render) ============

struct PlayerData {
    // Position/Rotation
    float angle = 0.0f;                 // Angle to player
    ImVec2 radar = ImVec2(0, 0);        // Radar position
    
    // Distance & Visibility
    float distance = 0.0f;              // Distance in meters
    bool visibility = false;            // Line of sight check
    bool inSmoke = false;               // In smoke check
    
    // Player Info
    int team = 0;                       // Team ID
    float hp = 0.0f;                    // Health (0-100)
    int robot = 0;                      // 0 = Real, 1 = Bot
    std::string statusName = "";        // Status string (Standing, Crouching, etc.)
    std::string weaponName = "";        // Current weapon name
    std::string name = "";              // Player name
    
    // Screen coordinates
    ImVec2 screen = ImVec2(0, 0);       // Screen position (center)
    ImVec2 size = ImVec2(0, 0);         // Box size (width, height)
    
    // Skeleton
    BonesData bonesData;                // Bone screen coordinates
    bool hasBones = false;              // Valid skeleton flag
    bool isVisibleBone = false;          // At least one bone visible
};

struct MaterialData {
    int type = 0;                       // MaterialType enum
    int id = 0;                         // Item ID
    std::string name = "";              // Item name
    float distance = 0.0f;              // Distance in meters
    ImVec2 screen = ImVec2(0, 0);       // Screen position
};

// ============ MATERIAL STRUCT (For item classification) ============

struct MaterialStruct {
    int type = -1;                      // MaterialType or -1 for invalid
    int id = 0;
    const char* name = nullptr;
};

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

// ============ MATH HELPERS ============

// 3D distance calculation
float get3dDistance(ImVec3 from, ImVec3 to, float divide = 1.0f);

// 2D distance calculation  
float get2dDistance(ImVec2 screen, ImVec2 pos);

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
