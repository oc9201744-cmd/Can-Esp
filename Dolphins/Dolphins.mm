//
//  Dolphins.mm - COMPLETE READY-TO-USE VERSION
//  All fixes applied, compile-ready
//
//  Created by XBK on 2022/4/24.
//  FIXED: PlayerState, thread safety, compile errors
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
#include "Dolphins/utils/module_tools.h"
#include "Dolphins/utils/pubg_offset.h"
#include "Dolphins/utils/memory_tools.h"
#include "Dolphins/utils/log.h"

// Thread safety
#import <pthread.h>
static pthread_mutex_t staticDataMutex = PTHREAD_MUTEX_INITIALIZER;

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

long gWorld() {
    OffsetValues offsetsForBundle = [OffsetsManager getOffsetsForBundleID:[[NSBundle mainBundle] bundleIdentifier]];
    return reinterpret_cast<long(__fastcall*)(long)>((long)_dyld_get_image_vmaddr_slide(0) + offsetsForBundle.gWorldFun)((long)_dyld_get_image_vmaddr_slide(0) + offsetsForBundle.gWorldData);
}

long gName() {
    OffsetValues offsetsForBundle = [OffsetsManager getOffsetsForBundleID:[[NSBundle mainBundle] bundleIdentifier]];
    return reinterpret_cast<long(__fastcall*)(long)>((long)_dyld_get_image_vmaddr_slide(0) + offsetsForBundle.gNameFun)((long)_dyld_get_image_vmaddr_slide(0) + offsetsForBundle.gNameData);
}

struct {
    uintptr_t libAddr = 0;
    uintptr_t gWorldAddr;
    uintptr_t gnameAddr;
    uintptr_t playerController;
    string playerControllerClassName;
    uintptr_t cameraManager;
    string cameraManagerClassName;
    uintptr_t selfAddr;
    uintptr_t selfPlayerState;
    uint64_t selfUID;
    int selfTeamID;
    vector<StaticPlayerData> playerDataList;
    vector<StaticMaterialData> materialDataList;
    vector<StaticMaterialData> smokeList;
} staticData;

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

__attribute__((constructor)) static void initialize() {
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorDrop);
    pthread_t staticDataThread;
    pthread_create(&staticDataThread, nullptr, readStaticData, nullptr);
    pthread_t silenceAimbotThread;
    pthread_create(&silenceAimbotThread, nullptr, silenceAimbot, nullptr);
}

