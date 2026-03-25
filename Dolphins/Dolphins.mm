//
//  Dolphins.m
//  Dolphins
//
//  Created by XBK on 2022/4/24.
//  Updated with AIO Dumper integration
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
#include "Offsets.hpp"

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

//掩体判断函数原型
bool (*LineOfSightTo)(void *controller, void *actor, ImVec3 bone_point, bool ischeck);

//移动X轴
void (*AddControllerYawInput)(void *actot, float val);

//移动Y轴
void (*AddControllerRollInput)(void *actot, float val);

//旋转
void (*AddControllerPitchInput)(void *actot, float val);

// ========== GWorld ve GNames (AIO Dumper ile güncellendi) ==========
long gWorld() {
    // UEngine->GameViewport->World
    uintptr_t engine = memoryTools.readPtr((uintptr_t)_dyld_get_image_vmaddr_slide(0) + UEPointers::Engine);
    if (engine == 0) return 0;
    uintptr_t gameViewport = memoryTools.readPtr(engine + 0x870); // UGameViewportClient*
    if (gameViewport == 0) return 0;
    return memoryTools.readPtr(gameViewport + 0x38); // World
}

long gName() {
    // FNamePool adresi
    return (uintptr_t)_dyld_get_image_vmaddr_slide(0) + UEPointers::Names;
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

// ========== DAN BOT TESPIT SISTEMI (AIO Dumper offset'leri ile) ==========
bool DAN_IsBot(uintptr_t actor) {
    if (actor == 0) return true;
    
    // 1. Yöntem: bIsAI (0xA40)
    uint8_t isAI = 0;
    memoryTools.readMemory(actor + PubgOffset::ASTExtraPlayerCharacter_bIsAI, 1, &isAI);
    if (isAI & 1) return true;
    
    // 2. Yöntem: kbIsMLAI (0xA41)
    uint8_t isMLAI = 0;
    memoryTools.readMemory(actor + PubgOffset::ASTExtraPlayerCharacter_bIsMLAI, 1, &isMLAI);
    if (isMLAI & 1) return true;
    
    // 3. Yöntem: UID (0x988) – botlarda genelde 0
    uint64_t uid = 0;
    memoryTools.readMemory(actor + 0x988, sizeof(uint64_t), &uid);
    if (uid == 0) return true;
    
    return false;
}
// ========== DAN BOT TESPIT SONU ==========

// ========== Class Name Alma (AIO Dumper GNames ile) ==========
char* getClassName(int classId) {
    static char buf[256];
    memset(buf, 0, sizeof(buf));
    
    if (classId <= 0 || classId > 2000000) {
        return (char*)"Unknown";
    }
    
    uintptr_t fnamePool = staticData.gnameAddr;
    if (fnamePool == 0) return (char*)"Unknown";
    
    int32_t block = classId / 16384;
    int32_t offset = classId % 16384;
    
    uintptr_t blockAddr = memoryTools.readPtr(fnamePool + (block * 8));
    if (blockAddr == 0) return (char*)"Unknown";
    
    uintptr_t nameEntry = blockAddr + (offset * 2); // FNameEntry size
    
    // İsim uzunluğu (header: 2 byte length)
    uint16_t nameLen = memoryTools.read<uint16_t>(nameEntry);
    if (nameLen > 255) nameLen = 255;
    
    // İsim okuma (UTF-16)
    char16_t wbuf[256] = {0};
    memoryTools.readMemory(nameEntry + 2, nameLen * 2, wbuf);
    
    // UTF-16 -> UTF-8 dönüşümü (basit ASCII için)
    for (int i = 0; i < nameLen && i < 255; i++) {
        buf[i] = (char)(wbuf[i] & 0xFF);
    }
    buf[nameLen] = 0;
    
    return buf;
}

// ========== Player Name Alma ==========
char* getPlayerName(uintptr_t addr) {
    static char buf[64];
    memset(buf, 0, sizeof(buf));
    
    if (addr == 0) return (char*)"Unknown";
    
    // FString yapısı: [DataPtr][Length][MaxLength]
    uintptr_t namePtr = memoryTools.readPtr(addr);
    int32_t nameLen = memoryTools.readInt(addr + 0x8);
    
    if (namePtr == 0 || nameLen <= 0 || nameLen > 63) {
        return (char*)"Unknown";
    }
    
    memoryTools.readMemory(namePtr, nameLen, buf);
    buf[nameLen] = 0;
    
    return buf;
}

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

// ========== STATIC DATA THREAD (AIO Dumper ile güncellendi) ==========
void *readStaticData(void *) {
    while (true) {
        sleep(4);
        
        if(moduleControl.systemStatus != TransmissionNormal){
            staticData.libAddr = (uintptr_t)_dyld_get_image_vmaddr_slide(0);
            if(staticData.libAddr != 1){
                moduleControl.systemStatus = TransmissionNormal;
            }
        } else if (moduleControl.systemStatus == TransmissionNormal) {
            staticData.gwlordAddr = gWorld();
            staticData.gnameAddr = gName();
            
            if (staticData.gwlordAddr == 0 || staticData.gnameAddr == 0) {
                continue;
            }
            
            // UWorld->PersistentLevel
            uintptr_t uLevel = memoryTools.readPtr(staticData.gwlordAddr + PubgOffset::UWorld_PersistentLevel);
            if (uLevel == 0) continue;
            
            // ULevel->Actors
            uintptr_t actorsArray = memoryTools.readPtr(uLevel + PubgOffset::ULevel_Actors);
            int actorCount = memoryTools.readInt(uLevel + PubgOffset::ULevel_ActorsCount);
            
            if (actorsArray == 0 || actorCount <= 0) continue;
            
            // Player Controller
            uintptr_t gameInstance = memoryTools.readPtr(staticData.gwlordAddr + PubgOffset::UWorld_OwningGameInstance);
            if (gameInstance != 0) {
                uintptr_t localPlayer = memoryTools.readPtr(gameInstance + 0x38); // UGameInstance::LocalPlayers
                if (localPlayer != 0) {
                    uintptr_t playerController = memoryTools.readPtr(localPlayer + 0x30); // ULocalPlayer::PlayerController
                    if (playerController != 0) {
                        staticData.playerController = playerController;
                        staticData.selfAddr = memoryTools.readPtr(staticData.playerController + PubgOffset::PlayerController_SelfOffset);
                        staticData.cameraManager = memoryTools.readPtr(staticData.playerController + PubgOffset::APlayerController_PlayerCameraManager);
                        
                        // Function pointers
                        uintptr_t selfVtable = memoryTools.readPtr(staticData.selfAddr);
                        if (selfVtable != 0) {
                            AddControllerYawInput = (void (*)(void *, float)) (memoryTools.readPtr(selfVtable + PubgOffset::PlayerControllerFunction::AddControllerYawInput));
                            AddControllerRollInput = (void (*)(void *, float)) (memoryTools.readPtr(selfVtable + PubgOffset::PlayerControllerFunction::AddControllerRollInput));
                            AddControllerPitchInput = (void (*)(void *, float)) (memoryTools.readPtr(selfVtable + PubgOffset::PlayerControllerFunction::AddControllerPitchInput));
                        }
                        
                        uintptr_t controllerVtable = memoryTools.readPtr(staticData.playerController);
                        if (controllerVtable != 0) {
                            LineOfSightTo = (bool (*)(void *, void *, ImVec3, bool)) (memoryTools.readPtr(controllerVtable + PubgOffset::PlayerControllerFunction::LineOfSightTo));
                        }
                    }
                }
            }
            
            if (staticData.selfAddr == 0) continue;
            
            int selfTeamID = memoryTools.readInt(staticData.selfAddr + PubgOffset::ASTExtraPlayerCharacter_TeamID);
            
            vector<StaticPlayerData> tmpPlayerDataList;
            vector<StaticMaterialData> tmpMaterialDataList;
            vector<StaticMaterialData> tmpSmokeList;
            
            // Actor döngüsü
            for (int index = 0; index < actorCount; ++index) {
                uintptr_t objectAddr = memoryTools.readPtr(actorsArray + index * 8);
                if (objectAddr <= 0x100000000 || objectAddr >= 0x2000000000 || objectAddr % 8 != 0) {
                    continue;
                }
                
                uintptr_t vtable = memoryTools.readPtr(objectAddr);
                if (vtable == 0) continue;
                
                uintptr_t uclass = memoryTools.readPtr(vtable + 0x8);
                if (uclass == 0) continue;
                
                int classId = memoryTools.readInt(uclass + PubgOffset::UObjectOffsets::NamePrivate);
                string className = getClassName(classId);
                
                // Root Component ve koordinat
                uintptr_t rootComponent = memoryTools.readPtr(objectAddr + PubgOffset::AActor_RootComponent);
                uintptr_t coordAddr = 0;
                if (rootComponent != 0) {
                    coordAddr = rootComponent + PubgOffset::USceneComponent_RelativeLocation;
                }
                
                // Player kontrolü
                bool isPlayer = (className.find("PlayerCharacter") != string::npos ||
                                 className.find("PlayerPawn") != string::npos ||
                                 className.find("STExtraPlayerCharacter") != string::npos);
                
                if (isPlayer && moduleControl.mainSwitch.playerStatus) {
                    // Kendini atla
                    if (objectAddr == staticData.selfAddr) continue;
                    
                    int team = memoryTools.readInt(objectAddr + PubgOffset::ASTExtraPlayerCharacter_TeamID);
                    if (team == selfTeamID) continue;
                    
                    bool isDead = memoryTools.readBool(objectAddr + PubgOffset::ASTExtraPlayerCharacter_DeadOffset);
                    if (isDead) continue;
                    
                    // Bot kontrolü
                    bool isBot = DAN_IsBot(objectAddr);
                    if (moduleControl.playerSwitch.ignorebot && isBot) continue;
                    
                    StaticPlayerData tmpPlayerData;
                    tmpPlayerData.addr = objectAddr;
                    tmpPlayerData.coordAddr = coordAddr;
                    tmpPlayerData.team = team;
                    tmpPlayerData.robot = isBot ? 1 : 0;
                    tmpPlayerData.name = getPlayerName(memoryTools.readPtr(objectAddr + PubgOffset::ASTExtraPlayerCharacter_PlayerName));
                    tmpPlayerData.status = memoryTools.readInt(objectAddr + PubgOffset::ASTExtraPlayerCharacter_Status);
                    
                    tmpPlayerDataList.push_back(tmpPlayerData);
                    
                } else if (className.find("ProjSmoke") != string::npos) {
                    StaticMaterialData tmpMaterialData;
                    tmpMaterialData.type = PubgOffset::Warning;
                    tmpMaterialData.id = 4;
                    tmpMaterialData.name = "[WARNING]SMOKE";
                    tmpMaterialData.addr = objectAddr;
                    tmpMaterialData.coordAddr = coordAddr;
                    tmpSmokeList.push_back(tmpMaterialData);
                }
            }
            
            staticData.playerDataList.swap(tmpPlayerDataList);
            staticData.materialDataList.swap(tmpMaterialDataList);
            staticData.smokeList.swap(tmpSmokeList);
        }
    }
    return nullptr;
}

// ========== READ FRAME DATA ==========
void readFrameData(ImVec2 screenSize, vector<PlayerData> &playerDataList, vector<MaterialData> &materialDataList) {
    playerDataList.clear();
    materialDataList.clear();
    
    if (moduleControl.systemStatus != TransmissionNormal) return;
    
    // Camera POV
    MinimalViewInfo pov;
    memoryTools.readMemory(staticData.cameraManager + PubgOffset::APlayerCameraManager_CameraCachePrivate + PubgOffset::FCameraCacheEntry_POV, sizeof(pov), &pov);
    
    ImVec3 selfCoord = pov.location;
    float lateralAngleView = memoryTools.readFloat(staticData.playerController + PubgOffset::PlayerController_MouseOffset + 0x4) - 90;
    
    // Player ESP
    if (moduleControl.mainSwitch.playerStatus) {
        for (auto staticPlayerData : staticData.playerDataList) {
            if (staticPlayerData.addr == staticData.selfAddr) continue;
            
            if (staticPlayerData.coordAddr == 0) continue;
            
            ImVec3 objectCoord = memoryTools.read<ImVec3>(staticPlayerData.coordAddr + PubgOffset::CoordOffset_Coord);
            float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
            
            if (objectDistance < 0 || objectDistance > 450) continue;
            
            float objectHeight = memoryTools.readFloat(staticPlayerData.coordAddr + PubgOffset::CoordOffset_Height);
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
            
            // Height adjustment
            if (objectHeight < 50) {
                objectHeight -= 18;
            } else if (objectHeight > 80) {
                objectHeight += 12;
            }
            
            playerData.team = staticPlayerData.team;
            playerData.hp = memoryTools.readFloat(staticPlayerData.addr + PubgOffset::ASTExtraPlayerCharacter_Health);
            if (playerData.hp > 100) playerData.hp = 100;
            
            // Status
            uintptr_t statusAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ASTExtraPlayerCharacter_Status);
            // Status string assignments (orijinal kodda olduğu gibi)
            playerData.statusName = getStatusName(statusAddr);
            
            // Weapon
            uintptr_t weaponAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ASTExtraPlayerCharacter_CurrentWeapon);
            if (weaponAddr == 0) {
                playerData.weaponName = "FIST";
            } else {
                string weaponClassName = getClassName(memoryTools.readInt(weaponAddr + PubgOffset::UObjectOffsets::NamePrivate));
                playerData.weaponName = weaponClassName;
            }
            
            playerData.name = staticPlayerData.name;
            playerData.screen = worldToScreen(objectCoord, pov, screenSize);
            
            ImVec2 width = worldToScreen(ImVec3(objectCoord.x, objectCoord.y, objectCoord.z + 100), pov, screenSize);
            ImVec2 height = worldToScreen(ImVec3(objectCoord.x, objectCoord.y, objectCoord.z + objectHeight), pov, screenSize);
            playerData.size.x = (playerData.screen.y - width.y) / 2;
            playerData.size.y = playerData.screen.y - height.y;
            
            // Bones
            uintptr_t meshAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ASTExtraPlayerCharacter_Mesh);
            if (meshAddr != 0) {
                uintptr_t boneAddr = memoryTools.readPtr(meshAddr + PubgOffset::USkeletalMeshComponent_CachedBoneSpaceTransforms);
                if (boneAddr != 0) {
                    BonesData bonesData;
                    if (getBone2d(pov, screenSize, meshAddr, boneAddr, PubgOffset::Bone_Head, bonesData.head))
                        if (getBone2d(pov, screenSize, meshAddr, boneAddr, PubgOffset::Bone_Spine1, bonesData.pit))
                            if (getBone2d(pov, screenSize, meshAddr, boneAddr, PubgOffset::Bone_Pelvis, bonesData.pelvis))
                                playerData.bonesData = bonesData;
                }
            }
            
            playerDataList.push_back(playerData);
        }
    }
}

