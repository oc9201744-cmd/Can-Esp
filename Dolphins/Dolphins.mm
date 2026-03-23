//
//  Dolphins.m
//  Dolphins
//
//  Created by XBK on 2022/4/24.
//

#import "Dolphins/crossoffsets.h"
#import <Foundation/Foundation.h>
#import "Dolphins/View/FloatView.h"
#import "Dolphins/View/OverlayView.h"
#include "Dolphins/dolphins.h"
#import <mach-o/dyld.h>
#include <stdio.h>
#include <vector>
#include <iostream>
#include <string>
#include <cmath>
#include "Dolphins/utils/module_tools.h"
#include "Dolphins/utils/pubg_offset.h"
#include "Dolphins/utils/memory_tools.h"
#include "Dolphins/utils/log.h"

#define CJID "com.tencent.tmgp.pubgmhd"
#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define screenHeight [UIScreen mainScreen].bounds.size.height
#define screenWidth [UIScreen mainScreen].bounds.size.width

using namespace std;

ModuleControl moduleControl;
MemoryTools memoryTools;

OffsetValues offsets[] = {
    { 0x102A5125C, 0x10A4A1960, 0x104C0F1E8, 0x10A0557E0 },  // GL
    { 0x1028791CC, 0x10A171A00, 0x104510EF0, 0x109AAA1A0 },  // VNG
    { 0x102AD71F8, 0x10A47D400, 0x10476F14C, 0x109DB5940 },  // KR
    { 0x102AAAB0C, 0x10A453300, 0x104742830, 0x109D8B830 }   // TW
};

bool (*LineOfSightTo)(void *controller, void *actor, ImVec3 bone_point, bool ischeck);
void (*AddControllerYawInput)(void *actor, float val);
void (*AddControllerRollInput)(void *actor, float val);
void (*AddControllerPitchInput)(void *actor, float val);

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

// ==================== FONKSİYON PROTOTİPLERİ ====================
long gWorld();
long gName();
bool IsBotPlayer(uintptr_t playerAddr);
void* readStaticData(void*);
void* silenceAimbot(void*);
bool isCoordVisibility(ImVec3 coord);
bool isOnSmoke(ImVec3 coord);
char* getPlayerName(uintptr_t addr);
char* getClassName(int classId);
string getStatusName(uintptr_t statusAddr);
ImVec3 getBone(uintptr_t human, uintptr_t bones, int part);
bool getBone2d(MinimalViewInfo pov, ImVec2 screen, uintptr_t human, uintptr_t bones, int part, ImVec2 &buf);
float get3dDistance(ImVec3 a, ImVec3 b, float scale);
float get2dDistance(ImVec2 screen, ImVec2 point);
float rotateAngle(ImVec3 selfCoord, ImVec3 objectCoord);
ImVec2 rotateCoord(float angle, ImVec2 coord);
ImVec2 rotateAngleView(ImVec3 selfCoord, ImVec3 aimbotCoord);
float getAngleDifference(float target, float current);
float change(float angle);
ImVec2 worldToScreen(ImVec3 worldLocation, MinimalViewInfo pov, ImVec2 screenSize);
Ue4Matrix transformToMatrix(Ue4Transform& transform);
Ue4Matrix matrixMulti(Ue4Matrix& m1, Ue4Matrix& m2);
ImVec3 matrixToVector(Ue4Matrix& matrix);
MaterialStruct isMaterial(const char* className);
MaterialStruct isWeapon(const char* className);
MaterialStruct isBoxMaterial(int id);
bool isRecycled(const char* className);

// ==================== GWorld ====================
long gWorld() {
    OffsetValues offsetsForBundle = [OffsetsManager getOffsetsForBundleID:[[NSBundle mainBundle] bundleIdentifier]];
    uintptr_t slide = (uintptr_t)_dyld_get_image_vmaddr_slide(0);
    uintptr_t gWorldFuncAddr = slide + offsetsForBundle.gWorldFun;
    uintptr_t gWorldDataAddr = slide + offsetsForBundle.gWorldData;
    typedef long (*gWorldFunc)(long);
    gWorldFunc func = (gWorldFunc)gWorldFuncAddr;
    return func(gWorldDataAddr);
}

// ==================== GName ====================
long gName() {
    OffsetValues offsetsForBundle = [OffsetsManager getOffsetsForBundleID:[[NSBundle mainBundle] bundleIdentifier]];
    uintptr_t slide = (uintptr_t)_dyld_get_image_vmaddr_slide(0);
    uintptr_t gNameFuncAddr = slide + offsetsForBundle.gNameFun;
    uintptr_t gNameDataAddr = slide + offsetsForBundle.gNameData;
    typedef long (*gNameFunc)(long);
    gNameFunc func = (gNameFunc)gNameFuncAddr;
    return func(gNameDataAddr);
}

// ==================== BOT KONTROLÜ ====================
bool IsBotPlayer(uintptr_t playerAddr) {
    if (playerAddr == 0) return true;
    uint8_t isRobot = 0;
    memoryTools.readMemory(playerAddr + PubgOffset::ObjectParam::RobotOffset(), 1, &isRobot);
    if (isRobot) return true;
    uint8_t isAI = 0;
    memoryTools.readMemory(playerAddr + 0xA40, 1, &isAI);
    if (isAI) return true;
    uint8_t isMLAI = 0;
    memoryTools.readMemory(playerAddr + 0xA41, 1, &isMLAI);
    if (isMLAI) return true;
    return false;
}

// ==================== UI BAŞLATMA ====================
static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        mao* drawWindow = [[mao alloc] initWithFrame:&moduleControl];
        mi* menuWindow = [[mi alloc] initWithFrame:&moduleControl];
        OverlayView* overlayView = [[OverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds:&moduleControl:drawWindow:menuWindow];
        [[UIApplication sharedApplication].keyWindow addSubview:overlayView];
        FloatView* floatView = [[FloatView alloc] initWithFrame:CGRectMake(489, 58, 45, 45):&moduleControl];
        [[UIApplication sharedApplication].keyWindow addSubview:floatView];
    });
}

