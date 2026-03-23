#pragma once

namespace PubgOffset {

// ---------------- PlayerController ----------------
static int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};

namespace PlayerControllerParam {
static int SelfOffset = 0x28e0;
static int CameraManagerOffset = 0x548;
static int AngleOffset = 0x4e0;

namespace ControllerFunction {
static int LineOfSightToOffset = 0x7B0;
}
}

// ---------------- ULevel ----------------
static int ULevelOffset = 0x30;

namespace ULevelParam {
static int ObjectArrayOffset = 0xA0;
static int ObjectCountOffset = 0xA8;
}

// ---------------- Object ----------------
namespace ObjectParam {

// --- PlayerState FIX (SDK uyumlu)
static int PlayerStateOffset = 0x4a8;   // gerekirse güncelle
static int bIsAI_Offset = 0x28;

// --- Temel bilgiler
static int TeamOffset = 0x998;
static int NameOffset = 0x960;

// --- Sağlık
static int HpOffset = 0xe60;
static int HpmaxOffset = 0xe64;
static int DeadOffset = 0xe7c;

// ---------------- Mesh / Bone FIX ----------------
static int MeshOffset = 0x510;

namespace MeshParam {
static int BonePtrOffset = 0x990;
static int BoneBaseOffset = 0x208;
}

// ---------------- Koordinat ----------------
static int CoordOffset = 0x208;

namespace CoordParam {
static int RelativeLocation = 0x1e4;
}

// ---------------- Player Input ----------------
namespace PlayerFunction {
static int AddControllerYawInputOffset = 0x890;
static int AddControllerRollInputOffset = 0x888;
static int AddControllerPitchInputOffset = 0x898;
}

}

}