//
//  Dolphins.m
//  Dolphins
//
//  Created by XBK on 2022/4/24.
//

// Kendi header'larımız
#import "crossoffsets.h"
#import "dolphins.h"
#import "View/FloatView.h"
#import "View/OverlayView.h"

// System header'lar
#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>

// C++ header'lar
#include <stdio.h>
#include <vector>
#include <iostream>
#include <string>
#include <cmath>
#include <pthread.h>

// Utils header'ları (relatif yol)
#include "utils/module_tools.h"
#include "utils/pubg_offset.h"
#include "utils/memory_tools.h"
#include "utils/log.h"

// Offsets.hpp
#include "../Offsets.hpp"

#define CJID "com.tencent.tmgp.pubgmhd"

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

using namespace std;

// ========== Global Variables ==========
ModuleControl moduleControl;
MemoryTools memoryTools;

bool (*LineOfSightTo)(void *controller, void *actor, ImVec3 bone_point, bool ischeck);
void (*AddControllerYawInput)(void *actor, float val);
void (*AddControllerRollInput)(void *actor, float val);
void (*AddControllerPitchInput)(void *actor, float val);

// ========== GWorld ve GNames ==========
long gWorld() {
    OffsetValues offsetsForBundle = [OffsetsManager getOffsetsForBundleID:[[NSBundle mainBundle] bundleIdentifier]];
    return reinterpret_cast<long(__fastcall*)(long)>((long)_dyld_get_image_vmaddr_slide(0) + offsetsForBundle.gWorldFun)((long)_dyld_get_image_vmaddr_slide(0) + offsetsForBundle.gWorldData);
}

long gName() {
    OffsetValues offsetsForBundle = [OffsetsManager getOffsetsForBundleID:[[NSBundle mainBundle] bundleIdentifier]];
    return reinterpret_cast<long(__fastcall*)(long)>((long)_dyld_get_image_vmaddr_slide(0) + offsetsForBundle.gNameFun)((long)_dyld_get_image_vmaddr_slide(0) + offsetsForBundle.gNameData);
}

// ========== Global Data ==========
struct {
    uintptr_t libAddr = 0;
    uintptr_t gwlordAddr;
    uintptr_t gnameAddr;
    uintptr_t playerController;
    string playerControllerClassName;
    uintptr_t cameraManager;
    string cameraManagerClassName;
    uintptr_t selfAddr;
    vector<StaticPlayerData> playerDataList;
    vector<StaticMaterialData> materialDataList;
    vector<StaticMaterialData> smokeList;
} staticData;

// ========== DAN Bot Detection ==========
bool DAN_IsBot(uintptr_t actor) {
    if (actor == 0) return true;
    
    uint8_t isAI = 0;
    memoryTools.readMemory(actor + 0xA40, 1, &isAI);
    if (isAI & 1) return true;
    
    uint8_t isMLAI = 0;
    memoryTools.readMemory(actor + 0xA41, 1, &isMLAI);
    if (isMLAI & 1) return true;
    
    uint64_t uid = 0;
    memoryTools.readMemory(actor + 0x988, sizeof(uint64_t), &uid);
    if (uid == 0) return true;
    
    return false;
}

// ========== Helper Functions (Kısa versiyon) ==========
float get3dDistance(ImVec3 a, ImVec3 b, float scale) {
    float dx = a.x - b.x, dy = a.y - b.y, dz = a.z - b.z;
    return sqrt(dx*dx + dy*dy + dz*dz) / scale;
}

float get2dDistance(ImVec2 screen, ImVec2 point) {
    float dx = screen.x/2 - point.x, dy = screen.y/2 - point.y;
    return sqrt(dx*dx + dy*dy);
}

float rotateAngle(ImVec3 from, ImVec3 to) {
    return atan2(to.y - from.y, to.x - from.x) * 180 / M_PI;
}

