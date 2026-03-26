#pragma once

#include <stdio.h>
#include <string>
#include <Foundation/Foundation.h>

// ============================================================================
// DYNAMIC OFFSET MANAGER
// Bundle ID bazında offset yönetimi (CrossOffsets global adresler için kullanılıyor)
// ============================================================================

namespace PubgOffset {

// Offset seti
struct OffsetSet {
    // PlayerController chain
    int playerControllerChain[3];
    
    // GWorld
    int gWorldNetDriver;
    int uLevel;
    
    // ULevel
    int actorList;
    int actorCount;
    
    // Object
    int classId;
    int className;
    
    // PlayerController
    int selfOffset;
    int mouseOffset;
    int cameraManagerOffset;
    int angleOffset;
    
    // CameraManager
    int povOffset;
    
    // Controller Functions
    int lineOfSightToOffset;
    int addYawOffset;
    int addRollOffset;
    int addPitchOffset;
    
    // Actor Properties
    int statusOffset;
    int teamOffset;
    int nameOffset;
    int robotOffset;
    int hpOffset;
    int hpMaxOffset;
    int deadOffset;
    
    // Vehicle
    int vehicleCommonOffset;
    int vehicleHPOffset;
    int vehicleHPMaxOffset;
    int vehicleFuelOffset;
    int vehicleFuelMaxOffset;
    
    // Movement & Mesh
    int moveCoordOffset;
    int meshOffset;
    int boneCountOffset;
    int meshHumanOffset;
    int meshBonesOffset;
    
    // Weapon
    int openFireOffset;
    int openSightOffset;
    int weaponManagerOffset;
    int currentWeaponOffset;
    int weaponMasterOffset;
    int shootModeOffset;
    int weaponAttrOffset;
    int bulletSpeedOffset;
    int recoilOffset;
    
    // Goods
    int goodsListOffset;
    int goodsDataOffset;
    
    // Coordinates
    int rootComponentOffset;
    int coordHeightOffset;
    int coordLocationOffset;
};

// Singleton pattern - Dinamik offset yönetimi
class OffsetManager {
private:
    static OffsetManager* instance;
    OffsetSet current;
    bool initialized;
    
    OffsetManager() : initialized(false) {
        // Default offset'ler (GL)
        initGL();
    }
    
    void initGL() {
        current.playerControllerChain[0] = 0x38;
        current.playerControllerChain[1] = 0x78;
        current.playerControllerChain[2] = 0x30;
        
        current.gWorldNetDriver = 0x118;
        current.uLevel = 0x30;
        current.actorList = 0xA0;
        current.actorCount = 0xA8;
        current.classId = 0x18;
        current.className = 0xC;
        
        current.selfOffset = 0x28E0;
        current.mouseOffset = 0x4e0;
        current.cameraManagerOffset = 0x548;
        current.angleOffset = 0x558;
        current.povOffset = 0x530;
        
        current.lineOfSightToOffset = 0x7B0;
        current.addYawOffset = 0x890;
        current.addRollOffset = 0x888;
        current.addPitchOffset = 0x898;
        
        current.statusOffset = 0x1058;
        current.teamOffset = 0x998;
        current.nameOffset = 0x960;
        current.robotOffset = 0xa40;
        current.hpOffset = 0xe60;
        current.hpMaxOffset = 0xe64;
        current.deadOffset = 0xe7c;
        
        current.vehicleCommonOffset = 0xc00;
        current.vehicleHPOffset = 0x354;
        current.vehicleHPMaxOffset = 0x350;
        current.vehicleFuelOffset = 0x43c;
        current.vehicleFuelMaxOffset = 0x438;
        
        current.moveCoordOffset = 0x110;
        current.meshOffset = 0x510;
        current.boneCountOffset = 0x8d0;
        current.meshHumanOffset = 0x210;
        current.meshBonesOffset = 0x988;
        
        current.openFireOffset = 0x1800;
        current.openSightOffset = 0x1134;
        current.weaponManagerOffset = 0x25b8;
        current.currentWeaponOffset = 0x5c8;
        current.weaponMasterOffset = 0x110;
        current.shootModeOffset = 0x10d9;
        current.weaponAttrOffset = 0x398;
        current.bulletSpeedOffset = 0x560;
        current.recoilOffset = 0xcf0;
        
        current.goodsListOffset = 0x940;
        current.goodsDataOffset = 0x38;
        
        current.rootComponentOffset = 0x208;
        current.coordHeightOffset = 0x1dc;
        current.coordLocationOffset = 0x1e4;
    }
    
