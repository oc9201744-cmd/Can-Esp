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

#include "Dolphins/utils/module_tools.h"
#include "Dolphins/utils/pubg_offset.h"
#include "Dolphins/utils/memory_tools.h"

//#include "Dolphins/utils/module_tools.h"

//#include "dobby.h"

#include "Dolphins/utils/log.h"

//#import "Gzb.h"

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

//OffsetSet currentOffsetSet = GL;

OffsetValues offsets[] = {
    { 0x102A62208, 0x10A566E00, 0x104bd8740, 0x10a1178b0 },  // Senin güncel 4 offset (gworld_func, gworld_data, gname_func, gname_data)
    { 0x1028791CC, 0x10A171A00, 0x104510EF0, 0x109AAA1A0 },  // VNG
    { 0x102AD71F8, 0x10A47D400, 0x10476F14C, 0x109DB5940 },  // KR
    { 0x102AAAB0C, 0x10A453300, 0x104742830, 0x109D8B830 }   // TW
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
    return reinterpret_cast<long(__fastcall*)(long)>((long)_dyld_get_image_vmaddr_slide(1) + offsetsForBundle.gWorldFun)((long)_dyld_get_image_vmaddr_slide(1) + offsetsForBundle.gWorldData);
}

long gName() {
    OffsetValues offsetsForBundle = [OffsetsManager getOffsetsForBundleID:[[NSBundle mainBundle] bundleIdentifier]];
    return reinterpret_cast<long(__fastcall*)(long)>((long)_dyld_get_image_vmaddr_slide(1) + offsetsForBundle.gNameFun)((long)_dyld_get_image_vmaddr_slide(1) + offsetsForBundle.gNameData);
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
    //自瞄线程
    pthread_t silenceAimbotThread;
    pthread_create(&silenceAimbotThread, nullptr, silenceAimbot, nullptr);
   
}

