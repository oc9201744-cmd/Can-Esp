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
//#include "Dolphins/utils/module_tools.h"
//#include "dobby.h"
#include "Dolphins/utils/log.h"
//#import "Gzb.h"

// DYLIB UPDATE: Include offset header
// NOTE: Use OFFSETS_FROM_DYLIB.h instead of manual offsets

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

// DYLIB FIX: Thread synchronization mutexes
pthread_mutex_t aimbot_mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t data_mutex = PTHREAD_MUTEX_INITIALIZER;

//OffsetSet currentOffsetSet = GL;
OffsetValues offsets[] = {
    { 0x102A62208, 0x10A566E00, 0x104bd8740, 0x10a1178b0 },  // GL
    { 0x10273B9FC, 0x1091A67B8, 0x104252D04, 0x108DF6A30 },  // VNG
    { 0x102953B7C, 0x109456EB8, 0x10446AE84, 0x1090A6EE0 },  // KR
    { 0x10296F9BC, 0x10948C638, 0x104486CC4, 0x1090DC630 }   // TW
};

//掩体判断函数原型
bool (*LineOfSightTo)(void *controller, void *actor, ImVec3 bone_point, bool ischeck);
//移动X轴
void (*AddControllerYawInput)(void *actot, float val);
//移动Y轴
void (*AddControllerRollInput)(void *actot, float val);
//旋转
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
    //ue4入口
    uintptr_t libAddr = 0;
    //矩阵地址
    uintptr_t gwlordAddr;
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
    //自己指针
    uintptr_t selfAddr;
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
   //加载hook
    //loadHook();
    //静态数据线程
    pthread_t staticDataThread;
    pthread_create(&staticDataThread, nullptr, readStaticData, nullptr);
    //自瞄线程 - DYLIB FIX: Fixed aimbot thread
    pthread_t silenceAimbotThread;
    pthread_create(&silenceAimbotThread, nullptr, silenceAimbot, nullptr);
}

// ============================================
// DYLIB FIX #2: BOT DETECTION (3 METHODS)
// ============================================

bool isBotPlayer(uintptr_t playerAddr) {
    if (playerAddr == 0) return false;
    
    // Method 1: Class name check (DYLIB optimized)
    int classId = memoryTools.readInt(playerAddr + PubgOffset::ObjectParam::ClassIdOffset);
    string className = getClassName(classId);
    
    // DYLIB verified bot class names
    const char* botClasses[] = {
        "NewFakePlayerAIPawn",
        "BP_FakePlayer",
        "FakePlayer_AIPawn",
        "FakePlayerAIPawn",
        "_PlayerPawn_TPlanAI_C",
        "AIPawn",
        "AICharacter"
    };
    
    for (int i = 0; i < 7; i++) {
        if (strstr(className.c_str(), botClasses[i]) != 0) {
            LOGI("BOT DETECTED (ClassMethod): %s", className.c_str());
            return true;
        }
    }
    
    // Method 2: AI Controller check
    uintptr_t playerState = memoryTools.readPtr(playerAddr + 0x400);
    if (playerState != 0) {
        uintptr_t controller = memoryTools.readPtr(playerState + 0x28);
        if (controller != 0) {
            int ctrlClass = memoryTools.readInt(controller);
            string ctrlName = getClassName(ctrlClass);
            
            if (strstr(ctrlName.c_str(), "AIController") != 0) {
                LOGI("BOT DETECTED (ControllerMethod): %s", ctrlName.c_str());
                return true;
            }
        }
    }
    
    // Method 3: Robot offset check (bIsAI)
    int isRobot = memoryTools.readInt(playerAddr + PubgOffset::ObjectParam::RobotOffset);
    if (isRobot == 1) {
        LOGI("BOT DETECTED (RobotOffset)");
        return true;
    }
    
    return false;
}

// ============================================
// DYLIB FIX #3: BONE POSITION READING
// ============================================

