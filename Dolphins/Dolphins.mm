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
void (*AddControllerYawInput)(void *actot, float val);
void (*AddControllerRollInput)(void *actot, float val);
void (*AddControllerPitchInput)(void *actot, float val);

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

// ========== BOT TESPİTİ ==========
bool IsBotPlayer(uintptr_t playerAddr) {
    if (playerAddr == 0) return true;
    uintptr_t playerState = memoryTools.readPtr(playerAddr + PubgOffset::ObjectParam::PlayerStateOffset);
    if (playerState != 0 && playerState > 0x100000000) {
        uint8_t isAI = 0;
        memoryTools.readMemory(playerState + PubgOffset::ObjectParam::bIsAI_Offset, 1, &isAI);
        return isAI != 0;
    }
    return false;
}

// ========== KEMİK SİSTEMİ ==========
ImVec3 GetBoneLocation(uintptr_t mesh, int boneIndex) {
    uintptr_t boneArray = memoryTools.readPtr(mesh + PubgOffset::ObjectParam::MeshParam::BonePtrOffset);
    if (boneArray == 0) return ImVec3(0,0,0);
    uintptr_t boneTransform = boneArray + (boneIndex * 0x30);
    ImVec3 location;
    memoryTools.readMemory(boneTransform + 0x10, sizeof(ImVec3), &location);
    return location;
}

ImVec3 GetWorldBoneLocation(uintptr_t mesh, int boneIndex) {
    ImVec3 componentSpace = GetBoneLocation(mesh, boneIndex);
    if (componentSpace.x == 0 && componentSpace.y == 0 && componentSpace.z == 0) return ImVec3(0,0,0);
    
    uintptr_t componentToWorld = mesh + PubgOffset::ObjectParam::MeshParam::HumanOffset;
    Ue4Transform trans;
    memoryTools.readMemory(componentToWorld, sizeof(ImVec4), &trans.rotation);
    memoryTools.readMemory(componentToWorld + 0x10, sizeof(ImVec3), &trans.translation);
    memoryTools.readMemory(componentToWorld + 0x20, sizeof(ImVec3), &trans.scale3d);
    
    Ue4Matrix matrix = transformToMatrix(trans);
    ImVec4 vec4(componentSpace.x, componentSpace.y, componentSpace.z, 1.0f);
    ImVec4 result;
    result.x = vec4.x * matrix.m[0][0] + vec4.y * matrix.m[1][0] + vec4.z * matrix.m[2][0] + matrix.m[3][0];
    result.y = vec4.x * matrix.m[0][1] + vec4.y * matrix.m[1][1] + vec4.z * matrix.m[2][1] + matrix.m[3][1];
    result.z = vec4.x * matrix.m[0][2] + vec4.y * matrix.m[1][2] + vec4.z * matrix.m[2][2] + matrix.m[3][2];
    return ImVec3(result.x, result.y, result.z);
}

