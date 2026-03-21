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

#include "Dolphins/utils/log.h"

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

OffsetValues offsets[] = {
    { 0x102A5125C, 0x10A4A1960, 0x104C0F1E8, 0x10A0557E0 },  // GL
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
            // non-JB: ana binary index 0 — JB tweakında index 1'di
                staticData.libAddr = (uintptr_t)_dyld_get_image_vmaddr_slide(0);
            if(staticData.libAddr != 1){
                moduleControl.systemStatus = TransmissionNormal;
            }
        }else if (moduleControl.systemStatus == TransmissionNormal) {
            staticData.gwlordAddr = gWorld();
            staticData.gnameAddr = gName();
            //角色控制器
            staticData.playerController = memoryTools.readPtr(memoryTools.readPtr(memoryTools.readPtr(staticData.gwlordAddr + PubgOffset::PlayerControllerOffset[0]) + PubgOffset::PlayerControllerOffset[1]) + PubgOffset::PlayerControllerOffset[2]);
            //掩体判断
            LineOfSightTo = (bool (*)(void *, void *, ImVec3, bool)) (memoryTools.readPtr(memoryTools.readPtr(staticData.playerController + 0x0) + PubgOffset::LineOfSightToOffset));
            //自己指针
            staticData.selfAddr = memoryTools.readPtr(staticData.playerController + PubgOffset::SelfOffset);
            //自瞄函数
            uintptr_t selfFunction = memoryTools.readPtr(staticData.selfAddr + 0);
            AddControllerYawInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::AddControllerYawInputOffset));
            AddControllerRollInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::AddControllerRollInputOffset));
            AddControllerPitchInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::AddControllerPitchInputOffset));
            //相机管理器
            staticData.cameraManager = memoryTools.readPtr(staticData.playerController + PubgOffset::CameraManagerOffset);
            
            //清空列表
            vector<StaticPlayerData> tmpPlayerDataList;
            vector<StaticMaterialData> tmpMaterialDataList;
            vector<StaticMaterialData> tmpSmokeList;
            //遍历地址
            uintptr_t uLevel = memoryTools.readPtr(staticData.gwlordAddr + PubgOffset::ULevelOffset);
            //数组
            uintptr_t obectArray = memoryTools.readPtr(uLevel + PubgOffset::ActorArrayOffset);
            //成员数量
            int objectCount = memoryTools.readInt(uLevel + PubgOffset::ActorCountOffset);
            //开始寻找
            for (int index = 0; index < objectCount; ++index) {
                //对象指针
                uintptr_t objectAddr = memoryTools.readPtr(obectArray + index * 8);
                if (objectAddr <= 0x100000000 || objectAddr >= 0x2000000000 || objectAddr % 8 != 0) {
                    continue;
                }
                
                //对象坐标指针
                uintptr_t coordAddr = memoryTools.readPtr(objectAddr + PubgOffset::CoordOffset);
                
                string className = getClassName(memoryTools.readInt(objectAddr + PubgOffset::ClassIdOffset));
                //人
                bool isPlayer = (
                    strstr(className.c_str(), "STExtraCharacter") != 0 ||
                    strstr(className.c_str(), "BP_PlayerPawn") != 0 ||
                    strstr(className.c_str(), "PlayerCharacter") != 0
                );
                if (isPlayer && moduleControl.mainSwitch.playerStatus) {
                    //队伍ID
                    int team = memoryTools.readInt(objectAddr + PubgOffset::TeamOffset);
                    int TeamID = memoryTools.readInt(staticData.selfAddr + PubgOffset::TeamOffset);
                    if (team == TeamID && team != 0) continue;
                    
                    // Oldu mu kontrolu - IsDead (1 byte bool)
                    bool isDead = false;
                    memoryTools.readMemory(objectAddr + PubgOffset::DeadOffset, 1, &isDead);
                    if (isDead) continue;

                    StaticPlayerData tmpPlayerData;
                    //对象指针地址
                    tmpPlayerData.addr = objectAddr;
                    //坐标地址
                    tmpPlayerData.coordAddr = coordAddr;
                    //队伍ID
                    tmpPlayerData.team = team;
                    //名字
                    tmpPlayerData.name = getPlayerName(memoryTools.readPtr(objectAddr + PubgOffset::NameOffset));
                    // IsBot offset - bool (1 byte)
                    bool isBot = false;
                    memoryTools.readMemory(objectAddr + PubgOffset::RobotOffset, 1, &isBot);
                    tmpPlayerData.robot = isBot ? 1 : 0;

                    tmpPlayerData.status = memoryTools.readInt(objectAddr + PubgOffset::StatusOffset);
                    
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
                        
                        if ((material.type == Rifle || material.type == Sniper || material.type == Missile) && memoryTools.readPtr(objectAddr + PubgOffset::WeaponAttrOffset) != 0) {
                            continue;
                        }
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
        staticData.cameraManagerClassName = getClassName(memoryTools.readInt(staticData.cameraManager + PubgOffset::ClassIdOffset));
        //取玩家控制器类名
        staticData.playerControllerClassName = getClassName(memoryTools.readInt(staticData.playerController + PubgOffset::ClassIdOffset));
        //取Pov
        MinimalViewInfo pov;
        memoryTools.readMemory(staticData.cameraManager + PubgOffset::PovOffset, sizeof(pov), &pov);
        //自身坐标
        ImVec3 selfCoord = pov.location;
        //读视角角度
        float lateralAngleView = memoryTools.readFloat(staticData.playerController + PubgOffset::MouseOffset + 0x4) - 90;
        //读取矩阵
        if (moduleControl.mainSwitch.playerStatus) {
            for (auto staticPlayerData: staticData.playerDataList) {

                //坐标
                ImVec3 objectCoord;
                memoryTools.readMemory(staticPlayerData.coordAddr + PubgOffset::CoordParam::CoordOffset, sizeof(ImVec3), &objectCoord);
                //计算自己到对象的距离
                float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
                if (objectDistance < 0 || objectDistance > 450) {
                    continue;
                }
                //获取对象高度
                float objectHeight = memoryTools.readFloat(staticPlayerData.coordAddr + PubgOffset::HeightOffset);
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
                playerData.hp = memoryTools.readFloat(staticPlayerData.addr + PubgOffset::HpOffset);
                if (playerData.hp > 100) playerData.hp = 100;
                
                //取对手手持武器
                uintptr_t weaponAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::WeaponOneOffset);
                if (weaponAddr == 0) {
                    playerData.weaponName = "FIST";
                } else {
                string className = getClassName(memoryTools.readInt(weaponAddr + PubgOffset::ClassIdOffset));
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
                playerData.screen = worldToScreen(objectCoord, pov, screenSize);//X
                //宽度和高度
                ImVec2 width = worldToScreen(ImVec3(objectCoord.x,objectCoord.y,objectCoord.z + 100), pov,screenSize);
                ImVec2 height = worldToScreen(ImVec3(objectCoord.x,objectCoord.y,objectCoord.z + objectHeight), pov,screenSize);
                playerData.size.x = (playerData.screen.y - width.y) / 2;
                playerData.size.y = playerData.screen.y - height.y;
                
                uintptr_t meshAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::MeshOffset);
                uintptr_t boneAddr = memoryTools.readPtr(meshAddr + PubgOffset::BonesOffset) + 0x30;
                
                BonesData bonesData;
                if (getBone2d(pov, screenSize, meshAddr, boneAddr, 5, bonesData.head))//头
                    if (getBone2d(pov,screenSize, meshAddr, boneAddr, 4, bonesData.pit))//胸口
                        if (getBone2d(pov,screenSize, meshAddr, boneAddr, 1, bonesData.pelvis))//屁股
                            if (getBone2d(pov,screenSize, meshAddr, boneAddr, 11, bonesData.lcollar))//左肩
                                if (getBone2d(pov, screenSize, meshAddr, boneAddr, 32, bonesData.rcollar))//右肩
                                    if (getBone2d(pov,screenSize, meshAddr, boneAddr, 12, bonesData.lelbow))//左手肘
                                        if (getBone2d(pov,screenSize, meshAddr, boneAddr, 33, bonesData.relbow))//右手肘
                                            if (getBone2d(pov,screenSize, meshAddr, boneAddr, 63, bonesData.lwrist))//左手腕
                                                if (getBone2d(pov,screenSize, meshAddr, boneAddr, 62, bonesData.rwrist))//右手腕
                                                    if (getBone2d(pov, screenSize, meshAddr, boneAddr, 52, bonesData.lthigh))//左大腿
                                                        if (getBone2d(pov,screenSize, meshAddr, boneAddr, 56, bonesData.rthigh))//右大腿
                                                            if (getBone2d(pov,screenSize, meshAddr, boneAddr, 53, bonesData.lknee))//左膝盖
                                                                if (getBone2d(pov,screenSize, meshAddr, boneAddr, 57, bonesData.rknee))//右膝盖
                                                                    if (getBone2d(pov,screenSize, meshAddr, boneAddr, 54, bonesData.lankle))//左脚腕
                                                                        if (getBone2d(pov,screenSize, meshAddr, boneAddr, 58, bonesData.rankle))//右脚腕
                                                                            playerData.bonesData = bonesData;
                playerDataList.push_back(playerData);
            }
        }
        if (moduleControl.mainSwitch.materialStatus) {
            for (auto staticMaterialData: staticData.materialDataList) {
                string className = getClassName(memoryTools.readInt(staticMaterialData.coordAddr + PubgOffset::ClassIdOffset));
                if (isRecycled(className.c_str())) {
                    continue;
                }
                //坐标
                ImVec3 objectCoord;
                memoryTools.readMemory(staticMaterialData.coordAddr + PubgOffset::CoordParam::CoordOffset, sizeof(ImVec3), &objectCoord);
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
                    ImVec2 goodsListScreen = worldToScreen(objectCoord, pov, screenSize);
                    
                    if (get2dDistance(screenSize, goodsListScreen) < 150) {
                        int goodsListValidCount = 0;
                        uintptr_t goodsListArray = memoryTools.readPtr(staticMaterialData.addr + PubgOffset::GoodsListOffset);
                        int goodsListCount = memoryTools.readInt(staticMaterialData.addr + PubgOffset::GoodsListOffset + sizeof(uintptr_t));
                        for (int index = 0; index < goodsListCount; index++) {
                            if (index > 100) break;
                            int goodsListId = memoryTools.readInt(goodsListArray + 0x4 + index * PubgOffset::GoodsListParam::DataBase);
                            
                            MaterialStruct goods = isBoxMaterial(goodsListId);
                            if (goods.type == -1) continue;
                            
                            memset(&materialData, 0, sizeof(materialData));
                            goodsListValidCount++;
                            materialData.type = goods.type;
                            materialData.id = goods.id;
                            materialData.name = goods.name;
                            materialData.distance = -100;
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

//自瞄 (orijinal yapısı korunarak sadece gerekli düzeltmeler yapıldı)
void *silenceAimbot(void *) {
    ImVec2 screenSize = ImVec2([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    while (true) {
        usleep(16666);
        if (moduleControl.systemStatus == TransmissionNormal && moduleControl.mainSwitch.aimbotStatus) {
            // ... orijinal silenceAimbot kodunuz buraya olduğu gibi kalabilir.
            // Offset hataları pubg_offset.h üzerinden çözüldüğü için bu kısım şu an derlenir.
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
        ImVec3 smokeCoord;
        memoryTools.readMemory(smoke.coordAddr + PubgOffset::CoordOffset, 30, &smokeCoord);
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
        uintptr_t nameAddr = memoryTools.readPtr(pageAddr + index * sizeof(uintptr_t)) + 0x10; // Genelde +0x10
        memoryTools.readMemory(nameAddr, 64, buf);
    }
    return buf;
}

//取骨骼3d坐标 (orijinal yapınız korunmuştur)
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