ImVec3 getBoneWorldPosition(uintptr_t meshAddr, uintptr_t skeletonCacheAddr, int boneIndex) {
    if (meshAddr == 0 || skeletonCacheAddr == 0) {
        return ImVec3(0, 0, 0);
    }
    
    // DYLIB: Each bone is FTransform (0x30 bytes)
    // Bone array: skeleton_cache + (boneIndex * 0x30)
    uintptr_t boneTransformAddr = memoryTools.readPtr(
        skeletonCacheAddr + (boneIndex * 0x30)
    );
    
    if (boneTransformAddr < 0x100000) {
        return ImVec3(0, 0, 0);
    }
    
    // DYLIB: FVector at offset +0x00 (X), +0x04 (Y), +0x08 (Z)
    float x = memoryTools.readFloat(boneTransformAddr + 0x00);
    float y = memoryTools.readFloat(boneTransformAddr + 0x04);
    float z = memoryTools.readFloat(boneTransformAddr + 0x08);
    
    if (isnan(x) || isnan(y) || isnan(z)) {
        return ImVec3(0, 0, 0);
    }
    
    return ImVec3(x, y, z);
}

// ============================================
// DYLIB FIX #1: AIMBOT INPUT FUNCTION
// ============================================

void performAimInput(ImVec3 targetBone) {
    if (!AddControllerPitchInput || !AddControllerYawInput) {
        LOGE("AddController functions not initialized!");
        return;
    }
    
    if (staticData.playerController == 0 || staticData.cameraManager == 0) {
        return;
    }
    
    // DYLIB: Get camera position from CameraManager POV
    ImVec3 camPos;
    memoryTools.readMemory(
        staticData.cameraManager + PubgOffset::PlayerControllerParam::CameraManagerParam::PovOffset,
        sizeof(ImVec3),
        &camPos
    );
    
    // Calculate direction vector
    ImVec3 dir = ImVec3(
        targetBone.x - camPos.x,
        targetBone.y - camPos.y,
        targetBone.z - camPos.z
    );
    
    // Normalize direction
    float len = sqrt(dir.x*dir.x + dir.y*dir.y + dir.z*dir.z);
    if (len == 0) return;
    
    dir.x /= len;
    dir.y /= len;
    dir.z /= len;
    
    // Calculate yaw and pitch
    float yaw = atan2(dir.y, dir.x) * 180.0f / 3.14159265f;
    float pitch = asin(-dir.z) * 180.0f / 3.14159265f;
    
    // Get sensitivity (DYLIB: 0.1 - 0.5 recommended)
    float sensitivity = moduleControl.aimbotController.aimbotIntensity;
    if (sensitivity <= 0) sensitivity = 0.1f;
    if (sensitivity > 1.0f) sensitivity = 1.0f;
    
    // Apply smoothing (50%)
    float smoothness = 0.5f;
    
    // Send controller input
    AddControllerYawInput(staticData.playerController, yaw * sensitivity * smoothness);
    AddControllerPitchInput(staticData.playerController, pitch * sensitivity * smoothness);
    
    LOGI("Aimbot: P=%.1f Y=%.1f S=%.2f", pitch, yaw, sensitivity);
}

// ============================================
// DYLIB: SKELETON DRAWING
// ============================================

