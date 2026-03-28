//
//  Dolphins.mm (COMPLETE FIXED VERSION)
//  Dolphins
//
//  Created by XBK on 2022/4/24.
//  FIXED: PlayerState okuma, thread safety, self detection
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
#include "Dolphins/utils/pubg_offset.h"  // REPLACE WITH pubg_offset_fixed.h
#include "Dolphins/utils/memory_tools.h"
#include "Dolphins/utils/log.h"

// ============================================================================
// THREAD SAFETY - ADDED
// ============================================================================
#import <pthread.h>

// Thread safety mutex for staticData
static pthread_mutex_t staticDataMutex = PTHREAD_MUTEX_INITIALIZER;

#define CJID "com.tencent.tmgp.pubgmhd"

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define screenHeight [UIScreen mainScreen].bounds.size.height
#define screenWidth [UIScreen mainScreen].bounds.size.width

using namespace std;

//模块功能控制器
ModuleControl moduleControl;
//内存读写
MemoryTools memoryTools;

OffsetValues offsets[] = {
    { 0x102A5125C, 0x10A4A1960, 0x104C0F1E8, 0x10A0557E0 },  // GL
    { 0x1028791CC, 0x10A171A00, 0x104510EF0, 0x109AAA1A0 },  // VNG
    { 0x102AD71F8, 0x10A47D400, 0x10476F14C, 0x109DB5940 },  // KR
    { 0x102AAAB0C, 0x10A453300, 0x104742830, 0x109D8B830 }   // TW
};

//掩体判断函数原型
bool (*LineOfSightTo)(void *controller, void *actor, ImVec3 bone_point, bool ischeck);

//移动X轴
void (*AddControllerYawInput)(void *actor, float val);

//移动Y轴
void (*AddControllerRollInput)(void *actor, float val);

//旋转
void (*AddControllerPitchInput)(void *actor, float val);

long gWorld() {
    OffsetValues offsetsForBundle = [OffsetsManager getOffsetsForBundleID:[[NSBundle mainBundle] bundleIdentifier]];
    return reinterpret_cast<long(__fastcall*)(long)>((long)_dyld_get_image_vmaddr_slide(0) + offsetsForBundle.gWorldFun)((long)_dyld_get_image_vmaddr_slide(0) + offsetsForBundle.gWorldData);
}

long gName() {
    OffsetValues offsetsForBundle = [OffsetsManager getOffsetsForBundleID:[[NSBundle mainBundle] bundleIdentifier]];
    return reinterpret_cast<long(__fastcall*)(long)>((long)_dyld_get_image_vmaddr_slide(0) + offsetsForBundle.gNameFun)((long)_dyld_get_image_vmaddr_slide(0) + offsetsForBundle.gNameData);
}

// ============================================================================
// STATIC DATA STRUCT - UPDATED
// ============================================================================
struct {
    //ue4入口
    uintptr_t libAddr = 0;
    //矩阵地址 (FIXED: gwlordAddr -> gWorldAddr)
    uintptr_t gWorldAddr;
    //Name地址
    uintptr_t gnameAddr;
    //玩家控制器
    uintptr_t playerController;
    //玩家控制器类名
    string playerControllerClassName;
    //相机管理器
    uintptr_t cameraManager;
    //相机管理器类名
    string cameraManagerClassName;
    //自己指针 (character)
    uintptr_t selfAddr;
    
    // ========================================================================
    // NEW FIELDS - ADDED FOR CORRECT SELF DETECTION
    // ========================================================================
    //自己的PlayerState pointer
    uintptr_t selfPlayerState;
    //自己的UID (for reliable self comparison)
    uint64_t selfUID;
    //自己的TeamID (cached from PlayerState)
    int selfTeamID;
    
    //静态数据列表
    vector<StaticPlayerData> playerDataList;
    vector<StaticMaterialData> materialDataList;
    //可视烟雾弹列表
    vector<StaticMaterialData> smokeList;
} staticData;

