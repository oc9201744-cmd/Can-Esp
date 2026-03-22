//
//  Dolphins.m
//  Final fix - self box, bot filtering, skeleton
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

OffsetValues regionOffsets[] = {
    { 0x102A62208, 0x10A566E00, 0x104bd8740, 0x10a1178b0 },
    { 0x1028791CC, 0x10A171A00, 0x104510EF0, 0x109AAA1A0 },
    { 0x102AD71F8, 0x10A47D400, 0x10476F14C, 0x109DB5940 },
    { 0x102AAAB0C, 0x10A453300, 0x104742830, 0x109D8B830 }
};

void *readStaticData(void *);
void *silenceAimbot(void *);
char *getPlayerName(uintptr_t addr);
char *getClassName(int classId);
bool isCoordVisibility(ImVec3 coord);
bool isOnSmoke(ImVec3 coord);
ImVec3 getBone(uintptr_t human, uintptr_t bones, int part);
bool getBone2d(MinimalViewInfo pov, ImVec2 screen, uintptr_t human, uintptr_t bones, int part, ImVec2 &buf);

bool (*LineOfSightTo)(void *controller, void *actor, ImVec3 bone_point, bool ischeck);
void (*AddControllerYawInput)(void *actor, float val);
void (*AddControllerRollInput)(void *actor, float val);
void (*AddControllerPitchInput)(void *actor, float val);

struct {
    uintptr_t libAddr = 0;
    uintptr_t gwlordAddr;
    uintptr_t gnameAddr;
    uintptr_t playerController;
    string playerControllerClassName;
    uintptr_t cameraManager;
    string cameraManagerClassName;
    uintptr_t selfAddr;
    string selfName;
    int selfTeam;
    vector<StaticPlayerData> playerDataList;
    vector<StaticMaterialData> materialDataList;
    vector<StaticMaterialData> smokeList;
} staticData;

const int BONE_HEAD = 5;
const int BONE_NECK = 4;
const int BONE_SPINE1 = 3;
const int BONE_SPINE2 = 2;
const int BONE_SPINE3 = 1;
const int BONE_LEFT_SHOULDER = 11;
const int BONE_LEFT_ELBOW = 12;
const int BONE_LEFT_WRIST = 63;
const int BONE_RIGHT_SHOULDER = 32;
const int BONE_RIGHT_ELBOW = 33;
const int BONE_RIGHT_WRIST = 62;
const int BONE_LEFT_HIP = 52;
const int BONE_LEFT_KNEE = 53;
const int BONE_LEFT_ANKLE = 54;
const int BONE_RIGHT_HIP = 56;
const int BONE_RIGHT_KNEE = 57;
const int BONE_RIGHT_ANKLE = 58;

struct FullSkeletonBones {
    ImVec2 head, neck, spine1, spine2, spine3;
    ImVec2 leftShoulder, leftElbow, leftWrist;
    ImVec2 rightShoulder, rightElbow, rightWrist;
    ImVec2 leftHip, leftKnee, leftAnkle;
    ImVec2 rightHip, rightKnee, rightAnkle;
    bool isValid;
};