bool GetBone2D(MinimalViewInfo pov, ImVec2 screen, uintptr_t mesh, int boneIndex, ImVec2 &out) {
    ImVec3 world = GetWorldBoneLocation(mesh, boneIndex);
    if (world.x == 0 && world.y == 0 && world.z == 0) return false;
    out = worldToScreen(world, pov, screen);
    return out.x > 0 && out.y > 0;
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
            staticData.gwlordAddr = gWorld();
            staticData.gnameAddr = gName();
            staticData.playerController = memoryTools.readPtr(memoryTools.readPtr(memoryTools.readPtr(staticData.gwlordAddr + PubgOffset::PlayerControllerOffset[0]) + PubgOffset::PlayerControllerOffset[1]) + PubgOffset::PlayerControllerOffset[2]);
            LineOfSightTo = (bool (*)(void *, void *, ImVec3, bool)) (memoryTools.readPtr(memoryTools.readPtr(staticData.playerController + 0x0) + PubgOffset::PlayerControllerParam::ControllerFunction::LineOfSightToOffset));
            staticData.selfAddr = memoryTools.readPtr(staticData.playerController + PubgOffset::PlayerControllerParam::SelfOffset);
            uintptr_t selfFunction = memoryTools.readPtr(staticData.selfAddr + 0);
            AddControllerYawInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::ObjectParam::PlayerFunction::AddControllerYawInputOffset));
            AddControllerRollInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::ObjectParam::PlayerFunction::AddControllerRollInputOffset));
            AddControllerPitchInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::ObjectParam::PlayerFunction::AddControllerPitchInputOffset));
            staticData.cameraManager = memoryTools.readPtr(staticData.playerController + PubgOffset::PlayerControllerParam::CameraManagerOffset);
            
            vector<StaticPlayerData> tmpPlayerDataList;
            vector<StaticMaterialData> tmpMaterialDataList;
            vector<StaticMaterialData> tmpSmokeList;
            
            uintptr_t uLevel = memoryTools.readPtr(staticData.gwlordAddr + PubgOffset::ULevelOffset);
            uintptr_t obectArray = memoryTools.readPtr(uLevel + PubgOffset::ULevelParam::ObjectArrayOffset);
            int objectCount = memoryTools.readInt(uLevel + PubgOffset::ULevelParam::ObjectCountOffset);
            
            int selfTeamID = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::TeamOffset);
            
            for (int index = 0; index < objectCount; ++index) {
                uintptr_t objectAddr = memoryTools.readPtr(obectArray + index * 8);
                if (objectAddr <= 0x100000000 || objectAddr >= 0x2000000000 || objectAddr % 8 != 0) continue;
                
                uintptr_t rootComponent = memoryTools.readPtr(objectAddr + PubgOffset::ObjectParam::RootComponentOffset);
                string className = getClassName(memoryTools.readInt(objectAddr + PubgOffset::ObjectParam::ClassIdOffset));
                bool isPlayer = (strstr(className.c_str(), "PlayerPawn") != 0 || strstr(className.c_str(), "PlayerCharacter") != 0 || strstr(className.c_str(), "BP_Player") != 0);
                
                if (isPlayer && moduleControl.mainSwitch.playerStatus) {
                    if (objectAddr == staticData.selfAddr) continue;
                    int team = memoryTools.readInt(objectAddr + PubgOffset::ObjectParam::TeamOffset);
                    if (team == selfTeamID) continue;
                    bool isDead = false;
                    memoryTools.readMemory(objectAddr + PubgOffset::ObjectParam::DeadOffset, 1, &isDead);
                    if (isDead) continue;
                    
                    StaticPlayerData tmpPlayerData;
                    tmpPlayerData.addr = objectAddr;
                    tmpPlayerData.coordAddr = rootComponent;
                    tmpPlayerData.team = team;
                    tmpPlayerData.name = getPlayerName(memoryTools.readPtr(objectAddr + PubgOffset::ObjectParam::NameOffset));
                    tmpPlayerData.robot = IsBotPlayer(objectAddr) ? 1 : 0;
                    if (moduleControl.playerSwitch.ignorebot && tmpPlayerData.robot) continue;
                    tmpPlayerData.status = memoryTools.readInt(objectAddr + PubgOffset::ObjectParam::StatusOffset);
                    tmpPlayerDataList.push_back(tmpPlayerData);
                    
                } else if (strstr(className.c_str(), "ProjSmoke_BP_C)") != 0) {
                    StaticMaterialData tmpMaterialData;
                    tmpMaterialData.type = Warning;
                    tmpMaterialData.id = 4;
                    tmpMaterialData.name = "[WARNING]SMOKE";
                    tmpMaterialData.addr = objectAddr;
                    tmpMaterialData.coordAddr = rootComponent;
                    tmpSmokeList.push_back(tmpMaterialData);
                } else if (moduleControl.mainSwitch.materialStatus) {
                    MaterialStruct material = isMaterial(className.c_str());
                    if (material.type > -1) {
                        StaticMaterialData tmpMaterialData;
                        tmpMaterialData.type = material.type;
                        tmpMaterialData.id = material.id;
                        tmpMaterialData.name = material.name;
                        tmpMaterialData.addr = objectAddr;
                        tmpMaterialData.coordAddr = rootComponent;
                        if ((material.type == Rifle || material.type == Sniper || material.type == Missile) && memoryTools.readPtr(objectAddr + PubgOffset::ObjectParam::WeaponParam::MasterOffset) != 0) continue;
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

void readFrameData(ImVec2 screenSize,vector<PlayerData> &playerDataList, vector<MaterialData> &materialDataList) {
    playerDataList.clear();
    materialDataList.clear();
    if (moduleControl.systemStatus == TransmissionNormal) {
        staticData.cameraManagerClassName = getClassName(memoryTools.readInt(staticData.cameraManager + PubgOffset::ObjectParam::ClassIdOffset));
        staticData.playerControllerClassName = getClassName(memoryTools.readInt(staticData.playerController + PubgOffset::ObjectParam::ClassIdOffset));
        
        MinimalViewInfo pov;
        memoryTools.readMemory(staticData.cameraManager + PubgOffset::PlayerControllerParam::CameraManagerParam::PovOffset, sizeof(pov), &pov);
        ImVec3 selfCoord = pov.location;
        float lateralAngleView = memoryTools.readFloat(staticData.playerController + PubgOffset::PlayerControllerParam::AngleOffset + 0x4) - 90;
        
        if (moduleControl.mainSwitch.playerStatus) {
            for (auto staticPlayerData: staticData.playerDataList) {
                if (staticPlayerData.addr == staticData.selfAddr) continue;
                
                ImVec3 objectCoord;
                memoryTools.readMemory(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::RelativeLocation, sizeof(ImVec3), &objectCoord);
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
                if (playerData.visibility && isOnSmoke(objectCoord)) playerData.visibility = false;
                
                if (objectHeight < 50) objectHeight -= 18;
                else if (objectHeight > 80) objectHeight += 12;
                
                playerData.team = staticPlayerData.team;
                playerData.hp = memoryTools.readFloat(staticPlayerData.addr + PubgOffset::ObjectParam::HpOffset);
                if (playerData.hp > 100) playerData.hp = 100;
                
                uintptr_t statusAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::StatusOffset);
                if (statusAddr == 2097168) playerData.statusName = "DRIVE";
                if (statusAddr == 262208) playerData.statusName = "HEALING";
                if (statusAddr == 33554449) playerData.statusName = "FLYING ON PARACHUTE";
                if (statusAddr == 262160) playerData.statusName = "STAND";
                if (statusAddr == 16) playerData.statusName = "STAND";
                if (statusAddr == 524288) playerData.statusName = "KNOCKED";
                if (statusAddr == 147) playerData.statusName = "JUMP";
                if (statusAddr == 529) playerData.statusName = "WALK & RELOADING";
                if (statusAddr == 35) playerData.statusName = "CROUCHING";
                if (statusAddr == 8205) playerData.statusName = "SHOOTING";
                if (statusAddr == 33) playerData.statusName = "蹲走";
                if (statusAddr == 65568) playerData.statusName = "蹲下丢雷";
                if (statusAddr == 65600) playerData.statusName = "趴下丢雷";
                if (statusAddr == 1088) playerData.statusName = "趴下开镜";
                if (statusAddr == 1056) playerData.statusName = "蹲下开镜";
                if (statusAddr == 18) playerData.statusName = "站立";
                if (statusAddr == 32784) playerData.statusName = "挥拳";
                if (statusAddr == 23) playerData.statusName = "拿枪";
                if (statusAddr == 1073741840) playerData.statusName = "开火";
                if (statusAddr == 16777219) playerData.statusName = "游泳";
                if (statusAddr == 524289) playerData.statusName = "击倒";
                if (statusAddr == 8205) playerData.statusName = "开火";
                if (statusAddr == 1040) playerData.statusName = "开镜";
                if (statusAddr == 272) playerData.statusName = "开枪";
                if (statusAddr == 4112) playerData.statusName = "歪头";
                if (statusAddr == 19) playerData.statusName = "奔跑";
                if (statusAddr == 6552) playerData.statusName = "拉手雷";
                if (statusAddr == 64) playerData.statusName = "趴着";
                if (statusAddr == 32) playerData.statusName = "蹲着";
                if (statusAddr == 144) playerData.statusName = "跳跃";
                if (statusAddr == 4128) playerData.statusName = "蹲着歪头";
                if (statusAddr == 4384) playerData.statusName = "蹲着开火";
                if (statusAddr == 528) playerData.statusName = "换弹中";
                if (statusAddr == 320) playerData.statusName = "趴着开火";
                if (statusAddr == 288) playerData.statusName = "蹲着开火";
                if (statusAddr == 576) playerData.statusName = "趴着换弹";
                if (statusAddr == 544) playerData.statusName = "蹲着换弹";
                if (statusAddr == 67108880) playerData.statusName = "翻墙中";
                if (statusAddr == 273) playerData.statusName = "RUN & SHOOT";
                if (statusAddr == 4194320) playerData.statusName = "乘坐";
                if (statusAddr == 17) playerData.statusName = "WALK";
                
                uintptr_t weaponAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::WeaponOneOffset);
                if (weaponAddr == 0) {
                    playerData.weaponName = "FIST";
                } else {
                    string className = getClassName(memoryTools.readInt(weaponAddr + PubgOffset::ObjectParam::ClassIdOffset));
                    MaterialStruct weaponName = isWeapon(className.c_str());
                    if (weaponName.id != 0) playerData.weaponName = weaponName.name;
                    else playerData.weaponName = "[RIFLE]M762";
                }
                playerData.name = staticPlayerData.name;
                playerData.screen = worldToScreen(objectCoord, pov, screenSize);
                ImVec2 width = worldToScreen(ImVec3(objectCoord.x,objectCoord.y,objectCoord.z + 100), pov,screenSize);
                ImVec2 height = worldToScreen(ImVec3(objectCoord.x,objectCoord.y,objectCoord.z + objectHeight), pov,screenSize);
                playerData.size.x = (playerData.screen.y - width.y) / 2;
                playerData.size.y = playerData.screen.y - height.y;
                
                uintptr_t mesh = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::MeshOffset);
                if (mesh) {
                    BonesData bonesData;
                    if (GetBone2D(pov, screenSize, mesh, 5, bonesData.head))//头
                        if (GetBone2D(pov, screenSize, mesh, 4, bonesData.pit))//胸口
                            if (GetBone2D(pov, screenSize, mesh, 1, bonesData.pelvis))//屁股
                                if (GetBone2D(pov, screenSize, mesh, 11, bonesData.lcollar))//左肩
                                    if (GetBone2D(pov, screenSize, mesh, 32, bonesData.rcollar))//右肩
                                        if (GetBone2D(pov, screenSize, mesh, 12, bonesData.lelbow))//左手肘
                                            if (GetBone2D(pov, screenSize, mesh, 33, bonesData.relbow))//右手肘
                                                if (GetBone2D(pov, screenSize, mesh, 63, bonesData.lwrist))//左手腕
                                                    if (GetBone2D(pov, screenSize, mesh, 62, bonesData.rwrist))//右手腕
                                                        if (GetBone2D(pov, screenSize, mesh, 52, bonesData.lthigh))//左大腿
                                                            if (GetBone2D(pov, screenSize, mesh, 56, bonesData.rthigh))//右大腿
                                                                if (GetBone2D(pov, screenSize, mesh, 53, bonesData.lknee))//左膝盖
                                                                    if (GetBone2D(pov, screenSize, mesh, 57, bonesData.rknee))//右膝盖
                                                                        if (GetBone2D(pov, screenSize, mesh, 54, bonesData.lankle))//左脚腕
                                                                            if (GetBone2D(pov, screenSize, mesh, 58, bonesData.rankle))//右脚腕
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
                memoryTools.readMemory(staticMaterialData.coordAddr + PubgOffset::ObjectParam::CoordParam::RelativeLocation, sizeof(ImVec3), &objectCoord);
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
                            int goodsListId = memoryTools.readInt(goodsListArray + 0x4 + index * 0x38);
                            MaterialStruct goods = isBoxMaterial(goodsListId);
                            if (goods.type == -1) continue;
                            memset(&materialData, 0, sizeof(materialData));
                            goodsListValidCount++;
                            materialData.type = goods.type;
                            materialData.id = goods.id;
                            materialData.name = goods.name;
                            materialData.distance = -100;
                            materialData.screen.x = goodsListScreen.x;
                            materialData.screen.y = goodsListScreen.y - 32 * goodsListValidCount;
                            materialDataList.push_back(materialData);
                        }
                    }
                }
            }
        }
    }
}

