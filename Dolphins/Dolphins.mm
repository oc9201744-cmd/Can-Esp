//
//  Dolphins.mm
//  Dolphins
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

using namespace std;

ModuleControl moduleControl;
MemoryTools memoryTools;

OffsetValues offsets[] = {
    { 0x102A5125C, 0x10A4A1960, 0x104C0F1E8, 0x10A0557E0 },
    { 0x1028791CC, 0x10A171A00, 0x104510EF0, 0x109AAA1A0 },
    { 0x102AD71F8, 0x10A47D400, 0x10476F14C, 0x109DB5940 },
    { 0x102AAAB0C, 0x10A453300, 0x104742830, 0x109D8B830 }
};

bool (*LineOfSightTo)(void *controller, void *actor, ImVec3 bone_point, bool ischeck);
void (*AddControllerYawInput)(void *actor, float val);
void (*AddControllerRollInput)(void *actor, float val);
void (*AddControllerPitchInput)(void *actor, float val);

long gWorld() {
    OffsetValues off = [OffsetsManager getOffsetsForBundleID:[[NSBundle mainBundle] bundleIdentifier]];
    return reinterpret_cast<long(__fastcall*)(long)>((long)_dyld_get_image_vmaddr_slide(0) + off.gWorldFun)
                                                    ((long)_dyld_get_image_vmaddr_slide(0) + off.gWorldData);
}

long gName() {
    OffsetValues off = [OffsetsManager getOffsetsForBundleID:[[NSBundle mainBundle] bundleIdentifier]];
    return reinterpret_cast<long(__fastcall*)(long)>((long)_dyld_get_image_vmaddr_slide(0) + off.gNameFun)
                                                    ((long)_dyld_get_image_vmaddr_slide(0) + off.gNameData);
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
    int selfTeamID;
    vector<StaticPlayerData>   playerDataList;
    vector<StaticMaterialData> materialDataList;
    vector<StaticMaterialData> smokeList;
} staticData;

static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        mao* drawWindow = [[mao alloc] initWithFrame:&moduleControl];
        mi* menuWindow  = [[mi alloc] initWithFrame:&moduleControl];
        OverlayView* overlayView = [[OverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds:&moduleControl:drawWindow:menuWindow];
        [[UIApplication sharedApplication].keyWindow addSubview:overlayView];
        FloatView* floatView = [[FloatView alloc] initWithFrame:CGRectMake(489, 58, 45, 45):&moduleControl];
        [[UIApplication sharedApplication].keyWindow addSubview:floatView];
    });
}

__attribute__((constructor)) static void initialize() {
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching,
        (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorDrop);
    pthread_t t1, t2;
    pthread_create(&t1, nullptr, readStaticData, nullptr);
    pthread_create(&t2, nullptr, silenceAimbot, nullptr);
}

// TeamID'yi PlayerState üzerinden oku
int getTeamID(uintptr_t actorAddr) {
    if (actorAddr == 0) return -1;
    uintptr_t playerState = memoryTools.readPtr(actorAddr + PubgOffset::ObjectParam::PlayerStateOffset);
    if (playerState == 0) return -1;
    return memoryTools.readInt(playerState + PubgOffset::ObjectParam::TeamOffset);
}

// Bot kontrolü
bool IsBotPlayer(uintptr_t actorAddr) {
    if (actorAddr == 0) return true;
    uint8_t isAI = 0, isMLAI = 0;
    memoryTools.readMemory(actorAddr + PubgOffset::ObjectParam::RobotOffset, 1, &isAI);
    memoryTools.readMemory(actorAddr + PubgOffset::ObjectParam::MLAIOffset,  1, &isMLAI);
    return isAI || isMLAI;
}

