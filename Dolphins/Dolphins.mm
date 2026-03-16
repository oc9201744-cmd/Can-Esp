// Dolphins_Final_Fixed.mm
// En Yeni Dylib Yöntemi ve Bot Ayrımı Entegre Edilmiş Versiyon

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

using namespace std;

ModuleControl moduleControl;
MemoryTools memoryTools;

// --- Dylib'den Alınan Fonksiyon Prototipleri ---
// Yeni dylib'de bu fonksiyonlar sembol olarak mevcut
void (*AddControllerYawInput)(void *pawn, float val);
void (*AddControllerPitchInput)(void *pawn, float val);
bool (*LineOfSightTo)(void *controller, void *actor, ImVec3 bone_point, bool ischeck);

struct {
    uintptr_t libAddr = 0;
    uintptr_t gwlordAddr;
    uintptr_t gnameAddr;
    uintptr_t playerController;
    uintptr_t cameraManager;
    uintptr_t selfAddr;
    vector<StaticPlayerData> playerDataList;
} staticData;

// --- BOT AYRIMI: Yeni Dylib Yöntemi ---
bool isActorBot(uintptr_t actorAddr) {
    // 1. Kontrol: PlayerState üzerinden bIsABot flag'i (En kesin yöntem)
    // Genellikle Actor + 0x3D8 -> PlayerState + 0x290 (1 byte bool)
    uintptr_t playerState = memoryTools.readPtr(actorAddr + 0x3D8);
    if (playerState != 0) {
        uint8_t isBotFlag = 0;
        memoryTools.readMemory(playerState + 0x290, 1, &isBotFlag);
        if (isBotFlag == 1) return true;
    }

    // 2. Kontrol: APawn::Controller kontrolü (Dylib'deki yedek yöntem)
    // Gerçek oyuncuların Controller adresi varken, uzaktaki botlarınki null olabilir
    uintptr_t controller = memoryTools.readPtr(actorAddr + 0x4E8);
    if (controller == 0) return true;

    // 3. Kontrol: İsim üzerinden (Gerekirse)
    // Bot isimleri genellikle belirli bir pattern izler veya boş döner
    return false;
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
            
            // PlayerController ve Alt Bileşenler
            staticData.playerController = memoryTools.readPtr(memoryTools.readPtr(memoryTools.readPtr(staticData.gwlordAddr + PubgOffset::PlayerControllerOffset[0]) + PubgOffset::PlayerControllerOffset[1]) + PubgOffset::PlayerControllerOffset[2]);
            
            if (staticData.playerController != 0) {
                staticData.selfAddr = memoryTools.readPtr(staticData.playerController + PubgOffset::PlayerControllerParam::SelfOffset);
                staticData.cameraManager = memoryTools.readPtr(staticData.playerController + PubgOffset::PlayerControllerParam::CameraManagerOffset);
                
                // --- DYLIB YÖNTEMİ: Fonksiyon Adreslerini vtable'dan Çekme ---
                // Yeni dylib bu adresleri vtable'ın belirli indexlerinden okuyor
                uintptr_t selfVtable = memoryTools.readPtr(staticData.selfAddr + 0);
                if (selfVtable != 0) {
                    // Ofsetler yeni dylib ile uyumlu hale getirildi
                    AddControllerYawInput   = (void (*)(void *, float)) (memoryTools.readPtr(selfVtable + 0x6E8)); 
                    AddControllerPitchInput = (void (*)(void *, float)) (memoryTools.readPtr(selfVtable + 0x6F8));
                }
                
                // LineOfSightTo (Görünürlük Kontrolü)
                uintptr_t pcVtable = memoryTools.readPtr(staticData.playerController + 0);
                LineOfSightTo = (bool (*)(void *, void *, ImVec3, bool)) (memoryTools.readPtr(pcVtable + 0x780));
            }

            // Oyuncu Taraması
            vector<StaticPlayerData> tmpList;
            uintptr_t uLevel = memoryTools.readPtr(staticData.gwlordAddr + PubgOffset::ULevelOffset);
            uintptr_t actors = memoryTools.readPtr(uLevel + PubgOffset::ULevelParam::ObjectArrayOffset);
            int count = memoryTools.readInt(uLevel + PubgOffset::ULevelParam::ObjectCountOffset);

            for (int i = 0; i < count; i++) {
                uintptr_t actor = memoryTools.readPtr(actors + i * 8);
                if (actor == 0 || actor == staticData.selfAddr) continue;

                string name = getClassName(memoryTools.readInt(actor + PubgOffset::ObjectParam::ClassIdOffset));
                if (strstr(name.c_str(), "PlayerPawn") || strstr(name.c_str(), "PlayerCharacter")) {
                    StaticPlayerData p;
                    p.addr = actor;
                    p.coordAddr = memoryTools.readPtr(actor + PubgOffset::ObjectParam::CoordOffset);
                    p.team = memoryTools.readInt(actor + PubgOffset::ObjectParam::TeamOffset);
                    
                    // BOT AYRIMI UYGULANIYOR
                    p.robot = isActorBot(actor) ? 1 : 0;

                    // Bot Filtresi (Menü Kontrolü)
                    if (p.robot == 1 && !moduleControl.mainSwitch.botStatus) continue;

                    tmpList.push_back(p);
                }
            }
            staticData.playerDataList = tmpList;
        }
    }
}