// ========== SILENCE AIMBOT ==========
void *silenceAimbot(void *) {
    ImVec2 screenSize = ImVec2([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    while (true) {
        usleep(16666);
        
        if (moduleControl.systemStatus == TransmissionNormal && moduleControl.mainSwitch.aimbotStatus) {
            uintptr_t weaponAddr = memoryTools.readPtr(staticData.selfAddr + PubgOffset::ASTExtraPlayerCharacter_CurrentWeapon);
            
            bool enabledAimbot = false;
            switch (moduleControl.aimbotController.aimbotMode) {
                case 0:
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ASTExtraPlayerCharacter_OpenTheSightOffset) == 257 || 
                                    memoryTools.readInt(staticData.selfAddr + PubgOffset::ASTExtraPlayerCharacter_OpenTheSightOffset) == 1;
                    break;
                case 1:
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ASTExtraPlayerCharacter_OpenFireOffset) == 1;
                    break;
                case 2:
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ASTExtraPlayerCharacter_OpenTheSightOffset) == 257 || 
                                    memoryTools.readInt(staticData.selfAddr + PubgOffset::ASTExtraPlayerCharacter_OpenTheSightOffset) == 1 || 
                                    memoryTools.readInt(staticData.selfAddr + PubgOffset::ASTExtraPlayerCharacter_OpenFireOffset) == 1;
                    break;
                case 3:
                    if (weaponAddr != 0) {
                        int shootMode = memoryTools.readInt(weaponAddr + PubgOffset::ASTExtraWeapon_ShootMode);
                        if (shootMode >= 1024) {
                            enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ASTExtraPlayerCharacter_OpenFireOffset) == 1;
                        } else {
                            enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ASTExtraPlayerCharacter_OpenTheSightOffset) == 257 || 
                                            memoryTools.readInt(staticData.selfAddr + PubgOffset::ASTExtraPlayerCharacter_OpenTheSightOffset) == 1;
                        }
                    }
                    break;
            }
            
            if (enabledAimbot) {
                MinimalViewInfo pov;
                memoryTools.readMemory(staticData.cameraManager + PubgOffset::APlayerCameraManager_CameraCachePrivate + PubgOffset::FCameraCacheEntry_POV, sizeof(pov), &pov);
                ImVec3 selfCoord = pov.location;
                
                float aimbotRadius = moduleControl.aimbotController.aimbotRadius;
                StaticPlayerData aimbotPlayerData = {0};
                ImVec3 aimbotCoord = {0, 0, 0};
                
                for (auto staticPlayerData : staticData.playerDataList) {
                    if (staticPlayerData.addr == staticData.selfAddr) continue;
                    if (moduleControl.playerSwitch.ignorebot && staticPlayerData.robot == 1) continue;
                    
                    if (staticPlayerData.coordAddr == 0) continue;
                    
                    ImVec3 objectCoord = memoryTools.read<ImVec3>(staticPlayerData.coordAddr + PubgOffset::CoordOffset_Coord);
                    float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
                    
                    if (objectDistance < 0 || objectDistance > 450 || objectDistance > moduleControl.aimbotController.distance) continue;
                    
                    float objectHeight = memoryTools.readFloat(staticPlayerData.coordAddr + PubgOffset::CoordOffset_Height);
                    if (objectHeight < 20) continue;
                    
                    float hp = memoryTools.readFloat(staticPlayerData.addr + PubgOffset::ASTExtraPlayerCharacter_Health);
                    if (hp < 0.5 && moduleControl.aimbotController.fallNotAim) continue;
                    
                    ImVec2 playerScreen = worldToScreen(objectCoord, pov, screenSize);
                    float screenDistance = get2dDistance(screenSize, playerScreen);
                    
                    if (screenDistance < aimbotRadius) {
                        uintptr_t meshAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ASTExtraPlayerCharacter_Mesh);
                        if (meshAddr != 0) {
                            uintptr_t boneAddr = memoryTools.readPtr(meshAddr + PubgOffset::USkeletalMeshComponent_CachedBoneSpaceTransforms);
                            if (boneAddr != 0) {
                                // Head bone
                                aimbotCoord = getBone(meshAddr, boneAddr, PubgOffset::Bone_Head);
                                if (isCoordVisibility(aimbotCoord)) {
                                    aimbotPlayerData = staticPlayerData;
                                    aimbotRadius = screenDistance;
                                } else {
                                    // Chest bone
                                    aimbotCoord = getBone(meshAddr, boneAddr, PubgOffset::Bone_Spine1);
                                    if (isCoordVisibility(aimbotCoord)) {
                                        aimbotPlayerData = staticPlayerData;
                                        aimbotRadius = screenDistance;
                                    }
                                }
                            }
                        }
                    }
                }
                
                if (aimbotPlayerData.addr != 0 && aimbotCoord.x != 0 && aimbotCoord.y != 0 && aimbotCoord.z != 0) {
                    if (moduleControl.aimbotController.smoke && isOnSmoke(aimbotCoord)) {
                        continue;
                    }
                    
                    // Prefire prediction
                    uintptr_t weaponAttrAddr = memoryTools.readPtr(weaponAddr + PubgOffset::ASTExtraWeapon_WeaponAttr);
                    if (weaponAttrAddr != 0) {
                        float bulletSpeed = memoryTools.readFloat(weaponAttrAddr + PubgOffset::UWeaponAttribute_BulletSpeed);
                        float bulletFlyTime = get3dDistance(selfCoord, aimbotCoord, bulletSpeed) * 1.2;
                        
                        ImVec3 moveCoord = memoryTools.read<ImVec3>(aimbotPlayerData.addr + PubgOffset::ASTExtraPlayerCharacter_MoveCoord);
                        aimbotCoord.x += moveCoord.x * bulletFlyTime;
                        aimbotCoord.y += moveCoord.y * bulletFlyTime;
                        aimbotCoord.z += moveCoord.z * bulletFlyTime;
                    }
                    
                    ImVec2 aimbotMouse = rotateAngleView(selfCoord, aimbotCoord);
                    float selfStatus = memoryTools.readFloat(memoryTools.readPtr(staticData.selfAddr + PubgOffset::AActor_RootComponent) + PubgOffset::USceneComponent_RelativeLocation + PubgOffset::CoordOffset_Height);
                    
                    // Recoil control
                    if (memoryTools.readInt(staticData.selfAddr + PubgOffset::ASTExtraPlayerCharacter_OpenFireOffset) == 1 && weaponAttrAddr != 0) {
                        float recoilTimes = 4.5 - get3dDistance(selfCoord, aimbotCoord, 10000);
                        recoilTimes += get3dDistance(selfCoord, aimbotCoord, 10000) * 0.2;
                        float recoil = memoryTools.readFloat(weaponAttrAddr + PubgOffset::UWeaponAttribute_Recoil);
                        
                        if (selfStatus < 50.0f) {
                            recoil *= 0.35;
                        }
                        aimbotMouse.y -= recoilTimes * recoil;
                    }
                    
                    if (!isfinite(aimbotMouse.x) || !isfinite(aimbotMouse.y)) continue;
                    
                    ImVec2 aimbotMouseMove;
                    aimbotMouseMove.x = change(getAngleDifference(aimbotMouse.x, memoryTools.readFloat(staticData.playerController + PubgOffset::PlayerController_MouseOffset + 0x4)) * moduleControl.aimbotController.aimbotIntensity);
                    aimbotMouseMove.y = change(getAngleDifference(aimbotMouse.y, memoryTools.readFloat(staticData.playerController + PubgOffset::PlayerController_MouseOffset)) * moduleControl.aimbotController.aimbotIntensity);
                    
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

// ========== HELPER FUNCTIONS ==========
bool isCoordVisibility(ImVec3 coord) {
    if (LineOfSightTo == nullptr || !isfinite(coord.x) || !isfinite(coord.y) || !isfinite(coord.z)) {
        return false;
    }
    return LineOfSightTo(reinterpret_cast<void *>(staticData.playerController), 
                         reinterpret_cast<void *>(staticData.cameraManager), coord, false);
}

bool isOnSmoke(ImVec3 coord) {
    for (StaticMaterialData smoke : staticData.smokeList) {
        if (smoke.coordAddr == 0) continue;
        ImVec3 smokeCoord = memoryTools.read<ImVec3>(smoke.coordAddr + PubgOffset::CoordOffset_Coord);
        if (get3dDistance(smokeCoord, coord, 100) < 4) {
            return true;
        }
    }
    return false;
}

string getStatusName(uintptr_t statusAddr) {
    // Orijinal status mapping
    if (statusAddr == 2097168) return "DRIVE";
    if (statusAddr == 262208) return "HEALING";
    if (statusAddr == 33554449) return "FLYING ON PARACHUTE";
    if (statusAddr == 262160 || statusAddr == 16) return "STAND";
    if (statusAddr == 524288 || statusAddr == 524289) return "KNOCKED";
    if (statusAddr == 147 || statusAddr == 144) return "JUMP";
    if (statusAddr == 529) return "WALK & RELOADING";
    if (statusAddr == 35 || statusAddr == 32) return "CROUCHING";
    if (statusAddr == 8205 || statusAddr == 272 || statusAddr == 273) return "SHOOTING";
    if (statusAddr == 64) return "PRONE";
    if (statusAddr == 528 || statusAddr == 544 || statusAddr == 576) return "RELOADING";
    if (statusAddr == 1040 || statusAddr == 1056 || statusAddr == 1088) return "AIMING";
    if (statusAddr == 4112 || statusAddr == 4128) return "LEAN";
    if (statusAddr == 6552 || statusAddr == 65568 || statusAddr == 65600) return "GRENADE";
    if (statusAddr == 16777219) return "SWIMMING";
    if (statusAddr == 67108880) return "VAULTING";
    if (statusAddr == 4194320) return "RIDING";
    return "MOVING";
}

// ========== BONE FUNCTIONS ==========
ImVec3 getBone(uintptr_t mesh, uintptr_t boneTransforms, int boneIndex) {
    ImVec3 result = {0, 0, 0};
    
    if (mesh == 0 || boneTransforms == 0) return result;
    
    // FTransform yapısı (48 bytes)
    uintptr_t boneTransform = boneTransforms + (boneIndex * 48);
    
    // Translation (FVector) at offset 0x10 in FTransform
    result = memoryTools.read<ImVec3>(boneTransform + 0x10);
    
    // Component to World transform
    uintptr_t componentToWorld = mesh + PubgOffset::USkeletalMeshComponent_ComponentToWorld;
    ImVec3 worldLocation = memoryTools.read<ImVec3>(componentToWorld + 0x10);
    
    result.x += worldLocation.x;
    result.y += worldLocation.y;
    result.z += worldLocation.z;
    
    return result;
}

bool getBone2d(MinimalViewInfo pov, ImVec2 screen, uintptr_t mesh, uintptr_t boneTransforms, int boneIndex, ImVec2 &buf) {
    ImVec3 worldPos = getBone(mesh, boneTransforms, boneIndex);
    buf = worldToScreen(worldPos, pov, screen);
    return buf.x != 0 && buf.y != 0;
}