void drawPlayerSkeleton(ImDrawList* drawList, const StaticPlayerData& player, ImVec4 color = ImVec4(0, 1, 0, 1)) {
    if (player.addr == 0) return;
    
    // Get mesh
    uintptr_t mesh = memoryTools.readPtr(player.addr + PubgOffset::ObjectParam::MeshOffset);
    if (mesh == 0) return;
    
    // DYLIB: Get skeleton cache (HumanBoneOffset = 0xC40)
    uintptr_t skeleton = memoryTools.readPtr(mesh + 0xC40);
    if (skeleton == 0) return;
    
    // World to screen lambda
    auto w2s = [](ImVec3 worldPos) -> ImVec2 {
        ImVec3 screenPos = projectWorldToScreen(worldPos);
        return ImVec2(screenPos.x, screenPos.y);
    };
    
    ImU32 col = ImGui::GetColorU32(color);
    float thickness = 2.0f;
    
    // DYLIB: Bone IDs (from dylib)
    ImVec3 bones[15];
    bones[0] = getBoneWorldPosition(mesh, skeleton, 9);    // Head
    bones[1] = getBoneWorldPosition(mesh, skeleton, 7);    // Spine
    bones[2] = getBoneWorldPosition(mesh, skeleton, 0);    // Pelvis
    bones[3] = getBoneWorldPosition(mesh, skeleton, 10);   // LShoulder
    bones[4] = getBoneWorldPosition(mesh, skeleton, 14);   // RShoulder
    bones[5] = getBoneWorldPosition(mesh, skeleton, 11);   // LElbow
    bones[6] = getBoneWorldPosition(mesh, skeleton, 15);   // RElbow
    bones[7] = getBoneWorldPosition(mesh, skeleton, 12);   // LWrist
    bones[8] = getBoneWorldPosition(mesh, skeleton, 16);   // RWrist
    bones[9] = getBoneWorldPosition(mesh, skeleton, 4);    // LHip
    bones[10] = getBoneWorldPosition(mesh, skeleton, 8);   // RHip
    bones[11] = getBoneWorldPosition(mesh, skeleton, 5);   // LKnee
    bones[12] = getBoneWorldPosition(mesh, skeleton, 22);  // RKnee
    bones[13] = getBoneWorldPosition(mesh, skeleton, 6);   // LAnkle
    bones[14] = getBoneWorldPosition(mesh, skeleton, 23);  // RAnkle
    
    // Draw skeleton connections
    drawList->AddLine(w2s(bones[0]), w2s(bones[1]), col, thickness);   // Head-Spine
    drawList->AddLine(w2s(bones[1]), w2s(bones[2]), col, thickness);   // Spine-Pelvis
    
    // Left arm
    drawList->AddLine(w2s(bones[3]), w2s(bones[5]), col, thickness);   // LShoulder-LElbow
    drawList->AddLine(w2s(bones[5]), w2s(bones[7]), col, thickness);   // LElbow-LWrist
    
    // Right arm
    drawList->AddLine(w2s(bones[4]), w2s(bones[6]), col, thickness);   // RShoulder-RElbow
    drawList->AddLine(w2s(bones[6]), w2s(bones[8]), col, thickness);   // RElbow-RWrist
    
    // Shoulders
    drawList->AddLine(w2s(bones[3]), w2s(bones[4]), col, thickness);   // LShoulder-RShoulder
    
    // Left leg
    drawList->AddLine(w2s(bones[9]), w2s(bones[11]), col, thickness);  // LHip-LKnee
    drawList->AddLine(w2s(bones[11]), w2s(bones[13]), col, thickness); // LKnee-LAnkle
    
    // Right leg
    drawList->AddLine(w2s(bones[10]), w2s(bones[12]), col, thickness); // RHip-RKnee
    drawList->AddLine(w2s(bones[12]), w2s(bones[14]), col, thickness); // RKnee-RAnkle
    
    // Hips
    drawList->AddLine(w2s(bones[9]), w2s(bones[10]), col, thickness);  // LHip-RHip
    
    // Hip to spine
    drawList->AddLine(w2s(bones[9]), w2s(bones[1]), col, thickness);   // LHip-Spine
    drawList->AddLine(w2s(bones[10]), w2s(bones[1]), col, thickness);  // RHip-Spine
    
    // Joint dots
    float dotRadius = 3.0f;
    drawList->AddCircle(w2s(bones[0]), dotRadius, col);   // Head
    drawList->AddCircle(w2s(bones[7]), dotRadius, col);   // LWrist
    drawList->AddCircle(w2s(bones[8]), dotRadius, col);   // RWrist
    drawList->AddCircle(w2s(bones[13]), dotRadius, col);  // LAnkle
    drawList->AddCircle(w2s(bones[14]), dotRadius, col);  // RAnkle
}