ImVec2 rotateCoord(float angle, ImVec2 coord) {
    float rad = angle * M_PI / 180;
    return ImVec2(coord.x * cos(rad) - coord.y * sin(rad), coord.x * sin(rad) + coord.y * cos(rad));
}

ImVec2 worldToScreen(ImVec3 worldPos, MinimalViewInfo pov, ImVec2 screenSize) {
    ImVec3 delta = {worldPos.x - pov.location.x, worldPos.y - pov.location.y, worldPos.z - pov.location.z};
    float pitch = pov.rotation.Pitch * M_PI / 180, yaw = pov.rotation.Yaw * M_PI / 180;
    float cp = cos(pitch), sp = sin(pitch), cy = cos(yaw), sy = sin(yaw);
    ImVec3 forward = {cp * cy, cp * sy, sp};
    ImVec3 right = {-sy, cy, 0};
    ImVec3 up = {-sp * cy, -sp * sy, cp};
    float dotF = delta.x*forward.x + delta.y*forward.y + delta.z*forward.z;
    if (dotF < 0.1f) return {0,0};
    float fovRad = pov.fov * M_PI / 180;
    float screenX = (delta.x*right.x + delta.y*right.y + delta.z*right.z) / dotF / tan(fovRad/2);
    float screenY = (delta.x*up.x + delta.y*up.y + delta.z*up.z) / dotF / tan(fovRad/2);
    return {screenSize.x/2 + screenX*screenSize.x/2, screenSize.y/2 - screenY*screenSize.y/2};
}

float getAngleDifference(float target, float current) {
    float diff = target - current;
    while (diff > 180) diff -= 360;
    while (diff < -180) diff += 360;
    return diff;
}

float change(float angle) { return angle; }

ImVec2 rotateAngleView(ImVec3 from, ImVec3 to) {
    float dx = to.x - from.x, dy = to.y - from.y, dz = to.z - from.z;
    return {atan2(dy, dx) * 180 / M_PI, atan2(dz, sqrt(dx*dx + dy*dy)) * 180 / M_PI};
}

Ue4Matrix transformToMatrix(Ue4Transform t) {
    Ue4Matrix m;
    float x2 = t.rotation.x * 2, y2 = t.rotation.y * 2, z2 = t.rotation.z * 2;
    float xx = t.rotation.x * x2, xy = t.rotation.x * y2, xz = t.rotation.x * z2;
    float yy = t.rotation.y * y2, yz = t.rotation.y * z2, zz = t.rotation.z * z2;
    float wx = t.rotation.w * x2, wy = t.rotation.w * y2, wz = t.rotation.w * z2;
    m.m[0][0] = 1 - (yy + zz); m.m[0][1] = xy - wz; m.m[0][2] = xz + wy; m.m[0][3] = 0;
    m.m[1][0] = xy + wz; m.m[1][1] = 1 - (xx + zz); m.m[1][2] = yz - wx; m.m[1][3] = 0;
    m.m[2][0] = xz - wy; m.m[2][1] = yz + wx; m.m[2][2] = 1 - (xx + yy); m.m[2][3] = 0;
    m.m[3][0] = t.translation.x; m.m[3][1] = t.translation.y; m.m[3][2] = t.translation.z; m.m[3][3] = 1;
    return m;
}

ImVec3 matrixToVector(Ue4Matrix m) {
    return {m.m[3][0], m.m[3][1], m.m[3][2]};
}

Ue4Matrix matrixMulti(Ue4Matrix a, Ue4Matrix b) {
    Ue4Matrix r;
    for (int i = 0; i < 4; i++)
        for (int j = 0; j < 4; j++)
            r.m[i][j] = a.m[i][0]*b.m[0][j] + a.m[i][1]*b.m[1][j] + a.m[i][2]*b.m[2][j] + a.m[i][3]*b.m[3][j];
    return r;
}

