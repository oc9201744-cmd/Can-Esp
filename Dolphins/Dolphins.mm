//
//  Dolphins.mm
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

// Modül kontrolü
ModuleControl moduleControl;
// Bellek araçları
MemoryTools memoryTools;

OffsetValues offsets[] = {
    { 0x102A5125C, 0x10A4A1960, 0x104C0F1E8, 0x10A0557E0 },  // GL
    { 0x1028791CC, 0x10A171A00, 0x104510EF0, 0x109AAA1A0 },  // VNG
    { 0x102AD71F8, 0x10A47D400, 0x10476F14C, 0x109DB5940 },  // KR
    { 0x102AAAB0C, 0x10A453300, 0x104742830, 0x109D8B830 }   // TW
};

// Fonksiyon prototipleri
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

// UI başlatma
static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        mao* drawWindow = [[mao alloc] initWithFrame:&moduleControl];
        mi* menuWindow = [[mi alloc] initWithFrame:&moduleControl];
        OverlayView* overlayView = [[OverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds :&moduleControl :drawWindow :menuWindow];
        [[UIApplication sharedApplication].keyWindow addSubview:overlayView];
        
        FloatView* floatView = [[FloatView alloc] initWithFrame:CGRectMake(489, 58, 45, 45) :&moduleControl];
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

// Statik veri okuma thread'i
void *readStaticData(void *) {
    while (true) {
        sleep(4);
        if (moduleControl.systemStatus != TransmissionNormal) {
            staticData.libAddr = (uintptr_t)_dyld_get_image_vmaddr_slide(0);
            if (staticData.libAddr != 1) {
                moduleControl.systemStatus = TransmissionNormal;
            }
        } else if (moduleControl.systemStatus == TransmissionNormal) {
            staticData.gwlordAddr = gWorld();
            staticData.gnameAddr = gName();
            
            // PlayerController chain
            staticData.playerController = memoryTools.readPtr(memoryTools.readPtr(memoryTools.readPtr(staticData.gwlordAddr + PubgOffset::PlayerControllerOffset[0]) + PubgOffset::PlayerControllerOffset[1]) + PubgOffset::PlayerControllerOffset[2]);
            
            // LineOfSightTo fonksiyonu
            LineOfSightTo = (bool (*)(void *, void *, ImVec3, bool)) (memoryTools.readPtr(memoryTools.readPtr(staticData.playerController + 0x0) + PubgOffset::LineOfSightToOffset));
            
            // Self pointer
            staticData.selfAddr = memoryTools.readPtr(staticData.playerController + PubgOffset::SelfOffset);
            
            // Input fonksiyonları
            uintptr_t selfFunction = memoryTools.readPtr(staticData.selfAddr + 0);
            AddControllerYawInput   = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::AddControllerYawInputOffset));
            AddControllerRollInput  = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::AddControllerRollInputOffset));
            AddControllerPitchInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::AddControllerPitchInputOffset));
            
            // Camera Manager
            staticData.cameraManager = memoryTools.readPtr(staticData.playerController + PubgOffset::CameraManagerOffset);
            
            // Listeleri temizle
            vector<StaticPlayerData> tmpPlayerDataList;
            vector<StaticMaterialData> tmpMaterialDataList;
            vector<StaticMaterialData> tmpSmokeList;
            
            uintptr_t uLevel = memoryTools.readPtr(staticData.gwlordAddr + PubgOffset::ULevelOffset);
            uintptr_t objectArray = memoryTools.readPtr(uLevel + PubgOffset::ActorArrayOffset);
            int objectCount = memoryTools.readInt(uLevel + PubgOffset::ActorCountOffset);
            
            for (int index = 0; index < objectCount; ++index) {
                uintptr_t objectAddr = memoryTools.readPtr(objectArray + index * 8);
                if (objectAddr <= 0x100000000 || objectAddr >= 0x2000000000 || objectAddr % 8 != 0) continue;
                
                uintptr_t coordAddr = memoryTools.readPtr(objectAddr + PubgOffset::CoordOffset);
                string className = getClassName(memoryTools.readInt(objectAddr + PubgOffset::ClassIdOffset));
                
                bool isPlayer = (
                    strstr(className.c_str(), "STExtraCharacter") != 0 ||
                    strstr(className.c_str(), "BP_PlayerPawn") != 0 ||
                    strstr(className.c_str(), "PlayerCharacter") != 0
                );
                
                if (isPlayer && moduleControl.mainSwitch.playerStatus) {
                    int team = memoryTools.readInt(objectAddr + PubgOffset::TeamOffset);
                    int selfTeam = memoryTools.readInt(staticData.selfAddr + PubgOffset::TeamOffset);
                    if (team == selfTeam && team != 0) continue;
                    
                    bool isDead = false;
                    memoryTools.readMemory(objectAddr + PubgOffset::DeadOffset, 1, &isDead);
                    if (isDead) continue;
                    
                    StaticPlayerData tmp;
                    tmp.addr = objectAddr;
                    tmp.coordAddr = coordAddr;
                    tmp.team = team;
                    tmp.name = getPlayerName(memoryTools.readPtr(objectAddr + PubgOffset::NameOffset));
                    
                    bool isBot = false;
                    memoryTools.readMemory(objectAddr + PubgOffset::RobotOffset, 1, &isBot);
                    tmp.robot = isBot ? 1 : 0;
                    
                    tmp.status = memoryTools.readInt(objectAddr + PubgOffset::StatusOffset);
                    tmpPlayerDataList.push_back(tmp);
                }
                else if (strstr(className.c_str(), "ProjSmoke_BP_C") != 0) {
                    StaticMaterialData tmp;
                    tmp.type = Warning;
                    tmp.id = 4;
                    tmp.name = "[WARNING]SMOKE";
                    tmp.addr = objectAddr;
                    tmp.coordAddr = coordAddr;
                    tmpSmokeList.push_back(tmp);
                }
                else if (moduleControl.mainSwitch.materialStatus) {
                    MaterialStruct mat = isMaterial(className.c_str());
                    if (mat.type > -1) {
                        StaticMaterialData tmp;
                        tmp.type = mat.type;
                        tmp.id = mat.id;
                        tmp.name = mat.name;
                        tmp.addr = objectAddr;
                        tmp.coordAddr = coordAddr;
                        
                        if ((mat.type == Rifle || mat.type == Sniper || mat.type == Missile) &&
                            memoryTools.readPtr(objectAddr + PubgOffset::WeaponAttrOffset) != 0) {
                            continue;
                        }
                        tmpMaterialDataList.push_back(tmp);
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

// Frame verisi okuma (hatalar düzeltildi)
void readFrameData(ImVec2 screenSize, vector<PlayerData> &playerDataList, vector<MaterialData> &materialDataList) {
    playerDataList.clear();
    materialDataList.clear();
    if (moduleControl.systemStatus != TransmissionNormal) return;

    staticData.cameraManagerClassName = getClassName(memoryTools.readInt(staticData.cameraManager + PubgOffset::ClassIdOffset));
    staticData.playerControllerClassName = getClassName(memoryTools.readInt(staticData.playerController + PubgOffset::ClassIdOffset));

    MinimalViewInfo pov;
    memoryTools.readMemory(staticData.cameraManager + PubgOffset::PovOffset, sizeof(pov), &pov);

    ImVec3 selfCoord = pov.location;
    float lateralAngleView = memoryTools.readFloat(staticData.playerController + PubgOffset::ControlRotationOffset + 0x4) - 90;

    if (moduleControl.mainSwitch.playerStatus) {
        for (auto &player : staticData.playerDataList) {
            ImVec3 objectCoord;
            memoryTools.readMemory(player.coordAddr + PubgOffset::CoordOffset, sizeof(ImVec3), &objectCoord);

            float distance = get3dDistance(objectCoord, selfCoord, 100);
            if (distance < 0 || distance > 450) continue;

            float height = memoryTools.readFloat(player.coordAddr + PubgOffset::HeightOffset);
            if (height < 20) continue;

            PlayerData data;
            data.angle = lateralAngleView - rotateAngle(selfCoord, objectCoord) - 180;
            data.radar = rotateCoord(lateralAngleView, ImVec2((selfCoord.x - objectCoord.x) / 200, (selfCoord.y - objectCoord.y) / 200));
            data.distance = distance;
            data.robot = player.robot;
            data.visibility = isCoordVisibility(objectCoord);
            if (data.visibility && isOnSmoke(objectCoord)) data.visibility = false;

            if (height < 50) height -= 18;
            else if (height > 80) height += 12;

            data.team = player.team;
            data.hp = memoryTools.readFloat(player.addr + PubgOffset::HpOffset);
            if (data.hp > 100) data.hp = 100;

            uintptr_t weapon = memoryTools.readPtr(player.addr + PubgOffset::WeaponOneOffset);
            if (weapon == 0) {
                data.weaponName = "FIST";
            } else {
                string wClass = getClassName(memoryTools.readInt(weapon + PubgOffset::ClassIdOffset));
                MaterialStruct w = isWeapon(wClass.c_str());
                data.weaponName = (w.id != 0) ? w.name : "[RIFLE]M762";
            }

            data.name = player.name;
            data.screen = worldToScreen(objectCoord, pov, screenSize);

            ImVec2 wPos = worldToScreen(ImVec3(objectCoord.x, objectCoord.y, objectCoord.z + 100), pov, screenSize);
            ImVec2 hPos = worldToScreen(ImVec3(objectCoord.x, objectCoord.y, objectCoord.z + height), pov, screenSize);
            data.size.x = (data.screen.y - wPos.y) / 2;
            data.size.y = data.screen.y - hPos.y;

            uintptr_t mesh = memoryTools.readPtr(player.addr + PubgOffset::MeshOffset);
            uintptr_t bones = memoryTools.readPtr(mesh + PubgOffset::BonesOffset) + 0x30;

            BonesData bonesData;
            if (getBone2d(pov, screenSize, mesh, bones, 5, bonesData.head) &&
                getBone2d(pov, screenSize, mesh, bones, 4, bonesData.pit) &&
                getBone2d(pov, screenSize, mesh, bones, 1, bonesData.pelvis)) {
                playerDataList.push_back(data);
            }
        }
    }

    if (moduleControl.mainSwitch.materialStatus) {
        for (auto &mat : staticData.materialDataList) {
            string className = getClassName(memoryTools.readInt(mat.coordAddr + PubgOffset::ClassIdOffset));
            if (isRecycled(className.c_str())) continue;

            ImVec3 coord;
            memoryTools.readMemory(mat.coordAddr + PubgOffset::CoordOffset, sizeof(ImVec3), &coord);

            float dist = get3dDistance(coord, pov.location, 100);
            if (mat.type > 1 && mat.type < All && dist > 100) continue;
            if (!moduleControl.materialSwitch[mat.type]) continue;

            MaterialData mData;
            mData.type = mat.type;
            mData.id = mat.id;
            mData.name = mat.name;
            mData.distance = dist;
            mData.screen = worldToScreen(coord, pov, screenSize);
            materialDataList.push_back(mData);

            if (mat.type == Airdrop) {
                ImVec2 pos = worldToScreen(coord, pov, screenSize);
                if (get2dDistance(screenSize, pos) < 150) {
                    uintptr_t array = memoryTools.readPtr(mat.addr + PubgOffset::GoodsListOffset);
                    int count = memoryTools.readInt(mat.addr + PubgOffset::GoodsListOffset + sizeof(uintptr_t));
                    int valid = 0;
                    for (int i = 0; i < count && i <= 100; ++i) {
                        int id = memoryTools.readInt(array + 0x4 + i * PubgOffset::GoodsListParam::DataBase);
                        MaterialStruct g = isBoxMaterial(id);
                        if (g.type == -1) continue;

                        MaterialData item;
                        item.type = g.type;
                        item.id = g.id;
                        item.name = g.name;
                        item.distance = -100;
                        item.screen = ImVec2(pos.x, pos.y - 32 * (++valid));
                        materialDataList.push_back(item);
                    }
                }
            }
        }
    }
}

// Silence Aimbot (içerik yoksa boş bırakıldı, sen doldurabilirsin)
void *silenceAimbot(void *) {
    ImVec2 screen = ImVec2(screenWidth, screenHeight);
    while (true) {
        usleep(16666);
        if (moduleControl.systemStatus == TransmissionNormal && moduleControl.mainSwitch.aimbotStatus) {
            // Aimbot mantığı buraya eklenebilir
        }
    }
    return nullptr;
}

bool isCoordVisibility(ImVec3 coord) {
    if (!LineOfSightTo || !isfinite(coord.x) || !isfinite(coord.y) || !isfinite(coord.z)) return false;
    if (strstr(staticData.cameraManagerClassName.c_str(), "PlayerCameraManager") &&
        strstr(staticData.playerControllerClassName.c_str(), "PlayerController")) {
        return LineOfSightTo(reinterpret_cast<void*>(staticData.playerController),
                             reinterpret_cast<void*>(staticData.cameraManager), coord, false);
    }
    return false;
}

bool isOnSmoke(ImVec3 coord) {
    for (auto &smoke : staticData.smokeList) {
        ImVec3 smokeCoord;
        memoryTools.readMemory(smoke.coordAddr + PubgOffset::CoordOffset, 30, &smokeCoord);
        if (get3dDistance(smokeCoord, coord, 100) < 4) return true;
    }
    return false;
}

char *getPlayerName(uintptr_t addr) {
    char *buf = (char *)malloc(448);
    unsigned short buf16[16] = {0};
    memoryTools.readMemory(addr, 28, buf16);
    unsigned short *temp16 = buf16;
    char *temp8 = buf;
    char *buf8 = temp8 + 32;
    while (temp16 < buf16 + 14) {
        if (*temp16 <= 0x007F && temp8 + 1 < buf8) {
            *temp8++ = (char)*temp16;
        } else if (*temp16 >= 0x0080 && *temp16 <= 0x07FF && temp8 + 2 < buf8) {
            *temp8++ = (*temp16 >> 6) | 0xC0;
            *temp8++ = (*temp16 & 0x3F) | 0x80;
        } else if (*temp16 >= 0x0800 && *temp16 <= 0xFFFF && temp8 + 3 < buf8) {
            *temp8++ = (*temp16 >> 12) | 0xE0;
            *temp8++ = ((*temp16 >> 6) & 0x3F) | 0x80;
            *temp8++ = (*temp16 & 0x3F) | 0x80;
        } else break;
        temp16++;
    }
    *temp8 = 0;
    return buf;
}

char *getClassName(int classId) {
    char *buf = (char *)malloc(64);
    if (classId > 0 && classId < 2000000) {
        int page = classId / 16384;
        int index = classId % 16384;
        uintptr_t pageAddr = memoryTools.readPtr(staticData.gnameAddr + page * sizeof(uintptr_t));
        uintptr_t nameAddr = memoryTools.readPtr(pageAddr + index * sizeof(uintptr_t)) + 0x10;
        memoryTools.readMemory(nameAddr, 64, buf);
    }
    return buf;
}

ImVec3 getBone(uintptr_t human, uintptr_t bones, int part) {
    Ue4Transform actor;
    memoryTools.readMemory(human, sizeof(ImVec4), &actor.rotation);
    memoryTools.readMemory(human + 0x10, sizeof(ImVec3), &actor.translation);
    memoryTools.readMemory(human + 0x20, sizeof(ImVec3), &actor.scale3d);
    
    Ue4Matrix actorMat = transformToMatrix(actor);
    
    Ue4Transform bone;
    memoryTools.readMemory(bones + part * 48, sizeof(ImVec4), &bone.rotation);
    memoryTools.readMemory(bones + part * 48 + 0x10, sizeof(ImVec3), &bone.translation);
    memoryTools.readMemory(bones + part * 48 + 0x20, sizeof(ImVec3), &bone.scale3d);
    
    Ue4Matrix boneMat = transformToMatrix(bone);
    return matrixToVector(matrixMulti(boneMat, actorMat));
}

bool getBone2d(MinimalViewInfo pov, ImVec2 screen, uintptr_t human, uintptr_t bones, int part, ImVec2 &buf) {
    ImVec3 pos = getBone(human, bones, part);
    buf = worldToScreen(pos, pov, screen);
    return buf.x != 0 && buf.y != 0;
}