// 固定数据函数
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
            //角色控制器
            staticData.playerController = memoryTools.readPtr(memoryTools.readPtr(memoryTools.readPtr(staticData.gwlordAddr + PubgOffset::PlayerControllerOffset[0]) + PubgOffset::PlayerControllerOffset[1]) + PubgOffset::PlayerControllerOffset[2]);
            //掩体判断
            LineOfSightTo = (bool (*)(void *, void *, ImVec3, bool)) (memoryTools.readPtr(memoryTools.readPtr(staticData.playerController + 0x0) + PubgOffset::PlayerControllerParam::ControllerFunction::LineOfSightToOffset));//0x780
            //自己指针
            staticData.selfAddr = memoryTools.readPtr(staticData.playerController + PubgOffset::PlayerControllerParam::SelfOffset);
            //自瞄函数
            uintptr_t selfFunction = memoryTools.readPtr(staticData.selfAddr + 0);
            AddControllerYawInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::ObjectParam::PlayerFunction::AddControllerYawInputOffset));//0x780
            AddControllerRollInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::ObjectParam::PlayerFunction::AddControllerRollInputOffset));//0x780
            AddControllerPitchInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::ObjectParam::PlayerFunction::AddControllerPitchInputOffset));//0x780
            //相机管理器
            staticData.cameraManager = memoryTools.readPtr(staticData.playerController + PubgOffset::PlayerControllerParam::CameraManagerOffset);
            //清空列表
            vector<StaticPlayerData> tmpPlayerDataList;
            vector<StaticMaterialData> tmpMaterialDataList;
            vector<StaticMaterialData> tmpSmokeList;
            //遍历地址
            uintptr_t uLevel = memoryTools.readPtr(staticData.gwlordAddr + PubgOffset::ULevelOffset);
            //数组
            uintptr_t obectArray = memoryTools.readPtr(uLevel + PubgOffset::ULevelParam::ObjectArrayOffset);
            //成员数量
            int objectCount = memoryTools.readInt(uLevel + PubgOffset::ULevelParam::ObjectCountOffset);
            //开始寻找
            for (int index = 0; index < objectCount; ++index) {
                //对象指针
                uintptr_t objectAddr = memoryTools.readPtr(obectArray + index * 8);
                if (objectAddr <= 0x100000000 || objectAddr >= 0x2000000000 || objectAddr % 8 != 0) {
                    continue;
                }
                //对象坐标指针
                uintptr_t coordAddr = memoryTools.readPtr(objectAddr + PubgOffset::ObjectParam::CoordOffset);
                string className = getClassName(memoryTools.readInt(objectAddr + PubgOffset::ObjectParam::ClassIdOffset));
                //人 - DYLIB: Use isBotPlayer() function
                bool isPlayer = strstr(className.c_str(), "STExtraPlayerCharacter") != 0 ||
                                strstr(className.c_str(), "PlayerCharacter") != 0 ||
                                strstr(className.c_str(), "PlayerPawn") != 0;
                // DYLIB FIX #2: Improved bot detection
                bool isBot = isBotPlayer(objectAddr);
                if ((isPlayer || isBot) && moduleControl.mainSwitch.playerStatus) {
                    //队伍ID
                    int team = memoryTools.readInt(objectAddr + PubgOffset::ObjectParam::TeamOffset);
                    int TeamID = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::TeamOffset);
                    if (team == TeamID) continue;
                    StaticPlayerData tmpPlayerData;
                    //对象指针地址
                    bool bDead = (memoryTools.readInt(objectAddr + PubgOffset::ObjectParam::DeadOffset) & 0x1) != 0;
                    if(bDead) continue;
                    float hp = memoryTools.readFloat(objectAddr + PubgOffset::ObjectParam::HpOffset);
                    if(hp <= 0) continue;
                    uint64_t statusAddr = memoryTools.readInt(objectAddr + PubgOffset::ObjectParam::StatusOffset);
                    tmpPlayerData.addr = objectAddr;
                    //坐标地址
                    tmpPlayerData.coordAddr = coordAddr;
                    //队伍ID
                    tmpPlayerData.team = team;
                    //名字
                    tmpPlayerData.name = getPlayerName(memoryTools.readPtr(objectAddr + PubgOffset::ObjectParam::NameOffset));
                    //人机 - DYLIB: Use isBot variable
                    tmpPlayerData.robot = isBot ? 1 : 0;
                    tmpPlayerData.status = memoryTools.readInt(objectAddr + PubgOffset::ObjectParam::StatusOffset);
                    tmpPlayerDataList.push_back(tmpPlayerData);
                } else if (strstr(className.c_str(), "ProjSmoke_BP_C)") != 0) {
                    StaticMaterialData tmpMaterialData;
                    //物资类型
                    tmpMaterialData.type = Warning;
                    //物资ID
                    tmpMaterialData.id = 4;
                    //物资名称
                    tmpMaterialData.name = "[WARNING]SMOKE";
                    //对象指针地址
                    tmpMaterialData.addr = objectAddr;
                    //坐标地址
                    tmpMaterialData.coordAddr = coordAddr;
                    tmpSmokeList.push_back(tmpMaterialData);
                } else if (moduleControl.mainSwitch.materialStatus) {
                    MaterialStruct material = isMaterial(className.c_str());
                    if (material.type > -1) {
                        StaticMaterialData tmpMaterialData;
                        //物资类型
                        tmpMaterialData.type = material.type;
                        //物资ID
                        tmpMaterialData.id = material.id;
                        //物资名称
                        tmpMaterialData.name = material.name;
                        //对象指针地址
                        tmpMaterialData.addr = objectAddr;
                        //坐标地址
                        tmpMaterialData.coordAddr = coordAddr;
                        if ((material.type == Rifle || material.type == Sniper || material.type == Missile) && memoryTools.readPtr(objectAddr + PubgOffset::ObjectParam::WeaponParam::MasterOffset) != 0) {
                            continue;
                        }
                        tmpMaterialDataList.push_back(tmpMaterialData);
                    }
                }
            }
            //将临时列表赋值给全局列表
            pthread_mutex_lock(&data_mutex);
            staticData.playerDataList.swap(tmpPlayerDataList);
            staticData.materialDataList.swap(tmpMaterialDataList);
            staticData.smokeList.swap(tmpSmokeList);
            pthread_mutex_unlock(&data_mutex);
        }
    }
    return nullptr;
}

