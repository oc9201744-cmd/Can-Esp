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
    // non-JB: dylib IPA içine gömülü, ana binary index 0'dır
    OffsetValues offsetsForBundle = [OffsetsManager getOffsetsForBundleID:[[NSBundle mainBundle] bundleIdentifier]];
    return reinterpret_cast<long(__fastcall*)(long)>((long)_dyld_get_image_vmaddr_slide(0) + offsetsForBundle.gWorldFun)((long)_dyld_get_image_vmaddr_slide(0) + offsetsForBundle.gWorldData);
}

long gName() {
    // non-JB: dylib IPA içine gömülü, ana binary index 0'dır
    OffsetValues offsetsForBundle = [OffsetsManager getOffsetsForBundleID:[[NSBundle mainBundle] bundleIdentifier]];
    return reinterpret_cast<long(__fastcall*)(long)>((long)_dyld_get_image_vmaddr_slide(0) + offsetsForBundle.gNameFun)((long)_dyld_get_image_vmaddr_slide(0) + offsetsForBundle.gNameData);
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
            LineOfSightTo = (bool (*)(void *, void *, ImVec3, bool)) (memoryTools.readPtr(memoryTools.readPtr(staticData.playerController + 0x0) + PubgOffset::PlayerControllerParam::ControllerFunction::LineOfSightToOffset));//0x780
            //自己指针
            staticData.selfAddr = memoryTools.readPtr(staticData.playerController + PubgOffset::PlayerControllerParam::SelfOffset);
            //自瞄函数
            uintptr_t selfFunction = memoryTools.readPtr(staticData.selfAddr + 0);
            AddControllerYawInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::ObjectParam::PlayerFunction::AddControllerYawInputOffset));//0x780
            AddControllerRollInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::ObjectParam::PlayerFunction::AddControllerRollInputOffset));//0x780
            AddControllerPitchInput = (void (*)(void *, float)) (memoryTools.readPtr(selfFunction + PubgOffset::ObjectParam::PlayerFunction::AddControllerPitchInputOffset));//0x780
            //相机管理器
            staticData.cameraManager = memoryTools.readPtr(staticData.playerController + PubgOffset::PlayerControllerParam::CameraManagerOffset);
            
            //清空列表
            vector<StaticPlayerData> tmpPlayerDataList;
            vector<StaticMaterialData> tmpMaterialDataList;
            vector<StaticMaterialData> tmpSmokeList;
            //遍历地址
            uintptr_t uLevel = memoryTools.readPtr(staticData.gwlordAddr + PubgOffset::ULevelOffset);
            //数组
            uintptr_t obectArray = memoryTools.readPtr(uLevel + PubgOffset::ULevelParam::ObjectArrayOffset);
            //成员数量
            int objectCount = memoryTools.readInt(uLevel + PubgOffset::ULevelParam::ObjectCountOffset);
            //开始寻找
            for (int index = 0; index < objectCount; ++index) {
                //对象指针
                uintptr_t objectAddr = memoryTools.readPtr(obectArray + index * 8);
                if (objectAddr <= 0x100000000 || objectAddr >= 0x2000000000 || objectAddr % 8 != 0) {
                    continue;
                }
                
                //对象坐标指针
                uintptr_t coordAddr = memoryTools.readPtr(objectAddr + PubgOffset::ObjectParam::CoordOffset);
                
                string className = getClassName(memoryTools.readInt(objectAddr + PubgOffset::ObjectParam::ClassIdOffset));
                //人
                bool isPlayer = (
                    strstr(className.c_str(), "STExtraCharacter") != 0 ||
                    strstr(className.c_str(), "BP_PlayerPawn") != 0 ||
                    strstr(className.c_str(), "PlayerCharacter") != 0
                );
                if (isPlayer && moduleControl.mainSwitch.playerStatus) {
                    // HP ve Dead kontrolü (4.3 için)
                    float hp = memoryTools.readFloat(objectAddr + PubgOffset::ObjectParam::HpOffset);
                    if (hp < 0.1f) continue;
                    
                    bool isDead = false;
                    memoryTools.readMemory(objectAddr + PubgOffset::ObjectParam::DeadOffset, 1, &isDead);
                    if (isDead) continue;

                    //队伍ID (dost düşman ayrımı)
                    int team = memoryTools.readInt(objectAddr + PubgOffset::ObjectParam::TeamOffset);
                    int TeamID = memoryTools.readInt(staticData.selfAddr + PubgOffset::ObjectParam::TeamOffset);
                    if (team == TeamID && team != 0) continue;
                    
                    StaticPlayerData tmpPlayerData;
                    tmpPlayerData.addr = objectAddr;
                    tmpPlayerData.coordAddr = coordAddr;
                    tmpPlayerData.team = team;
                    tmpPlayerData.name = getPlayerName(memoryTools.readPtr(objectAddr + PubgOffset::ObjectParam::NameOffset));
                    
                    bool isBot = false;
                    memoryTools.readMemory(objectAddr + PubgOffset::ObjectParam::RobotOffset, 1, &isBot);
                    tmpPlayerData.robot = isBot ? 1 : 0;

                    tmpPlayerData.status = memoryTools.readInt(objectAddr + PubgOffset::ObjectParam::StatusOffset);
                    
                    tmpPlayerDataList.push_back(tmpPlayerData);
                    
                } else if (strstr(className.c_str(), "ProjSmoke_BP_C)") != 0) {
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
                        
                        if ((material.type == Rifle || material.type == Sniper || material.type == Missile) && memoryTools.readPtr(objectAddr + PubgOffset::ObjectParam::WeaponParam::MasterOffset) != 0) {
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
        staticData.cameraManagerClassName = getClassName(memoryTools.readInt(staticData.cameraManager + PubgOffset::ObjectParam::ClassIdOffset));
        //取玩家控制器类名
        staticData.playerControllerClassName = getClassName(memoryTools.readInt(staticData.playerController + PubgOffset::ObjectParam::ClassIdOffset));
        //取Pov
        MinimalViewInfo pov;
        memoryTools.readMemory(staticData.cameraManager + PubgOffset::PlayerControllerParam::CameraManagerParam::PovOffset, sizeof(pov), &pov);
        //自身坐标
        ImVec3 selfCoord = pov.location;
        //读视角角度
        float lateralAngleView = memoryTools.readFloat(staticData.playerController + PubgOffset::PlayerControllerParam::MouseOffset + 0x4) - 90;
        //读取矩阵
        if (moduleControl.mainSwitch.playerStatus) {
            for (auto staticPlayerData: staticData.playerDataList) {

                //坐标
                ImVec3 objectCoord;
                memoryTools.readMemory(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, sizeof(ImVec3), &objectCoord);
                //计算自己到对象的距离
                float objectDistance = get3dDistance(objectCoord, selfCoord, 100);
                if (objectDistance < 0 || objectDistance > 450) {
                    continue;
                }
                //获取对象高度
                float objectHeight = memoryTools.readFloat(staticPlayerData.coordAddr + PubgOffset::ObjectParam::CoordParam::HeightOffset);
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
                playerData.hp = memoryTools.readFloat(staticPlayerData.addr + PubgOffset::ObjectParam::HpOffset);
                if (playerData.hp > 100) playerData.hp = 100;
                
                //取对手手持武器
                uintptr_t weaponAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::WeaponOneOffset);
                if (weaponAddr == 0) {
                    playerData.weaponName = "FIST";
                } else {
                string className = getClassName(memoryTools.readInt(weaponAddr + PubgOffset::ObjectParam::ClassIdOffset));
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
                
                // ====================== SKELETON DÜZELTİLDİ (4.3 Bone) ======================
                uintptr_t meshAddr = memoryTools.readPtr(staticPlayerData.addr + PubgOffset::ObjectParam::MeshOffset);
                uintptr_t boneAddr = memoryTools.readPtr(meshAddr + PubgOffset::ObjectParam::MeshParam::BonesOffset) + 0x30;  // 4.3 için +0x30
                
                BonesData bonesData;
                if (getBone2d(pov, screenSize,humanAddr, boneAddr, 5, bonesData.head))//头
                    if (getBone2d(pov,screenSize, humanAddr, boneAddr, 4, bonesData.pit))//胸口
                        if (getBone2d(pov,screenSize, humanAddr, boneAddr, 1, bonesData.pelvis))//屁股
                            if (getBone2d(pov,screenSize, humanAddr, boneAddr, 11, bonesData.lcollar))//左肩
                                if (getBone2d(pov, screenSize,humanAddr, boneAddr, 32, bonesData.rcollar))//右肩
                                    if (getBone2d(pov,screenSize, humanAddr, boneAddr, 12, bonesData.lelbow))//左手肘
                                        if (getBone2d(pov,screenSize, humanAddr, boneAddr, 33, bonesData.relbow))//右手肘
                                            if (getBone2d(pov,screenSize, humanAddr, boneAddr, 63, bonesData.lwrist))//左手腕
                                                if (getBone2d(pov,screenSize, humanAddr, boneAddr, 62, bonesData.rwrist))//右手腕
                                                    if (getBone2d(pov, screenSize,humanAddr, boneAddr, 52, bonesData.lthigh))//左大腿
                                                        if (getBone2d(pov,screenSize, humanAddr, boneAddr, 56, bonesData.rthigh))//右大腿
                                                            if (getBone2d(pov,screenSize, humanAddr, boneAddr, 53, bonesData.lknee))//左膝盖
                                                                if (getBone2d(pov,screenSize, humanAddr, boneAddr, 57, bonesData.rknee))//右膝盖
                                                                    if (getBone2d(pov,screenSize, humanAddr, boneAddr, 54, bonesData.lankle))//左脚腕
                                                                        if (getBone2d(pov,screenSize, humanAddr, boneAddr, 58, bonesData.rankle))//右脚腕
                                                                            playerData.bonesData = bonesData;
                playerDataList.push_back(playerData);
            }
        }
        if (moduleControl.mainSwitch.materialStatus) {
            for (auto staticMaterialData: staticData.materialDataList) {
                string className = getClassName(memoryTools.readInt(staticMaterialData.coordAddr + PubgOffset::ObjectParam::ClassIdOffset));
                if (isRecycled(className.c_str())) {
                    continue;
                }
                //坐标
                ImVec3 objectCoord;
                memoryTools.readMemory(staticMaterialData.coordAddr + PubgOffset::ObjectParam::CoordParam::CoordOffset, sizeof(ImVec3), &objectCoord);
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
                        uintptr_t goodsListArray = memoryTools.readPtr(staticMaterialData.addr + PubgOffset::ObjectParam::GoodsListOffset);
                        //盒子物资数量
                        int goodsListCount = memoryTools.readInt(staticMaterialData.addr + PubgOffset::ObjectParam::GoodsListOffset + sizeof(uintptr_t));
                        //开始遍历
                        for (int index = 0; index < goodsListCount; index++) {
                            if (index > 100) {
                                break;
                            }
                            //对象ID
                            int goodsListId = memoryTools.readInt(goodsListArray + 0x4 + index * PubgOffset::ObjectParam::GoodsListParam::DataBase);
                            
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

//自瞄 (değiştirilmedi)
void *silenceAimbot(void *) {
    // ... (orijinal kodun olduğu gibi kalıyor)
}

// Diğer fonksiyonlar (isCoordVisibility, isOnSmoke, getPlayerName, getClassName, getBone, getBone2d vb.) tamamen aynı kalıyor.