// ==================== READ STATIC DATA ====================
void *readStaticData(void *) {
    while (true) {
        sleep(4);
        if(moduleControl.systemStatus != TransmissionNormal){
            staticData.libAddr = (uintptr_t)_dyld_get_image_vmaddr_slide(0);
            if(staticData.libAddr != 0){
                moduleControl.systemStatus = TransmissionNormal;
            }
        }else if (moduleControl.systemStatus == TransmissionNormal) {
            staticData.gwlordAddr = gWorld();
            staticData.gnameAddr = gName();
            
            if(staticData.gwlordAddr == 0 || staticData.gnameAddr == 0) {
                continue;
            }
            
            // Player Controller - DÜZELTİLMİŞ
            uintptr_t uWorld = staticData.gwlordAddr;
            uintptr_t gameInstance = memoryTools.readPtr(uWorld + 0x180);
            uintptr_t localPlayers = memoryTools.readPtr(gameInstance + 0x38);
            uintptr_t localPlayer = memoryTools.readPtr(localPlayers);
            staticData.playerController = memoryTools.readPtr(localPlayer + 0x30);
            
            if(staticData.playerController == 0) continue;
            
            // LineOfSightTo
            uintptr_t controllerFuncs = memoryTools.readPtr(staticData.playerController + 0x0);
            if(controllerFuncs != 0) {
                LineOfSightTo = (bool (*)(void *, void *, ImVec3, bool)) (memoryTools.readPtr(controllerFuncs + 0x770));
                if(LineOfSightTo == nullptr) {
                    LineOfSightTo = (bool (*)(void *, void *, ImVec3, bool)) (memoryTools.readPtr(controllerFuncs + 0x778));
                }
            }
            
            // Self Pointer
            staticData.selfAddr = memoryTools.readPtr(staticData.playerController + PubgOffset::PlayerControllerParam::SelfOffset);
            if(staticData.selfAddr == 0) continue;
            
            // Self Functions
            uintptr_t selfFunction = memoryTools.readPtr(staticData.selfAddr + 0);
            if(selfFunction != 0) {
                AddControllerYawInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::ObjectParam::PlayerFunction::AddControllerYawInputOffset));
                AddControllerRollInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::ObjectParam::PlayerFunction::AddControllerRollInputOffset));
                AddControllerPitchInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::ObjectParam::PlayerFunction::AddControllerPitchInputOffset));
            }
            
            // Camera Manager
            staticData.cameraManager = memoryTools.readPtr(staticData.playerController + PubgOffset::PlayerControllerParam::CameraManagerOffset);
            if(staticData.cameraManager == 0) continue;
            
            // Class Names
            staticData.cameraManagerClassName = getClassName(memoryTools.readInt(staticData.cameraManager + PubgOffset::ObjectParam::ClassIdOffset));
            staticData.playerControllerClassName = getClassName(memoryTools.readInt(staticData.playerController + PubgOffset::ObjectParam::ClassIdOffset));
            
            // Clear Lists
            vector<StaticPlayerData> tmpPlayerDataList;
            vector<StaticMaterialData> tmpMaterialDataList;
            vector<StaticMaterialData> tmpSmokeList;
            
            // ULevel
            uintptr_t uLevel = memoryTools.readPtr(staticData.gwlordAddr + PubgOffset::ULevelOffset);
            if(uLevel == 0) continue;
            
            uintptr_t objectArray = memoryTools.readPtr(uLevel + PubgOffset::ULevelParam::ObjectArrayOffset);
            int objectCount = memoryTools.readInt(uLevel + PubgOffset::ULevelParam::ObjectCountOffset);
            
            if(objectArray == 0 || objectCount <= 0) continue;
            
            int selfTeamID = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::TeamOffset);
            
            for (int index = 0; index < objectCount; ++index) {
                uintptr_t objectAddr = memoryTools.readPtr(objectArray + index * 8);
                if (objectAddr <= 0x100000000 || objectAddr >= 0x2000000000 || objectAddr % 8 != 0) {
                    continue;
                }
                
                uintptr_t coordAddr = memoryTools.readPtr(objectAddr + PubgOffset::ObjectParam::CoordOffset);
                if(coordAddr == 0) continue;
                
                string className = getClassName(memoryTools.readInt(objectAddr + PubgOffset::ObjectParam::ClassIdOffset));
                
                // Player Check
                bool isPlayer = (
                    strstr(className.c_str(), "PlayerPawn") != 0 ||
                    strstr(className.c_str(), "PlayerCharacter") != 0 ||
                    strstr(className.c_str(), "BP_Player") != 0 ||
                    strstr(className.c_str(), "PlayerControllertSl") != 0 ||
                    strstr(className.c_str(), "CharacterModelTaget") != 0
                );
                
                if (isPlayer && moduleControl.mainSwitch.playerStatus) {
                    if (objectAddr == staticData.selfAddr) continue;
                    
                    int team = memoryTools.readInt(objectAddr + PubgOffset::ObjectParam::TeamOffset);
                    if (team == selfTeamID) continue;
                    
                    bool isDead = false;
                    memoryTools.readMemory(objectAddr + PubgOffset::ObjectParam::DeadOffset, 1, &isDead);
                    if (isDead) continue;
                    
                    StaticPlayerData tmpPlayerData;
                    tmpPlayerData.addr = objectAddr;
                    tmpPlayerData.coordAddr = coordAddr;
                    tmpPlayerData.team = team;
                    tmpPlayerData.name = getPlayerName(memoryTools.readPtr(objectAddr + PubgOffset::ObjectParam::NameOffset));
                    tmpPlayerData.robot = IsBotPlayer(objectAddr) ? 1 : 0;
                    
                    if (moduleControl.playerSwitch.ignorebot && tmpPlayerData.robot) continue;
                    
                    tmpPlayerData.status = memoryTools.readInt(objectAddr + PubgOffset::ObjectParam::StatusOffset);
                    tmpPlayerDataList.push_back(tmpPlayerData);
                    
                } else if (strstr(className.c_str(), "ProjSmoke_BP_C)") != 0 || strstr(className.c_str(), "ProjSmoke") != 0) {
                    StaticMaterialData tmpMaterialData;
                    tmpMaterialData.type = Warning;
                    tmpMaterialData.id = 4;
                    tmpMaterialData.name = "[WARNING]SMOKE";
                    tmpMaterialData.addr = objectAddr;
                    tmpMaterialData.coordAddr = coordAddr;
                    tmpSmokeList.push_back(tmpMaterialData);
                    
                } else if (moduleControl.mainSwitch.materialStatus) {
                    MaterialStruct material = isMaterial(className.c_str());
                    if (material.type > -1) {
                        StaticMaterialData tmpMaterialData;
                        tmpMaterialData.type = material.type;
                        tmpMaterialData.id = material.id;
                        tmpMaterialData.name = material.name;
                        tmpMaterialData.addr = objectAddr;
                        tmpMaterialData.coordAddr = coordAddr;
                        
                        if ((material.type == Rifle || material.type == Sniper || material.type == Missile) && 
                            memoryTools.readPtr(objectAddr + PubgOffset::ObjectParam::WeaponParam::MasterOffset) != 0) {
                            continue;
                        }
                        tmpMaterialDataList.push_back(tmpMaterialData);
                    }
                }
            }
            
            staticData.playerDataList.swap(tmpPlayerDataList);
            staticData.materialDataList.swap(tmpMaterialDataList);
            staticData.smokeList.swap(tmpSmokeList);
        }
    }
    return nullptr;
}