char* getClassName(int classId) {
    static char buf[256];
    if (classId <= 0 || classId > 2000000) return (char*)"Unknown";
    int page = classId / 16384, index = classId % 16384;
    uintptr_t pageAddr = memoryTools.readPtr(staticData.gnameAddr + page * 8);
    if (!pageAddr) return (char*)"Unknown";
    uintptr_t nameAddr = memoryTools.readPtr(pageAddr + index * 8) + PubgOffset::ObjectParam::ClassNameOffset;
    memoryTools.readMemory(nameAddr, 64, buf);
    return buf;
}

char* getPlayerName(uintptr_t addr) {
    static char buf[64];
    if (!addr) return (char*)"Unknown";
    uintptr_t namePtr = memoryTools.readPtr(addr);
    int len = memoryTools.readInt(addr + 8);
    if (!namePtr || len <= 0 || len > 63) return (char*)"Unknown";
    memoryTools.readMemory(namePtr, len, buf);
    buf[len] = 0;
    return buf;
}

ImVec3 getBone(uintptr_t human, uintptr_t bones, int part) {
    Ue4Transform actorftf;
    memoryTools.readMemory(human, sizeof(ImVec4), &actorftf.rotation);
    memoryTools.readMemory(human + 0x10, sizeof(ImVec3), &actorftf.translation);
    memoryTools.readMemory(human + 0x20, sizeof(ImVec3), &actorftf.scale3d);
    Ue4Matrix actormatrix = transformToMatrix(actorftf);
    Ue4Transform boneftf;
    memoryTools.readMemory(bones + part * 48, sizeof(ImVec4), &boneftf.rotation);
    memoryTools.readMemory(bones + part * 48 + 0x10, sizeof(ImVec3), &boneftf.translation);
    memoryTools.readMemory(bones + part * 48 + 0x20, sizeof(ImVec3), &boneftf.scale3d);
    return matrixToVector(matrixMulti(transformToMatrix(boneftf), actormatrix));
}

bool getBone2d(MinimalViewInfo pov, ImVec2 screen, uintptr_t human, uintptr_t bones, int part, ImVec2 &buf) {
    ImVec3 world = getBone(human, bones, part);
    buf = worldToScreen(world, pov, screen);
    return buf.x != 0 && buf.y != 0;
}

bool isCoordVisibility(ImVec3 coord) {
    if (!LineOfSightTo) return false;
    return LineOfSightTo((void*)staticData.playerController, (void*)staticData.cameraManager, coord, false);
}

bool isOnSmoke(ImVec3 coord) {
    for (auto& smoke : staticData.smokeList) {
        if (!smoke.coordAddr) continue;
        ImVec3 smokeCoord = memoryTools.read<ImVec3>(smoke.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset);
        if (get3dDistance(smokeCoord, coord, 100) < 4) return true;
    }
    return false;
}

MaterialStruct isMaterial(const char* className) {
    MaterialStruct r = {-1, 0, (char*)"Unknown"};
    return r;
}

MaterialStruct isWeapon(const char* className) {
    MaterialStruct r = {-1, 0, (char*)"Unknown"};
    return r;
}

MaterialStruct isBoxMaterial(int itemId) {
    MaterialStruct r = {-1, 0, (char*)"Unknown"};
    return r;
}

bool isRecycled(const char* className) { return false; }

// ========== UI ==========
static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        // ESP ve Menu burada başlatılacak
    });
}

__attribute__((constructor)) static void initialize() {
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorDrop);
    pthread_t t1, t2;
    pthread_create(&t1, nullptr, [](void*) -> void* { while(1) { sleep(4); /* static data */ } return nullptr; }, nullptr);
    pthread_create(&t2, nullptr, [](void*) -> void* { while(1) { usleep(16666); /* aimbot */ } return nullptr; }, nullptr);
}

void readFrameData(ImVec2 screenSize, vector<PlayerData>& playerDataList, vector<MaterialData>& materialDataList) {
    playerDataList.clear();
    materialDataList.clear();
}