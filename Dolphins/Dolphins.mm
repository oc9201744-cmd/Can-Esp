//
//  Dolphins.m (Non-Jailbreak Version - Base 0)
//  PUBG Mobile 4.3 iOS
//

#import "Dolphins/crossoffsets.h"
#import <Foundation/Foundation.h>
#import "Dolphins/View/FloatView.h"
#import "Dolphins/View/OverlayView.h"
#include "Dolphins/dolphins.h"
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
using namespace PubgOffset;

// Module controllers
ModuleControl moduleControl;
MemoryTools memoryTools;

// ============ NON-JAILBREAK BASE ============
// Base address = 0 (non-jailbreak için)
#define BASE_ADDR 0

// ============ OFFSET YAPILARI ============
typedef struct {
    uintptr_t gWorldFun;
    uintptr_t gWorldData;
    uintptr_t gNameFun;
    uintptr_t gNameData;
} OffsetValues;

// 4.3 Global Offsets (Base 0 ile kullanılır)
OffsetValues offsets[] = {
    { 
        GlobalOffsets::gworld_func,    // 0x102A62208
        GlobalOffsets::gworld_data,    // 0x10A566E00
        GlobalOffsets::gname_func,     // 0x104bd8740
        GlobalOffsets::gname_data      // 0x10a1178b0
    }
};

// ============ FONKSIYON POINTERLARI ============
bool (*LineOfSightTo)(void *controller, void *actor, ImVec3 bone_point, bool ischeck);
void (*AddControllerYawInput)(void *actor, float val);
void (*AddControllerRollInput)(void *actor, float val);
void (*AddControllerPitchInput)(void *actor, float val);

// ============ GLOBAL FONKSIYONLAR (NON-JAILBREAK) ============
// Base = 0 olduğu için direkt adresleri kullan
long gWorld() {
    OffsetValues offsetsForBundle = offsets[0];
    // Non-jailbreak: Direkt adres, slide yok
    uintptr_t funcAddr = offsetsForBundle.gWorldFun;
    uintptr_t dataAddr = offsetsForBundle.gWorldData;
    
    return reinterpret_cast<long(__fastcall*)(long)>(funcAddr)(dataAddr);
}

long gName() {
    OffsetValues offsetsForBundle = offsets[0];
    uintptr_t funcAddr = offsetsForBundle.gNameFun;
    uintptr_t dataAddr = offsetsForBundle.gNameData;
    
    return reinterpret_cast<long(__fastcall*)(long)>(funcAddr)(dataAddr);
}

// ============ STATIK DATA YAPISI ============
struct {
    uintptr_t libAddr = 0;
    uintptr_t gwlordAddr = 0;
    uintptr_t gnameAddr = 0;
    uintptr_t playerController = 0;
    string playerControllerClassName;
    uintptr_t cameraManager = 0;
    string cameraManagerClassName;
    uintptr_t selfAddr = 0;
    vector<StaticPlayerData> playerDataList;
    vector<StaticMaterialData> materialDataList;
    vector<StaticMaterialData> smokeList;
} staticData;

// ============ UI BASLATMA ============
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

// ============ KUTUPHANE GIRISI ============
__attribute__((constructor)) static void initialize() {
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching, 
        (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorDrop);
    
    pthread_t staticDataThread;
    pthread_create(&staticDataThread, nullptr, readStaticData, nullptr);
    
    pthread_t silenceAimbotThread;
    pthread_create(&silenceAimbotThread, nullptr, silenceAimbot, nullptr);
}

