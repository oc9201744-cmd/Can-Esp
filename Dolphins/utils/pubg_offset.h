//
// Created by XBK on 2022/1/16.
//
#include <stdio.h>
#include <string>
namespace PubgOffset {

int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};
namespace PlayerControllerParam {
// ở STExtraBaseCharacter* STExtraBaseCharacter;
int SelfOffset = 0x28E0;
// ở struct AController : AActor
// tìm Rotator ControlRotation
int MouseOffset = 0x4e0;
// ở PlayerCameraManager* PlayerCameraManager
int CameraManagerOffset = 0x548;
namespace CameraManagerParam{
// TViewTarget ViewTarget
int PovOffset = 0x10a0 + 0x10;
}
namespace ControllerFunction {
int LineOfSightToOffset = 0x7B0;
}
}
// ở struct UWorld : UObject
// tìm Level* PersistentLevel
int ULevelOffset = 0x30;//uLevel
namespace ULevelParam {
int ObjectArrayOffset = 0xA0;//数组
int ObjectCountOffset = 0xA8;//成员数量
}

namespace ObjectParam {
int ClassIdOffset = 0x18;//类型ID
int ClassNameOffset = 0xC;

namespace PlayerFunction {
int AddControllerYawInputOffset = 0x888 + 0x8;
int AddControllerRollInputOffset = 0x880 + 0x8;
int AddControllerPitchInputOffset = 0x880 + 0x8;
}
// ở struct ASTExtraCharacter : AUAECharacter
// tìm uint64 CurrentStates;
int StatusOffset = 0x1058;
// ở struct AUAECharacter : ACharacter
// tìm int TeamID
int TeamOffset = 0x998;
// ở struct AUAECharacter : ACharacter
// tìm FString PlayerName
int NameOffset = 0x960;
// ở struct AUAECharacter : ACharacter
// tìm bool bIsAI
int RobotOffset = 0xa40;
// ở struct ASTExtraCharacter : AUAECharacter
// tìm float Health
int HpOffset = 0xe60;
int HPMaxOffset = 0xe64;
int MoveCoordOffset = 0x110;
int DeadOffset = 0xe7c;
// ở struct ACharacter : APawn
// tìm SkeletalMeshComponent* Mesh
int MeshOffset = 0x510;
namespace MeshParam{
// ở struct UCharacterMovementComponent : UPawnMovementComponent
// tìm Character* CharacterOwner;
int HumanOffset = 0x208;
// ở struct UStaticMeshComponent : UMeshComponent
// tìm StaticMesh* StaticMesh;
int BonesOffset = 0x988;
}
// ở struct ASTExtraBaseCharacter : ASTExtraCharacter
// tìm bool bIsWeaponFiring
int OpenFireOffset = 0x1800;
// ở struct ASTExtraCharacter : AUAECharacter
// tìm bool bIsGunADS
int OpenTheSightOffset = 0x1134;
// ở struct ASTExtraBaseCharacter : ASTExtraCharacter
// tìm struct FAnimStatusKeyList LastUpdateStatusKeyList;
int WeaponOneOffset = 0x25b8+0x20;
namespace WeaponParam{
int MasterOffset = 0xF0;
// ở struct ASTExtraShootWeapon : ASTExtraWeapon
// tìm enum class EShootWeaponShootMode ShootMode;
int ShootModeOffset = 0x10d9;
// tìm struct UShootWeaponEntity* ShootWeaponEntityComp;
int WeaponAttrOffset = 0x1360;
namespace WeaponAttrParam{
// ở struct UShootWeaponEntity : UWeaponEntity
// tìm float BulletFireSpeed;
int BulletSpeedOffset = 0x560;
// ở struct UShootWeaponEntity : UWeaponEntity
// tìm float RecoilKickADS
int RecoilOffset = 0xcf0;
}
}
// ở struct APickUpListWrapperActor : APickUpWrapperActor
// tìm struct TArray<struct FPickUpItemData> PickUpDataList;
int GoodsListOffset = 0x940;
namespace GoodsListParam {
int DataBase = 0x38;
}
// ở struct AActor : UObject
// tìm SceneComponent* RootComponent;
int CoordOffset = 0x208;
namespace CoordParam {
int HeightOffset = 0x1c8;
int CoordOffset = 0x1dc;
}
}
}