void *readStaticData(void *) {
    while (true) {
        sleep(4);
        if (moduleControl.systemStatus != TransmissionNormal) {
            staticData.libAddr = (uintptr_t)_dyld_get_image_vmaddr_slide(0);
            if (staticData.libAddr != 1)
                moduleControl.systemStatus = TransmissionNormal;
        } else {
            staticData.gwlordAddr = gWorld();
            staticData.gnameAddr  = gName();

            // 4 adımlı PlayerController zinciri
            staticData.playerController = memoryTools.readPtr(
                memoryTools.readPtr(
                    memoryTools.readPtr(
                        memoryTools.readPtr(staticData.gwlordAddr + PubgOffset::PlayerControllerOffset[0])
                        + PubgOffset::PlayerControllerOffset[1])
                    + PubgOffset::PlayerControllerOffset[2])
                + PubgOffset::PlayerControllerOffset[3]);

            LineOfSightTo = (bool (*)(void *, void *, ImVec3, bool))(
                memoryTools.readPtr(
                    memoryTools.readPtr(staticData.playerController + 0x0)
                    + PubgOffset::PlayerControllerParam::ControllerFunction::LineOfSightToOffset));

            staticData.selfAddr = memoryTools.readPtr(
                staticData.playerController + PubgOffset::PlayerControllerParam::SelfOffset);

            // Kendi takım ID'sini PlayerState'ten al
            staticData.selfTeamID = getTeamID(staticData.selfAddr);

            uintptr_t selfVtable = memoryTools.readPtr(staticData.selfAddr + 0);
            AddControllerYawInput   = (void (*)(void *, float))(memoryTools.readPtr(selfVtable + PubgOffset::ObjectParam::PlayerFunction::AddControllerYawInputOffset));
            AddControllerRollInput  = (void (*)(void *, float))(memoryTools.readPtr(selfVtable + PubgOffset::ObjectParam::PlayerFunction::AddControllerRollInputOffset));
            AddControllerPitchInput = (void (*)(void *, float))(memoryTools.readPtr(selfVtable + PubgOffset::ObjectParam::PlayerFunction::AddControllerPitchInputOffset));

            staticData.cameraManager = memoryTools.readPtr(
                staticData.playerController + PubgOffset::PlayerControllerParam::CameraManagerOffset);

            vector<StaticPlayerData>   tmpPlayerList;
            vector<StaticMaterialData> tmpMaterialList;
            vector<StaticMaterialData> tmpSmokeList;

            uintptr_t uLevel     = memoryTools.readPtr(staticData.gwlordAddr + PubgOffset::ULevelOffset);
            uintptr_t objArray   = memoryTools.readPtr(uLevel + PubgOffset::ULevelParam::ObjectArrayOffset);
            int       objCount   = memoryTools.readInt(uLevel + PubgOffset::ULevelParam::ObjectCountOffset);

            for (int i = 0; i < objCount; ++i) {
                uintptr_t objAddr = memoryTools.readPtr(objArray + i * 8);
                if (objAddr <= 0x100000000 || objAddr >= 0x2000000000 || objAddr % 8 != 0) continue;

                // Kendi adresini atla
                if (objAddr == staticData.selfAddr) continue;

                uintptr_t coordAddr = memoryTools.readPtr(objAddr + PubgOffset::ObjectParam::CoordOffset);
                string    className = getClassName(memoryTools.readInt(objAddr + PubgOffset::ObjectParam::ClassIdOffset));

                bool isPlayer = (
                    strstr(className.c_str(), "PlayerPawn")          != 0 ||
                    strstr(className.c_str(), "PlayerCharacter")     != 0 ||
                    strstr(className.c_str(), "PlayerControllertSl") != 0 ||
                    strstr(className.c_str(), "CharacterModelTaget") != 0
                );

                if (isPlayer && moduleControl.mainSwitch.playerStatus) {
                    // Takım ID'sini PlayerState'ten al
                    int team = getTeamID(objAddr);
                    if (team != -1 && team == staticData.selfTeamID) continue;

                    // Ölü kontrolü
                    bool isDead = false;
                    memoryTools.readMemory(objAddr + PubgOffset::ObjectParam::DeadOffset, 1, &isDead);
                    if (isDead) continue;

                    // HP kontrolü
                    float hp = memoryTools.readFloat(objAddr + PubgOffset::ObjectParam::HpOffset);
                    if (hp <= 0) continue;

                    // Bot kontrolü
                    bool isBot = IsBotPlayer(objAddr);
                    if (moduleControl.playerSwitch.ignorebot && isBot) continue;

                    StaticPlayerData p;
                    p.addr      = objAddr;
                    p.coordAddr = coordAddr;
                    p.team      = team;
                    p.robot     = isBot ? 1 : 0;
                    p.name      = getPlayerName(memoryTools.readPtr(objAddr + PubgOffset::ObjectParam::NameOffset));
                    p.status    = (int)memoryTools.readInt(objAddr + PubgOffset::ObjectParam::StatusOffset);
                    tmpPlayerList.push_back(p);

                } else if (strstr(className.c_str(), "ProjSmoke_BP_C") != 0) {
                    StaticMaterialData s;
                    s.type = Warning; s.id = 4; s.name = "[WARNING]SMOKE";
                    s.addr = objAddr; s.coordAddr = coordAddr;
                    tmpSmokeList.push_back(s);

                } else if (moduleControl.mainSwitch.materialStatus) {
                    MaterialStruct mat = isMaterial(className.c_str());
                    if (mat.type > -1) {
                        if ((mat.type == Rifle || mat.type == Sniper || mat.type == Missile)
                            && memoryTools.readPtr(objAddr + PubgOffset::ObjectParam::WeaponParam::MasterOffset) != 0)
                            continue;
                        StaticMaterialData m;
                        m.type = mat.type; m.id = mat.id; m.name = mat.name;
                        m.addr = objAddr;  m.coordAddr = coordAddr;
                        tmpMaterialList.push_back(m);
                    }
                }
            }

            staticData.playerDataList.swap(tmpPlayerList);
            staticData.materialDataList.swap(tmpMaterialList);
            staticData.smokeList.swap(tmpSmokeList);
        }
    }
    return nullptr;
}