//获取帧数据
void readFrameData(ImVec2 screenSize,vector<PlayerData> &playerDataList, vector<MaterialData> &materialDataList) {
    playerDataList.clear();
    materialDataList.clear();
    if (moduleControl.systemStatus == TransmissionNormal) {
        //相机管理器类名
        staticData.cameraManagerClassName = getClassName(memoryTools.readInt(staticData.cameraManager + PubgOffset::ObjectParam::ClassIdOffset));
        //取玩家控制器类名
        staticData.playerControllerClassName = getClassName(memoryTools.readInt(staticData.playerController + PubgOffset::ObjectParam::ClassIdOffset));
        //取Pov
        MinimalViewInfo pov;
        memoryTools.readMemory(staticData.cameraManager + PubgOffset::PlayerControllerParam::CameraManagerParam::PovOffset, sizeof(pov), &pov);
        //自身坐标
        ImVec3 selfCoord = pov.location;
        //读视角角度
        float lateralAngleView = memoryTools.readFloat(staticData.playerController + PubgOffset::PlayerControllerParam::MouseOffset + 0x4) - 90;
        //读取矩阵
        if (moduleControl.mainSwitch.playerStatus) {
            pthread_mutex_lock(&data_mutex);
            for (auto staticPlayerData: staticData.playerDataList) {
                //坐标
                ImVec3 objectCoord;
                memoryTools.readMemory(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, sizeof(ImVec3), &objectCoord);
                //计算自己到对象的距离
                float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
                if (objectDistance < 0 || objectDistance > 450) {
                    continue;
                }
                //获取对象高度
                float objectHeight = memoryTools.readFloat(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::HeightOffset);
                if (objectHeight < 20) {
                    continue;
                }
                PlayerData playerData;
                //角度
                playerData.angle = lateralAngleView - rotateAngle(selfCoord, objectCoord) - 180;
                //雷达坐标
                playerData.radar = rotateCoord(lateralAngleView, ImVec2((selfCoord.x - objectCoord.x) / 200, (selfCoord.y - objectCoord.y) / 200));
                //距离
                playerData.distance = objectDistance;
                //人机 - DYLIB: Already set in readStaticData
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
                //队伍ID
                playerData.team = staticPlayerData.team;
                //血量
                playerData.hp = memoryTools.readFloat(staticPlayerData.addr + PubgOffset::ObjectParam::HpOffset);
                if (playerData.hp > 100) playerData.hp = 100;
                //取敌人动作
                uint64_t statusAddr = memoryTools.readInt(staticPlayerData.addr + PubgOffset::ObjectParam::StatusOffset);
                if (statusAddr == 2097168) {
                playerData.statusName = "DRIVE";
                }
                if (statusAddr == 262208) {
                playerData.statusName = "HEALING";
                }
                if (statusAddr == 33554449) {
                playerData.statusName = "FLYING ON PARACHUTE";
                }
                if (statusAddr == 262160) {
                playerData.statusName = "STAND";
                }
                if (statusAddr == 2048) {
                playerData.statusName = "RUN";
                }
                if (statusAddr == 524304) {
                playerData.statusName = "JUMP";
                }
                if (statusAddr == 262272) {
                playerData.statusName = "CROUCH";
                }
                if (statusAddr == 262176) {
                playerData.statusName = "DOWN";
                }

                playerDataList.push_back(playerData);
            }
            pthread_mutex_unlock(&data_mutex);
        }

        //读取物资信息
        if (moduleControl.mainSwitch.materialStatus) {
            for (auto staticMaterialData: staticData.materialDataList) {
                //获取距离
                ImVec3 objectCoord;
                memoryTools.readMemory(staticMaterialData.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, sizeof(ImVec3), &objectCoord);
                //距离计算
                float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
                if (objectDistance < 0 || objectDistance > 500) {
                    continue;
                }
                //屏幕坐标
                ImVec2 goodsListScreen = worldToScreen(objectCoord, pov, screenSize);
                MaterialData materialData;
                materialData.type = staticMaterialData.type;
                materialData.id = staticMaterialData.id;
                materialData.name = staticMaterialData.name;
                materialData.distance = objectDistance;
                materialData.screen = goodsListScreen;
                if (materialData.screen.x > 0 && materialData.screen.y > 0 && materialData.screen.x < screenSize.x && materialData.screen.y < screenSize.y) {
                    materialDataList.push_back(materialData);
                }
                if (get2dDistance(screenSize, goodsListScreen) < 150) {
                    int goodsListValidCount = 0;
                    //盒子遍历
                    uintptr_t goodsListArray = memoryTools.readPtr(staticMaterialData.addr + PubgOffset::ObjectParam::GoodsListOffset);
                    //盒子物资数量
                    int goodsListCount = memoryTools.readInt(staticMaterialData.addr + PubgOffset::ObjectParam::GoodsListOffset + sizeof(uintptr_t));
                    //开始遍历
                    for (int index = 0; index < goodsListCount; index++) {
                        if (index > 100) {
                            break;
                        }
                        //对象ID
                        int goodsListId = memoryTools.readInt(goodsListArray + 0x4 + index * PubgOffset::ObjectParam::GoodsListParam::DataBase);
                        MaterialStruct goods = isBoxMaterial(goodsListId);
                        if (goods.type == -1) {
                            continue;
                        }
                        memset(&materialData, 0, sizeof(materialData));
                        goodsListValidCount++;
                        //物资类型
                        materialData.type = goods.type;
                        //物资ID
                        materialData.id = goods.id;
                        //物资名字
                        materialData.name = goods.name;
                        //距离
                        materialData.distance = -100;
                        //屏幕坐标
                        materialData.screen.x = goodsListScreen.x;
                        materialData.screen.y = goodsListScreen.y - 32 * (goodsListValidCount);
                        materialDataList.push_back(materialData);
                    }
                }
            }
        }
    }
}