// ==================== READ FRAME DATA ====================
void readFrameData(ImVec2 screenSize,vector<PlayerData> &playerDataList, vector<MaterialData> &materialDataList) {
    playerDataList.clear();
    materialDataList.clear();
    
    if (moduleControl.systemStatus == TransmissionNormal) {
        if(staticData.cameraManager == 0 || staticData.playerController == 0) return;
        
        staticData.cameraManagerClassName = getClassName(memoryTools.readInt(staticData.cameraManager + PubgOffset::ObjectParam::ClassIdOffset));
        staticData.playerControllerClassName = getClassName(memoryTools.readInt(staticData.playerController + PubgOffset::ObjectParam::ClassIdOffset));
        
        MinimalViewInfo pov;
        memoryTools.readMemory(staticData.cameraManager + PubgOffset::PlayerControllerParam::CameraManagerParam::PovOffset, sizeof(pov), &pov);
        
        ImVec3 selfCoord = pov.location;
        float lateralAngleView = memoryTools.readFloat(staticData.playerController + PubgOffset::PlayerControllerParam::MouseOffset + 0x4) - 90;
        
        if (moduleControl.mainSwitch.playerStatus) {
            for (auto staticPlayerData: staticData.playerDataList) {
                if (staticPlayerData.addr == staticData.selfAddr) continue;
                
                ImVec3 objectCoord;
                memoryTools.readMemory(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, sizeof(ImVec3), &objectCoord);
                
                float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
                if (objectDistance < 0 || objectDistance > 450) continue;
                
                float objectHeight = memoryTools.readFloat(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::HeightOffset);
                if (objectHeight < 20) continue;
                
                PlayerData playerData;
                playerData.angle = lateralAngleView - rotateAngle(selfCoord, objectCoord) - 180;
                playerData.radar = rotateCoord(lateralAngleView, ImVec2((selfCoord.x - objectCoord.x) / 200, (selfCoord.y - objectCoord.y) / 200));
                playerData.distance = objectDistance;
                playerData.robot = staticPlayerData.robot;
                playerData.visibility = isCoordVisibility(objectCoord);
                
                if (playerData.visibility && isOnSmoke(objectCoord)) {
                    playerData.visibility = false;
                }
                
                if (objectHeight < 50) {
                    objectHeight -= 18;
                } else if (objectHeight > 80) {
                    objectHeight += 12;
                }
                
                playerData.team = staticPlayerData.team;
                playerData.hp = memoryTools.readFloat(staticPlayerData.addr + PubgOffset::ObjectParam::HpOffset);
                if (playerData.hp > 100) playerData.hp = 100;
                
                uintptr_t statusAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::StatusOffset);
                playerData.statusName = getStatusName(statusAddr);
                
                uintptr_t weaponAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::WeaponOneOffset);
                if (weaponAddr == 0) {
                    playerData.weaponName = "FIST";
                } else {
                    string className = getClassName(memoryTools.readInt(weaponAddr + PubgOffset::ObjectParam::ClassIdOffset));
                    MaterialStruct weaponName = isWeapon(className.c_str());
                    if (weaponName.id != 0) {
                        playerData.weaponName = weaponName.name;
                    } else {
                        playerData.weaponName = "[RIFLE]M762";
                    }
                }
                
                playerData.name = staticPlayerData.name;
                playerData.screen = worldToScreen(objectCoord, pov, screenSize);
                
                ImVec2 width = worldToScreen(ImVec3(objectCoord.x, objectCoord.y, objectCoord.z + 100), pov, screenSize);
                ImVec2 height = worldToScreen(ImVec3(objectCoord.x, objectCoord.y, objectCoord.z + objectHeight), pov, screenSize);
                playerData.size.x = (playerData.screen.y - width.y) / 2;
                playerData.size.y = playerData.screen.y - height.y;
                
                uintptr_t meshAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::MeshOffset);
                if(meshAddr != 0) {
                    uintptr_t humanAddr = meshAddr + PubgOffset::ObjectParam::MeshParam::HumanOffset;
                    uintptr_t boneAddr = memoryTools.readPtr(meshAddr + PubgOffset::ObjectParam::MeshParam::BonesOffset) + 48;
                    
                    BonesData bonesData;
                    if (getBone2d(pov, screenSize, humanAddr, boneAddr, 5, bonesData.head))
                        if (getBone2d(pov, screenSize, humanAddr, boneAddr, 4, bonesData.pit))
                            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 1, bonesData.pelvis))
                                if (getBone2d(pov, screenSize, humanAddr, boneAddr, 11, bonesData.lcollar))
                                    if (getBone2d(pov, screenSize, humanAddr, boneAddr, 32, bonesData.rcollar))
                                        if (getBone2d(pov, screenSize, humanAddr, boneAddr, 12, bonesData.lelbow))
                                            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 33, bonesData.relbow))
                                                if (getBone2d(pov, screenSize, humanAddr, boneAddr, 63, bonesData.lwrist))
                                                    if (getBone2d(pov, screenSize, humanAddr, boneAddr, 62, bonesData.rwrist))
                                                        if (getBone2d(pov, screenSize, humanAddr, boneAddr, 52, bonesData.lthigh))
                                                            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 56, bonesData.rthigh))
                                                                if (getBone2d(pov, screenSize, humanAddr, boneAddr, 53, bonesData.lknee))
                                                                    if (getBone2d(pov, screenSize, humanAddr, boneAddr, 57, bonesData.rknee))
                                                                        if (getBone2d(pov, screenSize, humanAddr, boneAddr, 54, bonesData.lankle))
                                                                            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 58, bonesData.rankle))
                                                                                playerData.bonesData = bonesData;
                }
                playerDataList.push_back(playerData);
            }
        }
        
        if (moduleControl.mainSwitch.materialStatus) {
            for (auto staticMaterialData: staticData.materialDataList) {
                string className = getClassName(memoryTools.readInt(staticMaterialData.coordAddr + PubgOffset::ObjectParam::ClassIdOffset));
                if (isRecycled(className.c_str())) continue;
                
                ImVec3 objectCoord;
                memoryTools.readMemory(staticMaterialData.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, sizeof(ImVec3), &objectCoord);
                
                float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
                if (staticMaterialData.type > 1 && staticMaterialData.type < All && objectDistance > 100) continue;
                if (staticMaterialData.type < 0 && staticMaterialData.type > All) continue;
                if (!moduleControl.materialSwitch[staticMaterialData.type]) continue;
                
                MaterialData materialData;
                materialData.type = staticMaterialData.type;
                materialData.id = staticMaterialData.id;
                materialData.name = staticMaterialData.name;
                materialData.distance = objectDistance;
                materialData.screen = worldToScreen(objectCoord, pov, screenSize);
                materialDataList.push_back(materialData);
                
                if (staticMaterialData.type == Airdrop) {
                    ImVec2 goodsListScreen = worldToScreen(objectCoord, pov, screenSize);
                    if (get2dDistance(screenSize, goodsListScreen) < 150) {
                        int goodsListValidCount = 0;
                        uintptr_t goodsListArray = memoryTools.readPtr(staticMaterialData.addr + PubgOffset::ObjectParam::GoodsListOffset);
                        int goodsListCount = memoryTools.readInt(staticMaterialData.addr + PubgOffset::ObjectParam::GoodsListOffset + sizeof(uintptr_t));
                        
                        for (int index = 0; index < goodsListCount; index++) {
                            if (index > 100) break;
                            int goodsListId = memoryTools.readInt(goodsListArray + 0x4 + index * PubgOffset::ObjectParam::GoodsListParam::DataBase);
                            MaterialStruct goods = isBoxMaterial(goodsListId);
                            if (goods.type == -1) continue;
                            
                            memset(&materialData, 0, sizeof(materialData));
                            goodsListValidCount++;
                            materialData.type = goods.type;
                            materialData.id = goods.id;
                            materialData.name = goods.name;
                            materialData.distance = -100;
                            materialData.screen.x = goodsListScreen.x;
                            materialData.screen.y = goodsListScreen.y - 32 * (goodsListValidCount);
                            materialDataList.push_back(materialData);
                        }
                    }
                }
            }
        }
    }
}