FullSkeletonBones GetFullSkeleton(MinimalViewInfo pov, ImVec2 screenSize, uintptr_t humanAddr, uintptr_t boneAddr) {
    FullSkeletonBones skeleton;
    skeleton.isValid = false;
    if (humanAddr == 0 || boneAddr == 0) return skeleton;
    
    bool success = true;
    success &= getBone2d(pov, screenSize, humanAddr, boneAddr, BONE_HEAD, skeleton.head);
    success &= getBone2d(pov, screenSize, humanAddr, boneAddr, BONE_NECK, skeleton.neck);
    success &= getBone2d(pov, screenSize, humanAddr, boneAddr, BONE_SPINE1, skeleton.spine1);
    success &= getBone2d(pov, screenSize, humanAddr, boneAddr, BONE_SPINE2, skeleton.spine2);
    success &= getBone2d(pov, screenSize, humanAddr, boneAddr, BONE_SPINE3, skeleton.spine3);
    success &= getBone2d(pov, screenSize, humanAddr, boneAddr, BONE_LEFT_SHOULDER, skeleton.leftShoulder);
    success &= getBone2d(pov, screenSize, humanAddr, boneAddr, BONE_LEFT_ELBOW, skeleton.leftElbow);
    success &= getBone2d(pov, screenSize, humanAddr, boneAddr, BONE_LEFT_WRIST, skeleton.leftWrist);
    success &= getBone2d(pov, screenSize, humanAddr, boneAddr, BONE_RIGHT_SHOULDER, skeleton.rightShoulder);
    success &= getBone2d(pov, screenSize, humanAddr, boneAddr, BONE_RIGHT_ELBOW, skeleton.rightElbow);
    success &= getBone2d(pov, screenSize, humanAddr, boneAddr, BONE_RIGHT_WRIST, skeleton.rightWrist);
    success &= getBone2d(pov, screenSize, humanAddr, boneAddr, BONE_LEFT_HIP, skeleton.leftHip);
    success &= getBone2d(pov, screenSize, humanAddr, boneAddr, BONE_LEFT_KNEE, skeleton.leftKnee);
    success &= getBone2d(pov, screenSize, humanAddr, boneAddr, BONE_LEFT_ANKLE, skeleton.leftAnkle);
    success &= getBone2d(pov, screenSize, humanAddr, boneAddr, BONE_RIGHT_HIP, skeleton.rightHip);
    success &= getBone2d(pov, screenSize, humanAddr, boneAddr, BONE_RIGHT_KNEE, skeleton.rightKnee);
    success &= getBone2d(pov, screenSize, humanAddr, boneAddr, BONE_RIGHT_ANKLE, skeleton.rightAnkle);
    
    skeleton.isValid = success;
    return skeleton;
}

bool IsBotPlayer(uintptr_t playerAddr) {
    uint8_t isAI = 0;
    uint8_t isMLAI = 0;
    memoryTools.readMemory(playerAddr + 0xa40, 1, &isAI);
    memoryTools.readMemory(playerAddr + 0xa41, 1, &isMLAI);
    return (isAI != 0) || (isMLAI != 0);
}

bool IsSelfPlayer(uintptr_t playerAddr) {
    return (playerAddr == staticData.selfAddr);
}

long gWorld() {
    long slide = (long)_dyld_get_image_vmaddr_slide(0);
    long gworld_func_addr = slide + PubgOffset::Global::gworld_func;
    long gworld_data_addr = slide + PubgOffset::Global::gworld_data;
    return reinterpret_cast<long(__fastcall*)(long)>(gworld_func_addr)(gworld_data_addr);
}

long gName() {
    long slide = (long)_dyld_get_image_vmaddr_slide(0);
    long gname_func_addr = slide + PubgOffset::Global::gname_func;
    long gname_data_addr = slide + PubgOffset::Global::gname_data;
    return reinterpret_cast<long(__fastcall*)(long)>(gname_func_addr)(gname_data_addr);
}

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

char *getClassName(int classId) {
    char *buf = (char *)malloc(64);
    if (classId > 0 && classId < 2000000) {
        int page = classId / 16384;
        int index = classId % 16384;
        uintptr_t pageAddr = memoryTools.readPtr(staticData.gnameAddr + page * sizeof(uintptr_t));
        uintptr_t nameAddr = memoryTools.readPtr(pageAddr + index * sizeof(uintptr_t)) + PubgOffset::ObjectParam::ClassNameOffset;
        memoryTools.readMemory(nameAddr, 64, buf);
    }
    return buf;
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

bool getBone2d(MinimalViewInfo pov, ImVec2 screen, uintptr_t human, uintptr_t bones, int part, ImVec2 &buf) {
    ImVec3 newmatrix = getBone(human, bones, part);
    buf = worldToScreen(newmatrix, pov, screen);
    return buf.x != 0 && buf.y != 0;
}

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
    for (StaticMaterialData smoke : staticData.smokeList) {
        ImVec3 smokeCoord;
        memoryTools.readMemory(smoke.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, 30, &smokeCoord);
        if (get3dDistance(smokeCoord, coord, 100) < 4) {
            return true;
        }
    }
    return false;
}