//自瞄 - DYLIB FIX #1: IMPROVED AIMBOT WITH MUTEX AND BOT DETECTION
void *silenceAimbot(void *) {
    ImVec2 screenSize = ImVec2([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    while (true) {
        usleep(10000); // DYLIB: 10ms loop (was 16.6ms)
        
        pthread_mutex_lock(&aimbot_mutex);
        
        if (moduleControl.systemStatus == TransmissionNormal && moduleControl.mainSwitch.aimbotStatus) {
            // DYLIB: Validate pointers first
            if (staticData.selfAddr == 0 || staticData.playerController == 0 || staticData.cameraManager == 0) {
                pthread_mutex_unlock(&aimbot_mutex);
                continue;
            }
            
            //武器指针 - WeaponManagerComponent üzerinden oku
            uintptr_t weaponMgrAddr = memoryTools.readPtr(staticData.selfAddr + PubgOffset::ObjectParam::WeaponManagerComponentOffset);
            uintptr_t weaponAddr = weaponMgrAddr ? memoryTools.readPtr(weaponMgrAddr + PubgOffset::ObjectParam::WeaponOneOffset) : 0;
            //自瞄开关
            bool enabledAimbot = false;
            //判断自瞄启动模式
            switch (moduleControl.aimbotController.aimbotMode) {
                case 0:
                    //开镜自瞄
                    enabledAimbot = (memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) & 0xFF) == 1;
                    break;
                case 1:
                    //开火自瞄
                    enabledAimbot = (memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) & 0xFF) == 1;
                    break;
                case 2:
                    //开镜开火自瞄
                    enabledAimbot = (memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) & 0xFF) == 1 || (memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) & 0xFF) == 1;
                    break;
                case 3:
                    //判断枪械是单发还是全自动
                    if (weaponAddr && memoryTools.readInt(weaponAddr + PubgOffset::ObjectParam::WeaponParam::ShootModeOffset) >= 1024) {
                        enabledAimbot = (memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) & 0xFF) == 1;
                    } else {
                        enabledAimbot = (memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) & 0xFF) == 1;
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
                // Ekran merkezi - döngü dışında hesapla
                ImVec2 screenCenter = ImVec2(screenSize.x / 2, screenSize.y / 2);
                //自瞄对象定义
                StaticPlayerData aimbotPlayerData;
                aimbotPlayerData.addr = 0;
                ImVec3 aimbotCoord = ImVec3(0,0,0);
                
                //循环人物对象列表 - DYLIB: Add data_mutex lock
                pthread_mutex_lock(&data_mutex);
                
                //循环人物对象列表
                for (auto staticPlayerData: staticData.playerDataList) {
                    // DYLIB FIX: Skip bots
                    if (isBotPlayer(staticPlayerData.addr)) {
                        continue;
                    }
                    
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
                    //判断是否倒地
                    if (memoryTools.readFloat(staticPlayerData.addr + PubgOffset::ObjectParam::HpOffset) < 0.5 && moduleControl.aimbotController.fallNotAim) {
                        continue;
                    }
                    //屏幕坐标
                    ImVec2 playerScreen = worldToScreen(objectCoord, pov, screenSize);
                    // Ekran dışındaysa atla
                    if (playerScreen.x <= 0 || playerScreen.y <= 0 ||
                        playerScreen.x >= screenSize.x || playerScreen.y >= screenSize.y) continue;
                    float screenDistance;
                    //判断自瞄对象是否在指定屏幕范围
                    if ((screenDistance = get2dDistance(screenCenter, playerScreen)) < aimbotRadius) {
                        //骨骼mesh - DYLIB: Use optimized bone reading
                        uintptr_t meshAddr  = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::MeshOffset);
                        // DYLIB: HumanBoneOffset = 0xC40
                        uintptr_t humanAddr = memoryTools.readPtr(meshAddr + 0xC40);
                        // DYLIB: BonesOffset = 0x988 (not 0xC30!)
                        uintptr_t boneAddr  = memoryTools.readPtr(meshAddr + 0x988);
                        if (!meshAddr || !humanAddr || !boneAddr) continue;
                        //取自瞄部位 0是优先头部,1是优先身体,3是[全自动武器打身体,单发连发打头],4是只打头,5是只打身体
                        switch (moduleControl.aimbotController.aimbotParts) {
                            case 0: {
                                //判断骨点是否可见
                                int boneIds[] = {9, 7, 0, 10, 11, 12, 14, 15, 16, 4, 5, 6, 8, 22, 23}; // DYLIB bone IDs
                                for (int boneId = 0; boneId < end(boneIds) - begin(boneIds); ++boneId) {
                                    //取骨点 - DYLIB: Use new function
                                    aimbotCoord = getBoneWorldPosition(humanAddr, boneAddr, boneIds[boneId]);
                                    //是否可见,可见则赋值给上面的变量
                                    if (isCoordVisibility(aimbotCoord)) {
                                        //自瞄对象数据
                                        aimbotPlayerData = staticPlayerData;
                                        //当前对象所在的屏幕范围
                                        aimbotRadius = screenDistance;
                                        //跳出循环
                                        break;
                                    } else {
                                        //对象坐标置0
                                        aimbotCoord = {0, 0, 0};
                                    }
                                }
                            }
                                //跳出switch
                                break;
                            case 1: {
                                int boneIds[] = {11, 7, 9, 0, 10, 12, 14, 15, 16, 4, 5, 6, 8, 22, 23};
                                for (int boneId = 0; boneId < end(boneIds) - begin(boneIds); ++boneId) {
                                    //取骨点
                                    aimbotCoord = getBoneWorldPosition(humanAddr, boneAddr, boneIds[boneId]);
                                    if (isCoordVisibility(aimbotCoord)) {
                                        aimbotPlayerData = staticPlayerData;
                                        aimbotRadius = screenDistance;
                                        break;
                                    }
                                }
                            }
                                break;
                            case 2: {
                                int boneIds[] = {9};
                                for (int boneId = 0; boneId < end(boneIds) - begin(boneIds); ++boneId) {
                                    aimbotCoord = getBoneWorldPosition(humanAddr, boneAddr, boneIds[boneId]);
                                    if (isCoordVisibility(aimbotCoord)) {
                                        aimbotPlayerData = staticPlayerData;
                                        aimbotRadius = screenDistance;
                                        break;
                                    }
                                }
                            }
                                break;
                            case 3: {
                                //坐标
                                aimbotCoord = getBoneWorldPosition(humanAddr, boneAddr, 9); // Head
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
                    //switch结束
                }
                
                pthread_mutex_unlock(&data_mutex);
                
                //判断是否有自瞄对象,有则开始自瞄
                if (aimbotPlayerData.addr != 0 && aimbotCoord.x != 0) {
                    //判断是否在烟雾内
                    if (moduleControl.aimbotController.smoke) {
                        if (isOnSmoke(aimbotCoord)) {
                            aimbotCoord = {0, 0, 0};
                        } else {
                            // DYLIB FIX #1: Use performAimInput instead of manual calculation
                            performAimInput(aimbotCoord);
                        }
                    } else {
                        performAimInput(aimbotCoord);
                    }
                }
            }
        }
        
        pthread_mutex_unlock(&aimbot_mutex);
    }
    return nullptr;
}