    void initVNG() {
        initGL(); // Şimdilik aynı, gerekirse değiştirilebilir
    }
    
    void initKR() {
        initGL(); // Şimdilik aynı
    }
    
    void initTW() {
        initGL(); // Şimdilik aynı
    }
    
public:
    static OffsetManager* get() {
        if (!instance) {
            instance = new OffsetManager();
        }
        return instance;
    }
    
    // Bundle ID'ye göre initialize et
    void init(const char* bundleID) {
        if (initialized) return;
        
        if (strcmp(bundleID, "com.tencent.ig") == 0) {
            initGL();
        } else if (strcmp(bundleID, "com.pubg.imobile") == 0) {
            initVNG();
        } else if (strcmp(bundleID, "com.pubg.krmobile") == 0) {
            initKR();
        } else if (strcmp(bundleID, "com.tencent.tmgp.pubgmhd") == 0) {
            initTW();
        } else {
            initGL(); // Default
        }
        
        initialized = true;
    }
    
    // Auto-init from bundle
    void autoInit() {
        NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
        init([bundleID UTF8String]);
    }
    
    // Getters
    const int* getPlayerControllerChain() { return current.playerControllerChain; }
    int getGWorldNetDriver() { return current.gWorldNetDriver; }
    int getULevel() { return current.uLevel; }
    int getActorList() { return current.actorList; }
    int getActorCount() { return current.actorCount; }
    int getClassId() { return current.classId; }
    int getClassName() { return current.className; }
    int getSelf() { return current.selfOffset; }
    int getMouse() { return current.mouseOffset; }
    int getCameraManager() { return current.cameraManagerOffset; }
    int getAngle() { return current.angleOffset; }
    int getPov() { return current.povOffset; }
    int getLineOfSightTo() { return current.lineOfSightToOffset; }
    int getAddYaw() { return current.addYawOffset; }
    int getAddRoll() { return current.addRollOffset; }
    int getAddPitch() { return current.addPitchOffset; }
    int getStatus() { return current.statusOffset; }
    int getTeam() { return current.teamOffset; }
    int getName() { return current.nameOffset; }
    int getRobot() { return current.robotOffset; }
    int getHp() { return current.hpOffset; }
    int getHpMax() { return current.hpMaxOffset; }
    int getDead() { return current.deadOffset; }
    int getVehicleCommon() { return current.vehicleCommonOffset; }
    int getVehicleHP() { return current.vehicleHPOffset; }
    int getVehicleHPMax() { return current.vehicleHPMaxOffset; }
    int getVehicleFuel() { return current.vehicleFuelOffset; }
    int getVehicleFuelMax() { return current.vehicleFuelMaxOffset; }
    int getMoveCoord() { return current.moveCoordOffset; }
    int getMesh() { return current.meshOffset; }
    int getBoneCount() { return current.boneCountOffset; }
    int getMeshHuman() { return current.meshHumanOffset; }
    int getMeshBones() { return current.meshBonesOffset; }
    int getOpenFire() { return current.openFireOffset; }
    int getOpenSight() { return current.openSightOffset; }
    int getWeaponManager() { return current.weaponManagerOffset; }
    int getCurrentWeapon() { return current.currentWeaponOffset; }
    int getWeaponMaster() { return current.weaponMasterOffset; }
    int getShootMode() { return current.shootModeOffset; }
    int getWeaponAttr() { return current.weaponAttrOffset; }
    int getBulletSpeed() { return current.bulletSpeedOffset; }
    int getRecoil() { return current.recoilOffset; }
    int getGoodsList() { return current.goodsListOffset; }
    int getGoodsData() { return current.goodsDataOffset; }
    int getRootComponent() { return current.rootComponentOffset; }
    int getCoordHeight() { return current.coordHeightOffset; }
    int getCoordLocation() { return current.coordLocationOffset; }
};

OffsetManager* OffsetManager::instance = nullptr;

// ============================================================================
// ESKİ KOD UYUMLULUĞU - Namespace yapısı korunuyor
// ============================================================================

// Auto-init helper
inline void InitOffsets() {
    OffsetManager::get()->autoInit();
}

// PlayerController chain
inline int* PlayerControllerOffset = const_cast<int*>(OffsetManager::get()->getPlayerControllerChain());

inline int GWorldOffset() { return OffsetManager::get()->getGWorldNetDriver(); }
inline int ULevelOffset() { return OffsetManager::get()->getULevel(); }

namespace PlayerControllerParam {
    inline int SelfOffset() { return OffsetManager::get()->getSelf(); }
    inline int MouseOffset() { return OffsetManager::get()->getMouse(); }
    inline int CameraManagerOffset() { return OffsetManager::get()->getCameraManager(); }
    inline int AngleOffset() { return OffsetManager::get()->getAngle(); }
    