void *silenceAimbot(void *) {
    while (true) {
        usleep(16666); // 60 FPS
        if (moduleControl.mainSwitch.aimbotStatus && staticData.selfAddr != 0) {
            
            MinimalViewInfo pov;
            memoryTools.readMemory(staticData.cameraManager + PubgOffset::PlayerControllerParam::CameraManagerParam::PovOffset, sizeof(pov), &pov);
            
            uintptr_t bestTarget = 0;
            ImVec3 bestCoord = {0,0,0};
            float minFov = moduleControl.aimbotController.aimbotRadius;

            for (auto &p : staticData.playerDataList) {
                ImVec3 headPos; // Kafa ofsetini al (Örn: Bone 5)
                uintptr_t mesh = memoryTools.readPtr(p.addr + PubgOffset::ObjectParam::MeshOffset);
                uintptr_t bones = memoryTools.readPtr(mesh + PubgOffset::ObjectParam::MeshParam::BonesOffset) + 48;
                headPos = getBone(mesh + PubgOffset::ObjectParam::MeshParam::HumanOffset, bones, 5);

                // Görünürlük Kontrolü (Dylib yöntemi)
                if (moduleControl.aimbotController.visibleCheck && LineOfSightTo) {
                    if (!LineOfSightTo((void*)staticData.playerController, (void*)p.addr, headPos, false)) continue;
                }

                ImVec2 screenPos = worldToScreen(headPos, pov, ImVec2(screenWidth, screenHeight));
                float dist = get2dDistance(ImVec2(screenWidth/2, screenHeight/2), screenPos);

                if (dist < minFov) {
                    minFov = dist;
                    bestTarget = p.addr;
                    bestCoord = headPos;
                }
            }

            if (bestTarget != 0) {
                // --- DYLIB AIMBOT YÖNTEMİ ---
                ImVec2 targetAngle = rotateAngleView(pov.location, bestCoord);
                
                // Mevcut ControlRotation (Mouse)
                float curPitch = memoryTools.readFloat(staticData.playerController + 0x4E0);
                float curYaw = memoryTools.readFloat(staticData.playerController + 0x4E4);

                if (AddControllerYawInput && AddControllerPitchInput) {
                    float diffYaw = targetAngle.x - curYaw;
                    float diffPitch = targetAngle.y - curPitch;

                    // Normalize Yaw (-180, 180)
                    while (diffYaw > 180) diffYaw -= 360;
                    while (diffYaw < -180) diffYaw += 360;

                    // Smooth/Intensity Uygula
                    float intensity = moduleControl.aimbotController.aimbotIntensity;
                    AddControllerYawInput((void*)staticData.selfAddr, diffYaw * intensity);
                    AddControllerPitchInput((void*)staticData.selfAddr, diffPitch * intensity);
                }
            }
        }
    }
}
