// Dolphins_Final_AllInOne.mm
// Linker Hataları Giderilmiş, Yeni Dylib Yöntemi ve Bot Ayrımı Entegre Edilmiş Versiyon

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

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

using namespace std;

ModuleControl moduleControl;
MemoryTools memoryTools;

// --- Dylib'den Alınan Fonksiyon Prototipleri ---
void (*AddControllerYawInput)(void *pawn, float val) = nullptr;
void (*AddControllerPitchInput)(void *pawn, float val) = nullptr;
bool (*LineOfSightTo)(void *controller, void *actor, ImVec3 bone_point, bool ischeck) = nullptr;

struct {
    uintptr_t libAddr = 0;
    uintptr_t gwlordAddr;
    uintptr_t gnameAddr;
    uintptr_t playerController;
    uintptr_t cameraManager;
    uintptr_t selfAddr;
    vector<StaticPlayerData> playerDataList;
} staticData;

// --- Orijinal gWorld ve gName Fonksiyonları ---
long gWorld() {
    OffsetValues offsetsForBundle = [OffsetsManager getOffsetsForBundleID:[[NSBundle mainBundle] bundleIdentifier]];
    return reinterpret_cast<long(__fastcall*)(long)>((long)_dyld_get_image_vmaddr_slide(0) + offsetsForBundle.gWorldFun)((long)_dyld_get_image_vmaddr_slide(0) + offsetsForBundle.gWorldData);
}

long gName() {
    OffsetValues offsetsForBundle = [OffsetsManager getOffsetsForBundleID:[[NSBundle mainBundle] bundleIdentifier]];
    return reinterpret_cast<long(__fastcall*)(long)>((long)_dyld_get_image_vmaddr_slide(0) + offsetsForBundle.gNameFun)((long)_dyld_get_image_vmaddr_slide(0) + offsetsForBundle.gNameData);
}

// --- BOT AYRIMI: Yeni Dylib Yöntemi ---
bool isActorBot(uintptr_t actorAddr) {
    uintptr_t playerState = memoryTools.readPtr(actorAddr + 0x3D8);
    if (playerState != 0) {
        uint8_t isBotFlag = 0;
        memoryTools.readMemory(playerState + 0x290, 1, &isBotFlag);
        if (isBotFlag == 1) return true;
    }
    uintptr_t controller = memoryTools.readPtr(actorAddr + 0x4E8);
    if (controller == 0) return true;
    return false;
}

// --- Linker Hatası Veren getClassName Fonksiyonu ---
char *getClassName(int classId) {
    char *buf = (char *) malloc(64);
    if (classId > 0 && classId < 2000000) {
        int page = classId / 16384;
        int index = classId % 16384;
        uintptr_t pageAddr = memoryTools.readPtr(staticData.gnameAddr + page * sizeof(uintptr_t));
        uintptr_t nameAddr = memoryTools.readPtr(pageAddr + index * sizeof(uintptr_t)) + PubgOffset::ObjectParam::ClassNameOffset;
        memoryTools.readMemory(nameAddr, 64, buf);
    } else {
        strcpy(buf, "None");
    }
    return buf;
}

// --- Linker Hatası Veren getBone Fonksiyonu ---
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