    namespace CameraManagerParam {
        inline int PovOffset() { return OffsetManager::get()->getPov(); }
    }
    
    namespace ControllerFunction {
        inline int LineOfSightToOffset() { return OffsetManager::get()->getLineOfSightTo(); }
    }
}

namespace ULevelParam {
    inline int ObjectArrayOffset() { return OffsetManager::get()->getActorList(); }
    inline int ObjectCountOffset() { return OffsetManager::get()->getActorCount(); }
}

namespace ObjectParam {
    inline int ClassIdOffset() { return OffsetManager::get()->getClassId(); }
    inline int ClassNameOffset() { return OffsetManager::get()->getClassName(); }
    
    namespace PlayerFunction {
        inline int AddControllerYawInputOffset() { return OffsetManager::get()->getAddYaw(); }
        inline int AddControllerRollInputOffset() { return OffsetManager::get()->getAddRoll(); }
        inline int AddControllerPitchInputOffset() { return OffsetManager::get()->getAddPitch(); }
    }
    
    inline int StatusOffset() { return OffsetManager::get()->getStatus(); }
    inline int TeamOffset() { return OffsetManager::get()->getTeam(); }
    inline int NameOffset() { return OffsetManager::get()->getName(); }
    inline int RobotOffset() { return OffsetManager::get()->getRobot(); }
    inline int HpOffset() { return OffsetManager::get()->getHp(); }
    inline int HpmaxOffset() { return OffsetManager::get()->getHpMax(); }
    inline int DeadOffset() { return OffsetManager::get()->getDead(); }
    
    inline int VehicleCommonComponentOffset() { return OffsetManager::get()->getVehicleCommon(); }
    inline int VehicleHPOffset() { return OffsetManager::get()->getVehicleHP(); }
    inline int VehicleHPMaxOffset() { return OffsetManager::get()->getVehicleHPMax(); }
    inline int VehicleFuelOffset() { return OffsetManager::get()->getVehicleFuel(); }
    inline int VehicleFuelMaxOffset() { return OffsetManager::get()->getVehicleFuelMax(); }
    
    inline int MoveCoordOffset() { return OffsetManager::get()->getMoveCoord(); }
    inline int MeshOffset() { return OffsetManager::get()->getMesh(); }
    inline int boneCountOffset() { return OffsetManager::get()->getBoneCount(); }
    
    namespace MeshParam {
        inline int HumanOffset() { return OffsetManager::get()->getMeshHuman(); }
        inline int BonesOffset() { return OffsetManager::get()->getMeshBones(); }
    }
    
    inline int OpenFireOffset() { return OffsetManager::get()->getOpenFire(); }
    inline int OpenTheSightOffset() { return OffsetManager::get()->getOpenSight(); }
    inline int WeaponManagerComponentOffset() { return OffsetManager::get()->getWeaponManager(); }
    inline int WeaponOneOffset() { return OffsetManager::get()->getCurrentWeapon(); }
    
    namespace WeaponParam {
        inline int MasterOffset() { return OffsetManager::get()->getWeaponMaster(); }
        inline int ShootModeOffset() { return OffsetManager::get()->getShootMode(); }
        inline int WeaponAttrOffset() { return OffsetManager::get()->getWeaponAttr(); }
        
        namespace WeaponAttrParam {
            inline int BulletSpeedOffset() { return OffsetManager::get()->getBulletSpeed(); }
            inline int RecoilOffset() { return OffsetManager::get()->getRecoil(); }
        }
    }
    
    inline int GoodsListOffset() { return OffsetManager::get()->getGoodsList(); }
    
    namespace GoodsListParam {
        inline int DataBase() { return OffsetManager::get()->getGoodsData(); }
    }
    
    inline int CoordOffset() { return OffsetManager::get()->getRootComponent(); }
    
    namespace CoordParam {
        inline int HeightOffset() { return OffsetManager::get()->getCoordHeight(); }
        inline int CoordOffset() { return OffsetManager::get()->getCoordLocation(); }
    }
}

}
