//
//  Dolphins.m
//  Dolphins - Slide 0 (No Jailbreak)
//
//  White Paper: PUBG Mobile iOS Memory Analysis
//  Created for educational research purposes
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

// Module controllers
ModuleControl moduleControl;
MemoryTools memoryTools;

// Updated offset sets for different regions
OffsetValues offsets[] = {
    { 0x102A62208, 0x10A566E00, 0x104bd8740, 0x10a1178b0 },  // GL
    { 0x1028791CC, 0x10A171A00, 0x104510EF0, 0x109AAA1A0 },  // VNG
    { 0x102AD71F8, 0x10A47D400, 0x10476F14C, 0x109DB5940 },  // KR
    { 0x102AAAB0C, 0x10A453300, 0x104742830, 0x109D8B830 }   // TW
};

// Function prototypes - FORWARD DECLARATIONS
void *readStaticData(void *);
void *silenceAimbot(void *);
char *getPlayerName(uintptr_t addr);
char *getClassName(int classId);
bool isCoordVisibility(ImVec3 coord);
bool isOnSmoke(ImVec3 coord);
string getStatusName(uintptr_t statusAddr);
ImVec3 getBone(uintptr_t human, uintptr_t bones, int part);
bool getBone2d(MinimalViewInfo pov, ImVec2 screen, uintptr_t human, uintptr_t bones, int part, ImVec2 &buf);

// Function pointers
bool (*LineOfSightTo)(void *controller, void *actor, ImVec3 bone_point, bool ischeck);
void (*AddControllerYawInput)(void *actor, float val);
void (*AddControllerRollInput)(void *actor, float val);
void (*AddControllerPitchInput)(void *actor, float val);

// Global data structure
struct {
    uintptr_t libAddr = 0;
    uintptr_t gworldAddr;
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

// Global functions - Slide 0 compatible
long gWorld() {
    OffsetValues offsetsForBundle = [OffsetsManager getOffsetsForBundleID:[[NSBundle mainBundle] bundleIdentifier]];
    return reinterpret_cast<long(__fastcall*)(long)>((long)_dyld_get_image_vmaddr_slide(1) + offsetsForBundle.gWorldFun)((long)_dyld_get_image_vmaddr_slide(1) + offsetsForBundle.gWorldData);
}

long gName() {
    OffsetValues offsetsForBundle = [OffsetsManager getOffsetsForBundleID:[[NSBundle mainBundle] bundleIdentifier]];
    return reinterpret_cast<long(__fastcall*)(long)>((long)_dyld_get_image_vmaddr_slide(1) + offsetsForBundle.gNameFun)((long)_dyld_get_image_vmaddr_slide(1) + offsetsForBundle.gNameData);
}

// UI entry point
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

// Library entry
__attribute__((constructor)) static void initialize() {
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorDrop);
    
    pthread_t staticDataThread;
    pthread_create(&staticDataThread, nullptr, readStaticData, nullptr);
    
    pthread_t silenceAimbotThread;
    pthread_create(&silenceAimbotThread, nullptr, silenceAimbot, nullptr);
}

// Helper: Read byte from memory (fix for readByte)
uint8_t readByte(uintptr_t addr) {
    uint8_t val = 0;
    memoryTools.readMemory(addr, 1, &val);
    return val;
}

// Get class name from GName
char *getClassName(int classId) {
    char *buf = (char *)malloc(64);
    if (classId > 0 && classId < 2000000) {
        int page = classId / 16384;
        int index = classId % 16384;
        uintptr_t pageAddr = memoryTools.readPtr(staticData.gnameAddr + page * sizeof(uintptr_t));
        uintptr_t nameAddr = memoryTools.readPtr(pageAddr + index * sizeof(uintptr_t)) + 0xC;
        memoryTools.readMemory(nameAddr, 64, buf);
    }
    return buf;
}

// Get player name with UTF-16 to UTF-8 conversion
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

// Get 3D bone position
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

// Convert bone to 2D screen position
bool getBone2d(MinimalViewInfo pov, ImVec2 screen, uintptr_t human, uintptr_t bones, int part, ImVec2 &buf) {
    ImVec3 newmatrix = getBone(human, bones, part);
    buf = worldToScreen(newmatrix, pov, screen);
    return buf.x != 0 && buf.y != 0;
}

// Visibility check with LineOfSightTo
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