void *readStaticData(void *) {
    while (true) {
        sleep(4);
        if(moduleControl.systemStatus != TransmissionNormal) {
            staticData.libAddr = (uintptr_t)_dyld_get_image_vmaddr_slide(0);
            if(staticData.libAddr != 1) {
                moduleControl.systemStatus = TransmissionNormal;
            }
        } else if (moduleControl.systemStatus == TransmissionNormal) {
            staticData.gwlordAddr = gWorld();
            staticData.gnameAddr = gName();
            
            staticData.playerController = memoryTools.readPtr(
                memoryTools.readPtr(
                    memoryTools.readPtr(staticData.gwlordAddr + PubgOffset::PlayerControllerOffset[0]) + 
                    PubgOffset::PlayerControllerOffset[1]
                ) + PubgOffset::PlayerControllerOffset[2]
            );
            
            LineOfSightTo = (bool (*)(void *, void *, ImVec3, bool)) (
                memoryTools.readPtr(
                    memoryTools.readPtr(staticData.playerController + 0x0) + 
                    PubgOffset::PlayerControllerParam::ControllerFunction::LineOfSightToOffset
                )
            );
            
            staticData.selfAddr = memoryTools.readPtr(staticData.playerController + PubgOffset::PlayerControllerParam::SelfOffset);
            staticData.selfTeam = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::TeamOffset);
            // kendi ismini de sakla
            uintptr_t namePtr = memoryTools.readPtr(staticData.selfAddr + PubgOffset::ObjectParam::NameOffset);
            char *selfNameBuf = getPlayerName(namePtr);
            staticData.selfName = selfNameBuf ? selfNameBuf : "";
            free(selfNameBuf);
            
            uintptr_t selfFunction = memoryTools.readPtr(staticData.selfAddr + 0);
            AddControllerYawInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::ObjectParam::PlayerFunction::AddControllerYawInputOffset));
            AddControllerRollInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::ObjectParam::PlayerFunction::AddControllerRollInputOffset));
            AddControllerPitchInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::ObjectParam::PlayerFunction::AddControllerPitchInputOffset));
            
            staticData.cameraManager = memoryTools.readPtr(staticData.playerController + PubgOffset::PlayerControllerParam::CameraManagerOffset);
            
            vector<StaticPlayerData> tmpPlayerDataList;
            vector<StaticMaterialData> tmpMaterialDataList;
            vector<StaticMaterialData> tmpSmokeList;
            
            uintptr_t uLevel = memoryTools.readPtr(staticData.gwlordAddr + PubgOffset::ULevelOffset);
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
                    strstr(className.c_str(), "PlayerPawn") != 0 ||
                    strstr(className.c_str(), "PlayerCharacter") != 0 ||
                    strstr(className.c_str(), "STExtraPlayerCharacter") != 0 ||
                    strstr(className.c_str(), "CharacterModelTaget") != 0
                );
                
                if (isPlayer && moduleControl.mainSwitch.playerStatus) {
                    int team = memoryTools.readInt(objectAddr + PubgOffset::ObjectParam::TeamOffset);
                    
                    // Kendini ve takım arkadaşlarını atla
                    if (IsSelfPlayer(objectAddr) || team == staticData.selfTeam) continue;
                    
                    StaticPlayerData tmpPlayerData;
                    
                    bool isDead = false;
                    memoryTools.readMemory(objectAddr + PubgOffset::ObjectParam::DeadOffset, 1, &isDead);
                    if (isDead) continue;
                    
                    bool isBot = IsBotPlayer(objectAddr);
                    
                    // Bot filtreleme: eğer menüde botları gizle seçiliyse botları listeye ekleme
                    if (moduleControl.playerSwitch.ignorebot && isBot) continue;
                    
                    tmpPlayerData.addr = objectAddr;
                    tmpPlayerData.coordAddr = coordAddr;
                    tmpPlayerData.team = team;
                    tmpPlayerData.name = getPlayerName(memoryTools.readPtr(objectAddr + PubgOffset::ObjectParam::NameOffset));
                    tmpPlayerData.robot = isBot ? 1 : 0;
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
                        
                        if ((material.type == Rifle || material.type == Sniper || material.type == Missile) && 
                            memoryTools.readPtr(objectAddr + PubgOffset::ObjectParam::WeaponParam::MasterOffset) != 0) {
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

void readFrameData(ImVec2 screenSize, vector<PlayerData> &playerDataList, vector<MaterialData> &materialDataList) {
    playerDataList.clear();
    materialDataList.clear();
    
    if (moduleControl.systemStatus == TransmissionNormal) {
        staticData.cameraManagerClassName = getClassName(memoryTools.readInt(staticData.cameraManager + PubgOffset::ObjectParam::ClassIdOffset));
        staticData.playerControllerClassName = getClassName(memoryTools.readInt(staticData.playerController + PubgOffset::ObjectParam::ClassIdOffset));
        
        MinimalViewInfo pov;
        memoryTools.readMemory(staticData.cameraManager + PubgOffset::PlayerControllerParam::CameraManagerParam::PovOffset, sizeof(pov), &pov);
        
        ImVec3 selfCoord = pov.location;
        float lateralAngleView = memoryTools.readFloat(staticData.playerController + PubgOffset::PlayerControllerParam::MouseOffset + 0x4) - 90;
        
        if (moduleControl.mainSwitch.playerStatus) {
            for (auto staticPlayerData : staticData.playerDataList) {
                // Kendini adres ve isimle filtrele (çift güvenlik)
                if (IsSelfPlayer(staticPlayerData.addr) || staticPlayerData.name == staticData.selfName) continue;
                
                ImVec3 objectCoord;
                memoryTools.readMemory(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, sizeof(ImVec3), &objectCoord);
                
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
                
                if (playerData.visibility && isOnSmoke(objectCoord)) {
                    playerData.visibility = false;
                }
                
                if (objectHeight < 50) {
                    objectHeight -= 18;
                } else if (objectHeight > 80) {
                    objectHeight += 12;
                }
                
                playerData.team = staticPlayerData.team;
                playerData.hp = memoryTools.readFloat(staticPlayerData.addr + PubgOffset::ObjectParam::HpOffset);
                if (playerData.hp > 100) playerData.hp = 100;
                
                uintptr_t statusAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::StatusOffset);
                if (statusAddr == 2097168) playerData.statusName = "DRIVE";
                else if (statusAddr == 262208) playerData.statusName = "HEALING";
                else if (statusAddr == 33554449) playerData.statusName = "FLYING ON PARACHUTE";
                else if (statusAddr == 262160 || statusAddr == 16) playerData.statusName = "STAND";
                else if (statusAddr == 524288 || statusAddr == 524289) playerData.statusName = "KNOCKED";
                else if (statusAddr == 147) playerData.statusName = "JUMP";
                else if (statusAddr == 529) playerData.statusName = "WALK & RELOADING";
                else if (statusAddr == 35) playerData.statusName = "CROUCHING";
                else if (statusAddr == 8205) playerData.statusName = "SHOOTING";
                else if (statusAddr == 1040) playerData.statusName = "ADS";
                else if (statusAddr == 19) playerData.statusName = "RUNNING";
                else if (statusAddr == 64) playerData.statusName = "PRONE";
                else if (statusAddr == 32) playerData.statusName = "CROUCH";
                else if (statusAddr == 17) playerData.statusName = "WALK";
                else playerData.statusName = "UNKNOWN";
                
                uintptr_t weaponMgr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::WeaponManagerComponentOffset);
                uintptr_t weaponAddr = memoryTools.readPtr(weaponMgr + PubgOffset::ObjectParam::WeaponOneOffset);
                
                if (weaponAddr == 0) {
                    playerData.weaponName = "FIST";
                } else {
                    string weaponClass = getClassName(memoryTools.readInt(weaponAddr + PubgOffset::ObjectParam::ClassIdOffset));
                    MaterialStruct weaponName = isWeapon(weaponClass.c_str());
                    playerData.weaponName = weaponName.id != 0 ? weaponName.name : "[RIFLE]M762";
                }
                
                playerData.name = staticPlayerData.name;
                playerData.screen = worldToScreen(objectCoord, pov, screenSize);
                
                ImVec2 width = worldToScreen(ImVec3(objectCoord.x, objectCoord.y, objectCoord.z + 100), pov, screenSize);
                ImVec2 height = worldToScreen(ImVec3(objectCoord.x, objectCoord.y, objectCoord.z + objectHeight), pov, screenSize);
                playerData.size.x = (playerData.screen.y - width.y) / 2;
                playerData.size.y = playerData.screen.y - height.y;
                
                uintptr_t meshAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::MeshOffset);
                if (meshAddr) {
                    uintptr_t humanAddr = meshAddr + PubgOffset::ObjectParam::MeshParam::HumanOffset;
                    uintptr_t boneAddr = memoryTools.readPtr(meshAddr + PubgOffset::ObjectParam::MeshParam::BonesOffset) + 48;
                    
                    FullSkeletonBones skeleton = GetFullSkeleton(pov, screenSize, humanAddr, boneAddr);
                    
                    if (skeleton.isValid) {
                        playerData.bonesData.head = skeleton.head;
                        playerData.bonesData.pit = skeleton.neck;
                        playerData.bonesData.pelvis = skeleton.spine3;
                        playerData.bonesData.lcollar = skeleton.leftShoulder;
                        playerData.bonesData.rcollar = skeleton.rightShoulder;
                        playerData.bonesData.lelbow = skeleton.leftElbow;
                        playerData.bonesData.relbow = skeleton.rightElbow;
                        playerData.bonesData.lwrist = skeleton.leftWrist;
                        playerData.bonesData.rwrist = skeleton.rightWrist;
                        playerData.bonesData.lthigh = skeleton.leftHip;
                        playerData.bonesData.rthigh = skeleton.rightHip;
                        playerData.bonesData.lknee = skeleton.leftKnee;
                        playerData.bonesData.rknee = skeleton.rightKnee;
                        playerData.bonesData.lankle = skeleton.leftAnkle;
                        playerData.bonesData.rankle = skeleton.rightAnkle;
                    } else {
                        // Fallback: sadece baş ve boyun dene
                        ImVec2 head2d, neck2d;
                        if (getBone2d(pov, screenSize, humanAddr, boneAddr, BONE_HEAD, head2d) &&
                            getBone2d(pov, screenSize, humanAddr, boneAddr, BONE_NECK, neck2d)) {
                            playerData.bonesData.head = head2d;
                            playerData.bonesData.pit = neck2d;
                        }
                    }
                }
                playerDataList.push_back(playerData);
            }
        }
        
        if (moduleControl.mainSwitch.materialStatus) {
            for (auto staticMaterialData : staticData.materialDataList) {
                string className = getClassName(memoryTools.readInt(staticMaterialData.coordAddr + PubgOffset::ObjectParam::ClassIdOffset));
                if (isRecycled(className.c_str())) continue;
                
                ImVec3 objectCoord;
                memoryTools.readMemory(staticMaterialData.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, sizeof(ImVec3), &objectCoord);
                
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
            }
        }
    }
}