void *readStaticData(void *) {
    while (true) {
        sleep(4);
        if(moduleControl.systemStatus != TransmissionNormal){
            staticData.libAddr = (uintptr_t)_dyld_get_image_vmaddr_slide(0);
            if(staticData.libAddr != 1){
                moduleControl.systemStatus = TransmissionNormal;
            }
        }else if (moduleControl.systemStatus == TransmissionNormal) {
            pthread_mutex_lock(&staticDataMutex);
            
            staticData.gWorldAddr = gWorld();
            staticData.gnameAddr = gName();
            staticData.playerController = memoryTools.readPtr(memoryTools.readPtr(memoryTools.readPtr(staticData.gWorldAddr + PubgOffset::PlayerControllerOffset[0]) + PubgOffset::PlayerControllerOffset[1]) + PubgOffset::PlayerControllerOffset[2]);
            LineOfSightTo = (bool (*)(void *, void *, ImVec3, bool)) (memoryTools.readPtr(memoryTools.readPtr(staticData.playerController + 0x0) + PubgOffset::PlayerControllerParam::ControllerFunction::LineOfSightToOffset));
            staticData.selfAddr = memoryTools.readPtr(staticData.playerController + PubgOffset::PlayerControllerParam::SelfOffset);
            
            staticData.selfPlayerState = memoryTools.readPtr(staticData.selfAddr + PubgOffset::ObjectParam::PlayerStateOffset);
            if (staticData.selfPlayerState != 0 && staticData.selfPlayerState > 0x100000000) {
                uint64_t selfUID = 0;
                memoryTools.readMemory(staticData.selfPlayerState + PubgOffset::ObjectParam::PlayerState::UIDOffset, sizeof(uint64_t), &selfUID);
                staticData.selfUID = selfUID;
                staticData.selfTeamID = memoryTools.readInt(staticData.selfPlayerState + PubgOffset::ObjectParam::PlayerState::TeamIDOffset);
            } else {
                staticData.selfUID = 0;
                staticData.selfTeamID = 0;
            }
            
            uintptr_t selfFunction = memoryTools.readPtr(staticData.selfAddr + 0);
            AddControllerYawInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::ObjectParam::PlayerFunction::AddControllerYawInputOffset));
            AddControllerRollInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::ObjectParam::PlayerFunction::AddControllerRollInputOffset));
            AddControllerPitchInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::ObjectParam::PlayerFunction::AddControllerPitchInputOffset));
            staticData.cameraManager = memoryTools.readPtr(staticData.playerController + PubgOffset::PlayerControllerParam::CameraManagerOffset);
            
            vector<StaticPlayerData> tmpPlayerDataList;
            vector<StaticMaterialData> tmpMaterialDataList;
            vector<StaticMaterialData> tmpSmokeList;
            
            uintptr_t uLevel = memoryTools.readPtr(staticData.gWorldAddr + PubgOffset::ULevelOffset);
            uintptr_t objectArray = memoryTools.readPtr(uLevel + PubgOffset::ULevelParam::ObjectArrayOffset);
            int objectCount = memoryTools.readInt(uLevel + PubgOffset::ULevelParam::ObjectCountOffset);
            
            for (int index = 0; index < objectCount; ++index) {
                uintptr_t objectAddr = memoryTools.readPtr(objectArray + index * 8);
                if (objectAddr <= 0x100000000 || objectAddr >= 0x2000000000 || objectAddr % 8 != 0) {
                    continue;
                }
                
                uintptr_t coordAddr = memoryTools.readPtr(objectAddr + PubgOffset::ObjectParam::CoordOffset);
                string className = getClassName(memoryTools.readInt(objectAddr + PubgOffset::ObjectParam::ClassIdOffset));
                
                bool isPlayer = (
                    strstr(className.c_str(), "PlayerPawn")       != 0 ||
                    strstr(className.c_str(), "PlayerCharacter")  != 0 ||
                    strstr(className.c_str(), "PlayerController") != 0 ||
                    strstr(className.c_str(), "CharacterModel")   != 0
                );
                
                if (isPlayer && moduleControl.mainSwitch.playerStatus) {
                    uintptr_t playerState = memoryTools.readPtr(objectAddr + PubgOffset::ObjectParam::PlayerStateOffset);
                    if (playerState == 0 || playerState <= 0x100000000) {
                        continue;
                    }
                    
                    uint64_t entityUID = 0;
                    memoryTools.readMemory(playerState + PubgOffset::ObjectParam::PlayerState::UIDOffset, sizeof(uint64_t), &entityUID);
                    if (staticData.selfUID != 0 && entityUID == staticData.selfUID) {
                        continue;
                    }
                    
                    int entityTeam = memoryTools.readInt(playerState + PubgOffset::ObjectParam::PlayerState::TeamIDOffset);
                    if (entityTeam != 0 && staticData.selfTeamID != 0 && entityTeam == staticData.selfTeamID) {
                        continue;
                    }
                    
                    float health = memoryTools.readFloat(playerState + PubgOffset::ObjectParam::PlayerState::PlayerHealthOffset);
                    float maxHealth = memoryTools.readFloat(playerState + PubgOffset::ObjectParam::PlayerState::PlayerHealthMaxOffset);
                    if (health <= 0 || maxHealth <= 0) {
                        continue;
                    }
                    
                    uint8_t liveState = 0;
                    memoryTools.readMemory(playerState + PubgOffset::ObjectParam::PlayerState::LiveStateOffset, 1, &liveState);
                    if (liveState != 0) {
                        continue;
                    }
                    
                    bool isAI = false;
                    memoryTools.readMemory(objectAddr + PubgOffset::ObjectParam::bIsAIOffset, 1, &isAI);
                    bool isMLAI = false;
                    memoryTools.readMemory(objectAddr + PubgOffset::ObjectParam::bIsMLAIOffset, 1, &isMLAI);
                    
                    StaticPlayerData tmpPlayerData;
                    tmpPlayerData.addr = objectAddr;
                    tmpPlayerData.coordAddr = coordAddr;
                    tmpPlayerData.playerState = playerState;
                    tmpPlayerData.team = entityTeam;
                    tmpPlayerData.health = health;
                    tmpPlayerData.maxHealth = maxHealth;
                    tmpPlayerData.robot = (isAI || isMLAI) ? 1 : 0;
                    tmpPlayerData.name = getPlayerName(memoryTools.readPtr(objectAddr + PubgOffset::ObjectParam::NameOffset));
                    tmpPlayerData.status = memoryTools.readInt(objectAddr + PubgOffset::ObjectParam::StatusOffset);
                    tmpPlayerDataList.push_back(tmpPlayerData);
                    
                } else if (strstr(className.c_str(), "ProjSmoke_BP_C") != 0) {
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
                        if ((material.type == Rifle || material.type == Sniper || material.type == Missile) && memoryTools.readPtr(objectAddr + PubgOffset::ObjectParam::WeaponParam::MasterOffset) != 0) {
                            continue;
                        }
                        tmpMaterialDataList.push_back(tmpMaterialData);
                    }
                }
            }
            
            staticData.playerDataList.swap(tmpPlayerDataList);
            staticData.materialDataList.swap(tmpMaterialDataList);
            staticData.smokeList.swap(tmpSmokeList);
            pthread_mutex_unlock(&staticDataMutex);
        }
    }
    return nullptr;
}

