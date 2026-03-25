//
//  dolphins.h
//  Dolphins
//

#pragma once

#include <vector>
#include <string>
#include <cmath>
#include <cstdint>

// imgui.h'ı dahil et (struct'ları ondan alsın)
#include "imgui/imgui.h"

// imgui'de olmayan struct'ları tanımla
struct FRotator {
    float Pitch, Yaw, Roll;
};

struct MinimalViewInfo {
    ImVec3 location;
    FRotator rotation;
    float fov;
};

struct Ue4Transform {
    ImVec4 rotation;
    ImVec3 translation;
    ImVec3 scale3d;
};

struct Ue4Matrix {
    float m[4][4];
};

struct BonesData {
    ImVec2 head, pit, pelvis;
    ImVec2 lcollar, rcollar;
    ImVec2 lelbow, relbow;
    ImVec2 lwrist, rwrist;
    ImVec2 lthigh, rthigh;
    ImVec2 lknee, rknee;
    ImVec2 lankle, rankle;
};

struct StaticPlayerData {
    uintptr_t addr = 0;
    uintptr_t coordAddr = 0;
    int team = 0;
    int robot = 0;
    int status = 0;
    char* name = nullptr;
};

struct StaticMaterialData {
    int type = 0;
    int id = 0;
    char* name = nullptr;
    uintptr_t addr = 0;
    uintptr_t coordAddr = 0;
};

struct PlayerData {
    float angle = 0;
    ImVec2 radar;
    float distance = 0;
    int robot = 0;
    bool visibility = false;
    int team = 0;
    float hp = 0;
    std::string statusName;
    std::string weaponName;
    char* name = nullptr;
    ImVec2 screen;
    ImVec2 size;
    BonesData bonesData;
};

struct MaterialData {
    int type = 0;
    int id = 0;
    char* name = nullptr;
    float distance = 0;
    ImVec2 screen;
};

struct MaterialStruct {
    int type = -1;
    int id = 0;
    char* name = nullptr;
};

// ========== Function Declarations ==========
float get3dDistance(ImVec3 a, ImVec3 b, float scale);
float get2dDistance(ImVec2 screen, ImVec2 point);
float rotateAngle(ImVec3 from, ImVec3 to);
ImVec2 rotateCoord(float angle, ImVec2 coord);
ImVec2 worldToScreen(ImVec3 worldPos, MinimalViewInfo pov, ImVec2 screenSize);
float getAngleDifference(float target, float current);
float change(float angle);
ImVec2 rotateAngleView(ImVec3 from, ImVec3 to);
Ue4Matrix transformToMatrix(Ue4Transform transform);
ImVec3 matrixToVector(Ue4Matrix matrix);
Ue4Matrix matrixMulti(Ue4Matrix a, Ue4Matrix b);
MaterialStruct isMaterial(const char* className);
MaterialStruct isWeapon(const char* className);
MaterialStruct isBoxMaterial(int itemId);
bool isRecycled(const char* className);
char* getClassName(int classId);
char* getPlayerName(uintptr_t addr);
ImVec3 getBone(uintptr_t human, uintptr_t bones, int part);
bool getBone2d(MinimalViewInfo pov, ImVec2 screen, uintptr_t human, uintptr_t bones, int part, ImVec2 &buf);
bool isCoordVisibility(ImVec3 coord);
bool isOnSmoke(ImVec3 coord);
void* readStaticData(void*);
void* silenceAimbot(void*);
void readFrameData(ImVec2 screenSize, std::vector<PlayerData>& playerDataList, std::vector<MaterialData>& materialDataList);