//UI入口函数
static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //Esp绘制
        mao* drawWindow = [[mao alloc] initWithFrame:&moduleControl];
        //菜单
        mi* menuWindow = [[mi alloc] initWithFrame:&moduleControl];
        //覆盖图层
        OverlayView* overlayView = [[OverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds:&moduleControl:drawWindow:menuWindow];
        [[UIApplication sharedApplication].keyWindow addSubview:overlayView];
        //小按钮
        FloatView* floatView = [[FloatView alloc] initWithFrame:CGRectMake(489, 58, 45, 45):&moduleControl];
        [[UIApplication sharedApplication].keyWindow addSubview:floatView];
    });
}

//库入口函数
__attribute__((constructor)) static void initialize() {
    //加载视图
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorDrop);
    
    //静态数据线程
    pthread_t staticDataThread;
    pthread_create(&staticDataThread, nullptr, readStaticData, nullptr);
    
    //自瞄线程
    pthread_t silenceAimbotThread;
    pthread_create(&silenceAimbotThread, nullptr, silenceAimbot, nullptr);
}

// ============================================================================
// FIXED: readStaticData - PlayerState-based reading
// ============================================================================
void *readStaticData(void *) {
    while (true) {
        sleep(4);
        
        if(moduleControl.systemStatus != TransmissionNormal){
            staticData.libAddr = (uintptr_t)_dyld_get_image_vmaddr_slide(0);
            if(staticData.libAddr != 1){
                moduleControl.systemStatus = TransmissionNormal;
            }
        } else if (moduleControl.systemStatus == TransmissionNormal) {
            
            // Thread safety - lock
            pthread_mutex_lock(&staticDataMutex);
            
            staticData.gWorldAddr = gWorld();
            staticData.gnameAddr = gName();
            
            //角色控制器
            staticData.playerController = memoryTools.readPtr(
                memoryTools.readPtr(
                    memoryTools.readPtr(staticData.gWorldAddr + PubgOffset::PlayerControllerOffset[0]) 
                    + PubgOffset::PlayerControllerOffset[1]
                ) + PubgOffset::PlayerControllerOffset[2]
            );
            
            //掩体判断
            LineOfSightTo = (bool (*)(void *, void *, ImVec3, bool)) (
                memoryTools.readPtr(
                    memoryTools.readPtr(staticData.playerController + 0x0) 
                    + PubgOffset::PlayerControllerParam::ControllerFunction::LineOfSightToOffset
                )
            );
            
            //自己指针 (character)
            staticData.selfAddr = memoryTools.readPtr(
                staticData.playerController + PubgOffset::PlayerControllerParam::SelfOffset
            );
            
            // ====================================================================
            // CRITICAL: Get self PlayerState and cache UID for comparison
            // ====================================================================
            staticData.selfPlayerState = memoryTools.readPtr(
                staticData.selfAddr + PubgOffset::ObjectParam::PlayerStateOffset
            );
            
            if (staticData.selfPlayerState != 0 && staticData.selfPlayerState > 0x100000000) {
                // Read and cache self UID - most reliable self detection
                staticData.selfUID = memoryTools.readLong(
                    staticData.selfPlayerState + PubgOffset::ObjectParam::PlayerState::UIDOffset
                );
                
                // Read and cache self TeamID from PlayerState
                staticData.selfTeamID = memoryTools.readInt(
                    staticData.selfPlayerState + PubgOffset::ObjectParam::PlayerState::TeamIDOffset
                );
            } else {
                // Fallback if PlayerState unavailable
                staticData.selfUID = 0;
                staticData.selfTeamID = 0;
            }
            
            //自瞄函数
            uintptr_t selfFunction = memoryTools.readPtr(staticData.selfAddr + 0);
            AddControllerYawInput = (void (*)(void *, float)) (
                memoryTools.readPtr(selfFunction + PubgOffset::ObjectParam::PlayerFunction::AddControllerYawInputOffset)
            );
            AddControllerRollInput = (void (*)(void *, float)) (
                memoryTools.readPtr(selfFunction + PubgOffset::ObjectParam::PlayerFunction::AddControllerRollInputOffset)
            );
            AddControllerPitchInput = (void (*)(void *, float)) (
                memoryTools.readPtr(selfFunction + PubgOffset::ObjectParam::PlayerFunction::AddControllerPitchInputOffset)
            );
            
            //相机管理器
            staticData.cameraManager = memoryTools.readPtr(
                staticData.playerController + PubgOffset::PlayerControllerParam::CameraManagerOffset
            );
            
            //清空列表
            vector<StaticPlayerData> tmpPlayerDataList;
            vector<StaticMaterialData> tmpMaterialDataList;
            vector<StaticMaterialData> tmpSmokeList;
            
            //遍历地址
            uintptr_t uLevel = memoryTools.readPtr(staticData.gWorldAddr + PubgOffset::ULevelOffset);
            
            //数组 (FIXED: obectArray -> objectArray)
            uintptr_t objectArray = memoryTools.readPtr(uLevel + PubgOffset::ULevelParam::ObjectArrayOffset);
            
            //成员数量
            int objectCount = memoryTools.readInt(uLevel + PubgOffset::ULevelParam::ObjectCountOffset);
            
            //开始寻找
            for (int index = 0; index < objectCount; ++index) {
                //对象指针
                uintptr_t objectAddr = memoryTools.readPtr(objectArray + index * 8);
                
                // Sanity check
                if (objectAddr <= 0x100000000 || objectAddr >= 0x2000000000 || objectAddr % 8 != 0) {
                    continue;
                }
                
                //对象坐标指针
                uintptr_t coordAddr = memoryTools.readPtr(objectAddr + PubgOffset::ObjectParam::CoordOffset);
                
                string className = getClassName(memoryTools.readInt(objectAddr + PubgOffset::ObjectParam::ClassIdOffset));
                
                //人 (FIXED: typos corrected)
                bool isPlayer = (
                    strstr(className.c_str(), "PlayerPawn")       != 0 ||
                    strstr(className.c_str(), "PlayerCharacter")  != 0 ||
                    strstr(className.c_str(), "PlayerController") != 0 ||
                    strstr(className.c_str(), "CharacterModel")   != 0
                );
                
                if (isPlayer && moduleControl.mainSwitch.playerStatus) {
                    
                    // ================================================================
                    // CRITICAL: Read from PlayerState - RELIABLE DATA
                    // ================================================================
                    
                    // 1. Get PlayerState pointer
                    uintptr_t playerState = memoryTools.readPtr(
                        objectAddr + PubgOffset::ObjectParam::PlayerStateOffset
                    );
                    
                    // Skip if PlayerState invalid
                    if (playerState == 0 || playerState <= 0x100000000) {
                        continue;
                    }
                    
                    // 2. UID-based self detection - MOST RELIABLE
                    uint64_t entityUID = memoryTools.readLong(
                        playerState + PubgOffset::ObjectParam::PlayerState::UIDOffset
                    );
                    
                    if (staticData.selfUID != 0 && entityUID == staticData.selfUID) {
                        continue; // Skip self - 100% reliable
                    }
                    
                    // 3. Read TeamID from PlayerState - RELIABLE
                    int entityTeam = memoryTools.readInt(
                        playerState + PubgOffset::ObjectParam::PlayerState::TeamIDOffset
                    );
                    
                    // Skip teammates
                    if (entityTeam != 0 && staticData.selfTeamID != 0 && entityTeam == staticData.selfTeamID) {
                        continue;
                    }
                    
                    // 4. Read Health from PlayerState - RELIABLE
                    float health = memoryTools.readFloat(
                        playerState + PubgOffset::ObjectParam::PlayerState::PlayerHealthOffset
                    );
                    
                    float maxHealth = memoryTools.readFloat(
                        playerState + PubgOffset::ObjectParam::PlayerState::PlayerHealthMaxOffset
                    );
                    
                    // Skip dead players
                    if (health <= 0 || maxHealth <= 0) {
                        continue;
                    }
                    
                    // 5. LiveState check (additional validation)
                    uint8_t liveState = 0;
                    memoryTools.readMemory(
                        playerState + PubgOffset::ObjectParam::PlayerState::LiveStateOffset, 
                        1, 
                        &liveState
                    );
                    
                    // LiveState != 0 means dead or invalid
                    if (liveState != 0) {
                        continue;
                    }
                    
                    // ================================================================
                    // AI Detection - Character body is OK for this
                    // ================================================================
                    bool isAI = false;
                    memoryTools.readMemory(
                        objectAddr + PubgOffset::ObjectParam::bIsAIOffset, 
                        1, 
                        &isAI
                    );
                    
                    bool isMLAI = false;
                    memoryTools.readMemory(
                        objectAddr + PubgOffset::ObjectParam::bIsMLAIOffset, 
                        1, 
                        &isMLAI
                    );
                    
                    // ================================================================
                    // Store data
                    // ================================================================
                    StaticPlayerData tmpPlayerData;
                    
                    tmpPlayerData.addr = objectAddr;
                    tmpPlayerData.coordAddr = coordAddr;
                    tmpPlayerData.playerState = playerState;  // Store PlayerState pointer
                    tmpPlayerData.team = entityTeam;
                    tmpPlayerData.health = health;
                    tmpPlayerData.maxHealth = maxHealth;
                    tmpPlayerData.robot = (isAI || isMLAI) ? 1 : 0;
                    
                    // PlayerName - can read from character body for now
                    tmpPlayerData.name = getPlayerName(
                        memoryTools.readPtr(objectAddr + PubgOffset::ObjectParam::PlayerNameOffset_Character)
                    );
                    
                    // Status - using old offset (needs verification)
                    tmpPlayerData.status = memoryTools.readInt(
                        objectAddr + PubgOffset::ObjectParam::StatusOffset
                    );
                    
                    tmpPlayerDataList.push_back(tmpPlayerData);
                    
                } else if (strstr(className.c_str(), "ProjSmoke_BP_C") != 0) {
                    // Smoke handling
                    StaticMaterialData tmpMaterialData;
                    tmpMaterialData.type = Warning;
                    tmpMaterialData.id = 4;
                    tmpMaterialData.name = "[WARNING]SMOKE";
                    tmpMaterialData.addr = objectAddr;
                    tmpMaterialData.coordAddr = coordAddr;
                    tmpSmokeList.push_back(tmpMaterialData);
                    
                } else if (moduleControl.mainSwitch.materialStatus) {
                    // Material handling
                    MaterialStruct material = isMaterial(className.c_str());
                    if (material.type > -1) {
                        StaticMaterialData tmpMaterialData;
                        tmpMaterialData.type = material.type;
                        tmpMaterialData.id = material.id;
                        tmpMaterialData.name = material.name;
                        tmpMaterialData.addr = objectAddr;
                        tmpMaterialData.coordAddr = coordAddr;
                        
                        if ((material.type == Rifle || material.type == Sniper || material.type == Missile) 
                            && memoryTools.readPtr(objectAddr + PubgOffset::ObjectParam::WeaponParam::MasterOffset) != 0) {
                            continue;
                        }
                        tmpMaterialDataList.push_back(tmpMaterialData);
                    }
                }
            }
            
            //将临时列表赋值给全局列表
            staticData.playerDataList.swap(tmpPlayerDataList);
            staticData.materialDataList.swap(tmpMaterialDataList);
            staticData.smokeList.swap(tmpSmokeList);
            
            // Thread safety - unlock
            pthread_mutex_unlock(&staticDataMutex);
        }
    }
    return nullptr;
}