void readFrameData(ImVec2 screenSize, vector<PlayerData> &playerDataList, vector<MaterialData> &materialDataList) {
    playerDataList.clear();
    materialDataList.clear();
    if (moduleControl.systemStatus != TransmissionNormal) return;

    staticData.cameraManagerClassName    = getClassName(memoryTools.readInt(staticData.cameraManager + PubgOffset::ObjectParam::ClassIdOffset));
    staticData.playerControllerClassName = getClassName(memoryTools.readInt(staticData.playerController + PubgOffset::ObjectParam::ClassIdOffset));

    MinimalViewInfo pov;
    memoryTools.readMemory(staticData.cameraManager + PubgOffset::PlayerControllerParam::CameraManagerParam::PovOffset, sizeof(pov), &pov);

    ImVec3 selfCoord        = pov.location;
    float  lateralAngleView = memoryTools.readFloat(staticData.playerController + PubgOffset::PlayerControllerParam::MouseOffset + 0x4) - 90;

    if (moduleControl.mainSwitch.playerStatus) {
        for (auto &sp : staticData.playerDataList) {
            if (sp.addr == staticData.selfAddr) continue;

            ImVec3 coord;
            memoryTools.readMemory(sp.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, sizeof(ImVec3), &coord);

            float dist = get3dDistance(coord, selfCoord, 100);
            if (dist < 0 || dist > 450) continue;

            float height = memoryTools.readFloat(sp.coordAddr + PubgOffset::ObjectParam::CoordParam::HeightOffset);
            if (height < 20) continue;

            PlayerData pd;
            pd.angle    = lateralAngleView - rotateAngle(selfCoord, coord) - 180;
            pd.radar    = rotateCoord(lateralAngleView, ImVec2((selfCoord.x - coord.x) / 200, (selfCoord.y - coord.y) / 200));
            pd.distance = dist;
            pd.robot    = sp.robot;
            pd.team     = sp.team;

            pd.visibility = isCoordVisibility(coord);
            if (pd.visibility && isOnSmoke(coord)) pd.visibility = false;

            if (height < 50) height -= 18;
            else if (height > 80) height += 12;

            pd.hp = memoryTools.readFloat(sp.addr + PubgOffset::ObjectParam::HpOffset);
            if (pd.hp > 100) pd.hp = 100;

            // Durum
            uint64_t sv = 0;
            memoryTools.readMemory(sp.addr + PubgOffset::ObjectParam::StatusOffset, sizeof(uint64_t), &sv);
            if      (sv == 2097168)  pd.statusName = "DRIVE";
            else if (sv == 524288)   pd.statusName = "KNOCKED";
            else if (sv == 262208)   pd.statusName = "HEALING";
            else if (sv == 33554449) pd.statusName = "PARACHUTE";
            else if (sv == 8205)     pd.statusName = "SHOOT";
            else if (sv == 273)      pd.statusName = "RUN & SHOOT";
            else if (sv == 529)      pd.statusName = "WALK & RELOAD";
            else if (sv == 528)      pd.statusName = "RELOADING";
            else if (sv == 1040)     pd.statusName = "ADS";
            else if (sv == 1088)     pd.statusName = "PRONE ADS";
            else if (sv == 35)       pd.statusName = "CROUCH";
            else if (sv == 64)       pd.statusName = "PRONE";
            else if (sv == 19)       pd.statusName = "RUN";
            else if (sv == 17)       pd.statusName = "WALK";
            else if (sv == 147)      pd.statusName = "JUMP";
            else if (sv == 4194320)  pd.statusName = "IN VEHICLE";
            else                     pd.statusName = "STAND";

            // Silah
            uintptr_t wAddr = memoryTools.readPtr(sp.addr + PubgOffset::ObjectParam::WeaponOneOffset);
            if (wAddr == 0) {
                pd.weaponName = "FIST";
            } else {
                string wClass = getClassName(memoryTools.readInt(wAddr + PubgOffset::ObjectParam::ClassIdOffset));
                MaterialStruct wn = isWeapon(wClass.c_str());
                pd.weaponName = (wn.id != 0) ? wn.name : "UNKNOWN";
            }

            pd.name   = sp.name;
            pd.screen = worldToScreen(coord, pov, screenSize);

            ImVec2 w = worldToScreen(ImVec3(coord.x, coord.y, coord.z + 100), pov, screenSize);
            ImVec2 h = worldToScreen(ImVec3(coord.x, coord.y, coord.z + height), pov, screenSize);
            pd.size.x = (pd.screen.y - w.y) / 2;
            pd.size.y = pd.screen.y - h.y;

            // Skeleton
            uintptr_t meshAddr  = memoryTools.readPtr(sp.addr + PubgOffset::ObjectParam::MeshOffset);
            uintptr_t humanAddr = meshAddr + PubgOffset::ObjectParam::MeshParam::HumanOffset;
            uintptr_t boneAddr  = memoryTools.readPtr(meshAddr + PubgOffset::ObjectParam::MeshParam::BonesOffset) + 48;

            BonesData bd;
            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 5,  bd.head))
            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 4,  bd.pit))
            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 1,  bd.pelvis))
            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 11, bd.lcollar))
            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 32, bd.rcollar))
            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 12, bd.lelbow))
            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 33, bd.relbow))
            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 63, bd.lwrist))
            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 62, bd.rwrist))
            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 52, bd.lthigh))
            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 56, bd.rthigh))
            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 53, bd.lknee))
            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 57, bd.rknee))
            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 54, bd.lankle))
            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 58, bd.rankle))
                pd.bonesData = bd;

            playerDataList.push_back(pd);
        }
    }

    if (moduleControl.mainSwitch.materialStatus) {
        for (auto &sm : staticData.materialDataList) {
            string cn = getClassName(memoryTools.readInt(sm.coordAddr + PubgOffset::ObjectParam::ClassIdOffset));
            if (isRecycled(cn.c_str())) continue;

            ImVec3 coord;
            memoryTools.readMemory(sm.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, sizeof(ImVec3), &coord);

            float dist = get3dDistance(coord, selfCoord, 100);
            if (sm.type > 1 && sm.type < All && dist > 100) continue;
            if (sm.type < 0 && sm.type > All) continue;
            if (!moduleControl.materialSwitch[sm.type]) continue;

            MaterialData md;
            md.type = sm.type; md.id = sm.id; md.name = sm.name;
            md.distance = dist;
            md.screen = worldToScreen(coord, pov, screenSize);
            materialDataList.push_back(md);

            if (sm.type == Airdrop) {
                ImVec2 gs = worldToScreen(coord, pov, screenSize);
                if (get2dDistance(screenSize, gs) < 150) {
                    int cnt = 0;
                    uintptr_t gArr = memoryTools.readPtr(sm.addr + PubgOffset::ObjectParam::GoodsListOffset);
                    int gCnt = memoryTools.readInt(sm.addr + PubgOffset::ObjectParam::GoodsListOffset + sizeof(uintptr_t));
                    for (int i = 0; i < gCnt && i < 100; i++) {
                        int gid = memoryTools.readInt(gArr + 0x4 + i * PubgOffset::ObjectParam::GoodsListParam::DataBase);
                        MaterialStruct g = isBoxMaterial(gid);
                        if (g.type == -1) continue;
                        memset(&md, 0, sizeof(md));
                        cnt++;
                        md.type = g.type; md.id = g.id; md.name = g.name;
                        md.distance = -100;
                        md.screen.x = gs.x;
                        md.screen.y = gs.y - 32 * cnt;
                        materialDataList.push_back(md);
                    }
                }
            }
        }
    }
}