// Smoke check
bool isOnSmoke(ImVec3 coord) {
    for (StaticMaterialData smoke : staticData.smokeList) {
        ImVec3 smokeCoord;
        memoryTools.readMemory(smoke.coordAddr + 0x1e4, 30, &smokeCoord);
        if (get3dDistance(smokeCoord, coord, 100) < 4) {
            return true;
        }
    }
    return false;
}

// Status name helper
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
        case 23: return "HOLDING WEAPON";
        case 1073741840: return "FIRING";
        case 16777219: return "SWIMMING";
        case 524289: return "KNOCKED";
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
        case 67108880: return "VAULTING";
        case 273: return "RUN & SHOOT";
        case 4194320: return "IN VEHICLE";
        case 17: return "WALK";
        default: return "UNKNOWN";
    }
}

// Static data reading with updated offsets
void *readStaticData(void *) {
    while (true) {
        sleep(4);
        if(moduleControl.systemStatus != TransmissionNormal) {
            staticData.libAddr = (uintptr_t)_dyld_get_image_vmaddr_slide(1);
            if(staticData.libAddr != 1) {
                moduleControl.systemStatus = TransmissionNormal;
            }
        } else if (moduleControl.systemStatus == TransmissionNormal) {
            staticData.gworldAddr = gWorld();
            staticData.gnameAddr = gName();
            
            // PlayerController: GWorld -> NetDriver (0x38) -> ServerConnection (0x78) -> PlayerController (0x30)
            staticData.playerController = memoryTools.readPtr(
                memoryTools.readPtr(
                    memoryTools.readPtr(staticData.gworldAddr + 0x38) + 0x78
                ) + 0x30
            );
            
            // LineOfSightTo function
            LineOfSightTo = (bool (*)(void *, void *, ImVec3, bool)) (
                memoryTools.readPtr(
                    memoryTools.readPtr(staticData.playerController + 0x0) + 0x7B0
                )
            );
            
            // Self Pawn - STBaseCharacter (0x28E0)
            staticData.selfAddr = memoryTools.readPtr(staticData.playerController + 0x28E0);
            
            // Input functions
            uintptr_t selfFunction = memoryTools.readPtr(staticData.selfAddr + 0);
            AddControllerYawInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + 0x890));
            AddControllerRollInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + 0x888));
            AddControllerPitchInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + 0x898));
            
            // CameraManager
            staticData.cameraManager = memoryTools.readPtr(staticData.playerController + 0x548);
            
            // Clear lists
            vector<StaticPlayerData> tmpPlayerDataList;
            vector<StaticMaterialData> tmpMaterialDataList;
            vector<StaticMaterialData> tmpSmokeList;
            
            // ULevel traversal
            uintptr_t uLevel = memoryTools.readPtr(staticData.gworldAddr + 0x30);
            uintptr_t objectArray = memoryTools.readPtr(uLevel + 0xA0);
            int objectCount = memoryTools.readInt(uLevel + 0xA8);
            
            for (int index = 0; index < objectCount; ++index) {
                uintptr_t objectAddr = memoryTools.readPtr(objectArray + index * 8);
                if (objectAddr <= 0x100000000 || objectAddr >= 0x2000000000 || objectAddr % 8 != 0) {
                    continue;
                }
                
                uintptr_t coordAddr = memoryTools.readPtr(objectAddr + 0x208);
                string className = getClassName(memoryTools.readInt(objectAddr + 0x18));
                
                // Player detection with BOT check (kbIsAI = 0xa40, kbIsMLAI = 0xa41)
                if (strstr(className.c_str(), "PlayerPawn") || 
                    strstr(className.c_str(), "PlayerCharacter") ||
                    strstr(className.c_str(), "STExtraPlayerCharacter") ||
                    strstr(className.c_str(), "_PlayerPawn_TPlanAI_C") ||
                    strstr(className.c_str(), "CharacterModelTaget") ||
                    strstr(className.c_str(), "FakePlayer_AIPawn")) {
                    
                    int team = memoryTools.readInt(objectAddr + 0x998);  // kTeamID
                    int selfTeam = memoryTools.readInt(staticData.selfAddr + 0x998);
                    if (team == selfTeam) continue;
                    
                    // BOT detection using kbIsAI (0xa40) and kbIsMLAI (0xa41)
                    bool isAI = readByte(objectAddr + 0xa40);
                    bool isMLAI = readByte(objectAddr + 0xa41);
                    
                    StaticPlayerData tmpPlayerData;
                    
                    bool bDead = readByte(staticData.selfAddr + 0xe7c);  // kbDead
                    float hp = memoryTools.readFloat(objectAddr + 0xe60);  // kHealth
                    
                    if(bDead) continue;
                    
                    tmpPlayerData.addr = objectAddr;
                    tmpPlayerData.coordAddr = coordAddr;
                    tmpPlayerData.team = team;
                    tmpPlayerData.name = getPlayerName(memoryTools.readPtr(objectAddr + 0x960));  // kPlayerName
                    tmpPlayerData.robot = isAI || isMLAI ? 1 : 0;  // BOT flag
                    tmpPlayerData.status = memoryTools.readInt(objectAddr + 0x1058);  // kCurrentStates
                    
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
                        
                        // Skip weapons held by players
                        if ((material.type == Rifle || material.type == Sniper || material.type == Missile) && 
                            memoryTools.readPtr(objectAddr + 0x110) != 0) {
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

// Frame data reading with skeleton fix
void readFrameData(ImVec2 screenSize, vector<PlayerData> &playerDataList, vector<MaterialData> &materialDataList) {
    playerDataList.clear();
    materialDataList.clear();
    
    if (moduleControl.systemStatus == TransmissionNormal) {
        staticData.cameraManagerClassName = getClassName(memoryTools.readInt(staticData.cameraManager + 0x18));
        staticData.playerControllerClassName = getClassName(memoryTools.readInt(staticData.playerController + 0x18));
        
        // Camera POV - kCameraCache (0x520) + 0x10
        MinimalViewInfo pov;
        memoryTools.readMemory(staticData.cameraManager + 0x530, sizeof(pov), &pov);
        
        ImVec3 selfCoord = pov.location;
        float lateralAngleView = memoryTools.readFloat(staticData.playerController + 0x4e0 + 0x4) - 90;  // kControlRotation + 0x4
        
        if (moduleControl.mainSwitch.playerStatus) {
            for (auto staticPlayerData : staticData.playerDataList) {
                ImVec3 objectCoord;
                memoryTools.readMemory(staticPlayerData.coordAddr + 0x1e4, sizeof(ImVec3), &objectCoord);  // kRelativeLocation
                
                float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
                if (objectDistance < 0 || objectDistance > 450) continue;
                
                // Height check - kRelativeLocation Z (0x1dc)
                float objectHeight = memoryTools.readFloat(staticPlayerData.coordAddr + 0x1dc);
                if (objectHeight < 20) continue;
                
                PlayerData playerData;
                playerData.angle = lateralAngleView - rotateAngle(selfCoord, objectCoord) - 180;
                playerData.radar = rotateCoord(lateralAngleView, ImVec2((selfCoord.x - objectCoord.x) / 200, (selfCoord.y - objectCoord.y) / 200));
                playerData.distance = objectDistance;
                playerData.robot = staticPlayerData.robot;  // BOT indicator
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
                playerData.hp = memoryTools.readFloat(staticPlayerData.addr + 0xe60);  // kHealth
                if (playerData.hp > 100) playerData.hp = 100;
                
                // Status parsing - kCurrentStates (0x1058)
                uintptr_t statusAddr = memoryTools.readPtr(staticPlayerData.addr + 0x1058);
                playerData.statusName = getStatusName(statusAddr);
                
                // Weapon detection
                uintptr_t weaponAddr = memoryTools.readPtr(staticPlayerData.addr + 0x25b8 + 0x20);  // kWeaponManagerComponent + 0x20
                if (weaponAddr == 0) {
                    playerData.weaponName = "FIST";
                } else {
                    string weaponClass = getClassName(memoryTools.readInt(weaponAddr + 0x18));
                    MaterialStruct weaponName = isWeapon(weaponClass.c_str());
                    playerData.weaponName = weaponName.id != 0 ? weaponName.name : "[RIFLE]M762";
                }
                
                playerData.name = staticPlayerData.name;
                playerData.screen = worldToScreen(objectCoord, pov, screenSize);
                
                ImVec2 width = worldToScreen(ImVec3(objectCoord.x, objectCoord.y, objectCoord.z + 100), pov, screenSize);
                ImVec2 height = worldToScreen(ImVec3(objectCoord.x, objectCoord.y, objectCoord.z + objectHeight), pov, screenSize);
                playerData.size.x = (playerData.screen.y - width.y) / 2;
                playerData.size.y = playerData.screen.y - height.y;
                
                // Skeleton fix - Updated bone structure
                // kMesh (0x510) -> HumanOffset (0x210) -> BonesOffset (0x988)
                uintptr_t meshAddr = memoryTools.readPtr(staticPlayerData.addr + 0x510);  // kMesh
                if (meshAddr) {
                    uintptr_t humanAddr = meshAddr + 0x210;  // HumanOffset
                    uintptr_t boneAddr = memoryTools.readPtr(meshAddr + 0x988) + 48;  // kStaticMesh + 48
                    
                    BonesData bonesData;
                    // Bone indices: 5=head, 4=chest, 1=pelvis, 11/32=shoulders, 12/33=elbows, 63/62=wrists, 52/56=thighs, 53/57=knees, 54/58=ankles
                    if (getBone2d(pov, screenSize, humanAddr, boneAddr, 5, bonesData.head))
                        if (getBone2d(pov, screenSize, humanAddr, boneAddr, 4, bonesData.pit))
                            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 1, bonesData.pelvis))
                                if (getBone2d(pov, screenSize, humanAddr, boneAddr, 11, bonesData.lcollar))
                                    if (getBone2d(pov, screenSize, humanAddr, boneAddr, 32, bonesData.rcollar))
                                        if (getBone2d(pov, screenSize, humanAddr, boneAddr, 12, bonesData.lelbow))
                                            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 33, bonesData.relbow))
                                                if (getBone2d(pov, screenSize, humanAddr, boneAddr, 63, bonesData.lwrist))
                                                    if (getBone2d(pov, screenSize, humanAddr, boneAddr, 62, bonesData.rwrist))
                                                        if (getBone2d(pov, screenSize, humanAddr, boneAddr, 52, bonesData.lthigh))
                                                            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 56, bonesData.rthigh))
                                                                if (getBone2d(pov, screenSize, humanAddr, boneAddr, 53, bonesData.lknee))
                                                                    if (getBone2d(pov, screenSize, humanAddr, boneAddr, 57, bonesData.rknee))
                                                                        if (getBone2d(pov, screenSize, humanAddr, boneAddr, 54, bonesData.lankle))
                                                                            if (getBone2d(pov, screenSize, humanAddr, boneAddr, 58, bonesData.rankle))
                                                                                playerData.bonesData = bonesData;
                }
                playerDataList.push_back(playerData);
            }
        }
        
        // Materials processing
        if (moduleControl.mainSwitch.materialStatus) {
            for (auto staticMaterialData : staticData.materialDataList) {
                string className = getClassName(memoryTools.readInt(staticMaterialData.coordAddr + 0x18));
                if (isRecycled(className.c_str())) continue;
                
                ImVec3 objectCoord;
                memoryTools.readMemory(staticMaterialData.coordAddr + 0x1e4, sizeof(ImVec3), &objectCoord);
                
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
                
                // Airdrop contents
                if (staticMaterialData.type == Airdrop) {
                    ImVec2 goodsListScreen = worldToScreen(objectCoord, pov, screenSize);
                    if (get2dDistance(screenSize, goodsListScreen) < 150) {
                        int goodsListValidCount = 0;
                        uintptr_t goodsListArray = memoryTools.readPtr(staticMaterialData.addr + 0x940);  // kPickUpDataList
                        int goodsListCount = memoryTools.readInt(staticMaterialData.addr + 0x948);
                        
                        for (int index = 0; index < goodsListCount && index < 100; index++) {
                            int goodsListId = memoryTools.readInt(goodsListArray + 0x4 + index * 0x38);  // kGoodsID
                            
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

// Aimbot with updated offsets
void *silenceAimbot(void *) {
    ImVec2 screenSize = ImVec2(kWidth, kHeight);
    
    while (true) {
        usleep(16666);
        if (moduleControl.systemStatus == TransmissionNormal && moduleControl.mainSwitch.aimbotStatus) {
            // Current weapon - kWeaponManagerComponent (0x25b8) + 0x20
            uintptr_t weaponAddr = memoryTools.readPtr(staticData.selfAddr + 0x25d8);
            
            bool enabledAimbot = false;
            switch (moduleControl.aimbotController.aimbotMode) {
                case 0: // ADS aim
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + 0x1134) == 1;  // kbIsGunADS
                    break;
                case 1: // Fire aim
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + 0x1800) == 1;  // kbIsWeaponFiring
                    break;
                case 2: // ADS or Fire
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + 0x1134) == 1 || 
                                   memoryTools.readInt(staticData.selfAddr + 0x1800) == 1;
                    break;
                case 3: // Smart mode
                    if (memoryTools.readInt(weaponAddr + 0x10d9) >= 1024) {  // kShootMode
                        enabledAimbot = memoryTools.readInt(staticData.selfAddr + 0x1800) == 1;
                    } else {
                        enabledAimbot = memoryTools.readInt(staticData.selfAddr + 0x1134) == 1;
                    }
                    break;
            }
            
            if (enabledAimbot) {
                // Camera POV
                MinimalViewInfo pov;
                memoryTools.readMemory(staticData.cameraManager + 0x530, sizeof(pov), &pov);
                ImVec3 selfCoord = pov.location;
                
                float aimbotRadius = moduleControl.aimbotController.aimbotRadius;
                StaticPlayerData aimbotPlayerData;
                aimbotPlayerData.addr = 0;
                ImVec3 aimbotCoord = ImVec3(0,0,0);
                
                for (auto staticPlayerData : staticData.playerDataList) {
                    ImVec3 objectCoord;
                    memoryTools.readMemory(staticPlayerData.coordAddr + 0x1e4, sizeof(ImVec3), &objectCoord);
                    
                    float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
                    if (objectDistance < 0 || objectDistance > 450 || 
                        objectDistance > moduleControl.aimbotController.distance) continue;
                    
                    float objectHeight = memoryTools.readFloat(staticPlayerData.coordAddr + 0x1dc);
                    if (objectHeight < 20) continue;
                    
                    // Skip knocked players if configured
                    if (memoryTools.readFloat(staticPlayerData.addr + 0xe60) < 0.5 && 
                        moduleControl.aimbotController.fallNotAim) continue;
                    
                    ImVec2 playerScreen = worldToScreen(objectCoord, pov, screenSize);
                    float screenDistance = get2dDistance(screenSize, playerScreen);
                    
                    if (screenDistance < aimbotRadius) {
                        // Skeleton for aimbot
                        uintptr_t meshAddr = memoryTools.readPtr(staticPlayerData.addr + 0x510);
                        if (!meshAddr) continue;
                        
                        uintptr_t humanAddr = meshAddr + 0x210;
                        uintptr_t boneAddr = memoryTools.readPtr(meshAddr + 0x988) + 48;
                        
                        // Aim parts: 0=head priority, 1=body priority, 2=smart, 3=head only, 4=body only
                        switch (moduleControl.aimbotController.aimbotParts) {
                            case 0: { // Head priority
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
                            case 1: { // Body priority
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
                            case 2: { // Smart
                                if (memoryTools.readInt(weaponAddr + 0x10d9) >= 1024) {
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
                                } else {
                                    int boneIds[] = {5, 4, 3, 1, 11, 32, 12, 33, 63, 62, 52, 56, 53, 57, 54, 58};
                                    for (int i = 0; i < 16; i++) {
                                        aimbotCoord = getBone(humanAddr, boneAddr, boneIds[i]);
                                        if (isCoordVisibility(aimbotCoord)) {
                                            aimbotPlayerData = staticPlayerData;
                                            aimbotRadius = screenDistance;
                                            break;
                                        }
                                        aimbotCoord = {0, 0, 0};
                                    }
                                }
                                break;
                            }
                            case 3: // Head only
                                aimbotCoord = getBone(humanAddr, boneAddr, 5);
                                if (isCoordVisibility(aimbotCoord)) {
                                    aimbotPlayerData = staticPlayerData;
                                    aimbotRadius = screenDistance;
                                } else {
                                    aimbotCoord = {0, 0, 0};
                                }
                                break;
                            case 4: // Body only
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
                
                // Execute aim
                if (aimbotPlayerData.addr != 0 && aimbotCoord.x != 0) {
                    // Smoke check
                    if (moduleControl.aimbotController.smoke && isOnSmoke(aimbotCoord)) {
                        aimbotCoord = {0, 0, 0};
                        continue;
                    }
                    
                    // Weapon attributes
                    uintptr_t weaponAttrAddr = memoryTools.readPtr(weaponAddr + 0x398);
                    float bulletSpeed = memoryTools.readFloat(weaponAttrAddr + 0x560);  // kBulletFireSpeed
                    float bulletFlyTime = get3dDistance(selfCoord, aimbotCoord, bulletSpeed) * 1.2;
                    
                    // Prediction
                    ImVec3 moveCoord;
                    memoryTools.readMemory(aimbotPlayerData.addr + 0x110, 12, &moveCoord);  // kRepMovement
                    
                    float bulletSpeed1 = memoryTools.readFloat(weaponAttrAddr + 0x560);
                    if(bulletSpeed1 != 1800000) {
                        aimbotCoord.x += moveCoord.x * bulletFlyTime;
                        aimbotCoord.y += moveCoord.y * bulletFlyTime;
                        aimbotCoord.z += moveCoord.z * bulletFlyTime;
                    }
                    
                    // Calculate aim angles
                    ImVec2 aimbotMouse = rotateAngleView(selfCoord, aimbotCoord);
                    
                    // Stance and weapon adjustments
                    float selfStatus = memoryTools.readFloat(
                        memoryTools.readPtr(staticData.selfAddr + 0x208) + 0x1dc
                    );
                    string className = getClassName(memoryTools.readInt(weaponAddr + 0x18));
                    
                    // Weapon-specific adjustments (standing)
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
                        }
                        else if (strstr(className.c_str(), "BP_Rifle_QBZ_Wrapper_C")) {
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
                        }
                        else if (strstr(className.c_str(), "BP_Other_M249_Wrapper_C")) {
                            aimbotMouse.x += 0.025; aimbotMouse.y -= 0.06;
                        } else if (strstr(className.c_str(), "BP_Other_MG3_Wrapper_C")) {
                            aimbotMouse.x += 0.03; aimbotMouse.y -= 0.07;
                        } else if (strstr(className.c_str(), "BP_Other_DP28_Wrapper_C")) {
                            aimbotMouse.x += 0.045; aimbotMouse.y -= 0.095;
                        }
                    }
                    
                    // Recoil control - kRecoilKickADS (0xcf0)
                    if (memoryTools.readInt(staticData.selfAddr + 0x1800) == 1) {
                        float recoilTimes = 4.5 - get3dDistance(selfCoord, aimbotCoord, 10000);
                        recoilTimes += get3dDistance(selfCoord, aimbotCoord, 10000) * 0.2;
                        float recoil = memoryTools.readFloat(weaponAttrAddr + 0xcf0);
                        
                        if (strstr(className.c_str(), "BP_Sniper_VSS_Wrapper_C")) recoil *= 0.4;
                        else if (strstr(className.c_str(), "BP_Rifle_G36_Wrapper_C")) recoil *= 0.6;
                        else if (strstr(className.c_str(), "BP_Rifle_VAL_Wrapper_C")) recoil *= 0.45;
                        else if (strstr(className.c_str(), "BP_Rifle_AUG_Wrapper_C")) recoil *= 0.7;
                        else if (strstr(className.c_str(), "BP_Rifle_AKM_Wrapper_C")) recoil *= 1.15;
                        else if (strstr(className.c_str(), "BP_Other_MG3_Wrapper_C")) recoil *= 0.2;
                        else if (strstr(className.c_str(), "BP_Other_DP28_Wrapper_C")) recoil *= 0.3;
                        
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
                    
                    // Validate and apply
                    if (!isfinite(aimbotMouse.x) || !isfinite(aimbotMouse.y)) continue;
                    
                    ImVec2 aimbotMouseMove;
                    aimbotMouseMove.x = change(getAngleDifference(aimbotMouse.x, 
                        memoryTools.readFloat(staticData.playerController + 0x4e0 + 0x4)) * 
                        moduleControl.aimbotController.aimbotIntensity);
                    aimbotMouseMove.y = change(getAngleDifference(aimbotMouse.y, 
                        memoryTools.readFloat(staticData.playerController + 0x4e0)) * 
                        moduleControl.aimbotController.aimbotIntensity);
                    
                    if (!isfinite(aimbotMouseMove.x) || !isfinite(aimbotMouseMove.y)) continue;
                    
                    // Apply aim
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