// ==================== SILENT AIMBOT ====================
void *silenceAimbot(void *) {
    ImVec2 screenSize = ImVec2([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    while (true) {
        usleep(16666);
        
        if (moduleControl.systemStatus == TransmissionNormal && moduleControl.mainSwitch.aimbotStatus) {
            uintptr_t weaponAddr = memoryTools.readPtr(staticData.selfAddr + PubgOffset::ObjectParam::WeaponOneOffset);
            bool enabledAimbot = false;
            
            switch (moduleControl.aimbotController.aimbotMode) {
                case 0:
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 257 || 
                                   memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 1;
                    break;
                case 1:
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1;
                    break;
                case 2:
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 257 || 
                                   memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 1 || 
                                   memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1;
                    break;
                case 3:
                    if (memoryTools.readInt(weaponAddr + PubgOffset::ObjectParam::WeaponParam::ShootModeOffset) >= 1024) {
                        enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1;
                    } else {
                        enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 257 || 
                                       memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 1;
                    }
                    break;
            }
            
            if (enabledAimbot && staticData.cameraManager != 0 && staticData.playerController != 0) {
                MinimalViewInfo pov;
                memoryTools.readMemory(staticData.cameraManager + PubgOffset::PlayerControllerParam::CameraManagerParam::PovOffset, sizeof(pov), &pov);
                
                ImVec3 selfCoord = pov.location;
                float aimbotRadius = moduleControl.aimbotController.aimbotRadius;
                StaticPlayerData aimbotPlayerData;
                aimbotPlayerData.addr = 0;
                ImVec3 aimbotCoord = ImVec3(0,0,0);
                
                for (auto staticPlayerData: staticData.playerDataList) {
                    if (staticPlayerData.addr == staticData.selfAddr) continue;
                    if (moduleControl.playerSwitch.ignorebot && staticPlayerData.robot == 1) continue;
                    
                    ImVec3 objectCoord;
                    memoryTools.readMemory(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, sizeof(ImVec3), &objectCoord);
                    
                    float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
                    if (objectDistance < 0 || objectDistance > 450 || objectDistance > moduleControl.aimbotController.distance) continue;
                    
                    float objectHeight = memoryTools.readFloat(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::HeightOffset);
                    if (objectHeight < 20) continue;
                    
                    if (memoryTools.readFloat(staticPlayerData.addr + PubgOffset::ObjectParam::HpOffset) < 0.5 && moduleControl.aimbotController.fallNotAim) continue;
                    
                    ImVec2 playerScreen = worldToScreen(objectCoord, pov, screenSize);
                    float screenDistance = get2dDistance(screenSize, playerScreen);
                    
                    if (screenDistance < aimbotRadius) {
                        uintptr_t meshAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::MeshOffset);
                        if(meshAddr != 0) {
                            uintptr_t humanAddr = meshAddr + PubgOffset::ObjectParam::MeshParam::HumanOffset;
                            uintptr_t boneAddr = memoryTools.readPtr(meshAddr + PubgOffset::ObjectParam::MeshParam::BonesOffset) + 48;
                            
                            switch (moduleControl.aimbotController.aimbotParts) {
                                case 0: {
                                    int boneIds[] = {5, 3, 1, 11, 12, 32, 33, 52, 53, 54, 56, 57, 58, 62, 63};
                                    for (int boneId = 0; boneId < end(boneIds) - begin(boneIds); ++boneId) {
                                        aimbotCoord = getBone(humanAddr, boneAddr, boneIds[boneId]);
                                        if (isCoordVisibility(aimbotCoord)) {
                                            aimbotPlayerData = staticPlayerData;
                                            aimbotRadius = screenDistance;
                                            break;
                                        } else {
                                            aimbotCoord = {0, 0, 0};
                                        }
                                    }
                                }
                                    break;
                                case 1: {
                                    int boneIds[] = {11, 3, 5, 1, 11, 32, 12, 33, 63, 62, 52, 56, 53, 57, 54, 58};
                                    for (int boneId = 0; boneId < end(boneIds) - begin(boneIds); ++boneId) {
                                        aimbotCoord = getBone(humanAddr, boneAddr, boneIds[boneId]);
                                        if (isCoordVisibility(aimbotCoord)) {
                                            aimbotPlayerData = staticPlayerData;
                                            aimbotRadius = screenDistance;
                                            break;
                                        } else {
                                            aimbotCoord = {0, 0, 0};
                                        }
                                    }
                                }
                                    break;
                                case 2: {
                                    if (memoryTools.readInt(weaponAddr + PubgOffset::ObjectParam::WeaponParam::ShootModeOffset) >= 1024) {
                                        int boneIds[] = {3, 5, 1, 11, 32, 12, 33, 63, 62, 52, 56, 53, 57, 54, 58};
                                        for (int boneId = 0; boneId < end(boneIds) - begin(boneIds); ++boneId) {
                                            aimbotCoord = getBone(humanAddr, boneAddr, boneIds[boneId]);
                                            if (isCoordVisibility(aimbotCoord)) {
                                                aimbotPlayerData = staticPlayerData;
                                                aimbotRadius = screenDistance;
                                                break;
                                            } else {
                                                aimbotCoord = {0, 0, 0};
                                            }
                                        }
                                    } else {
                                        int boneIds[] = {5, 3, 1, 11, 32, 12, 33, 63, 62, 52, 56, 53, 57, 54, 58};
                                        for (int boneId = 0; boneId < end(boneIds) - begin(boneIds); ++boneId) {
                                            aimbotCoord = getBone(humanAddr, boneAddr, boneIds[boneId]);
                                            if (isCoordVisibility(aimbotCoord)) {
                                                aimbotPlayerData = staticPlayerData;
                                                aimbotRadius = screenDistance;
                                                break;
                                            } else {
                                                aimbotCoord = {0, 0, 0};
                                            }
                                        }
                                    }
                                }
                                    break;
                                case 3: {
                                    aimbotCoord = getBone(humanAddr, boneAddr, 5);
                                    if (isCoordVisibility(aimbotCoord)) {
                                        aimbotPlayerData = staticPlayerData;
                                        aimbotRadius = screenDistance;
                                        break;
                                    } else {
                                        aimbotCoord = {0, 0, 0};
                                    }
                                }
                                    break;
                                case 4: {
                                    aimbotCoord = getBone(humanAddr, boneAddr, 3);
                                    if (isCoordVisibility(aimbotCoord)) {
                                        aimbotPlayerData = staticPlayerData;
                                        aimbotRadius = screenDistance;
                                        break;
                                    } else {
                                        aimbotCoord = {0, 0, 0};
                                    }
                                }
                                    break;
                            }
                        }
                    }
                }
                
                if (aimbotPlayerData.addr != 0 && aimbotCoord.x != 0 && aimbotCoord.y != 0 && aimbotCoord.z != 0) {
                    if (moduleControl.aimbotController.smoke) {
                        if (isOnSmoke(aimbotCoord)) {
                            aimbotCoord = {0, 0, 0};
                            continue;
                        }
                    }
                    
                    uintptr_t weaponAttrAddr = memoryTools.readPtr(weaponAddr + PubgOffset::ObjectParam::WeaponParam::WeaponAttrOffset);
                    if(weaponAttrAddr != 0) {
                        float bulletSpeed = memoryTools.readFloat(weaponAttrAddr + PubgOffset::ObjectParam::WeaponParam::WeaponAttrParam::BulletSpeedOffset);
                        float bulletFlyTime = get3dDistance(selfCoord, aimbotCoord, bulletSpeed) * 1.2;
                        
                        ImVec3 moveCoord;
                        memoryTools.readMemory(aimbotPlayerData.addr + PubgOffset::ObjectParam::MoveCoordOffset, 12, &moveCoord);
                        
                        float bulletSpeed1 = memoryTools.readFloat(weaponAttrAddr + PubgOffset::ObjectParam::WeaponParam::WeaponAttrParam::BulletSpeedOffset);
                        if(bulletSpeed1 != 1800000){
                            aimbotCoord.x += moveCoord.x * bulletFlyTime;
                            aimbotCoord.y += moveCoord.y * bulletFlyTime;
                            aimbotCoord.z += moveCoord.z * bulletFlyTime;
                        }
                    }
                    
                    ImVec2 aimbotMouse = rotateAngleView(selfCoord, aimbotCoord);
                    float selfStatus = memoryTools.readFloat(memoryTools.readPtr(staticData.selfAddr + PubgOffset::ObjectParam::CoordOffset) + PubgOffset::ObjectParam::CoordParam::HeightOffset);
                    string className = getClassName(memoryTools.readInt(weaponAddr + PubgOffset::ObjectParam::ClassIdOffset));
                    
                    if (selfStatus > 47) {
                        if (strstr(className.c_str(), "BP_Sniper_AWM_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.06;
                            aimbotMouse.y -= 0.06;
                        } else if (strstr(className.c_str(), "BP_Sniper_AMR_Wrapper_C") != 0) {
                            aimbotMouse.x -= 0.075;
                            aimbotMouse.y -= 0.035;
                        } else if (strstr(className.c_str(), "BP_Sniper_M24_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.04;
                            aimbotMouse.y -= 0.03;
                        } else if (strstr(className.c_str(), "BP_Sniper_Kar98k_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.05;
                            aimbotMouse.y -= 0.02;
                        } else if (strstr(className.c_str(), "BP_Sniper_Mosin_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.04;
                            aimbotMouse.y -= 0.05;
                        } else if (strstr(className.c_str(), "BP_Sniper_Mk14_Wrapper_C") != 0) {
                            aimbotMouse.x += 1.05;
                            aimbotMouse.y -= 1.05;
                        } else if (strstr(className.c_str(), "BP_Sniper_QBU_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.055;
                            aimbotMouse.y -= 0.085;
                        } else if (strstr(className.c_str(), "BP_Sniper_SKS_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.06;
                            aimbotMouse.y -= 0.085;
                        } else if (strstr(className.c_str(), "BP_Sniper_SLR_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.055;
                            aimbotMouse.y -= 0.03;
                        } else if (strstr(className.c_str(), "BP_Sniper_Mini14_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.015;
                            aimbotMouse.y -= 0.05;
                        } else if (strstr(className.c_str(), "BP_Rifle_QBZ_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.045;
                            aimbotMouse.y -= 0.09;
                        } else if (strstr(className.c_str(), "BP_Rifle_G36_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.02;
                            aimbotMouse.y -= 0.055;
                        } else if (strstr(className.c_str(), "BP_Rifle_Groza_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.03;
                            aimbotMouse.y -= 0.065;
                        } else if (strstr(className.c_str(), "BP_Rifle_AUG_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.015;
                            aimbotMouse.y -= 0.08;
                        } else if (strstr(className.c_str(), "BP_Rifle_M16A4_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.04;
                            aimbotMouse.y -= 0.07;
                        } else if (strstr(className.c_str(), "BP_Rifle_AKM_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.04;
                            aimbotMouse.y -= 0.07;
                        } else if (strstr(className.c_str(), "BP_Rifle_SCAR_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.02;
                            aimbotMouse.y -= 0.085;
                        } else if (strstr(className.c_str(), "BP_Rifle_M416_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.02;
                            aimbotMouse.y -= 0.08;
                        } else if (strstr(className.c_str(), "BP_Rifle_M762_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.03;
                            aimbotMouse.y -= 0.07;
                        } else if (strstr(className.c_str(), "BP_Other_M249_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.025;
                            aimbotMouse.y -= 0.06;
                        } else if (strstr(className.c_str(), "BP_Other_MG3_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.03;
                            aimbotMouse.y -= 0.07;
                        } else if (strstr(className.c_str(), "BP_Other_DP28_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.045;
                            aimbotMouse.y -= 0.095;
                        }
                    }
                    
                    if (memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1 && weaponAttrAddr != 0) {
                        float recoilTimes = 4.5 - get3dDistance(selfCoord, aimbotCoord, 10000);
                        recoilTimes += get3dDistance(selfCoord, aimbotCoord, 10000) * 0.2;
                        float recoil = memoryTools.readFloat(weaponAttrAddr + PubgOffset::ObjectParam::WeaponParam::WeaponAttrParam::RecoilOffset);
                        
                        if (strstr(className.c_str(), "BP_Sniper_VSS_Wrapper_C") != 0) {
                            recoil *= 0.4;
                        } else if (strstr(className.c_str(), "BP_Rifle_G36_Wrapper_C") != 0) {
                            recoil *= 0.6;
                        } else if (strstr(className.c_str(), "BP_Rifle_VAL_Wrapper_C") != 0) {
                            recoil *= 0.45;
                        } else if (strstr(className.c_str(), "BP_Rifle_AUG_Wrapper_C") != 0) {
                            recoil *= 0.7;
                        } else if (strstr(className.c_str(), "BP_Rifle_AKM_Wrapper_C") != 0) {
                            recoil *= 1.15;
                        } else if (strstr(className.c_str(), "BP_Other_MG3_Wrapper_C") != 0) {
                            recoil *= 0.2;
                        } else if (strstr(className.c_str(), "BP_Other_DP28_Wrapper_C") != 0) {
                            recoil *= 0.3;
                        }
                        
                        if (selfStatus < 50.0f) {
                            if (strstr(className.c_str(), "BP_Rifle_M762_Wrapper_C") != 0) {
                                recoil *= 0.55;
                                aimbotMouse.x += 0.2;
                            } else if (strstr(className.c_str(), "BP_Other_M249_Wrapper_C") != 0) {
                                recoil *= 0.6;
                                aimbotMouse.x += 0.08;
                            } else {
                                recoil *= 0.35;
                            }
                        }
                        aimbotMouse.y -= recoilTimes * recoil;
                    }
                    
                    if (!isfinite(aimbotMouse.x) || !isfinite(aimbotMouse.y)) continue;
                    
                    ImVec2 aimbotMouseMove;
                    aimbotMouseMove.x = change(getAngleDifference(aimbotMouse.x, memoryTools.readFloat(staticData.playerController + PubgOffset::PlayerControllerParam::MouseOffset + 0x4)) * moduleControl.aimbotController.aimbotIntensity);
                    aimbotMouseMove.y = change(getAngleDifference(aimbotMouse.y, memoryTools.readFloat(staticData.playerController + PubgOffset::PlayerControllerParam::MouseOffset)) * moduleControl.aimbotController.aimbotIntensity);
                    
                    if (!isfinite(aimbotMouseMove.x) || !isfinite(aimbotMouseMove.y)) continue;
                    
                    if (AddControllerYawInput != NULL) {
                        AddControllerYawInput(reinterpret_cast<void *>(staticData.selfAddr), aimbotMouseMove.x);
                    }
                    if (AddControllerRollInput != NULL) {
                        AddControllerRollInput(reinterpret_cast<void *>(staticData.selfAddr), aimbotMouseMove.y);
                    }
                    if (AddControllerPitchInput != NULL) {
                        AddControllerPitchInput(reinterpret_cast<void *>(staticData.selfAddr), 0);
                    }
                }
            }
        }
    }
    return nullptr;
}

// ==================== YARDIMCI FONKSİYONLAR ====================
bool isCoordVisibility(ImVec3 coord) {
    if (LineOfSightTo == nullptr || !isfinite(coord.x) || !isfinite(coord.y) || !isfinite(coord.z)) {
        return false;
    }
    if (strstr(staticData.cameraManagerClassName.c_str(), "PlayerCameraManager") != 0 && 
        strstr(staticData.playerControllerClassName.c_str(), "PlayerController") != 0) {
        return LineOfSightTo(reinterpret_cast<void *>(staticData.playerController), 
                            reinterpret_cast<void *>(staticData.cameraManager), coord, false);
    }
    return false;
}

bool isOnSmoke(ImVec3 coord) {
    for (StaticMaterialData smoke: staticData.smokeList) {
        ImVec3 smokeCoord;
        memoryTools.readMemory(smoke.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, 30, &smokeCoord);
        if (get3dDistance(smokeCoord, coord, 100) < 4) {
            return true;
        }
    }
    return false;
}

char *getPlayerName(uintptr_t addr) {
    char *buf = (char *) malloc(448);
    memset(buf, 0, 448);
    unsigned short buf16[16] = {0};
    memoryTools.readMemory(addr, 28, buf16);
    unsigned short *tempbuf16 = buf16;
    char *tempbuf8 = buf;
    char *buf8 = tempbuf8 + 32;
    while (tempbuf16 < tempbuf16 + 28) {
        if (*tempbuf16 <= 0x007F && tempbuf8 + 1 < buf8) {
            *tempbuf8++ = (char) *tempbuf16;
        } else if (*tempbuf16 >= 0x0080 && *tempbuf16 <= 0x07FF && tempbuf8 + 2 < buf8) {
            *tempbuf8++ = (*tempbuf16 >> 6) | 0xC0;
            *tempbuf8++ = (*tempbuf16 & 0x3F) | 0x80;
        } else if (*tempbuf16 >= 0x0800 && *tempbuf16 <= 0xFFFF && tempbuf8 + 3 < buf8) {
            *tempbuf8++ = (*tempbuf16 >> 12) | 0xE0;
            *tempbuf8++ = ((*tempbuf16 >> 6) & 0x3F) | 0x80;
            *tempbuf8++ = (*tempbuf16 & 0x3F) | 0x80;
        } else {
            break;
        }
        tempbuf16++;
    }
    return buf;
}

char *getClassName(int classId) {
    char *buf = (char *) malloc(64);
    memset(buf, 0, 64);
    if (classId > 0 && classId < 2000000 && staticData.gnameAddr != 0) {
        int page = classId / 16384;
        int index = classId % 16384;
        uintptr_t pageAddr = memoryTools.readPtr(staticData.gnameAddr + page * sizeof(uintptr_t));
        if(pageAddr != 0) {
            uintptr_t nameAddr = memoryTools.readPtr(pageAddr + index * sizeof(uintptr_t)) + PubgOffset::ObjectParam::ClassNameOffset;
            memoryTools.readMemory(nameAddr, 64, buf);
        }
    }
    return buf;
}

string getStatusName(uintptr_t statusAddr) {
    if (statusAddr == 0) return "IDLE";
    
    uint32_t status = 0;
    memoryTools.readMemory(statusAddr, 4, &status);
    
    switch(status) {
        case 16: return "STAND";
        case 17: return "WALK";
        case 18: return "RUN";
        case 19: return "SPRINT";
        case 32: return "CROUCH";
        case 33: return "CROUCH_WALK";
        case 64: return "PRONE";
        case 144: return "JUMP";
        case 272: return "FIRE";
        case 273: return "RUN_FIRE";
        case 528: return "RELOAD";
        case 529: return "WALK_RELOAD";
        case 1040: return "ADS";
        case 1088: return "PRONE_ADS";
        case 4112: return "LEAN";
        case 4128: return "CROUCH_LEAN";
        case 4384: return "CROUCH_FIRE";
        case 8205: return "SHOOT";
        case 262144: return "DRIVE";
        case 262160: return "STAND_IDLE";
        case 524288: return "KNOCKED";
        case 524289: return "KNOCKED_MOVE";
        case 16777219: return "SWIM";
        case 33554449: return "PARACHUTE";
        default: return "UNKNOWN";
    }
}

ImVec3 getBone(uintptr_t human, uintptr_t bones, int part) {
    ImVec3 result = {0,0,0};
    if(human == 0 || bones == 0) return result;
    
    Ue4Transform actorftf;
    Ue4Transform boneftf;
    
    memoryTools.readMemory(human, sizeof(ImVec4), &actorftf.rotation);
    memoryTools.readMemory(human + 0x10, sizeof(ImVec3), &actorftf.translation);
    memoryTools.readMemory(human + 0x20, sizeof(ImVec3), &actorftf.scale3d);
    
    Ue4Matrix actormatrix = transformToMatrix(actorftf);
    
    memoryTools.readMemory(bones + part * 48, sizeof(ImVec4), &boneftf.rotation);
    memoryTools.readMemory(bones + part * 48 + 0x10, sizeof(ImVec3), &boneftf.translation);
    memoryTools.readMemory(bones + part * 48 + 0x20, sizeof(ImVec3), &boneftf.scale3d);
    
    Ue4Matrix bonematrix = transformToMatrix(boneftf);
    
    return matrixToVector(matrixMulti(bonematrix, actormatrix));
}

bool getBone2d(MinimalViewInfo pov, ImVec2 screen, uintptr_t human, uintptr_t bones, int part, ImVec2 &buf) {
    ImVec3 newmatrix = getBone(human, bones, part);
    buf = worldToScreen(newmatrix, pov, screen);
    return buf.x != 0 && buf.y != 0;
}

float get3dDistance(ImVec3 a, ImVec3 b, float scale) {
    float dx = a.x - b.x;
    float dy = a.y - b.y;
    float dz = a.z - b.z;
    return sqrtf(dx*dx + dy*dy + dz*dz) / scale;
}

float get2dDistance(ImVec2 screen, ImVec2 point) {
    float dx = screen.x / 2 - point.x;
    float dy = screen.y / 2 - point.y;
    return sqrtf(dx*dx + dy*dy);
}

float rotateAngle(ImVec3 selfCoord, ImVec3 objectCoord) {
    float dx = selfCoord.x - objectCoord.x;
    float dy = selfCoord.y - objectCoord.y;
    float angle = atan2f(dy, dx);
    return angle * 180 / M_PI;
}

ImVec2 rotateCoord(float angle, ImVec2 coord) {
    float rad = angle * M_PI / 180;
    float cosTheta = cos(rad);
    float sinTheta = sin(rad);
    return ImVec2(
        coord.x * cosTheta - coord.y * sinTheta,
        coord.x * sinTheta + coord.y * cosTheta
    );
}

ImVec2 rotateAngleView(ImVec3 selfCoord, ImVec3 aimbotCoord) {
    float dx = aimbotCoord.x - selfCoord.x;
    float dy = aimbotCoord.y - selfCoord.y;
    float dz = aimbotCoord.z - selfCoord.z;
    
    float yaw = atan2f(dy, dx) * 180 / M_PI;
    float pitch = -atan2f(dz, sqrtf(dx*dx + dy*dy)) * 180 / M_PI;
    
    return ImVec2(yaw, pitch);
}

float getAngleDifference(float target, float current) {
    float diff = target - current;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return diff;
}

float change(float angle) {
    return angle;
}

ImVec2 worldToScreen(ImVec3 worldLocation, MinimalViewInfo pov, ImVec2 screenSize) {
    ImVec2 screenLocation = ImVec2(0, 0);
    
    ImVec3 delta = ImVec3(
        worldLocation.x - pov.location.x,
        worldLocation.y - pov.location.y,
        worldLocation.z - pov.location.z
    );
    
    ImVec3 transformed;
    transformed.x = delta.x * pov.rotation.yaw + delta.y * pov.rotation.pitch + delta.z * pov.rotation.roll;
    transformed.y = delta.x * pov.rotation.yaw2 + delta.y * pov.rotation.pitch2 + delta.z * pov.rotation.roll2;
    transformed.z = delta.x * pov.rotation.yaw3 + delta.y * pov.rotation.pitch3 + delta.z * pov.rotation.roll3;
    
    if (transformed.z < 1) {
        transformed.z = 1;
    }
    
    screenLocation.x = screenSize.x / 2 + transformed.x * (screenSize.x / 2 / tanf(pov.fov * M_PI / 360)) / transformed.z;
    screenLocation.y = screenSize.y / 2 - transformed.y * (screenSize.x / 2 / tanf(pov.fov * M_PI / 360)) / transformed.z;
    
    return screenLocation;
}

Ue4Matrix transformToMatrix(Ue4Transform& transform) {
    Ue4Matrix matrix;
    
    float x2 = transform.rotation.x * transform.rotation.x;
    float y2 = transform.rotation.y * transform.rotation.y;
    float z2 = transform.rotation.z * transform.rotation.z;
    float w2 = transform.rotation.w * transform.rotation.w;
    
    matrix.m[0][0] = 1 - 2 * y2 - 2 * z2;
    matrix.m[0][1] = 2 * transform.rotation.x * transform.rotation.y - 2 * transform.rotation.w * transform.rotation.z;
    matrix.m[0][2] = 2 * transform.rotation.x * transform.rotation.z + 2 * transform.rotation.w * transform.rotation.y;
    matrix.m[0][3] = transform.translation.x;
    
    matrix.m[1][0] = 2 * transform.rotation.x * transform.rotation.y + 2 * transform.rotation.w * transform.rotation.z;
    matrix.m[1][1] = 1 - 2 * x2 - 2 * z2;
    matrix.m[1][2] = 2 * transform.rotation.y * transform.rotation.z - 2 * transform.rotation.w * transform.rotation.x;
    matrix.m[1][3] = transform.translation.y;
    
    matrix.m[2][0] = 2 * transform.rotation.x * transform.rotation.z - 2 * transform.rotation.w * transform.rotation.y;
    matrix.m[2][1] = 2 * transform.rotation.y * transform.rotation.z + 2 * transform.rotation.w * transform.rotation.x;
    matrix.m[2][2] = 1 - 2 * x2 - 2 * y2;
    matrix.m[2][3] = transform.translation.z;
    
    matrix.m[3][0] = 0;
    matrix.m[3][1] = 0;
    matrix.m[3][2] = 0;
    matrix.m[3][3] = 1;
    
    return matrix;
}

Ue4Matrix matrixMulti(Ue4Matrix& m1, Ue4Matrix& m2) {
    Ue4Matrix result;
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            result.m[i][j] = 0;
            for (int k = 0; k < 4; k++) {
                result.m[i][j] += m1.m[i][k] * m2.m[k][j];
            }
        }
    }
    return result;
}

ImVec3 matrixToVector(Ue4Matrix& matrix) {
    return ImVec3(matrix.m[0][3], matrix.m[1][3], matrix.m[2][3]);
}

MaterialStruct isMaterial(const char* className) {
    MaterialStruct result = {-1, 0, ""};
    
    // Rifle
    if (strstr(className, "BP_Rifle") != 0) {
        result.type = Rifle;
        result.id = 1;
        result.name = "[RIFLE]";
        if (strstr(className, "M416") != 0) result.name = "[RIFLE]M416";
        else if (strstr(className, "SCAR") != 0) result.name = "[RIFLE]SCAR-L";
        else if (strstr(className, "AKM") != 0) result.name = "[RIFLE]AKM";
        else if (strstr(className, "M762") != 0) result.name = "[RIFLE]M762";
        else if (strstr(className, "QBZ") != 0) result.name = "[RIFLE]QBZ";
        else if (strstr(className, "G36") != 0) result.name = "[RIFLE]G36C";
        else if (strstr(className, "AUG") != 0) result.name = "[RIFLE]AUG";
        else if (strstr(className, "Groza") != 0) result.name = "[RIFLE]Groza";
        else if (strstr(className, "M16") != 0) result.name = "[RIFLE]M16A4";
    }
    // Sniper
    else if (strstr(className, "BP_Sniper") != 0) {
        result.type = Sniper;
        result.id = 2;
        result.name = "[SNIPER]";
        if (strstr(className, "AWM") != 0) result.name = "[SNIPER]AWM";
        else if (strstr(className, "M24") != 0) result.name = "[SNIPER]M24";
        else if (strstr(className, "Kar98k") != 0) result.name = "[SNIPER]Kar98k";
        else if (strstr(className, "Mosin") != 0) result.name = "[SNIPER]Mosin";
        else if (strstr(className, "Mk14") != 0) result.name = "[SNIPER]Mk14";
        else if (strstr(className, "SKS") != 0) result.name = "[SNIPER]SKS";
        else if (strstr(className, "SLR") != 0) result.name = "[SNIPER]SLR";
        else if (strstr(className, "Mini14") != 0) result.name = "[SNIPER]Mini14";
        else if (strstr(className, "QBU") != 0) result.name = "[SNIPER]QBU";
        else if (strstr(className, "VSS") != 0) result.name = "[SNIPER]VSS";
    }
    // Shotgun
    else if (strstr(className, "BP_Shotgun") != 0) {
        result.type = Shotgun;
        result.id = 3;
        result.name = "[SHOTGUN]";
        if (strstr(className, "S686") != 0) result.name = "[SHOTGUN]S686";
        else if (strstr(className, "S1897") != 0) result.name = "[SHOTGUN]S1897";
        else if (strstr(className, "DBS") != 0) result.name = "[SHOTGUN]DBS";
    }
    // Pistol
    else if (strstr(className, "BP_Pistol") != 0) {
        result.type = Pistol;
        result.id = 4;
        result.name = "[PISTOL]";
        if (strstr(className, "P1911") != 0) result.name = "[PISTOL]P1911";
        else if (strstr(className, "P92") != 0) result.name = "[PISTOL]P92";
        else if (strstr(className, "R1895") != 0) result.name = "[PISTOL]R1895";
        else if (strstr(className, "P18C") != 0) result.name = "[PISTOL]P18C";
        else if (strstr(className, "Skorpion") != 0) result.name = "[PISTOL]Skorpion";
        else if (strstr(className, "Deagle") != 0) result.name = "[PISTOL]Deagle";
    }
    // SMG
    else if (strstr(className, "BP_SMG") != 0) {
        result.type = SMG;
        result.id = 5;
        result.name = "[SMG]";
        if (strstr(className, "UZI") != 0) result.name = "[SMG]UZI";
        else if (strstr(className, "UMP") != 0) result.name = "[SMG]UMP45";
        else if (strstr(className, "Vector") != 0) result.name = "[SMG]Vector";
        else if (strstr(className, "Tommy") != 0) result.name = "[SMG]Tommy Gun";
        else if (strstr(className, "MP5K") != 0) result.name = "[SMG]MP5K";
        else if (strstr(className, "PP19") != 0) result.name = "[SMG]PP-19 Bizon";
    }
    // LMG
    else if (strstr(className, "BP_Other_M249") != 0 || strstr(className, "BP_Other_DP28") != 0 || strstr(className, "BP_Other_MG3") != 0) {
        result.type = LMG;
        result.id = 6;
        result.name = "[LMG]";
        if (strstr(className, "M249") != 0) result.name = "[LMG]M249";
        else if (strstr(className, "DP28") != 0) result.name = "[LMG]DP-28";
        else if (strstr(className, "MG3") != 0) result.name = "[LMG]MG3";
    }
    // Melee
    else if (strstr(className, "BP_Melee") != 0) {
        result.type = Melee;
        result.id = 7;
        result.name = "[MELEE]";
    }
    // Throwable
    else if (strstr(className, "BP_Throwable") != 0) {
        result.type = Throwable;
        result.id = 8;
        result.name = "[THROWABLE]";
        if (strstr(className, "Frag") != 0) result.name = "[THROWABLE]Frag Grenade";
        else if (strstr(className, "Smoke") != 0) result.name = "[THROWABLE]Smoke Grenade";
        else if (strstr(className, "Flash") != 0) result.name = "[THROWABLE]Flashbang";
        else if (strstr(className, "Molotov") != 0) result.name = "[THROWABLE]Molotov";
    }
    // Armor
    else if (strstr(className, "BP_Armor") != 0) {
        result.type = Armor;
        result.id = 9;
        result.name = "[ARMOR]";
        if (strstr(className, "Helmet") != 0) {
            if (strstr(className, "Lv1") != 0) result.name = "[ARMOR]Lv1 Helmet";
            else if (strstr(className, "Lv2") != 0) result.name = "[ARMOR]Lv2 Helmet";
            else if (strstr(className, "Lv3") != 0) result.name = "[ARMOR]Lv3 Helmet";
        } else if (strstr(className, "Vest") != 0) {
            if (strstr(className, "Lv1") != 0) result.name = "[ARMOR]Lv1 Vest";
            else if (strstr(className, "Lv2") != 0) result.name = "[ARMOR]Lv2 Vest";
            else if (strstr(className, "Lv3") != 0) result.name = "[ARMOR]Lv3 Vest";
        }
    }
    // Backpack
    else if (strstr(className, "BP_Backpack") != 0) {
        result.type = Backpack;
        result.id = 10;
        result.name = "[BACKPACK]";
        if (strstr(className, "Lv1") != 0) result.name = "[BACKPACK]Lv1";
        else if (strstr(className, "Lv2") != 0) result.name = "[BACKPACK]Lv2";
        else if (strstr(className, "Lv3") != 0) result.name = "[BACKPACK]Lv3";
    }
    // Heal
    else if (strstr(className, "BP_Heal") != 0) {
        result.type = Heal;
        result.id = 11;
        result.name = "[HEAL]";
        if (strstr(className, "Bandage") != 0) result.name = "[HEAL]Bandage";
        else if (strstr(className, "FirstAid") != 0) result.name = "[HEAL]First Aid Kit";
        else if (strstr(className, "MedKit") != 0) result.name = "[HEAL]Med Kit";
        else if (strstr(className, "EnergyDrink") != 0) result.name = "[HEAL]Energy Drink";
        else if (strstr(className, "PainKiller") != 0) result.name = "[HEAL]Pain Killer";
        else if (strstr(className, "Adrenaline") != 0) result.name = "[HEAL]Adrenaline Syringe";
    }
    // Ammo
    else if (strstr(className, "BP_Ammo") != 0) {
        result.type = Ammo;
        result.id = 12;
        result.name = "[AMMO]";
        if (strstr(className, "556mm") != 0) result.name = "[AMMO]5.56mm";
        else if (strstr(className, "762mm") != 0) result.name = "[AMMO]7.62mm";
        else if (strstr(className, "300Magnum") != 0) result.name = "[AMMO].300 Magnum";
        else if (strstr(className, "45ACP") != 0) result.name = "[AMMO].45 ACP";
        else if (strstr(className, "9mm") != 0) result.name = "[AMMO]9mm";
        else if (strstr(className, "12Gauge") != 0) result.name = "[AMMO]12 Gauge";
    }
    // Scope
    else if (strstr(className, "BP_Scope") != 0) {
        result.type = Scope;
        result.id = 13;
        result.name = "[SCOPE]";
        if (strstr(className, "RedDot") != 0) result.name = "[SCOPE]Red Dot";
        else if (strstr(className, "Holo") != 0) result.name = "[SCOPE]Holographic";
        else if (strstr(className, "2x") != 0) result.name = "[SCOPE]2x Scope";
        else if (strstr(className, "3x") != 0) result.name = "[SCOPE]3x Scope";
        else if (strstr(className, "4x") != 0) result.name = "[SCOPE]4x Scope";
        else if (strstr(className, "6x") != 0) result.name = "[SCOPE]6x Scope";
        else if (strstr(className, "8x") != 0) result.name = "[SCOPE]8x Scope";
    }
    // Airdrop
    else if (strstr(className, "AirDrop") != 0 || strstr(className, "CarePackage") != 0) {
        result.type = Airdrop;
        result.id = 14;
        result.name = "[AIRDROP]";
    }
    // Vehicle
    else if (strstr(className, "BP_Vehicle") != 0 || strstr(className, "BP_Car") != 0) {
        result.type = Vehicle;
        result.id = 15;
        result.name = "[VEHICLE]";
    }
    
    return result;
}

MaterialStruct isWeapon(const char* className) {
    return isMaterial(className);
}

MaterialStruct isBoxMaterial(int id) {
    MaterialStruct result = {-1, 0, ""};
    
    switch(id) {
        case 1001: result = {Ammo, 12, "[AMMO]5.56mm"}; break;
        case 1002: result = {Ammo, 12, "[AMMO]7.62mm"}; break;
        case 1003: result = {Ammo, 12, "[AMMO].45 ACP"}; break;
        case 1004: result = {Ammo, 12, "[AMMO]9mm"}; break;
        case 1005: result = {Ammo, 12, "[AMMO]12 Gauge"}; break;
        case 1006: result = {Ammo, 12, "[AMMO].300 Magnum"}; break;
        case 2001: result = {Heal, 11, "[HEAL]Bandage"}; break;
        case 2002: result = {Heal, 11, "[HEAL]First Aid Kit"}; break;
        case 2003: result = {Heal, 11, "[HEAL]Med Kit"}; break;
        case 2004: result = {Heal, 11, "[HEAL]Energy Drink"}; break;
        case 2005: result = {Heal, 11, "[HEAL]Pain Killer"}; break;
        case 2006: result = {Heal, 11, "[HEAL]Adrenaline Syringe"}; break;
        case 3001: result = {Armor, 9, "[ARMOR]Lv1 Helmet"}; break;
        case 3002: result = {Armor, 9, "[ARMOR]Lv2 Helmet"}; break;
        case 3003: result = {Armor, 9, "[ARMOR]Lv3 Helmet"}; break;
        case 3004: result = {Armor, 9, "[ARMOR]Lv1 Vest"}; break;
        case 3005: result = {Armor, 9, "[ARMOR]Lv2 Vest"}; break;
        case 3006: result = {Armor, 9, "[ARMOR]Lv3 Vest"}; break;
        case 4001: result = {Backpack, 10, "[BACKPACK]Lv1"}; break;
        case 4002: result = {Backpack, 10, "[BACKPACK]Lv2"}; break;
        case 4003: result = {Backpack, 10, "[BACKPACK]Lv3"}; break;
        case 5001: result = {Scope, 13, "[SCOPE]Red Dot"}; break;
        case 5002: result = {Scope, 13, "[SCOPE]Holographic"}; break;
        case 5003: result = {Scope, 13, "[SCOPE]2x Scope"}; break;
        case 5004: result = {Scope, 13, "[SCOPE]3x Scope"}; break;
        case 5005: result = {Scope, 13, "[SCOPE]4x Scope"}; break;
        case 5006: result = {Scope, 13, "[SCOPE]6x Scope"}; break;
        case 5007: result = {Scope, 13, "[SCOPE]8x Scope"}; break;
        default: break;
    }
    
    return result;
}

bool isRecycled(const char* className) {
    return strstr(className, "Recycled") != 0;
}

// ==================== KÜTÜPHANE GİRİŞ ====================
__attribute__((constructor)) static void initialize() {
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching, 
                                    (CFStringRef)UIApplicationDidFinishLaunchingNotification, 
                                    NULL, CFNotificationSuspensionBehaviorDrop);
    
    pthread_t staticDataThread;
    pthread_create(&staticDataThread, nullptr, readStaticData, nullptr);
    
    pthread_t silenceAimbotThread;
    pthread_create(&silenceAimbotThread, nullptr, silenceAimbot, nullptr);
}