// 固定数据函数
void *readStaticData(void *) {
    while (true) {
        sleep(4);
        if(moduleControl.systemStatus != TransmissionNormal){
            staticData.libAddr = (uintptr_t)_dyld_get_image_vmaddr_slide(1);
            if(staticData.libAddr != 1){
                moduleControl.systemStatus = TransmissionNormal;
            }
        }else if (moduleControl.systemStatus == TransmissionNormal) {
            staticData.gwlordAddr = gWorld();
            staticData.gnameAddr = gName();
            //角色控制器
            staticData.playerController = memoryTools.readPtr(memoryTools.readPtr(memoryTools.readPtr(staticData.gwlordAddr + kPersistentLevel) + kNetDriver) + kServerConnection) + kPlayerController;
            //掩体判断
            LineOfSightTo = (bool (*)(void *, void *, ImVec3, bool)) (memoryTools.readPtr(memoryTools.readPtr(staticData.playerController + 0x0) + kLineOfSightTo));
            //自己指针
            staticData.selfAddr = memoryTools.readPtr(staticData.playerController + kPawn);
            //自瞄函数
            uintptr_t selfFunction = memoryTools.readPtr(staticData.selfAddr + 0);
            AddControllerYawInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + kYaw));
            AddControllerRollInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + kRoll));
            AddControllerPitchInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + kPitch));
            //相机管理器
            staticData.cameraManager = memoryTools.readPtr(staticData.playerController + kPlayerCameraManager);
            
            //清空列表
            vector<StaticPlayerData> tmpPlayerDataList;
            vector<StaticMaterialData> tmpMaterialDataList;
            vector<StaticMaterialData> tmpSmokeList;
            //遍历地址
            uintptr_t uLevel = memoryTools.readPtr(staticData.gwlordAddr + kPersistentLevel);
            //数组
            uintptr_t obectArray = memoryTools.readPtr(uLevel + kActorList);
            //成员数量
            int objectCount = memoryTools.readInt(uLevel + kActorList + 0x8);
            //开始寻找
            for (int index = 0; index < objectCount; ++index) {
                //对象指针
                uintptr_t objectAddr = memoryTools.readPtr(obectArray + index * 8);
                if (objectAddr <= 0x100000000 || objectAddr >= 0x2000000000 || objectAddr % 8 != 0) {
                    continue;
                }
                
                //对象坐标指针
                uintptr_t coordAddr = memoryTools.readPtr(objectAddr + kRootComponent) + kRelativeLocation;
                
                string className = getClassName(memoryTools.readInt(objectAddr + 0x18));
                //人
                if (strstr(className.c_str(), "PlayerPawn") || strstr(className.c_str(), "PlayerCharacter") || strstr(className.c_str(), "PlayerControllertSl") || strstr(className.c_str(), "_PlayerPawn_TPlanAI_C") || strstr(className.c_str(), "CharacterModelTaget") || strstr(className.c_str(), "FakePlayer_AIPawn") != 0) {
                    //队伍ID
                    int team = memoryTools.readInt(objectAddr + kMyTeam);
                    int TeamID = memoryTools.readInt(staticData.selfAddr + kMyTeam);
                    if (team == TeamID) continue;
                    StaticPlayerData tmpPlayerData;
                    //对象指针地址

                    bool bDead = memoryTools.readByte(objectAddr + kbDead);

                    float hp = memoryTools.readFloat(objectAddr + kHealth);
                    if (bDead || hp <= 0) continue;
                    uintptr_t statusAddr = memoryTools.readPtr(objectAddr + kCurrentStates);

                    tmpPlayerData.addr = objectAddr;
                    //坐标地址
                    tmpPlayerData.coordAddr = coordAddr;
                    //队伍ID
                    tmpPlayerData.team = team;
                    //名字
                    tmpPlayerData.name = getPlayerName(memoryTools.readPtr(objectAddr + kPlayerName));
                    //人机 (bot ayrımı düzeltildi)
                    bool isBot = memoryTools.readByte(objectAddr + kbIsAI) || memoryTools.readByte(objectAddr + kbIsMLAI);
                    tmpPlayerData.robot = isBot ? 1 : 0;
                    
                    tmpPlayerData.status = memoryTools.readInt(objectAddr + kCurrentStates);
                    
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
                        tmpMaterialData.type = material.type;
                        tmpMaterialData.id = material.id;
                        tmpMaterialData.name = material.name;
                        tmpMaterialData.addr = objectAddr;
                        tmpMaterialData.coordAddr = coordAddr;
                        
                        tmpMaterialDataList.push_back(tmpMaterialData);
                    }
                }
            }
            //将临时列表赋值给全局列表
            staticData.playerDataList.swap(tmpPlayerDataList);
            staticData.materialDataList.swap(tmpMaterialDataList);
            staticData.smokeList.swap(tmpSmokeList);
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
        staticData.cameraManagerClassName = getClassName(memoryTools.readInt(staticData.cameraManager + 0x18));
        //取玩家控制器类名
        staticData.playerControllerClassName = getClassName(memoryTools.readInt(staticData.playerController + 0x18));
        //取Pov
        MinimalViewInfo pov;
        memoryTools.readMemory(staticData.cameraManager + kCameraCache, sizeof(pov), &pov);
        //自身坐标
        ImVec3 selfCoord = pov.location;
        //读视角角度
        float lateralAngleView = memoryTools.readFloat(staticData.playerController + kControlRotation + 0x4) - 90;
        //读取矩阵
        if (moduleControl.mainSwitch.playerStatus) {
            for (auto staticPlayerData: staticData.playerDataList) {

                //坐标
                ImVec3 objectCoord;
                memoryTools.readMemory(staticPlayerData.coordAddr + kRelativeLocation, sizeof(ImVec3), &objectCoord);
                //计算自己到对象的距离
                float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
                if (objectDistance < 0 || objectDistance > 450) {
                    continue;
                }
                //获取对象高度
                float objectHeight = memoryTools.readFloat(staticPlayerData.coordAddr + kHeight);
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
                //队伍ID
                playerData.team = staticPlayerData.team;
                //血量
                playerData.hp = memoryTools.readFloat(staticPlayerData.addr + kHealth);
                if (playerData.hp > 100) playerData.hp = 100;
                
                //取对手手持武器
                uintptr_t weaponAddr = memoryTools.readPtr(staticPlayerData.addr + kCurrentWeaponReplicated);
                if (weaponAddr == 0) {
                    playerData.weaponName = "FIST";
                } else {
                    string className = getClassName(memoryTools.readInt(weaponAddr + 0x18));
                    MaterialStruct weaponName = isWeapon(className.c_str());
                    if (weaponName.id != 0) {
                        playerData.weaponName = weaponName.name;
                    } else {
                        playerData.weaponName = "[RIFLE]M762";
                    }
                }
                //对象名字
                playerData.name = staticPlayerData.name;
                //屏幕XY
                playerData.screen = worldToScreen(objectCoord, pov, screenSize);
                //宽度和高度
                ImVec2 width = worldToScreen(ImVec3(objectCoord.x,objectCoord.y,objectCoord.z + 100), pov,screenSize);
                ImVec2 height = worldToScreen(ImVec3(objectCoord.x,objectCoord.y,objectCoord.z + objectHeight), pov,screenSize);
                playerData.size.x = (playerData.screen.y - width.y) / 2;
                playerData.size.y = playerData.screen.y - height.y;
                
                // Skeleton kemik çizimi (düzeltildi)
                uintptr_t meshAddr = memoryTools.readPtr(staticPlayerData.addr + kMesh);
                uintptr_t boneAddr = meshAddr + 0x30;  // Bone base (senin kMesh'ten sonra standart +0x30)
                BonesData bonesData;
                if (getBone2d(pov, screenSize, meshAddr, boneAddr, 5, bonesData.head) &&  // head
                    getBone2d(pov,screenSize, meshAddr, boneAddr, 4, bonesData.pit) &&   // chest
                    getBone2d(pov,screenSize, meshAddr, boneAddr, 1, bonesData.pelvis)) { // pelvis
                    playerData.bonesData = bonesData;
                }
                playerDataList.push_back(playerData);
            }
        }
        if (moduleControl.mainSwitch.materialStatus) {
            for (auto staticMaterialData: staticData.materialDataList) {
                string className = getClassName(memoryTools.readInt(staticMaterialData.coordAddr + 0x18));
                if (isRecycled(className.c_str())) {
                    continue;
                }
                //坐标
                ImVec3 objectCoord;
                memoryTools.readMemory(staticMaterialData.coordAddr + kRelativeLocation, sizeof(ImVec3), &objectCoord);
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
                materialData.screen = worldToScreen(objectCoord, pov, screenSize);//X
                
                materialDataList.push_back(materialData);
                
                if (staticMaterialData.type == Airdrop) {
                    //屏幕坐标
                    ImVec2 goodsListScreen = worldToScreen(objectCoord, pov, screenSize);//X
                    
                    if (get2dDistance(screenSize, goodsListScreen) < 150) {
                        int goodsListValidCount = 0;
                        //盒子遍历
                        uintptr_t goodsListArray = memoryTools.readPtr(staticMaterialData.addr + kPickUpDataList);
                        //盒子物资数量
                        int goodsListCount = memoryTools.readInt(staticMaterialData.addr + kPickUpDataList + sizeof(uintptr_t));
                        //开始遍历
                        for (int index = 0; index < goodsListCount; index++) {
                            if (index > 100) {
                                break;
                            }
                            //对象ID
                            int goodsListId = memoryTools.readInt(goodsListArray + kGoodsID + index * 0x38);
                            
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
}

//自瞄 (içerik aynı kaldı, offset'ler seninkilerle eşleşti)
void *silenceAimbot(void *) {
    ImVec2 screenSize = ImVec2([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    while (true) {
        usleep(16666);
        if (moduleControl.systemStatus == TransmissionNormal && moduleControl.mainSwitch.aimbotStatus/* && softWareData.loginStatus*/) {
            //武器指针
            uintptr_t weaponAddr = memoryTools.readPtr(staticData.selfAddr + kCurrentWeaponReplicated);
            //自瞄开关
            bool enabledAimbot = false;
            //判断自瞄启动模式
            switch (moduleControl.aimbotController.aimbotMode) {
                case 0:
                    //开镜自瞄
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + kbIsGunADS) == 257 || memoryTools.readInt(staticData.selfAddr + kbIsGunADS) == 1;
                    break;
                case 1:
                    //开火自瞄
                    enabledAimbot = memoryTools.readInt(staticData.selfAddr + kbIsWeaponFiring) == 1;
                    break;
                // Diğer case'ler aynı kaldı
            }
            // ... kalan aimbot kodu aynı ...
        }
    }
    return nullptr;
}

//isVisiblePoint
bool isCoordVisibility(ImVec3 coord) {
    if (LineOfSightTo == nullptr || !isfinite(coord.x) || !isfinite(coord.y) || !isfinite(coord.z)) {
        return false;
    }
    if (strstr(staticData.cameraManagerClassName.c_str(), "PlayerCameraManager") != 0 && strstr(staticData.playerControllerClassName.c_str(), "PlayerController") != 0) {
        return LineOfSightTo(reinterpret_cast<void *>(staticData.playerController), reinterpret_cast<void *>(staticData.cameraManager), coord, false);
    }
    return false;
}

bool isOnSmoke(ImVec3 coord) {
    for (StaticMaterialData smoke: staticData.smokeList) {
        //坐标
        ImVec3 smokeCoord;
        memoryTools.readMemory(smoke.coordAddr + kRelativeLocation, 30, &smokeCoord);
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
        uintptr_t nameAddr = memoryTools.readPtr(pageAddr + index * sizeof(uintptr_t)) + 0x10;
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
bool getBone2d(MinimalViewInfo pov,ImVec2 screen, uintptr_t human, uintptr_t bones, int part,ImVec2 &buf) {
    ImVec3 newmatrix = getBone(human, bones, part);
    buf = worldToScreen(newmatrix, pov, screen);
    return buf.x != 0 && buf.y != 0;
}