// ============ STATIK DATA OKUMA ============
void *readStaticData(void *) {
    while (true) {
        sleep(4);
        
        if(moduleControl.systemStatus != TransmissionNormal) {
            // Non-jailbreak: Base adres kontrolü farklı
            staticData.libAddr = BASE_ADDR;
            moduleControl.systemStatus = TransmissionNormal;
        } else if (moduleControl.systemStatus == TransmissionNormal) {
            staticData.gwlordAddr = gWorld();
            staticData.gnameAddr = gName();
            
            // Player Controller
            staticData.playerController = memoryTools.readPtr(
                memoryTools.readPtr(
                    memoryTools.readPtr(staticData.gwlordAddr + PlayerControllerOffset::offsets[0]) 
                    + PlayerControllerOffset::offsets[1]
                ) + PlayerControllerOffset::offsets[2]
            );
            
            // LineOfSightTo
            LineOfSightTo = (bool (*)(void *, void *, ImVec3, bool))(
                memoryTools.readPtr(
                    memoryTools.readPtr(staticData.playerController + 0x0) 
                    + PlayerControllerParam::ControllerFunction::LineOfSightToOffset
                )
            );
            
            // Self/Pawn
            staticData.selfAddr = memoryTools.readPtr(
                staticData.playerController + PlayerControllerParam::SelfOffset
            );
            
            // Input fonksiyonlari
            uintptr_t selfFunction = memoryTools.readPtr(staticData.selfAddr + 0);
            AddControllerYawInput = (void (*)(void *, float))(
                memoryTools.readPtr(selfFunction + ObjectParam::PlayerFunction::AddControllerYawInputOffset)
            );
            AddControllerRollInput = (void (*)(void *, float))(
                memoryTools.readPtr(selfFunction + ObjectParam::PlayerFunction::AddControllerRollInputOffset)
            );
            AddControllerPitchInput = (void (*)(void *, float))(
                memoryTools.readPtr(selfFunction + ObjectParam::PlayerFunction::AddControllerPitchInputOffset)
            );
            
            // Camera Manager
            staticData.cameraManager = memoryTools.readPtr(
                staticData.playerController + PlayerControllerParam::CameraManagerOffset
            );
            
            // Listeleri temizle
            vector<StaticPlayerData> tmpPlayerDataList;
            vector<StaticMaterialData> tmpMaterialDataList;
            vector<StaticMaterialData> tmpSmokeList;
            
            // ULevel ve objeleri oku
            uintptr_t uLevel = memoryTools.readPtr(staticData.gwlordAddr + ULevelOffset);
            uintptr_t obectArray = memoryTools.readPtr(uLevel + ULevelParam::ObjectArrayOffset);
            int objectCount = memoryTools.readInt(uLevel + ULevelParam::ObjectCountOffset);
            
            for (int index = 0; index < objectCount; ++index) {
                uintptr_t objectAddr = memoryTools.readPtr(obectArray + index * 8);
                if (objectAddr <= 0x100000000 || objectAddr >= 0x2000000000 || objectAddr % 8 != 0) {
                    continue;
                }
                
                uintptr_t coordAddr = memoryTools.readPtr(objectAddr + ObjectParam::CoordOffset);
                string className = getClassName(memoryTools.readInt(objectAddr + ObjectParam::ClassIdOffset));
                
                // PLAYER TESPITI
                if (strstr(className.c_str(), "PlayerPawn") || 
                    strstr(className.c_str(), "PlayerCharacter") ||
                    strstr(className.c_str(), "PlayerControllertSl") ||
                    strstr(className.c_str(), "_PlayerPawn_TPlanAI_C") ||
                    strstr(className.c_str(), "CharacterModelTaget") ||
                    strstr(className.c_str(), "FakePlayer_AIPawn")) {
                    
                    // TAKIM KONTROLU
                    int team = memoryTools.readInt(objectAddr + ObjectParam::TeamOffset);
                    int selfTeam = memoryTools.readInt(staticData.selfAddr + ObjectParam::TeamOffset);
                    if (team == selfTeam) continue;
                    
                    // OLUM KONTROLU
                    bool bDead = memoryTools.readByte(objectAddr + ObjectParam::DeadOffset);
                    if(bDead) continue;
                    
                    StaticPlayerData tmpPlayerData;
                    tmpPlayerData.addr = objectAddr;
                    tmpPlayerData.coordAddr = coordAddr;
                    tmpPlayerData.team = team;
                    tmpPlayerData.name = getPlayerName(memoryTools.readPtr(objectAddr + ObjectParam::NameOffset));
                    
                    // BOT/AI KONTROLU (0xa40 ve 0xa41)
                    bool isAI = memoryTools.readByte(objectAddr + ObjectParam::RobotOffset);
                    bool isMLAI = memoryTools.readByte(objectAddr + ObjectParam::MLAIOffset);
                    tmpPlayerData.robot = (isAI || isMLAI) ? 1 : 0;
                    
                    // HP (0xe60)
                    tmpPlayerData.hp = memoryTools.readFloat(objectAddr + ObjectParam::HpOffset);
                    
                    // STATUS (0x1058)
                    tmpPlayerData.status = memoryTools.readInt(objectAddr + ObjectParam::StatusOffset);
                    
                    tmpPlayerDataList.push_back(tmpPlayerData);
                }
                // DUMAN TESPITI
                else if (strstr(className.c_str(), "ProjSmoke_BP_C") != 0) {
                    StaticMaterialData tmpMaterialData;
                    tmpMaterialData.type = Warning;
                    tmpMaterialData.id = 4;
                    tmpMaterialData.name = "[WARNING]SMOKE";
                    tmpMaterialData.addr = objectAddr;
                    tmpMaterialData.coordAddr = coordAddr;
                    tmpSmokeList.push_back(tmpMaterialData);
                }
                // ITEM TESPITI
                else if (moduleControl.mainSwitch.materialStatus) {
                    MaterialStruct material = isMaterial(className.c_str());
                    if (material.type > -1) {
                        StaticMaterialData tmpMaterialData;
                        tmpMaterialData.type = material.type;
                        tmpMaterialData.id = material.id;
                        tmpMaterialData.name = material.name;
                        tmpMaterialData.addr = objectAddr;
                        tmpMaterialData.coordAddr = coordAddr;
                        
                        if ((material.type == Rifle || material.type == Sniper || material.type == Missile) && 
                            memoryTools.readPtr(objectAddr + ObjectParam::WeaponParam::MasterOffset) != 0) {
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

// ============ FRAME DATA OKUMA (ESP) ============
void readFrameData(ImVec2 screenSize, vector<PlayerData> &playerDataList, vector<MaterialData> &materialDataList) {
    playerDataList.clear();
    materialDataList.clear();
    
    if (moduleControl.systemStatus != TransmissionNormal) return;
    
    staticData.cameraManagerClassName = getClassName(
        memoryTools.readInt(staticData.cameraManager + ObjectParam::ClassIdOffset)
    );
    staticData.playerControllerClassName = getClassName(
        memoryTools.readInt(staticData.playerController + ObjectParam::ClassIdOffset)
    );
    
    // POV oku (0x10a0)
    MinimalViewInfo pov;
    memoryTools.readMemory(
        staticData.cameraManager + PlayerControllerParam::CameraManagerParam::PovOffset, 
        sizeof(pov), 
        &pov
    );
    
    ImVec3 selfCoord = pov.location;
    float lateralAngleView = memoryTools.readFloat(
        staticData.playerController + PlayerControllerParam::MouseOffset + 0x4
    ) - 90;
    
    // PLAYER ESP
    if (moduleControl.mainSwitch.playerStatus) {
        for (auto staticPlayerData : staticData.playerDataList) {
            
            // KOORDINAT (0x1c8)
            ImVec3 objectCoord;
            memoryTools.readMemory(
                staticPlayerData.coordAddr + ObjectParam::CoordParam::CoordOffset, 
                sizeof(ImVec3), 
                &objectCoord
            );
            
            float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
            if (objectDistance < 0 || objectDistance > 450) continue;
            
            // YUKSEKLIK (0x1c8)
            float objectHeight = memoryTools.readFloat(
                staticPlayerData.coordAddr + ObjectParam::CoordParam::HeightOffset
            );
            if (objectHeight < 20) continue;
            
            PlayerData playerData;
            playerData.angle = lateralAngleView - rotateAngle(selfCoord, objectCoord) - 180;
            playerData.radar = rotateCoord(lateralAngleView, ImVec2(
                (selfCoord.x - objectCoord.x) / 200, 
                (selfCoord.y - objectCoord.y) / 200
            ));
            playerData.distance = objectDistance;
            playerData.robot = staticPlayerData.robot;
            
            // GORUNURLUK KONTROLU
            playerData.visibility = isCoordVisibility(objectCoord);
            if (playerData.visibility && isOnSmoke(objectCoord)) {
                playerData.visibility = false;
            }
            
            // YUKSEKLIK AYARI
            if (objectHeight < 50) {
                objectHeight -= 18;
            } else if (objectHeight > 80) {
                objectHeight += 12;
            }
            
            playerData.team = staticPlayerData.team;
            playerData.hp = memoryTools.readFloat(staticPlayerData.addr + ObjectParam::HpOffset);
            if (playerData.hp > 100) playerData.hp = 100;
            
            // STATUS (0x1058)
            uintptr_t statusAddr = memoryTools.readInt(staticPlayerData.addr + ObjectParam::StatusOffset);
            playerData.statusName = getStatusName(statusAddr);
            
            // SILAH ADI (0x25b8)
            uintptr_t weaponAddr = memoryTools.readPtr(
                staticPlayerData.addr + ObjectParam::WeaponManagerComponentOffset
            );
            if (weaponAddr == 0) {
                playerData.weaponName = "FIST";
            } else {
                string className = getClassName(memoryTools.readInt(weaponAddr + ObjectParam::ClassIdOffset));
                MaterialStruct weaponName = isWeapon(className.c_str());
                playerData.weaponName = (weaponName.id != 0) ? weaponName.name : "[RIFLE]M762";
            }
            
            playerData.name = staticPlayerData.name;
            playerData.screen = worldToScreen(objectCoord, pov, screenSize);
            
            // KUTU BOYUTU
            ImVec2 width = worldToScreen(ImVec3(objectCoord.x, objectCoord.y, objectCoord.z + 100), pov, screenSize);
            ImVec2 height = worldToScreen(ImVec3(objectCoord.x, objectCoord.y, objectCoord.z + objectHeight), pov, screenSize);
            playerData.size.x = (playerData.screen.y - width.y) / 2;
            playerData.size.y = playerData.screen.y - height.y;
            
            // SKELETON (0x510 mesh, 0x988 bones)
            uintptr_t meshAddr = memoryTools.readPtr(staticPlayerData.addr + ObjectParam::MeshOffset);
            if (meshAddr != 0) {
                uintptr_t humanAddr = meshAddr + ObjectParam::MeshParam::HumanOffset;
                uintptr_t boneAddr = memoryTools.readPtr(meshAddr + ObjectParam::MeshParam::BonesOffset) + 48;
                
                BonesData bonesData;
                if (getBone2d(pov, screenSize, humanAddr, boneAddr, 5, bonesData.head))      // Kafa
                    if (getBone2d(pov, screenSize, humanAddr, boneAddr, 4, bonesData.pit))   // Gogus
                        if (getBone2d(pov, screenSize, humanAddr, boneAddr, 1, bonesData.pelvis)) // Pelvis
                            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 11, bonesData.lcollar)) // Sol omuz
                                if (getBone2d(pov, screenSize, humanAddr, boneAddr, 32, bonesData.rcollar)) // Sag omuz
                                    if (getBone2d(pov, screenSize, humanAddr, boneAddr, 12, bonesData.lelbow)) // Sol dirsek
                                        if (getBone2d(pov, screenSize, humanAddr, boneAddr, 33, bonesData.relbow)) // Sag dirsek
                                            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 63, bonesData.lwrist)) // Sol bilek
                                                if (getBone2d(pov, screenSize, humanAddr, boneAddr, 62, bonesData.rwrist)) // Sag bilek
                                                    if (getBone2d(pov, screenSize, humanAddr, boneAddr, 52, bonesData.lthigh)) // Sol kalca
                                                        if (getBone2d(pov, screenSize, humanAddr, boneAddr, 56, bonesData.rthigh)) // Sag kalca
                                                            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 53, bonesData.lknee)) // Sol diz
                                                                if (getBone2d(pov, screenSize, humanAddr, boneAddr, 57, bonesData.rknee)) // Sag diz
                                                                    if (getBone2d(pov, screenSize, humanAddr, boneAddr, 54, bonesData.lankle)) // Sol ayak
                                                                        if (getBone2d(pov, screenSize, humanAddr, boneAddr, 58, bonesData.rankle)) // Sag ayak
                                                                            playerData.bonesData = bonesData;
            }
            
            playerDataList.push_back(playerData);
        }
    }
    
    // ITEM ESP
    if (moduleControl.mainSwitch.materialStatus) {
        for (auto staticMaterialData : staticData.materialDataList) {
            string className = getClassName(
                memoryTools.readInt(staticMaterialData.coordAddr + ObjectParam::ClassIdOffset)
            );
            if (isRecycled(className.c_str())) continue;
            
            ImVec3 objectCoord;
            memoryTools.readMemory(
                staticMaterialData.coordAddr + ObjectParam::CoordParam::CoordOffset, 
                sizeof(ImVec3), 
                &objectCoord
            );
            
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
            
            // AirDrop icindeki itemler
            if (staticMaterialData.type == Airdrop) {
                ImVec2 goodsListScreen = worldToScreen(objectCoord, pov, screenSize);
                if (get2dDistance(screenSize, goodsListScreen) < 150) {
                    int goodsListValidCount = 0;
                    uintptr_t goodsListArray = memoryTools.readPtr(
                        staticMaterialData.addr + ObjectParam::PickUpDataListOffset
                    );
                    int goodsListCount = memoryTools.readInt(
                        staticMaterialData.addr + ObjectParam::PickUpDataListOffset + sizeof(uintptr_t)
                    );
                    
                    for (int index = 0; index < goodsListCount && index < 100; index++) {
                        int goodsListId = memoryTools.readInt(
                            goodsListArray + 0x4 + index * ObjectParam::GoodsListParam::DataBase
                        );
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

// ============ STATUS ADI DONUSTURME ============
string getStatusName(uintptr_t statusAddr) {
    switch (statusAddr) {
        case 2097168: return "DRIVE";
        case 262208: return "HEALING";
        case 33554449: return "FLYING ON PARACHUTE";
        case 262160: return "STAND";
        case 16: return "STAND";
        case 524288: return "KNOCKED";
        case 147: return "JUMP";
        case 529: return "WALK & RELOADING";
        case 35: return "CROUCHING";
        case 8205: return "SHOOTING";
        case 33: return "CROUCH WALK";
        case 65568: return "CROUCH GRENADE";
        case 65600: return "PRONE GRENADE";
        case 1088: return "PRONE ADS";
        case 1056: return "CROUCH ADS";
        case 18: return "STANDING";
        case 32784: return "PUNCHING";
        case 23: return "HOLDING GUN";
        case 1073741840: return "FIRING";
        case 16777219: return "SWIMMING";
        case 524289: return "KNOCKED DOWN";
        case 1040: return "ADS";
        case 272: return "SHOOTING";
        case 4112: return "LEANING";
        case 19: return "RUNNING";
        case 6552: return "GRENADE PIN";
        case 64: return "PRONE";
        case 32: return "CROUCH";
        case 144: return "JUMPING";
        case 4128: return "CROUCH LEAN";
        case 4384: return "CROUCH FIRE";
        case 528: return "RELOADING";
        case 320: return "PRONE FIRE";
        case 288: return "CROUCH FIRE";
        case 576: return "PRONE RELOAD";
        case 544: return "CROUCH RELOAD";
        case 67108880: return "CLIMBING";
        case 273: return "RUN & SHOOT";
        case 4194320: return "IN VEHICLE";
        case 17: return "WALKING";
        default: return "UNKNOWN";
    }
}

// ============ AIMBOT ============
void *silenceAimbot(void *) {
    ImVec2 screenSize = ImVec2([UIScreen mainScreen].bounds.size.width, 
                               [UIScreen mainScreen].bounds.size.height);
    
    while (true) {
        usleep(16666);
        
        if (moduleControl.systemStatus != TransmissionNormal || !moduleControl.mainSwitch.aimbotStatus) {
            continue;
        }
        
        // Silah pointer (0x25b8)
        uintptr_t weaponAddr = memoryTools.readPtr(
            staticData.selfAddr + ObjectParam::WeaponManagerComponentOffset
        );
        
        bool enabledAimbot = false;
        
        // Aimbot mod kontrolu
        switch (moduleControl.aimbotController.aimbotMode) {
            case 0: // ADS aimbot
                enabledAimbot = (
                    memoryTools.readInt(staticData.selfAddr + ObjectParam::OpenTheSightOffset) == 257 ||
                    memoryTools.readInt(staticData.selfAddr + ObjectParam::OpenTheSightOffset) == 1
                );
                break;
            case 1: // Fire aimbot
                enabledAimbot = (memoryTools.readInt(staticData.selfAddr + ObjectParam::OpenFireOffset) == 1);
                break;
            case 2: // ADS + Fire
                enabledAimbot = (
                    memoryTools.readInt(staticData.selfAddr + ObjectParam::OpenTheSightOffset) == 257 ||
                    memoryTools.readInt(staticData.selfAddr + ObjectParam::OpenTheSightOffset) == 1 ||
                    memoryTools.readInt(staticData.selfAddr + ObjectParam::OpenFireOffset) == 1
                );
                break;
            case 3: // Auto detect
                if (memoryTools.readInt(weaponAddr + ObjectParam::WeaponParam::ShootModeOffset) >= 1024) {
                    enabledAimbot = (memoryTools.readInt(staticData.selfAddr + ObjectParam::OpenFireOffset) == 1);
                } else {
                    enabledAimbot = (
                        memoryTools.readInt(staticData.selfAddr + ObjectParam::OpenTheSightOffset) == 257 ||
                        memoryTools.readInt(staticData.selfAddr + ObjectParam::OpenTheSightOffset) == 1
                    );
                }
                break;
        }
        
        if (!enabledAimbot) continue;
        
        // POV ve koordinatlar
        MinimalViewInfo pov;
        memoryTools.readMemory(
            staticData.cameraManager + PlayerControllerParam::CameraManagerParam::PovOffset, 
            sizeof(pov), 
            &pov
        );
        
        ImVec3 selfCoord = pov.location;
        float aimbotRadius = moduleControl.aimbotController.aimbotRadius;
        StaticPlayerData aimbotPlayerData;
        aimbotPlayerData.addr = 0;
        ImVec3 aimbotCoord = ImVec3(0, 0, 0);
        
        // Hedef secimi
        for (auto staticPlayerData : staticData.playerDataList) {
            ImVec3 objectCoord;
            memoryTools.readMemory(
                staticPlayerData.coordAddr + ObjectParam::CoordParam::CoordOffset, 
                sizeof(ImVec3), 
                &objectCoord
            );
            
            float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
            if (objectDistance < 0 || objectDistance > 450 || 
                objectDistance > moduleControl.aimbotController.distance) continue;
            
            float objectHeight = memoryTools.readFloat(
                staticPlayerData.coordAddr + ObjectParam::CoordParam::HeightOffset
            );
            if (objectHeight < 20) continue;
            
            // Olum kontrolu
            if (memoryTools.readFloat(staticPlayerData.addr + ObjectParam::HpOffset) < 0.5 && 
                moduleControl.aimbotController.fallNotAim) continue;
            
            ImVec2 playerScreen = worldToScreen(objectCoord, pov, screenSize);
            float screenDistance = get2dDistance(screenSize, playerScreen);
            
            if (screenDistance >= aimbotRadius) continue;
            
            // Mesh ve bone okuma (0x510 / 0x988)
            uintptr_t meshAddr = memoryTools.readPtr(staticPlayerData.addr + ObjectParam::MeshOffset);
            if (meshAddr == 0) continue;
            
            uintptr_t humanAddr = meshAddr + ObjectParam::MeshParam::HumanOffset;
            uintptr_t boneAddr = memoryTools.readPtr(meshAddr + ObjectParam::MeshParam::BonesOffset) + 48;
            
            // Hedef secimi ve visibility check
            int boneIds[15];
            int boneCount = 0;
            
            switch (moduleControl.aimbotController.aimbotParts) {
                case 0: // Priority head
                    boneIds[0] = 5; boneIds[1] = 3; boneIds[2] = 1; boneIds[3] = 11; boneIds[4] = 12;
                    boneIds[5] = 32; boneIds[6] = 33; boneIds[7] = 52; boneIds[8] = 53; boneIds[9] = 54;
                    boneIds[10] = 56; boneIds[11] = 57; boneIds[12] = 58; boneIds[13] = 62; boneIds[14] = 63;
                    boneCount = 15;
                    break;
                case 1: // Priority body
                    boneIds[0] = 11; boneIds[1] = 3; boneIds[2] = 5; boneIds[3] = 1; boneIds[4] = 11;
                    boneIds[5] = 32; boneIds[6] = 12; boneIds[7] = 33; boneIds[8] = 63; boneIds[9] = 62;
                    boneIds[10] = 52; boneIds[11] = 56; boneIds[12] = 53; boneIds[13] = 57; boneIds[14] = 54;
                    boneIds[15] = 58;
                    boneCount = 16;
                    break;
                case 2: // Auto
                    if (memoryTools.readInt(weaponAddr + ObjectParam::WeaponParam::ShootModeOffset) >= 1024) {
                        boneIds[0] = 3; boneIds[1] = 5; boneIds[2] = 1; boneIds[3] = 11; boneIds[4] = 32;
                        boneIds[5] = 12; boneIds[6] = 33; boneIds[7] = 63; boneIds[8] = 62; boneIds[9] = 52;
                        boneIds[10] = 56; boneIds[11] = 53; boneIds[12] = 57; boneIds[13] = 54; boneIds[14] = 58;
                        boneCount = 15;
                    } else {
                        boneIds[0] = 5; boneIds[1] = 3; boneIds[2] = 1; boneIds[3] = 11; boneIds[4] = 32;
                        boneIds[5] = 12; boneIds[6] = 33; boneIds[7] = 63; boneIds[8] = 62; boneIds[9] = 52;
                        boneIds[10] = 56; boneIds[11] = 53; boneIds[12] = 57; boneIds[13] = 54; boneIds[14] = 58;
                        boneCount = 15;
                    }
                    break;
                case 3: // Only head
                    boneIds[0] = 5;
                    boneCount = 1;
                    break;
                case 4: // Only body
                    boneIds[0] = 3;
                    boneCount = 1;
                    break;
            }
            
            // Bone visibility check
            for (int i = 0; i < boneCount; i++) {
                aimbotCoord = getBone(humanAddr, boneAddr, boneIds[i]);
                if (isCoordVisibility(aimbotCoord)) {
                    aimbotPlayerData = staticPlayerData;
                    aimbotRadius = screenDistance;
                    break;
                }
                aimbotCoord = ImVec3(0, 0, 0);
            }
        }
        
        // Aimbot uygula
        if (aimbotPlayerData.addr != 0 && aimbotCoord.x != 0) {
            // Duman kontrolu
            if (moduleControl.aimbotController.smoke && isOnSmoke(aimbotCoord)) continue;
            
            // Silah ozellikleri (0xf30 weapon attr)
            uintptr_t weaponAttrAddr = memoryTools.readPtr(
                weaponAddr + ObjectParam::WeaponParam::WeaponAttrOffset
            );
            float bulletSpeed = memoryTools.readFloat(
                weaponAttrAddr + ObjectParam::WeaponParam::WeaponAttrParam::BulletSpeedOffset
            );
            float bulletFlyTime = get3dDistance(selfCoord, aimbotCoord, bulletSpeed) * 1.2;
            
            // Prediction
            ImVec3 moveCoord;
            memoryTools.readMemory(aimbotPlayerData.addr + ObjectParam::MoveCoordOffset, 12, &moveCoord);
            
            float bulletSpeed1 = memoryTools.readFloat(
                weaponAttrAddr + ObjectParam::WeaponParam::WeaponAttrParam::BulletSpeedOffset
            );
            if (bulletSpeed1 != 1800000) {
                aimbotCoord.x += moveCoord.x * bulletFlyTime;
                aimbotCoord.y += moveCoord.y * bulletFlyTime;
                aimbotCoord.z += moveCoord.z * bulletFlyTime;
            }
            
            // Acı hesaplama
            ImVec2 aimbotMouse = rotateAngleView(selfCoord, aimbotCoord);
            
            // Durus pozisyonu kontrolu
            float selfStatus = memoryTools.readFloat(
                memoryTools.readPtr(staticData.selfAddr + ObjectParam::CoordOffset) + 
                ObjectParam::CoordParam::HeightOffset
            );
            
            string className = getClassName(memoryTools.readInt(weaponAddr + ObjectParam::ClassIdOffset));
            
            // Silah bazlı ayarlamalar (Ayakta)
            if (selfStatus > 47) {
                if (strstr(className.c_str(), "BP_Sniper_AWM_Wrapper_C")) {
                    aimbotMouse.x += 0.06; aimbotMouse.y -= 0.06;
                } else if (strstr(className.c_str(), "BP_Sniper_AMR_Wrapper_C")) {
                    aimbotMouse.x -= 0.075; aimbotMouse.y -= 0.035;
                } else if (strstr(className.c_str(), "BP_Sniper_M24_Wrapper_C")) {
                    aimbotMouse.x += 0.04; aimbotMouse.y -= 0.03;
                } else if (strstr(className.c_str(), "BP_Sniper_Kar98k_Wrapper_C")) {
                    aimbotMouse.x += 0.05; aimbotMouse.y -= 0.02;
                } else if (strstr(className.c_str(), "BP_Sniper_Mosin_Wrapper_C")) {
                    aimbotMouse.x += 0.04; aimbotMouse.y -= 0.05;
                } else if (strstr(className.c_str(), "BP_Sniper_Mk14_Wrapper_C")) {
                    aimbotMouse.x += 1.05; aimbotMouse.y -= 1.05;
                } else if (strstr(className.c_str(), "BP_Sniper_QBU_Wrapper_C")) {
                    aimbotMouse.x += 0.055; aimbotMouse.y -= 0.085;
                } else if (strstr(className.c_str(), "BP_Sniper_SKS_Wrapper_C")) {
                    aimbotMouse.x += 0.06; aimbotMouse.y -= 0.085;
                } else if (strstr(className.c_str(), "BP_Sniper_SLR_Wrapper_C")) {
                    aimbotMouse.x += 0.055; aimbotMouse.y -= 0.03;
                } else if (strstr(className.c_str(), "BP_Sniper_Mini14_Wrapper_C")) {
                    aimbotMouse.x += 0.015; aimbotMouse.y -= 0.05;
                } else if (strstr(className.c_str(), "BP_Rifle_QBZ_Wrapper_C")) {
                    aimbotMouse.x += 0.045; aimbotMouse.y -= 0.09;
                } else if (strstr(className.c_str(), "BP_Rifle_G36_Wrapper_C")) {
                    aimbotMouse.x += 0.02; aimbotMouse.y -= 0.055;
                } else if (strstr(className.c_str(), "BP_Rifle_Groza_Wrapper_C")) {
                    aimbotMouse.x += 0.03; aimbotMouse.y -= 0.065;
                } else if (strstr(className.c_str(), "BP_Rifle_AUG_Wrapper_C")) {
                    aimbotMouse.x += 0.015; aimbotMouse.y -= 0.08;
                } else if (strstr(className.c_str(), "BP_Rifle_M16A4_Wrapper_C")) {
                    aimbotMouse.x += 0.04; aimbotMouse.y -= 0.07;
                } else if (strstr(className.c_str(), "BP_Rifle_AKM_Wrapper_C")) {
                    aimbotMouse.x += 0.04; aimbotMouse.y -= 0.07;
                } else if (strstr(className.c_str(), "BP_Rifle_SCAR_Wrapper_C")) {
                    aimbotMouse.x += 0.02; aimbotMouse.y -= 0.085;
                } else if (strstr(className.c_str(), "BP_Rifle_M416_Wrapper_C")) {
                    aimbotMouse.x += 0.02; aimbotMouse.y -= 0.08;
                } else if (strstr(className.c_str(), "BP_Rifle_M762_Wrapper_C")) {
                    aimbotMouse.x += 0.03; aimbotMouse.y -= 0.07;
                } else if (strstr(className.c_str(), "BP_Other_M249_Wrapper_C")) {
                    aimbotMouse.x += 0.025; aimbotMouse.y -= 0.06;
                } else if (strstr(className.c_str(), "BP_Other_MG3_Wrapper_C")) {
                    aimbotMouse.x += 0.03; aimbotMouse.y -= 0.07;
                } else if (strstr(className.c_str(), "BP_Other_DP28_Wrapper_C")) {
                    aimbotMouse.x += 0.045; aimbotMouse.y -= 0.095;
                }
            }
            
            // Recoil control (0xcf0)
            if (memoryTools.readInt(staticData.selfAddr + ObjectParam::OpenFireOffset) == 1) {
                float recoilTimes = 4.5 - get3dDistance(selfCoord, aimbotCoord, 10000);
                recoilTimes += get3dDistance(selfCoord, aimbotCoord, 10000) * 0.2;
                
                float recoil = memoryTools.readFloat(
                    weaponAttrAddr + ObjectParam::WeaponParam::WeaponAttrParam::RecoilOffset
                );
                
                // Silah bazlı recoil ayarları
                if (strstr(className.c_str(), "BP_Sniper_VSS_Wrapper_C")) recoil *= 0.4;
                else if (strstr(className.c_str(), "BP_Rifle_G36_Wrapper_C")) recoil *= 0.6;
                else if (strstr(className.c_str(), "BP_Rifle_VAL_Wrapper_C")) recoil *= 0.45;
                else if (strstr(className.c_str(), "BP_Rifle_AUG_Wrapper_C")) recoil *= 0.7;
                else if (strstr(className.c_str(), "BP_Rifle_AKM_Wrapper_C")) recoil *= 1.15;
                else if (strstr(className.c_str(), "BP_Other_MG3_Wrapper_C")) recoil *= 0.2;
                else if (strstr(className.c_str(), "BP_Other_DP28_Wrapper_C")) recoil *= 0.3;
                
                // Crouch recoil
                if (selfStatus < 50.0f) {
                    if (strstr(className.c_str(), "BP_Rifle_M762_Wrapper_C")) {
                        recoil *= 0.55;
                        aimbotMouse.x += 0.2;
                    } else if (strstr(className.c_str(), "BP_Other_M249_Wrapper_C")) {
                        recoil *= 0.6;
                        aimbotMouse.x += 0.08;
                    } else {
                        recoil *= 0.35;
                    }
                }
                
                aimbotMouse.y -= recoilTimes * recoil;
            }
            
            if (!isfinite(aimbotMouse.x) || !isfinite(aimbotMouse.y)) continue;
            
            // Smooth aim
            ImVec2 aimbotMouseMove;
            aimbotMouseMove.x = change(getAngleDifference(
                aimbotMouse.x, 
                memoryTools.readFloat(staticData.playerController + PlayerControllerParam::MouseOffset + 0x4)
            ) * moduleControl.aimbotController.aimbotIntensity);
            
            aimbotMouseMove.y = change(getAngleDifference(
                aimbotMouse.y, 
                memoryTools.readFloat(staticData.playerController + PlayerControllerParam::MouseOffset)
            ) * moduleControl.aimbotController.aimbotIntensity);
            
            if (!isfinite(aimbotMouseMove.x) || !isfinite(aimbotMouseMove.y)) continue;
            
            // Apply input
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

// ============ YARDIMCI FONKSIYONLAR ============
bool isCoordVisibility(ImVec3 coord) {
    if (LineOfSightTo == nullptr || !isfinite(coord.x) || !isfinite(coord.y) || !isfinite(coord.z)) {
        return false;
    }
    if (strstr(staticData.cameraManagerClassName.c_str(), "PlayerCameraManager") != 0 && 
        strstr(staticData.playerControllerClassName.c_str(), "PlayerController") != 0) {
        return LineOfSightTo(
            reinterpret_cast<void *>(staticData.playerController), 
            reinterpret_cast<void *>(staticData.cameraManager), 
            coord, 
            false
        );
    }
    return false;
}

bool isOnSmoke(ImVec3 coord) {
    for (StaticMaterialData smoke : staticData.smokeList) {
        ImVec3 smokeCoord;
        memoryTools.readMemory(
            smoke.coordAddr + ObjectParam::CoordParam::CoordOffset, 
            30, 
            &smokeCoord
        );
        if (get3dDistance(smokeCoord, coord, 100) < 4) {
            return true;
        }
    }
    return false;
}

char *getPlayerName(uintptr_t addr) {
    char *buf = (char *)malloc(448);
    unsigned short buf16[16] = {0};
    memoryTools.readMemory(addr, 28, buf16);
    unsigned short *tempbuf16 = buf16;
    char *tempbuf8 = buf;
    char *buf8 = tempbuf8 + 32;
    
    while (tempbuf16 < tempbuf16 + 28) {
        if (*tempbuf16 <= 0x007F && tempbuf8 + 1 < buf8) {
            *tempbuf8++ = (char)*tempbuf16;
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
    char *buf = (char *)malloc(64);
    if (classId > 0 && classId < 2000000) {
        int page = classId / 16384;
        int index = classId % 16384;
        uintptr_t pageAddr = memoryTools.readPtr(staticData.gnameAddr + page * sizeof(uintptr_t));
        uintptr_t nameAddr = memoryTools.readPtr(pageAddr + index * sizeof(uintptr_t)) + 
                             ObjectParam::ClassNameOffset;
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
    uintptr_t boneBase = bones + part * 48;
    memoryTools.readMemory(boneBase, sizeof(ImVec4), &boneftf.rotation);
    memoryTools.readMemory(boneBase + 0x10, sizeof(ImVec3), &boneftf.translation);
    memoryTools.readMemory(boneBase + 0x20, sizeof(ImVec3), &boneftf.scale3d);
    
    Ue4Matrix bonematrix = transformToMatrix(boneftf);
    
    return matrixToVector(matrixMulti(bonematrix, actormatrix));
}

bool getBone2d(MinimalViewInfo pov, ImVec2 screen, uintptr_t human, uintptr_t bones, int part, ImVec2 &buf) {
    ImVec3 newmatrix = getBone(human, bones, part);
    buf = worldToScreen(newmatrix, pov, screen);
    return buf.x != 0 && buf.y != 0;
}
