#pragma once

namespace PubgOffset {

// --- PlayerController zinciri
static int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};

namespace PlayerControllerParam {
static int SelfOffset = 0x28e0;
static int CameraManagerOffset = 0x548;
static int AngleOffset = 0x4e0;

namespace ControllerFunction {
static int LineOfSightToOffset = 0x7B0;
}
}

// --- ULevel
static int ULevelOffset = 0x30;

namespace ULevelParam {
static int ObjectArrayOffset = 0xA0;
static int ObjectCountOffset = 0xA8;
}

// --- Object
namespace ObjectParam {

static int ClassIdOffset = 0x18;
static int TeamOffset = 0x998;
static int NameOffset = 0x960;

// FIX: doğru bot offset
static int RobotOffset = 0xa40;

// FIX: doğru health
static int HpOffset = 0xe60;
static int HpmaxOffset = 0xe64;
static int DeadOffset = 0xe7c;

// --- Mesh / Bone FIX
static int MeshOffset = 0x510;

namespace MeshParam {
// FIX: doğru bone pointer zinciri
static int BonePtrOffset = 0x990;
static int BoneBaseOffset = 0x208;
}

// --- Coord
static int CoordOffset = 0x208;

namespace CoordParam {
static int HeightOffset = 0x1e4;
static int CoordOffset = 0x1e4;
}

// --- Player input
namespace PlayerFunction {
static int AddControllerYawInputOffset = 0x890;
static int AddControllerRollInputOffset = 0x888;
static int AddControllerPitchInputOffset = 0x898;
}

}

}