void *silenceAimbot(void *) {
    ImVec2 screenSize = ImVec2([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    while (true) {
        usleep(16666);
        if (moduleControl.systemStatus != TransmissionNormal || !moduleControl.mainSwitch.aimbotStatus) continue;

        uintptr_t wAddr = memoryTools.readPtr(staticData.selfAddr + PubgOffset::ObjectParam::WeaponOneOffset);
        bool enabled    = false;

        switch (moduleControl.aimbotController.aimbotMode) {
            case 0: enabled = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 1; break;
            case 1: enabled = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1; break;
            case 2: enabled = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 1
                           || memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1; break;
            case 3:
                if (memoryTools.readInt(wAddr + PubgOffset::ObjectParam::WeaponParam::ShootModeOffset) >= 1024)
                    enabled = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1;
                else
                    enabled = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 1;
                break;
        }

        if (!enabled) continue;

        MinimalViewInfo pov;
        memoryTools.readMemory(staticData.cameraManager + PubgOffset::PlayerControllerParam::CameraManagerParam::PovOffset, sizeof(pov), &pov);

        ImVec3 selfCoord    = pov.location;
        float  aimbotRadius = moduleControl.aimbotController.aimbotRadius;

        StaticPlayerData target; target.addr = 0;
        ImVec3 aimCoord = {0, 0, 0};

        for (auto &sp : staticData.playerDataList) {
            if (sp.addr == staticData.selfAddr) continue;
            if (moduleControl.playerSwitch.ignorebot && sp.robot == 1) continue;

            ImVec3 coord;
            memoryTools.readMemory(sp.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, sizeof(ImVec3), &coord);

            float dist = get3dDistance(coord, selfCoord, 100);
            if (dist < 0 || dist > 450 || dist > moduleControl.aimbotController.distance) continue;

            float h = memoryTools.readFloat(sp.coordAddr + PubgOffset::ObjectParam::CoordParam::HeightOffset);
            if (h < 20) continue;

            if (memoryTools.readFloat(sp.addr + PubgOffset::ObjectParam::HpOffset) < 0.5 && moduleControl.aimbotController.fallNotAim) continue;

            ImVec2 scr = worldToScreen(coord, pov, screenSize);
            float  sd;

            if ((sd = get2dDistance(screenSize, scr)) < aimbotRadius) {
                uintptr_t mesh  = memoryTools.readPtr(sp.addr + PubgOffset::ObjectParam::MeshOffset);
                uintptr_t human = mesh + PubgOffset::ObjectParam::MeshParam::HumanOffset;
                uintptr_t bones = memoryTools.readPtr(mesh + PubgOffset::ObjectParam::MeshParam::BonesOffset) + 48;

                auto tryBones = [&](int *ids, int cnt) {
                    for (int i = 0; i < cnt; i++) {
                        ImVec3 bc = getBone(human, bones, ids[i]);
                        if (isCoordVisibility(bc)) { target = sp; aimbotRadius = sd; aimCoord = bc; break; }
                    }
                };

                switch (moduleControl.aimbotController.aimbotParts) {
                    case 0: { int ids[] = {5,3,1,11,12,32,33,52,53,54,56,57,58,62,63}; tryBones(ids, 15); } break;
                    case 1: { int ids[] = {3,5,1,11,32,12,33,63,62,52,56,53,57,54,58}; tryBones(ids, 15); } break;
                    case 2: { int ids[] = {5,3,1,11,32,12,33,63,62,52,56,53,57,54,58}; tryBones(ids, 15); } break;
                    case 3: { int ids[] = {5}; tryBones(ids, 1); } break;
                    case 4: { int ids[] = {3}; tryBones(ids, 1); } break;
                }
            }
        }

        if (target.addr == 0 || aimCoord.x == 0) continue;
        if (moduleControl.aimbotController.smoke && isOnSmoke(aimCoord)) continue;

        uintptr_t waAttr = memoryTools.readPtr(wAddr + PubgOffset::ObjectParam::WeaponParam::WeaponAttrOffset);
        float bs  = memoryTools.readFloat(waAttr + PubgOffset::ObjectParam::WeaponParam::WeaponAttrParam::BulletSpeedOffset);
        float bft = get3dDistance(selfCoord, aimCoord, bs) * 1.2;

        ImVec3 mv;
        memoryTools.readMemory(target.addr + PubgOffset::ObjectParam::MoveCoordOffset, 12, &mv);
        if (bs != 1800000) { aimCoord.x += mv.x * bft; aimCoord.y += mv.y * bft; aimCoord.z += mv.z * bft; }

        ImVec2 am = rotateAngleView(selfCoord, aimCoord);
        float ss = memoryTools.readFloat(
            memoryTools.readPtr(staticData.selfAddr + PubgOffset::ObjectParam::CoordOffset)
            + PubgOffset::ObjectParam::CoordParam::HeightOffset);
        string cn = getClassName(memoryTools.readInt(wAddr + PubgOffset::ObjectParam::ClassIdOffset));

        if (ss > 47) {
            if      (strstr(cn.c_str(), "BP_Sniper_AWM_Wrapper_C")    != 0) { am.x += 0.06;  am.y -= 0.06;  }
            else if (strstr(cn.c_str(), "BP_Sniper_M24_Wrapper_C")    != 0) { am.x += 0.04;  am.y -= 0.03;  }
            else if (strstr(cn.c_str(), "BP_Sniper_Kar98k_Wrapper_C") != 0) { am.x += 0.05;  am.y -= 0.02;  }
            else if (strstr(cn.c_str(), "BP_Sniper_Mosin_Wrapper_C")  != 0) { am.x += 0.04;  am.y -= 0.05;  }
            else if (strstr(cn.c_str(), "BP_Sniper_SKS_Wrapper_C")    != 0) { am.x += 0.06;  am.y -= 0.085; }
            else if (strstr(cn.c_str(), "BP_Sniper_SLR_Wrapper_C")    != 0) { am.x += 0.055; am.y -= 0.03;  }
            else if (strstr(cn.c_str(), "BP_Sniper_Mini14_Wrapper_C") != 0) { am.x += 0.015; am.y -= 0.05;  }
            else if (strstr(cn.c_str(), "BP_Rifle_AKM_Wrapper_C")     != 0) { am.x += 0.04;  am.y -= 0.07;  }
            else if (strstr(cn.c_str(), "BP_Rifle_M416_Wrapper_C")    != 0) { am.x += 0.02;  am.y -= 0.08;  }
            else if (strstr(cn.c_str(), "BP_Rifle_M762_Wrapper_C")    != 0) { am.x += 0.03;  am.y -= 0.07;  }
            else if (strstr(cn.c_str(), "BP_Rifle_SCAR_Wrapper_C")    != 0) { am.x += 0.02;  am.y -= 0.085; }
            else if (strstr(cn.c_str(), "BP_Rifle_AUG_Wrapper_C")     != 0) { am.x += 0.015; am.y -= 0.08;  }
            else if (strstr(cn.c_str(), "BP_Rifle_G36_Wrapper_C")     != 0) { am.x += 0.02;  am.y -= 0.055; }
            else if (strstr(cn.c_str(), "BP_Other_M249_Wrapper_C")    != 0) { am.x += 0.025; am.y -= 0.06;  }
            else if (strstr(cn.c_str(), "BP_Other_DP28_Wrapper_C")    != 0) { am.x += 0.045; am.y -= 0.095; }
        }

        if (memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1) {
            float rt = 4.5 - get3dDistance(selfCoord, aimCoord, 10000);
            rt += get3dDistance(selfCoord, aimCoord, 10000) * 0.2;
            float rc = memoryTools.readFloat(waAttr + PubgOffset::ObjectParam::WeaponParam::WeaponAttrParam::RecoilOffset);
            if      (strstr(cn.c_str(), "BP_Sniper_VSS_Wrapper_C") != 0) rc *= 0.4;
            else if (strstr(cn.c_str(), "BP_Rifle_G36_Wrapper_C")  != 0) rc *= 0.6;
            else if (strstr(cn.c_str(), "BP_Rifle_AUG_Wrapper_C")  != 0) rc *= 0.7;
            else if (strstr(cn.c_str(), "BP_Rifle_AKM_Wrapper_C")  != 0) rc *= 1.15;
            else if (strstr(cn.c_str(), "BP_Other_MG3_Wrapper_C")  != 0) rc *= 0.2;
            else if (strstr(cn.c_str(), "BP_Other_DP28_Wrapper_C") != 0) rc *= 0.3;
            if (ss < 50.0f) {
                if      (strstr(cn.c_str(), "BP_Rifle_M762_Wrapper_C") != 0) { rc *= 0.55; am.x += 0.2;  }
                else if (strstr(cn.c_str(), "BP_Other_M249_Wrapper_C") != 0) { rc *= 0.6;  am.x += 0.08; }
                else rc *= 0.35;
            }
            am.y -= rt * rc;
        }

        if (!isfinite(am.x) || !isfinite(am.y)) continue;

        ImVec2 move;
        move.x = change(getAngleDifference(am.x, memoryTools.readFloat(staticData.playerController + PubgOffset::PlayerControllerParam::MouseOffset + 0x4)) * moduleControl.aimbotController.aimbotIntensity);
        move.y = change(getAngleDifference(am.y, memoryTools.readFloat(staticData.playerController + PubgOffset::PlayerControllerParam::MouseOffset)) * moduleControl.aimbotController.aimbotIntensity);

        if (!isfinite(move.x) || !isfinite(move.y)) continue;

        if (AddControllerYawInput)   AddControllerYawInput(reinterpret_cast<void *>(staticData.selfAddr), move.x);
        if (AddControllerRollInput)  AddControllerRollInput(reinterpret_cast<void *>(staticData.selfAddr), move.y);
        if (AddControllerPitchInput) AddControllerPitchInput(reinterpret_cast<void *>(staticData.selfAddr), 0);
    }
    return nullptr;
}

bool isCoordVisibility(ImVec3 coord) {
    if (!LineOfSightTo || !isfinite(coord.x) || !isfinite(coord.y) || !isfinite(coord.z)) return false;
    if (strstr(staticData.cameraManagerClassName.c_str(), "PlayerCameraManager") != 0
     && strstr(staticData.playerControllerClassName.c_str(), "PlayerController") != 0)
        return LineOfSightTo(reinterpret_cast<void *>(staticData.playerController),
                             reinterpret_cast<void *>(staticData.cameraManager), coord, false);
    return false;
}

bool isOnSmoke(ImVec3 coord) {
    for (auto &s : staticData.smokeList) {
        ImVec3 sc;
        memoryTools.readMemory(s.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, 30, &sc);
        if (get3dDistance(sc, coord, 100) < 4) return true;
    }
    return false;
}

char *getPlayerName(uintptr_t addr) {
    char *buf = (char *)malloc(448);
    unsigned short buf16[16] = {0};
    memoryTools.readMemory(addr, 28, buf16);
    unsigned short *s = buf16;
    char *d = buf, *end = buf + 32;
    while (s < buf16 + 16) {
        if (*s <= 0x7F && d + 1 < end) { *d++ = (char)*s; }
        else if (*s <= 0x7FF && d + 2 < end) { *d++ = (*s >> 6) | 0xC0; *d++ = (*s & 0x3F) | 0x80; }
        else if (d + 3 < end) { *d++ = (*s >> 12) | 0xE0; *d++ = ((*s >> 6) & 0x3F) | 0x80; *d++ = (*s & 0x3F) | 0x80; }
        else break;
        s++;
    }
    *d = 0;
    return buf;
}

char *getClassName(int classId) {
    char *buf = (char *)malloc(64);
    memset(buf, 0, 64);
    if (classId > 0 && classId < 2000000) {
        int page  = classId / 16384;
        int index = classId % 16384;
        uintptr_t pageAddr = memoryTools.readPtr(staticData.gnameAddr + page * sizeof(uintptr_t));
        uintptr_t nameAddr = memoryTools.readPtr(pageAddr + index * sizeof(uintptr_t)) + PubgOffset::ObjectParam::ClassNameOffset;
        memoryTools.readMemory(nameAddr, 64, buf);
    }
    return buf;
}

ImVec3 getBone(uintptr_t human, uintptr_t bones, int part) {
    Ue4Transform af, bf;
    memoryTools.readMemory(human,        sizeof(ImVec4), &af.rotation);
    memoryTools.readMemory(human + 0x10, sizeof(ImVec3), &af.translation);
    memoryTools.readMemory(human + 0x20, sizeof(ImVec3), &af.scale3d);
    memoryTools.readMemory(bones + part * 48,        sizeof(ImVec4), &bf.rotation);
    memoryTools.readMemory(bones + part * 48 + 0x10, sizeof(ImVec3), &bf.translation);
    memoryTools.readMemory(bones + part * 48 + 0x20, sizeof(ImVec3), &bf.scale3d);
    return matrixToVector(matrixMulti(transformToMatrix(bf), transformToMatrix(af)));
}

bool getBone2d(MinimalViewInfo pov, ImVec2 screen, uintptr_t human, uintptr_t bones, int part, ImVec2 &buf) {
    buf = worldToScreen(getBone(human, bones, part), pov, screen);
    return buf.x != 0 && buf.y != 0;
}