void *readStaticData(void *) {
    while (true) {
        sleep(4);
        if(moduleControl.systemStatus != TransmissionNormal){
            staticData.libAddr = (uintptr_t)_dyld_get_image_vmaddr_slide(0);
            if(staticData.libAddr != 0) moduleControl.systemStatus = TransmissionNormal;
        } else {
            staticData.gwlordAddr = gWorld();
            staticData.gnameAddr = gName();
            
            staticData.playerController = memoryTools.readPtr(memoryTools.readPtr(memoryTools.readPtr(staticData.gwlordAddr + PubgOffset::PlayerControllerOffset[0]) + PubgOffset::PlayerControllerOffset[1]) + PubgOffset::PlayerControllerOffset[2]);
            
            if (staticData.playerController != 0) {
                staticData.selfAddr = memoryTools.readPtr(staticData.playerController + PubgOffset::PlayerControllerParam::SelfOffset);
                staticData.cameraManager = memoryTools.readPtr(staticData.playerController + PubgOffset::PlayerControllerParam::CameraManagerOffset);
                
                uintptr_t selfVtable = memoryTools.readPtr(staticData.selfAddr + 0);
                if (selfVtable != 0) {
                    AddControllerYawInput   = (void (*)(void *, float)) (memoryTools.readPtr(selfVtable + 0x6E8)); 
                    AddControllerPitchInput = (void (*)(void *, float)) (memoryTools.readPtr(selfVtable + 0x6F8));
                }
                
                uintptr_t pcVtable = memoryTools.readPtr(staticData.playerController + 0);
                if (pcVtable != 0) {
                    LineOfSightTo = (bool (*)(void *, void *, ImVec3, bool)) (memoryTools.readPtr(pcVtable + 0x780));
                }
            }

            vector<StaticPlayerData> tmpList;
            uintptr_t uLevel = memoryTools.readPtr(staticData.gwlordAddr + PubgOffset::ULevelOffset);
            uintptr_t actors = memoryTools.readPtr(uLevel + PubgOffset::ULevelParam::ObjectArrayOffset);
            int count = memoryTools.readInt(uLevel + PubgOffset::ULevelParam::ObjectCountOffset);

            for (int i = 0; i < count; i++) {
                uintptr_t actor = memoryTools.readPtr(actors + i * 8);
                if (actor == 0 || actor == staticData.selfAddr) continue;

                char* className = getClassName(memoryTools.readInt(actor + PubgOffset::ObjectParam::ClassIdOffset));
                if (strstr(className, "PlayerPawn") || strstr(className, "PlayerCharacter")) {
                    StaticPlayerData p;
                    p.addr = actor;
                    p.coordAddr = memoryTools.readPtr(actor + PubgOffset::ObjectParam::CoordOffset);
                    p.team = memoryTools.readInt(actor + PubgOffset::ObjectParam::TeamOffset);
                    p.robot = isActorBot(actor) ? 1 : 0;

                    if (p.robot == 1 && !moduleControl.mainSwitch.botStatus) {
                        free(className);
                        continue;
                    }
                    tmpList.push_back(p);
                }
                free(className);
            }
            staticData.playerDataList = tmpList;
        }
    }
}

void *silenceAimbot(void *) {
    while (true) {
        usleep(16666); 
        if (moduleControl.mainSwitch.aimbotStatus && staticData.selfAddr != 0) {
            MinimalViewInfo pov;
            memoryTools.readMemory(staticData.cameraManager + PubgOffset::PlayerControllerParam::CameraManagerParam::PovOffset, sizeof(pov), &pov);
            
            uintptr_t bestTarget = 0;
            ImVec3 bestCoord = {0,0,0};
            float minFov = moduleControl.aimbotController.aimbotRadius;

            for (auto &p : staticData.playerDataList) {
                uintptr_t mesh = memoryTools.readPtr(p.addr + PubgOffset::ObjectParam::MeshOffset);
                uintptr_t bones = memoryTools.readPtr(mesh + PubgOffset::ObjectParam::MeshParam::BonesOffset) + 48;
                ImVec3 headPos = getBone(mesh + PubgOffset::ObjectParam::MeshParam::HumanOffset, bones, 5);

                if (LineOfSightTo) {
                    if (!LineOfSightTo((void*)staticData.playerController, (void*)p.addr, headPos, false)) continue;
                }

                ImVec2 screenPos = worldToScreen(headPos, pov, ImVec2(kWidth, kHeight));
                float dist = get2dDistance(ImVec2(kWidth/2, kHeight/2), screenPos);

                if (dist < minFov) {
                    minFov = dist;
                    bestTarget = p.addr;
                    bestCoord = headPos;
                }
            }

            if (bestTarget != 0) {
                ImVec2 targetAngle = rotateAngleView(pov.location, bestCoord);
                float curPitch = memoryTools.readFloat(staticData.playerController + 0x4E0);
                float curYaw = memoryTools.readFloat(staticData.playerController + 0x4E4);

                if (AddControllerYawInput && AddControllerPitchInput) {
                    float diffYaw = targetAngle.x - curYaw;
                    float diffPitch = targetAngle.y - curPitch;
                    while (diffYaw > 180) diffYaw -= 360;
                    while (diffYaw < -180) diffYaw += 360;

                    float intensity = moduleControl.aimbotController.aimbotIntensity;
                    AddControllerYawInput((void*)staticData.selfAddr, diffYaw * intensity);
                    AddControllerPitchInput((void*)staticData.selfAddr, diffPitch * intensity);
                }
            }
        }
    }
}