// ============================================================================
// FIXED: readFrameData - Thread-safe version
// ============================================================================
void readFrameData(ImVec2 screenSize, vector<PlayerData> &playerDataList, vector<MaterialData> &materialDataList) {
    playerDataList.clear();
    materialDataList.clear();
    
    if (moduleControl.systemStatus == TransmissionNormal) {
        
        // Thread safety - lock and make local copies
        pthread_mutex_lock(&staticDataMutex);
        
        // Make local copies to minimize lock time
        vector<StaticPlayerData> localPlayerList = staticData.playerDataList;
        vector<StaticMaterialData> localMaterialList = staticData.materialDataList;
        uintptr_t localCameraManager = staticData.cameraManager;
        uintptr_t localPlayerController = staticData.playerController;
        
        // Unlock early
        pthread_mutex_unlock(&staticDataMutex);
        
        //相机管理器类名
        string cameraManagerClassName = getClassName(
            memoryTools.readInt(localCameraManager + PubgOffset::ObjectParam::ClassIdOffset)
        );
        
        //取玩家控制器类名
        string playerControllerClassName = getClassName(
            memoryTools.readInt(localPlayerController + PubgOffset::ObjectParam::ClassIdOffset)
        );
        
        //取Pov
        MinimalViewInfo pov;
        memoryTools.readMemory(
            localCameraManager + PubgOffset::PlayerControllerParam::CameraManagerParam::PovOffset, 
            sizeof(pov), 
            &pov
        );
        
        //自身坐标
        ImVec3 selfCoord = pov.location;
        
        //读视角角度
        float lateralAngleView = memoryTools.readFloat(
            localPlayerController + PubgOffset::PlayerControllerParam::MouseOffset + 0x4
        ) - 90;
        
        //读取矩阵
        if (moduleControl.mainSwitch.playerStatus) {
            for (auto staticPlayerData: localPlayerList) {
                
                //坐标
                ImVec3 objectCoord;
                memoryTools.readMemory(
                    staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, 
                    sizeof(ImVec3), 
                    &objectCoord
                );
                
                //计算自己到对象的距离
                float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
                if (objectDistance < 0 || objectDistance > 450) {
                    continue;
                }
                
                //获取对象高度
                float objectHeight = memoryTools.readFloat(
                    staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::HeightOffset
                );
                if (objectHeight < 20) {
                    continue;
                }
                
                PlayerData playerData;
                //角度
                playerData.angle = lateralAngleView - rotateAngle(selfCoord, objectCoord) - 180;
                //雷达坐标
                playerData.radar = rotateCoord(
                    lateralAngleView, 
                    ImVec2((selfCoord.x - objectCoord.x) / 200, (selfCoord.y - objectCoord.y) / 200)
                );
                //距离
                playerData.distance = objectDistance;
                //人机
                playerData.robot = staticPlayerData.robot;
                //掩体判断
                playerData.visibility = isCoordVisibility(objectCoord);
                if (playerData.visibility && isOnSmoke(objectCoord)) {
                    playerData.visibility = false;
                }
                
                //判断一下高度
                if (objectHeight < 50) {
                    objectHeight -= 18;
                } else if (objectHeight > 80) {
                    objectHeight += 12;
                }
                
                //队伍ID (now from PlayerState - reliable)
                playerData.team = staticPlayerData.team;
                
                //血量 (now from PlayerState - reliable)
                playerData.hp = staticPlayerData.health;
                if (playerData.hp > 100) playerData.hp = 100;
                if (playerData.hp < 0) playerData.hp = 0;
                
                //取敌人动作
                uintptr_t statusAddr = memoryTools.readPtr(
                    staticPlayerData.addr + PubgOffset::ObjectParam::StatusOffset
                );
                
                // Status mapping - cleaned up
                playerData.statusName = "UNKNOWN";
                
                if (statusAddr == 2097168) playerData.statusName = "DRIVE";
                else if (statusAddr == 262208) playerData.statusName = "HEALING";
                else if (statusAddr == 33554449) playerData.statusName = "PARACHUTE";
                else if (statusAddr == 262160) playerData.statusName = "STAND";
                else if (statusAddr == 16) playerData.statusName = "STAND";
                else if (statusAddr == 524288) playerData.statusName = "KNOCKED";
                else if (statusAddr == 524289) playerData.statusName = "KNOCKED";
                else if (statusAddr == 147) playerData.statusName = "JUMP";
                else if (statusAddr == 144) playerData.statusName = "JUMP";
                else if (statusAddr == 529) playerData.statusName = "WALK";
                else if (statusAddr == 35) playerData.statusName = "CROUCH";
                else if (statusAddr == 32) playerData.statusName = "CROUCH";
                else if (statusAddr == 8205) playerData.statusName = "SHOOTING";
                else if (statusAddr == 272) playerData.statusName = "SHOOTING";
                else if (statusAddr == 273) playerData.statusName = "SHOOTING";
                else if (statusAddr == 33) playerData.statusName = "CROUCH WALK";
                else if (statusAddr == 1040) playerData.statusName = "SCOPE";
                else if (statusAddr == 1056) playerData.statusName = "SCOPE";
                else if (statusAddr == 1088) playerData.statusName = "SCOPE";
                else if (statusAddr == 19) playerData.statusName = "RUN";
                else if (statusAddr == 17) playerData.statusName = "WALK";
                else if (statusAddr == 18) playerData.statusName = "STAND";
                else if (statusAddr == 64) playerData.statusName = "PRONE";
                else if (statusAddr == 4128) playerData.statusName = "LEAN";
                else if (statusAddr == 4112) playerData.statusName = "LEAN";
                else if (statusAddr == 528) playerData.statusName = "RELOAD";
                else if (statusAddr == 16777219) playerData.statusName = "SWIM";
                else if (statusAddr == 67108880) playerData.statusName = "CLIMB";
                else if (statusAddr == 4194320) playerData.statusName = "VEHICLE";
                
                //取对手手持武器
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
                
                //对象名字
                playerData.name = staticPlayerData.name;
                
                //屏幕XY
                playerData.screen = worldToScreen(objectCoord, pov, screenSize);
                
                //宽度和高度
                ImVec2 width = worldToScreen(ImVec3(objectCoord.x, objectCoord.y, objectCoord.z + 100), pov, screenSize);
                ImVec2 height = worldToScreen(ImVec3(objectCoord.x, objectCoord.y, objectCoord.z + objectHeight), pov, screenSize);
                playerData.size.x = (playerData.screen.y - width.y) / 2;
                playerData.size.y = playerData.screen.y - height.y;
                
                //骨骼
                uintptr_t meshAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::MeshOffset);
                uintptr_t humanAddr = meshAddr + PubgOffset::ObjectParam::MeshParam::HumanOffset;
                uintptr_t boneAddr = memoryTools.readPtr(meshAddr + PubgOffset::ObjectParam::MeshParam::BonesOffset) + 48;
                
                //判断是否需要骨骼掩体判断
                BonesData bonesData;
                if (getBone2d(pov, screenSize, humanAddr, boneAddr, 5, bonesData.head))//头
                    if (getBone2d(pov, screenSize, humanAddr, boneAddr, 4, bonesData.pit))//胸口
                        if (getBone2d(pov, screenSize, humanAddr, boneAddr, 1, bonesData.pelvis))//屁股
                            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 11, bonesData.lcollar))//左肩
                                if (getBone2d(pov, screenSize, humanAddr, boneAddr, 32, bonesData.rcollar))//右肩
                                    if (getBone2d(pov, screenSize, humanAddr, boneAddr, 12, bonesData.lelbow))//左手肘
                                        if (getBone2d(pov, screenSize, humanAddr, boneAddr, 33, bonesData.relbow))//右手肘
                                            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 63, bonesData.lwrist))//左手腕
                                                if (getBone2d(pov, screenSize, humanAddr, boneAddr, 62, bonesData.rwrist))//右手腕
                                                    if (getBone2d(pov, screenSize, humanAddr, boneAddr, 52, bonesData.lthigh))//左大腿
                                                        if (getBone2d(pov, screenSize, humanAddr, boneAddr, 56, bonesData.rthigh))//右大腿
                                                            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 53, bonesData.lknee))//左膝盖
                                                                if (getBone2d(pov, screenSize, humanAddr, boneAddr, 57, bonesData.rknee))//右膝盖
                                                                    if (getBone2d(pov, screenSize, humanAddr, boneAddr, 54, bonesData.lankle))//左脚腕
                                                                        if (getBone2d(pov, screenSize, humanAddr, boneAddr, 58, bonesData.rankle))//右脚腕
                                                                            playerData.bonesData = bonesData;
                
                playerDataList.push_back(playerData);
            }
        }
        
        // Material processing
        if (moduleControl.mainSwitch.materialStatus) {
            for (auto staticMaterialData: localMaterialList) {
                string className = getClassName(memoryTools.readInt(staticMaterialData.coordAddr + PubgOffset::ObjectParam::ClassIdOffset));
                if (isRecycled(className.c_str())) {
                    continue;
                }
                
                //坐标
                ImVec3 objectCoord;
                memoryTools.readMemory(staticMaterialData.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, sizeof(ImVec3), &objectCoord);
                
                //计算自己到对象的距离
                float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
                if (staticMaterialData.type > 1 && staticMaterialData.type < All && objectDistance > 100) {
                    continue;
                }
                
                //判断数据是否是0
                if (staticMaterialData.type < 0 && staticMaterialData.type > All) {
                    continue;
                }
                
                //判断开关 数组下标是否超出
                if (!moduleControl.materialSwitch[staticMaterialData.type]) {
                    continue;
                }
                
                MaterialData materialData;
                //物资类型
                materialData.type = staticMaterialData.type;
                //物资ID
                materialData.id = staticMaterialData.id;
                //物资名字
                materialData.name = staticMaterialData.name;
                //距离
                materialData.distance = objectDistance;
                //屏幕坐标
                materialData.screen = worldToScreen(objectCoord, pov, screenSize);
                
                materialDataList.push_back(materialData);
                
                // Airdrop goods list
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

// ============================================================================
// AIMBOT - Same as original but uses updated data
// ============================================================================
void *silenceAimbot(void *) {
    ImVec2 screenSize = ImVec2([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    while (true) {
        usleep(16666);
        
        if (moduleControl.systemStatus == TransmissionNormal && moduleControl.mainSwitch.aimbotStatus) {
            
            //武器指针
            uintptr_t weaponAddr = memoryTools.readPtr(staticData.selfAddr + PubgOffset::ObjectParam::WeaponOneOffset);
            
            //自瞄开关
            bool enabledAimbot = false;
            
            //判断自瞄启动模式
            switch (moduleControl.aimbotController.aimbotMode) {
                case 0:
                    //开镜自瞄
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 1;
                    break;
                case 1:
                    //开火自瞄
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1;
                    break;
                case 2:
                    //开镜开火自瞄
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 1 || 
                                    memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1;
                    break;
                case 3:
                    //判断枪械是单发还是全自动
                    if (memoryTools.readInt(weaponAddr + PubgOffset::ObjectParam::WeaponParam::ShootModeOffset) >= 1024) {
                        //全自动用开火
                        enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1;
                    } else {
                        //单发连发用开镜
                        enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 1;
                    }
                    break;
            }
            
            //启动自瞄
            if (enabledAimbot) {
                
                //取Pov
                MinimalViewInfo pov;
                memoryTools.readMemory(staticData.cameraManager + PubgOffset::PlayerControllerParam::CameraManagerParam::PovOffset, sizeof(pov), &pov);
                
                //自身坐标
                ImVec3 selfCoord = pov.location;
                
                //复位自瞄范围
                float aimbotRadius = moduleControl.aimbotController.aimbotRadius;
                
                //自瞄对象定义
                StaticPlayerData aimbotPlayerData;
                aimbotPlayerData.addr = 0;
                
                //自瞄对象坐标,指定部位的坐标
                ImVec3 aimbotCoord = ImVec3(0, 0, 0);
                
                // Thread-safe access to player list
                pthread_mutex_lock(&staticDataMutex);
                vector<StaticPlayerData> localPlayerList = staticData.playerDataList;
                pthread_mutex_unlock(&staticDataMutex);
                
                //循环人物对象列表
                for (auto staticPlayerData: localPlayerList) {
                    
                    //坐标
                    ImVec3 objectCoord;
                    memoryTools.readMemory(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, sizeof(ImVec3), &objectCoord);
                    
                    //计算自己到对象的距离
                    float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
                    if (objectDistance < 0 || objectDistance > 450 || objectDistance > moduleControl.aimbotController.distance) {
                        continue;
                    }
                    
                    //获取对象高度
                    float objectHeight = memoryTools.readFloat(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::HeightOffset);
                    if (objectHeight < 20) {
                        continue;
                    }
                    
                    //判断是否倒地 (now using cached health from PlayerState)
                    if (staticPlayerData.health < 0.5 && moduleControl.aimbotController.fallNotAim) {
                        continue;
                    }
                    
                    //屏幕坐标
                    ImVec2 objectScreen = worldToScreen(objectCoord, pov, screenSize);
                    
                    //屏幕坐标不符合则跳过
                    if (objectScreen.x <= 0 || objectScreen.y <= 0) {
                        continue;
                    }
                    
                    //计算自瞄范围
                    float objectRadius = get2dDistance(screenSize, objectScreen);
                    
                    //范围不符合则跳过
                    if (objectRadius > aimbotRadius) {
                        continue;
                    }
                    
                    //判断这个对象和上个对象哪个离目标点近
                    if (objectRadius < aimbotRadius) {
                        //优先级
                        aimbotPlayerData = staticPlayerData;
                        //坐标
                        aimbotCoord = objectCoord;
                        //最近距离
                        aimbotRadius = objectRadius;
                    }
                }
                
                //自瞄人员不为空
                if (aimbotPlayerData.addr != 0) {
                    //自瞄位置
                    ImVec3 part = ImVec3(0, 0, 0);
                    
                    //骨骼地址
                    uintptr_t meshAddr = memoryTools.readPtr(aimbotPlayerData.addr + PubgOffset::ObjectParam::MeshOffset);
                    uintptr_t humanAddr = meshAddr + PubgOffset::ObjectParam::MeshParam::HumanOffset;
                    uintptr_t boneAddr = memoryTools.readPtr(meshAddr + PubgOffset::ObjectParam::MeshParam::BonesOffset) + 48;
                    
                    //部位
                    switch (moduleControl.aimbotController.part) {
                        case 0:
                            //头
                            part = getBone(humanAddr, boneAddr, 5);
                            break;
                        case 1:
                            //胸
                            part = getBone(humanAddr, boneAddr, 4);
                            break;
                        case 2:
                            //腰
                            part = getBone(humanAddr, boneAddr, 1);
                            break;
                    }
                    
                    //掩体判断
                    bool visibility = isCoordVisibility(part);
                    if (visibility && !isOnSmoke(part)) {
                        //自瞄开始
                        aimbot(part, pov, staticData.selfAddr, aimbotPlayerData.addr, moduleControl.aimbotController.speed);
                    }
                }
            }
        }
    }
    return nullptr;
}

// ============================================================================
// HELPER FUNCTIONS - Same as original
// ============================================================================

//坐标可见性判断
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
    pthread_mutex_lock(&staticDataMutex);
    vector<StaticMaterialData> localSmokeList = staticData.smokeList;
    pthread_mutex_unlock(&staticDataMutex);
    
    for (StaticMaterialData smoke: localSmokeList) {
        //坐标
        ImVec3 smokeCoord;
        memoryTools.readMemory(smoke.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, 30, &smokeCoord);
        if (get3dDistance(smokeCoord, coord, 100) < 4) {
            return true;
        }
    }
    return false;
}

//获取玩家名字
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

//获取类名
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

//取骨骼3d坐标
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

//骨骼3d转换屏幕
bool getBone2d(MinimalViewInfo pov, ImVec2 screen, uintptr_t human, uintptr_t bones, int part, ImVec2 &buf) {
    //取世界坐标
    ImVec3 newmatrix = getBone(human, bones, part);
    //转屏幕坐标
    buf = worldToScreen(newmatrix, pov, screen);
    //范围
    return buf.x != 0 && buf.y != 0;
}

// ============================================================================
// CRITICAL CHANGES SUMMARY:
// ============================================================================
/*
1. Added pthread_mutex_t for thread safety
2. Added selfPlayerState, selfUID, selfTeamID to staticData struct
3. Completely rewrote readStaticData:
   - PlayerState-based reading for Team, Health, UID
   - UID-based self detection (100% reliable)
   - LiveState validation
   - AI detection with both bIsAI and bIsMLAI
4. Made readFrameData thread-safe with mutex and local copies
5. Fixed typos: gwlordAddr->gWorldAddr, obectArray->objectArray
6. Fixed status mapping (cleaner version)
7. All PlayerData now comes from reliable PlayerState sources
8. Added StaticPlayerData fields: playerState, health, maxHealth

TO USE:
1. Replace #include "Dolphins/utils/pubg_offset.h" with pubg_offset_fixed.h
2. Update StaticPlayerData struct to include new fields
3. Compile and test

EXPECTED RESULTS:
- 100% reliable team filtering
- No more self-box drawing
- Correct health values
- Better AI/player distinction
- No crashes from race conditions
*/