void *silenceAimbot(void *) {
    ImVec2 screenSize = ImVec2(kWidth, kHeight);
    
    while (true) {
        usleep(16666);
        if (moduleControl.systemStatus == TransmissionNormal && moduleControl.mainSwitch.aimbotStatus) {
            uintptr_t weaponMgr = memoryTools.readPtr(staticData.selfAddr + PubgOffset::ObjectParam::WeaponManagerComponentOffset);
            uintptr_t weaponAddr = memoryTools.readPtr(weaponMgr + PubgOffset::ObjectParam::WeaponOneOffset);
            
            bool enabledAimbot = false;
            switch (moduleControl.aimbotController.aimbotMode) {
                case 0:
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 1;
                    break;
                case 1:
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1;
                    break;
                case 2:
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenTheSightOffset) == 1 || 
                                   memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1;
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
                
                for (auto staticPlayerData : staticData.playerDataList) {
                    if (IsSelfPlayer(staticPlayerData.addr)) continue;
                    
                    ImVec3 objectCoord;
                    memoryTools.readMemory(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, sizeof(ImVec3), &objectCoord);
                    
                    float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
                    if (objectDistance < 0 || objectDistance > 450 || 
                        objectDistance > moduleControl.aimbotController.distance) continue;
                    
                    float objectHeight = memoryTools.readFloat(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::HeightOffset);
                    if (objectHeight < 20) continue;
                    
                    if (memoryTools.readFloat(staticPlayerData.addr + PubgOffset::ObjectParam::HpOffset) < 0.5 && 
                        moduleControl.aimbotController.fallNotAim) continue;
                    
                    ImVec2 playerScreen = worldToScreen(objectCoord, pov, screenSize);
                    float screenDistance = get2dDistance(screenSize, playerScreen);
                    
                    if (screenDistance < aimbotRadius) {
                        uintptr_t meshAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::MeshOffset);
                        if (!meshAddr) continue;
                        
                        uintptr_t humanAddr = meshAddr + PubgOffset::ObjectParam::MeshParam::HumanOffset;
                        uintptr_t boneAddr = memoryTools.readPtr(meshAddr + PubgOffset::ObjectParam::MeshParam::BonesOffset) + 48;
                        
                        switch (moduleControl.aimbotController.aimbotParts) {
                            case 0: {
                                int boneIds[] = {5, 4, 3, 11, 12, 32, 33, 52, 53, 54, 56, 57, 58, 62, 63};
                                for (int i = 0; i < 15; i++) {
                                    aimbotCoord = getBone(humanAddr, boneAddr, boneIds[i]);
                                    if (isCoordVisibility(aimbotCoord)) {
                                        aimbotPlayerData = staticPlayerData;
                                        aimbotRadius = screenDistance;
                                        break;
                                    }
                                    aimbotCoord = {0, 0, 0};
                                }
                                break;
                            }
                            case 1: {
                                int boneIds[] = {4, 3, 5, 1, 11, 32, 12, 33, 63, 62, 52, 56, 53, 57, 54, 58};
                                for (int i = 0; i < 16; i++) {
                                    aimbotCoord = getBone(humanAddr, boneAddr, boneIds[i]);
                                    if (isCoordVisibility(aimbotCoord)) {
                                        aimbotPlayerData = staticPlayerData;
                                        aimbotRadius = screenDistance;
                                        break;
                                    }
                                    aimbotCoord = {0, 0, 0};
                                }
                                break;
                            }
                            case 3:
                                aimbotCoord = getBone(humanAddr, boneAddr, 5);
                                if (isCoordVisibility(aimbotCoord)) {
                                    aimbotPlayerData = staticPlayerData;
                                    aimbotRadius = screenDistance;
                                } else {
                                    aimbotCoord = {0, 0, 0};
                                }
                                break;
                            case 4:
                                aimbotCoord = getBone(humanAddr, boneAddr, 4);
                                if (isCoordVisibility(aimbotCoord)) {
                                    aimbotPlayerData = staticPlayerData;
                                    aimbotRadius = screenDistance;
                                } else {
                                    aimbotCoord = {0, 0, 0};
                                }
                                break;
                        }
                    }
                }
                
                if (aimbotPlayerData.addr != 0 && aimbotCoord.x != 0) {
                    if (moduleControl.aimbotController.smoke && isOnSmoke(aimbotCoord)) {
                        aimbotCoord = {0, 0, 0};
                        continue;
                    }
                    
                    uintptr_t weaponAttrAddr = memoryTools.readPtr(weaponAddr + PubgOffset::ObjectParam::WeaponParam::WeaponAttrOffset);
                    float bulletSpeed = memoryTools.readFloat(weaponAttrAddr + PubgOffset::ObjectParam::WeaponParam::WeaponAttrParam::BulletSpeedOffset);
                    float bulletFlyTime = get3dDistance(selfCoord, aimbotCoord, bulletSpeed) * 1.2;
                    
                    ImVec3 moveCoord;
                    memoryTools.readMemory(aimbotPlayerData.addr + PubgOffset::ObjectParam::MoveCoordOffset, 12, &moveCoord);
                    
                    float bulletSpeed1 = memoryTools.readFloat(weaponAttrAddr + PubgOffset::ObjectParam::WeaponParam::WeaponAttrParam::BulletSpeedOffset);
                    if(bulletSpeed1 != 1800000) {
                        aimbotCoord.x += moveCoord.x * bulletFlyTime;
                        aimbotCoord.y += moveCoord.y * bulletFlyTime;
                        aimbotCoord.z += moveCoord.z * bulletFlyTime;
                    }
                    
                    ImVec2 aimbotMouse = rotateAngleView(selfCoord, aimbotCoord);
                    
                    float selfStatus = memoryTools.readFloat(
                        memoryTools.readPtr(staticData.selfAddr + PubgOffset::ObjectParam::CoordOffset) + 
                        PubgOffset::ObjectParam::CoordParam::HeightOffset
                    );
                    string className = getClassName(memoryTools.readInt(weaponAddr + PubgOffset::ObjectParam::ClassIdOffset));
                    
                    if (selfStatus > 47) {
                        if (strstr(className.c_str(), "AWM")) {
                            aimbotMouse.x += 0.06; aimbotMouse.y -= 0.06;
                        } else if (strstr(className.c_str(), "M24")) {
                            aimbotMouse.x += 0.04; aimbotMouse.y -= 0.03;
                        } else if (strstr(className.c_str(), "Kar98k")) {
                            aimbotMouse.x += 0.05; aimbotMouse.y -= 0.02;
                        } else if (strstr(className.c_str(), "M416")) {
                            aimbotMouse.x += 0.02; aimbotMouse.y -= 0.08;
                        } else if (strstr(className.c_str(), "AKM")) {
                            aimbotMouse.x += 0.04; aimbotMouse.y -= 0.07;
                        } else if (strstr(className.c_str(), "M762")) {
                            aimbotMouse.x += 0.03; aimbotMouse.y -= 0.07;
                        }
                    }
                    
                    if (memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::OpenFireOffset) == 1) {
                        float recoilTimes = 4.5 - get3dDistance(selfCoord, aimbotCoord, 10000);
                        recoilTimes += get3dDistance(selfCoord, aimbotCoord, 10000) * 0.2;
                        float recoil = memoryTools.readFloat(weaponAttrAddr + PubgOffset::ObjectParam::WeaponParam::WeaponAttrParam::RecoilOffset);
                        
                        if (strstr(className.c_str(), "AKM")) recoil *= 1.15;
                        else if (strstr(className.c_str(), "M416")) recoil *= 0.7;
                        
                        if (selfStatus < 50.0f) recoil *= 0.35;
                        aimbotMouse.y -= recoilTimes * recoil;
                    }
                    
                    if (!isfinite(aimbotMouse.x) || !isfinite(aimbotMouse.y)) continue;
                    
                    ImVec2 aimbotMouseMove;
                    aimbotMouseMove.x = change(getAngleDifference(aimbotMouse.x, 
                        memoryTools.readFloat(staticData.playerController + PubgOffset::PlayerControllerParam::MouseOffset + 0x4)) * 
                        moduleControl.aimbotController.aimbotIntensity);
                    aimbotMouseMove.y = change(getAngleDifference(aimbotMouse.y, 
                        memoryTools.readFloat(staticData.playerController + PubgOffset::PlayerControllerParam::MouseOffset)) * 
                        moduleControl.aimbotController.aimbotIntensity);
                    
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