void *silenceAimbot(void *) {
    ImVec2 screenSize = ImVec2(kWidth, kHeight);
    while (true) {
        usleep(16666);
        if (moduleControl.systemStatus != TransmissionNormal || !moduleControl.mainSwitch.aimbotStatus) continue;
        
        uintptr_t weaponAddr = memoryTools.readPtr(staticData.selfAddr + PubgOffset::ObjectParam::WeaponOneOffset);
        bool enabledAimbot = false;
        switch (moduleControl.aimbotController.aimbotMode) {
            case 0:
                enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 257 || memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 1;
                break;
            case 1:
                enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1;
                break;
            case 2:
                enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 257 || memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 1 || memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1;
                break;
            case 3:
                if (memoryTools.readInt(weaponAddr + PubgOffset::ObjectParam::WeaponParam::ShootModeOffset) >= 1024) {
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1;
                } else {
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 257 || memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 1;
                }
                break;
        }
        if (!enabledAimbot) continue;
        
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
            memoryTools.readMemory(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::RelativeLocation, sizeof(ImVec3), &objectCoord);
            float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
            if (objectDistance < 0 || objectDistance > 450 || objectDistance > moduleControl.aimbotController.distance) continue;
            float objectHeight = memoryTools.readFloat(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::HeightOffset);
            if (objectHeight < 20) continue;
            if (memoryTools.readFloat(staticPlayerData.addr + PubgOffset::ObjectParam::HpOffset) < 0.5 && moduleControl.aimbotController.fallNotAim) continue;
            
            ImVec2 playerScreen = worldToScreen(objectCoord, pov, screenSize);
            float screenDistance;
            if ((screenDistance = get2dDistance(screenSize,playerScreen)) >= aimbotRadius) continue;
            
            uintptr_t mesh = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::MeshOffset);
            if (!mesh) continue;
            
            int targetBone = (moduleControl.aimbotController.aimbotParts == 4) ? 5 : 3;
            ImVec3 boneCoord = GetWorldBoneLocation(mesh, targetBone);
            if (boneCoord.x == 0 && boneCoord.y == 0 && boneCoord.z == 0) continue;
            if (!isCoordVisibility(boneCoord)) continue;
            
            aimbotPlayerData = staticPlayerData;
            aimbotCoord = boneCoord;
            aimbotRadius = screenDistance;
        }
        
        if (aimbotPlayerData.addr != 0 && aimbotCoord.x != 0 && aimbotCoord.y != 0 && aimbotCoord.z != 0) {
            if (moduleControl.aimbotController.smoke && isOnSmoke(aimbotCoord)) continue;
            
            ImVec2 aimbotMouse = rotateAngleView(selfCoord, aimbotCoord);
            float selfStatus = memoryTools.readFloat(memoryTools.readPtr(staticData.selfAddr + PubgOffset::ObjectParam::RootComponentOffset) + PubgOffset::ObjectParam::CoordParam::HeightOffset);
            string className = getClassName(memoryTools.readInt(weaponAddr + PubgOffset::ObjectParam::ClassIdOffset));
            
            if (selfStatus > 47) {
                if (strstr(className.c_str(), "BP_Sniper_AWM_Wrapper_C") != 0) {
                    aimbotMouse.x += 0.06; aimbotMouse.y -= 0.06;
                } else if (strstr(className.c_str(), "BP_Sniper_AMR_Wrapper_C") != 0) {
                    aimbotMouse.x -= 0.075; aimbotMouse.y -= 0.035;
                } else if (strstr(className.c_str(), "BP_Sniper_M24_Wrapper_C") != 0) {
                    aimbotMouse.x += 0.04; aimbotMouse.y -= 0.03;
                } else if (strstr(className.c_str(), "BP_Sniper_Kar98k_Wrapper_C") != 0) {
                    aimbotMouse.x += 0.05; aimbotMouse.y -= 0.02;
                } else if (strstr(className.c_str(), "BP_Sniper_Mosin_Wrapper_C") != 0) {
                    aimbotMouse.x += 0.04; aimbotMouse.y -= 0.05;
                } else if (strstr(className.c_str(), "BP_Sniper_Mk14_Wrapper_C") != 0) {
                    aimbotMouse.x += 1.05; aimbotMouse.y -= 1.05;
                } else if (strstr(className.c_str(), "BP_Sniper_QBU_Wrapper_C") != 0) {
                    aimbotMouse.x += 0.055; aimbotMouse.y -= 0.085;
                } else if (strstr(className.c_str(), "BP_Sniper_SKS_Wrapper_C") != 0) {
                    aimbotMouse.x += 0.06; aimbotMouse.y -= 0.085;
                } else if (strstr(className.c_str(), "BP_Sniper_SLR_Wrapper_C") != 0) {
                    aimbotMouse.x += 0.055; aimbotMouse.y -= 0.03;
                } else if (strstr(className.c_str(), "BP_Sniper_Mini14_Wrapper_C") != 0) {
                    aimbotMouse.x += 0.015; aimbotMouse.y -= 0.05;
                } else if (strstr(className.c_str(), "BP_Rifle_QBZ_Wrapper_C") != 0) {
                    aimbotMouse.x += 0.045; aimbotMouse.y -= 0.09;
                } else if (strstr(className.c_str(), "BP_Rifle_G36_Wrapper_C") != 0) {
                    aimbotMouse.x += 0.02; aimbotMouse.y -= 0.055;
                } else if (strstr(className.c_str(), "BP_Rifle_Groza_Wrapper_C") != 0) {
                    aimbotMouse.x += 0.03; aimbotMouse.y -= 0.065;
                } else if (strstr(className.c_str(), "BP_Rifle_AUG_Wrapper_C") != 0) {
                    aimbotMouse.x += 0.015; aimbotMouse.y -= 0.08;
                } else if (strstr(className.c_str(), "BP_Rifle_M16A4_Wrapper_C") != 0) {
                    aimbotMouse.x += 0.04; aimbotMouse.y -= 0.07;
                } else if (strstr(className.c_str(), "BP_Rifle_AKM_Wrapper_C") != 0) {
                    aimbotMouse.x += 0.04; aimbotMouse.y -= 0.07;
                } else if (strstr(className.c_str(), "BP_Rifle_SCAR_Wrapper_C") != 0) {
                    aimbotMouse.x += 0.02; aimbotMouse.y -= 0.085;
                } else if (strstr(className.c_str(), "BP_Rifle_M416_Wrapper_C") != 0) {
                    aimbotMouse.x += 0.02; aimbotMouse.y -= 0.08;
                } else if (strstr(className.c_str(), "BP_Rifle_M762_Wrapper_C") != 0) {
                    aimbotMouse.x += 0.03; aimbotMouse.y -= 0.07;
                } else if (strstr(className.c_str(), "BP_Other_M249_Wrapper_C") != 0) {
                    aimbotMouse.x += 0.025; aimbotMouse.y -= 0.06;
                } else if (strstr(className.c_str(), "BP_Other_MG3_Wrapper_C") != 0) {
                    aimbotMouse.x += 0.03; aimbotMouse.y -= 0.07;
                } else if (strstr(className.c_str(), "BP_Other_DP28_Wrapper_C") != 0) {
                    aimbotMouse.x += 0.045; aimbotMouse.y -= 0.095;
                }
            }
            
            if (memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1) {
                uintptr_t weaponAttrAddr = memoryTools.readPtr(weaponAddr + PubgOffset::ObjectParam::WeaponParam::WeaponAttrOffset);
                float recoilTimes = 4.5 - get3dDistance(selfCoord, aimbotCoord, 10000);
                recoilTimes += get3dDistance(selfCoord, aimbotCoord, 10000) * 0.2;
                float recoil = memoryTools.readFloat(weaponAttrAddr + PubgOffset::ObjectParam::WeaponParam::WeaponAttrParam::RecoilOffset);
                if (strstr(className.c_str(), "BP_Sniper_VSS_Wrapper_C") != 0) recoil *= 0.4;
                else if (strstr(className.c_str(), "BP_Rifle_G36_Wrapper_C") != 0) recoil *= 0.6;
                else if (strstr(className.c_str(), "BP_Rifle_VAL_Wrapper_C") != 0) recoil *= 0.45;
                else if (strstr(className.c_str(), "BP_Rifle_AUG_Wrapper_C") != 0) recoil *= 0.7;
                else if (strstr(className.c_str(), "BP_Rifle_AKM_Wrapper_C") != 0) recoil *= 1.15;
                else if (strstr(className.c_str(), "BP_Other_MG3_Wrapper_C") != 0) recoil *= 0.2;
                else if (strstr(className.c_str(), "BP_Other_DP28_Wrapper_C") != 0) recoil *= 0.3;
                if (selfStatus < 50.0f) {
                    if (strstr(className.c_str(), "BP_Rifle_M762_Wrapper_C") != 0) {
                        recoil *= 0.55; aimbotMouse.x += 0.2;
                    } else if (strstr(className.c_str(), "BP_Other_M249_Wrapper_C") != 0) {
                        recoil *= 0.6; aimbotMouse.x += 0.08;
                    } else {
                        recoil *= 0.35;
                    }
                }
                aimbotMouse.y -= recoilTimes * recoil;
            }
            
            if (!isfinite(aimbotMouse.x) || !isfinite(aimbotMouse.y)) continue;
            ImVec2 aimbotMouseMove;
            aimbotMouseMove.x = change(getAngleDifference(aimbotMouse.x, memoryTools.readFloat(staticData.playerController + PubgOffset::PlayerControllerParam::AngleOffset + 0x4)) * moduleControl.aimbotController.aimbotIntensity);
            aimbotMouseMove.y = change(getAngleDifference(aimbotMouse.y, memoryTools.readFloat(staticData.playerController + PubgOffset::PlayerControllerParam::AngleOffset)) * moduleControl.aimbotController.aimbotIntensity);
            if (!isfinite(aimbotMouseMove.x) || !isfinite(aimbotMouseMove.y)) continue;
            if (AddControllerYawInput) AddControllerYawInput((void*)staticData.selfAddr, aimbotMouseMove.x);
            if (AddControllerRollInput) AddControllerRollInput((void*)staticData.selfAddr, aimbotMouseMove.y);
            if (AddControllerPitchInput) AddControllerPitchInput((void*)staticData.selfAddr, 0);
        }
    }
    return nullptr;
}

bool isCoordVisibility(ImVec3 coord) {
    if (LineOfSightTo == nullptr || !isfinite(coord.x) || !isfinite(coord.y) || !isfinite(coord.z)) return false;
    if (strstr(staticData.cameraManagerClassName.c_str(), "PlayerCameraManager") != 0 && strstr(staticData.playerControllerClassName.c_str(), "PlayerController") != 0) {
        return LineOfSightTo((void*)staticData.playerController, (void*)staticData.cameraManager, coord, false);
    }
    return false;
}

bool isOnSmoke(ImVec3 coord) {
    for (StaticMaterialData smoke: staticData.smokeList) {
        ImVec3 smokeCoord;
        memoryTools.readMemory(smoke.coordAddr + PubgOffset::ObjectParam::CoordParam::RelativeLocation, 30, &smokeCoord);
        if (get3dDistance(smokeCoord, coord, 100) < 4) return true;
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
        } else break;
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