void readFrameData(ImVec2 screenSize,vector<PlayerData> &playerDataList, vector<MaterialData> &materialDataList) {
    playerDataList.clear();
    materialDataList.clear();
    if (moduleControl.systemStatus == TransmissionNormal) {
        pthread_mutex_lock(&staticDataMutex);
        vector<StaticPlayerData> localPlayerList = staticData.playerDataList;
        vector<StaticMaterialData> localMaterialList = staticData.materialDataList;
        uintptr_t localCameraManager = staticData.cameraManager;
        uintptr_t localPlayerController = staticData.playerController;
        pthread_mutex_unlock(&staticDataMutex);
        
        staticData.cameraManagerClassName = getClassName(memoryTools.readInt(localCameraManager + PubgOffset::ObjectParam::ClassIdOffset));
        staticData.playerControllerClassName = getClassName(memoryTools.readInt(localPlayerController + PubgOffset::ObjectParam::ClassIdOffset));
        MinimalViewInfo pov;
        memoryTools.readMemory(localCameraManager + PubgOffset::PlayerControllerParam::CameraManagerParam::PovOffset, sizeof(pov), &pov);
        ImVec3 selfCoord = pov.location;
        float lateralAngleView = memoryTools.readFloat(localPlayerController + PubgOffset::PlayerControllerParam::MouseOffset + 0x4) - 90;
        
        if (moduleControl.mainSwitch.playerStatus) {
            for (auto staticPlayerData: localPlayerList) {
                ImVec3 objectCoord;
                memoryTools.readMemory(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, sizeof(ImVec3), &objectCoord);
                float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
                if (objectDistance < 0 || objectDistance > 450) {
                    continue;
                }
                float objectHeight = memoryTools.readFloat(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::HeightOffset);
                if (objectHeight < 20) {
                    continue;
                }
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
                playerData.hp = staticPlayerData.health;
                if (playerData.hp > 100) playerData.hp = 100;
                if (playerData.hp < 0) playerData.hp = 0;
                
                uintptr_t statusAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::StatusOffset);
                playerData.statusName = "UNKNOWN";
                if (statusAddr == 2097168) playerData.statusName = "DRIVE";
                else if (statusAddr == 262208) playerData.statusName = "HEALING";
                else if (statusAddr == 33554449) playerData.statusName = "PARACHUTE";
                else if (statusAddr == 262160 || statusAddr == 16 || statusAddr == 18) playerData.statusName = "STAND";
                else if (statusAddr == 524288 || statusAddr == 524289) playerData.statusName = "KNOCKED";
                else if (statusAddr == 147 || statusAddr == 144) playerData.statusName = "JUMP";
                else if (statusAddr == 529) playerData.statusName = "WALK";
                else if (statusAddr == 35 || statusAddr == 32) playerData.statusName = "CROUCH";
                else if (statusAddr == 8205 || statusAddr == 272 || statusAddr == 273 || statusAddr == 1073741840 || statusAddr == 320 || statusAddr == 288 || statusAddr == 4384) playerData.statusName = "SHOOTING";
                else if (statusAddr == 33) playerData.statusName = "CROUCH WALK";
                else if (statusAddr == 1040 || statusAddr == 1056 || statusAddr == 1088) playerData.statusName = "SCOPE";
                else if (statusAddr == 19) playerData.statusName = "RUN";
                else if (statusAddr == 17) playerData.statusName = "WALK";
                else if (statusAddr == 64) playerData.statusName = "PRONE";
                else if (statusAddr == 4128 || statusAddr == 4112) playerData.statusName = "LEAN";
                else if (statusAddr == 528 || statusAddr == 576 || statusAddr == 544) playerData.statusName = "RELOAD";
                else if (statusAddr == 16777219) playerData.statusName = "SWIM";
                else if (statusAddr == 67108880) playerData.statusName = "CLIMB";
                else if (statusAddr == 4194320) playerData.statusName = "VEHICLE";
                else if (statusAddr == 6552 || statusAddr == 65568 || statusAddr == 65600) playerData.statusName = "GRENADE";
                
                uintptr_t weaponAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::WeaponOneOffset);
                if (weaponAddr == 0) {
                    playerData.weaponName = "FIST";
                } else {
                    string weaponClassName = getClassName(memoryTools.readInt(weaponAddr + PubgOffset::ObjectParam::ClassIdOffset));
                    MaterialStruct weaponName = isWeapon(weaponClassName.c_str());
                    if (weaponName.id != 0) {
                        playerData.weaponName = weaponName.name;
                    } else {
                        playerData.weaponName = "UNKNOWN";
                    }
                }
                playerData.name = staticPlayerData.name;
                playerData.screen = worldToScreen(objectCoord, pov, screenSize);
                ImVec2 width = worldToScreen(ImVec3(objectCoord.x,objectCoord.y,objectCoord.z + 100), pov,screenSize);
                ImVec2 height = worldToScreen(ImVec3(objectCoord.x,objectCoord.y,objectCoord.z + objectHeight), pov,screenSize);
                playerData.size.x = (playerData.screen.y - width.y) / 2;
                playerData.size.y = playerData.screen.y - height.y;
                
                uintptr_t meshAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::MeshOffset);
                uintptr_t humanAddr = meshAddr + PubgOffset::ObjectParam::MeshParam::HumanOffset;
                uintptr_t boneAddr = memoryTools.readPtr(meshAddr + PubgOffset::ObjectParam::MeshParam::BonesOffset) + 48;
                BonesData bonesData;
                if (getBone2d(pov, screenSize,humanAddr, boneAddr, 5, bonesData.head))
                    if (getBone2d(pov,screenSize, humanAddr, boneAddr, 4, bonesData.pit))
                        if (getBone2d(pov,screenSize, humanAddr, boneAddr, 1, bonesData.pelvis))
                            if (getBone2d(pov, screenSize,humanAddr, boneAddr, 11, bonesData.lcollar))
                                if (getBone2d(pov, screenSize,humanAddr, boneAddr, 32, bonesData.rcollar))
                                    if (getBone2d(pov,screenSize, humanAddr, boneAddr, 12, bonesData.lelbow))
                                        if (getBone2d(pov,screenSize, humanAddr, boneAddr, 33, bonesData.relbow))
                                            if (getBone2d(pov,screenSize, humanAddr, boneAddr, 63, bonesData.lwrist))
                                                if (getBone2d(pov,screenSize, humanAddr, boneAddr, 62, bonesData.rwrist))
                                                    if (getBone2d(pov, screenSize,humanAddr, boneAddr, 52, bonesData.lthigh))
                                                        if (getBone2d(pov,screenSize, humanAddr, boneAddr, 56, bonesData.rthigh))
                                                            if (getBone2d(pov,screenSize, humanAddr, boneAddr, 53, bonesData.lknee))
                                                                if (getBone2d(pov,screenSize, humanAddr, boneAddr, 57, bonesData.rknee))
                                                                    if (getBone2d(pov,screenSize, humanAddr, boneAddr, 54, bonesData.lankle))
                                                                        if (getBone2d(pov,screenSize, humanAddr, boneAddr, 58, bonesData.rankle))
                                                                            playerData.bonesData = bonesData;
                playerDataList.push_back(playerData);
            }
        }
        if (moduleControl.mainSwitch.materialStatus) {
            for (auto staticMaterialData: localMaterialList) {
                string className = getClassName(memoryTools.readInt(staticMaterialData.coordAddr + PubgOffset::ObjectParam::ClassIdOffset));
                if (isRecycled(className.c_str())) {
                    continue;
                }
                ImVec3 objectCoord;
                memoryTools.readMemory(staticMaterialData.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, sizeof(ImVec3), &objectCoord);
                float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
                if (staticMaterialData.type > 1 && staticMaterialData.type < All && objectDistance > 100) {
                    continue;
                }
                if (staticMaterialData.type < 0 && staticMaterialData.type > All) {
                    continue;
                }
                if (!moduleControl.materialSwitch[staticMaterialData.type]) {
                    continue;
                }
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
                            if (index > 100) {
                                break;
                            }
                            int goodsListId = memoryTools.readInt(goodsListArray + 0x4 + index * PubgOffset::ObjectParam::GoodsListParam::DataBase);
                            MaterialStruct goods = isBoxMaterial(goodsListId);
                            if (goods.type == -1) {
                                continue;
                            }
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

void *silenceAimbot(void *) {
    ImVec2 screenSize = ImVec2([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    while (true) {
        usleep(16666);
        if (moduleControl.systemStatus == TransmissionNormal && moduleControl.mainSwitch.aimbotStatus) {
            uintptr_t weaponAddr = memoryTools.readPtr(staticData.selfAddr + PubgOffset::ObjectParam::WeaponOneOffset);
            bool enabledAimbot = false;
            switch (moduleControl.aimbotController.aimbotMode) {
                case 0:
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 1;
                    break;
                case 1:
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1;
                    break;
                case 2:
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 1 || memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1;
                    break;
                case 3:
                    if (memoryTools.readInt(weaponAddr + PubgOffset::ObjectParam::WeaponParam::ShootModeOffset) >= 1024) {
                        enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1;
                    } else {
                        enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 1;
                    }
                    break;
            }
            if (enabledAimbot) {
                MinimalViewInfo pov;
                memoryTools.readMemory(staticData.cameraManager + PubgOffset::PlayerControllerParam::CameraManagerParam::PovOffset, sizeof(pov), &pov);
                ImVec3 selfCoord = pov.location;
                float aimbotRadius = moduleControl.aimbotController.aimbotRadius;
                StaticPlayerData aimbotPlayerData;
                aimbotPlayerData.addr = 0;
                ImVec3 aimbotCoord = ImVec3(0,0,0);
                
                pthread_mutex_lock(&staticDataMutex);
                vector<StaticPlayerData> localPlayerList = staticData.playerDataList;
                pthread_mutex_unlock(&staticDataMutex);
                
                for (auto staticPlayerData: localPlayerList) {
                    ImVec3 objectCoord;
                    memoryTools.readMemory(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, sizeof(ImVec3), &objectCoord);
                    float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
                    if (objectDistance < 0 || objectDistance > 450 || objectDistance > moduleControl.aimbotController.distance) {
                        continue;
                    }
                    float objectHeight = memoryTools.readFloat(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::HeightOffset);
                    if (objectHeight < 20) {
                        continue;
                    }
                    if (staticPlayerData.health < 0.5 && moduleControl.aimbotController.fallNotAim) {
                        continue;
                    }
                    ImVec2 playerScreen = worldToScreen(objectCoord, pov, screenSize);
                    float screenDistance;
                    PlayerData playerData;
                    if ((screenDistance = get2dDistance(screenSize,playerScreen)) < aimbotRadius) {
                        uintptr_t meshAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::MeshOffset);
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
                if (aimbotPlayerData.addr != 0 && aimbotCoord.x != 0 && aimbotCoord.y != 0 && aimbotCoord.z != 0) {
                    if (moduleControl.aimbotController.smoke) {
                        if (isOnSmoke(aimbotCoord)) {
                            aimbotCoord = {0, 0, 0};
                            continue;
                        }
                    }
                    uintptr_t weaponAttrAddr = memoryTools.readPtr(weaponAddr + PubgOffset::ObjectParam::WeaponParam::WeaponAttrOffset);
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
                        } else if (strstr(className.c_str(), "BP_Rifle_SCAR_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.015;
                            aimbotMouse.y -= 0.065;
                        } else if (strstr(className.c_str(), "BP_Rifle_M416_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.01;
                            aimbotMouse.y -= 0.07;
                        } else if (strstr(className.c_str(), "BP_Rifle_AKM_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.03;
                            aimbotMouse.y -= 0.05;
                        }
                    } else {
                        if (strstr(className.c_str(), "BP_Sniper_AWM_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.045;
                            aimbotMouse.y -= 0.085;
                        } else if (strstr(className.c_str(), "BP_Sniper_AMR_Wrapper_C") != 0) {
                            aimbotMouse.x -= 0.075;
                            aimbotMouse.y -= 0.045;
                        } else if (strstr(className.c_str(), "BP_Sniper_M24_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.045;
                            aimbotMouse.y -= 0.05;
                        } else if (strstr(className.c_str(), "BP_Sniper_Kar98k_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.075;
                            aimbotMouse.y -= 0.04;
                        } else if (strstr(className.c_str(), "BP_Sniper_Mosin_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.0225;
                            aimbotMouse.y -= 0.07;
                        } else if (strstr(className.c_str(), "BP_Sniper_Mk14_Wrapper_C") != 0) {
                            aimbotMouse.x += 1.05;
                            aimbotMouse.y -= 1.05;
                        } else if (strstr(className.c_str(), "BP_Sniper_QBU_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.055;
                            aimbotMouse.y -= 0.1;
                        } else if (strstr(className.c_str(), "BP_Sniper_SKS_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.04;
                            aimbotMouse.y -= 0.1;
                        } else if (strstr(className.c_str(), "BP_Sniper_SLR_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.055;
                            aimbotMouse.y -= 0.045;
                        } else if (strstr(className.c_str(), "BP_Sniper_Mini14_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.045;
                            aimbotMouse.y -= 0.07;
                        } else if (strstr(className.c_str(), "BP_Rifle_QBZ_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.045;
                            aimbotMouse.y -= 0.105;
                        } else if (strstr(className.c_str(), "BP_Rifle_G36_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.02;
                            aimbotMouse.y -= 0.07;
                        } else if (strstr(className.c_str(), "BP_Rifle_Groza_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.03;
                            aimbotMouse.y -= 0.08;
                        } else if (strstr(className.c_str(), "BP_Rifle_AUG_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.015;
                            aimbotMouse.y -= 0.095;
                        } else if (strstr(className.c_str(), "BP_Rifle_M16A4_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.04;
                            aimbotMouse.y -= 0.085;
                        } else if (strstr(className.c_str(), "BP_Rifle_SCAR_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.02;
                            aimbotMouse.y -= 0.08;
                        } else if (strstr(className.c_str(), "BP_Rifle_M416_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.01;
                            aimbotMouse.y -= 0.085;
                        } else if (strstr(className.c_str(), "BP_Rifle_AKM_Wrapper_C") != 0) {
                            aimbotMouse.x += 0.03;
                            aimbotMouse.y -= 0.065;
                        }
                    }
                    int count = moduleControl.aimbotController.speed;
                    if (count < 1) {
                        count = 1;
                    }
                    AddControllerYawInput(reinterpret_cast<void *>(staticData.selfAddr), aimbotMouse.x / count);
                    AddControllerPitchInput(reinterpret_cast<void *>(staticData.selfAddr), aimbotMouse.y / count);
                }
            }
        }
    }
    return nullptr;
}

bool isCoordVisibility(ImVec3 coord) {
    if (LineOfSightTo == nullptr || !isfinite(coord.x) || !isfinite(coord.y) || !isfinite(coord.z)) {
        return false;
    }
    if (strstr(staticData.cameraManagerClassName.c_str(), "PlayerCameraManager") != 0 && strstr(staticData.playerControllerClassName.c_str(), "PlayerController") != 0) {
        return LineOfSightTo(reinterpret_cast<void *>(staticData.playerController), reinterpret_cast<void *>(staticData.cameraManager), coord, false);
    }
    return false;
}

bool isOnSmoke(ImVec3 coord) {
    pthread_mutex_lock(&staticDataMutex);
    vector<StaticMaterialData> localSmokeList = staticData.smokeList;
    pthread_mutex_unlock(&staticDataMutex);
    for (StaticMaterialData smoke: localSmokeList) {
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
    if (classId > 0 && classId < 2000000) {
        int page = classId / 16384;
        int index = classId % 16384;
        uintptr_t pageAddr = memoryTools.readPtr(staticData.gnameAddr + page * sizeof(uintptr_t));
        uintptr_t nameAddr = memoryTools.readPtr(pageAddr + index * sizeof(uintptr_t)) + PubgOffset::ObjectParam::ClassNameOffset;
        memoryTools.readMemory(nameAddr, 64, buf);
    }
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
    Ue4Matrix bonematrix = transformToMatrix(boneftf);
    return matrixToVector(matrixMulti(bonematrix, actormatrix));
}

bool getBone2d(MinimalViewInfo pov,ImVec2 screen, uintptr_t human, uintptr_t bones, int part,ImVec2 &buf) {
    ImVec3 newmatrix = getBone(human, bones, part);
    buf = worldToScreen(newmatrix, pov, screen);
    return buf.x != 0 && buf.y != 0;
}