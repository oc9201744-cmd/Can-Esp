//
//  Dolphins.mm
//  Tam Sistem (ESP + Aimbot + Statik Data)
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <pthread.h>
#import <objc/runtime.h>

#include <vector>
#include <string>
#include <math.h>

using namespace std;

// ================= SCREEN =================
#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

// ================= STRUCTS =================
struct ImVec2 { float x, y; };
struct ImVec3 { float x, y, z; };

struct MinimalViewInfo {
    ImVec3 location;
    ImVec3 rotation;
    float fov;
};

struct StaticPlayerData {
    uintptr_t addr;
    uintptr_t coordAddr;
    int team;
    int robot;
};

struct PlayerData {
    uintptr_t addr;
    ImVec2 screen;
    float distance;
    int team;
    int robot;
    bool visible;
};

struct OffsetValues {
    unsigned long gWorldFun;
    unsigned long gNameFun;
    unsigned long gWorldData;
    unsigned long gNameData;
};

// ================= OFFSET NAMESPACE (Beyaz Defter) =================
namespace PubgOffset {

// PlayerController
static int PlayerControllerOffset[3] = {0x38, 0x78, 0x30};

namespace PlayerControllerParam {
    static int SelfOffset = 0x28e0;
    static int CameraManagerOffset = 0x548;
    static int AngleOffset = 0x4e0;
    
    namespace ControllerFunction {
        static int LineOfSightToOffset = 0x7B0;
    }
    
    namespace CameraManagerParam {
        static int PovOffset = 0x410; // Kamera görüş açısı
    }
}

// ULevel
static int ULevelOffset = 0x30;

namespace ULevelParam {
    static int ObjectArrayOffset = 0xA0;
    static int ObjectCountOffset = 0xA8;
}

// Object
namespace ObjectParam {
    static int PlayerStateOffset = 0x4D0;
    static int bIsAI_Offset = 0x28;
    static int TeamOffset = 0x998;
    static int NameOffset = 0x960;
    static int HpOffset = 0xe60;
    static int DeadOffset = 0xe7c;
    static int RootComponentOffset = 0x208;
    static int MeshOffset = 0x510;
    
    namespace CoordParam {
        static int RelativeLocation = 0x1e4;
    }
    
    namespace MeshParam {
        static int BonePtrOffset = 0x990;
        static int BoneBaseOffset = 0x208;
    }
}

}

// ================= MEMORY TOOLS (Basit Implementasyon) =================
class MemoryTools {
public:
    template<typename T>
    T readPtr(uintptr_t addr) {
        T val = 0;
        if (addr) vm_read_overwrite(mach_task_self(), addr, sizeof(T), &val, nullptr);
        return val;
    }
    
    int readInt(uintptr_t addr) {
        int val = 0;
        if (addr) vm_read_overwrite(mach_task_self(), addr, sizeof(int), &val, nullptr);
        return val;
    }
    
    float readFloat(uintptr_t addr) {
        float val = 0;
        if (addr) vm_read_overwrite(mach_task_self(), addr, sizeof(float), &val, nullptr);
        return val;
    }
    
    void readMemory(uintptr_t addr, size_t size, void *buff) {
        if (addr) vm_read_overwrite(mach_task_self(), addr, size, buff, nullptr);
    }
};
MemoryTools memoryTools;

// ================= GLOBAL DATA =================
struct {
    uintptr_t gworld;
    uintptr_t gname;
    uintptr_t playerController;
    uintptr_t cameraManager;
    uintptr_t self;
    vector<StaticPlayerData> playerDataList;
    pthread_mutex_t mutex;
} staticData;

struct ModuleControl {
    struct { bool playerStatus; bool aimbotStatus; } mainSwitch;
    struct { bool ignorebot; } playerSwitch;
    struct { float aimbotRadius; float distance; } aimbotController;
} moduleControl = {{true, true}, {false}, {100.0f, 400.0f}};

// ================= FUNCTION POINTERS =================
bool (*LineOfSightTo)(void*, void*, ImVec3, bool);
void (*AddControllerYawInput)(void*, float);
void (*AddControllerPitchInput)(void*, float);

OffsetValues offsets[] = {
    { 0x102A5125C, 0x10A4A1960, 0x104C0F1E8, 0x10A0557E0 },
    { 0x1028791CC, 0x10A171A00, 0x104510EF0, 0x109AAA1A0 },
    { 0x102AD71F8, 0x10A47D400, 0x10476F14C, 0x109DB5940 },
    { 0x102AAAB0C, 0x10A453300, 0x104742830, 0x109D8B830 }
};

// ================= MATH =================
float get3dDistance(ImVec3 src, ImVec3 dst, float divide) {
    float x = src.x - dst.x;
    float y = src.y - dst.y;
    float z = src.z - dst.z;
    return sqrt(x*x + y*y + z*z) / divide;
}

float get2dDistance(ImVec2 screen, ImVec2 pos) {
    float x = screen.x/2 - pos.x;
    float y = screen.y/2 - pos.y;
    return sqrt(x*x + y*y);
}

ImVec2 worldToScreen(ImVec3 world, MinimalViewInfo pov, ImVec2 screen) {
    ImVec2 out = {0,0};
    
    float radX = pov.rotation.x * M_PI / 180;
    float radY = pov.rotation.y * M_PI / 180;
    float radZ = pov.rotation.z * M_PI / 180;
    
    float cosX = cos(radX), sinX = sin(radX);
    float cosY = cos(radY), sinY = sin(radY);
    float cosZ = cos(radZ), sinZ = sin(radZ);
    
    float dx = world.x - pov.location.x;
    float dy = world.y - pov.location.y;
    float dz = world.z - pov.location.z;
    
    float d1 = cosY * (sinZ * dy + cosZ * dx) - sinY * dz;
    float d2 = sinX * (cosY * dz + sinY * (sinZ * dy + cosZ * dx)) + cosX * (cosZ * dy - sinZ * dx);
    float d3 = cosX * (cosY * dz + sinY * (sinZ * dy + cosZ * dx)) - sinX * (cosZ * dy - sinZ * dx);
    
    if (d3 < 0.1f) return out;
    
    float fov = pov.fov * M_PI / 180;
    float tanFov = tan(fov/2);
    
    out.x = screen.x/2 + (d1 / (d3 * tanFov)) * screen.x/2;
    out.y = screen.y/2 - (d2 / (d3 * tanFov)) * screen.y/2;
    
    return out;
}

// ================= CORE FUNCTIONS =================
long gWorld() {
    // Basit implementasyon - gerçek projede OffsetsManager kullanılmalı
    return memoryTools.readPtr<long>((uintptr_t)_dyld_get_image_vmaddr_slide(0) + offsets[0].gWorldData);
}

long gName() {
    return memoryTools.readPtr<long>((uintptr_t)_dyld_get_image_vmaddr_slide(0) + offsets[0].gNameData);
}

bool IsBot(uintptr_t actor) {
    uintptr_t ps = memoryTools.readPtr<uintptr_t>(actor + PubgOffset::ObjectParam::PlayerStateOffset);
    if (ps > 0x100000000) {
        uint8_t ai = 0;
        memoryTools.readMemory(ps + PubgOffset::ObjectParam::bIsAI_Offset, 1, &ai);
        return ai != 0;
    }
    return false;
}

char* getClassName(int id) {
    static char buf[64];
    memset(buf, 0, 64);
    
    int page = id / 16384;
    int index = id % 16384;
    
    uintptr_t pageAddr = memoryTools.readPtr<uintptr_t>(staticData.gname + page * 8);
    if (!pageAddr) return buf;
    
    uintptr_t nameAddr = memoryTools.readPtr<uintptr_t>(pageAddr + index * 8);
    if (!nameAddr) return buf;
    
    memoryTools.readMemory(nameAddr + 0x10, 64, buf);
    return buf;
}

// ================= ESP OVERLAY =================
@interface ESPLayer : UIView
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) vector<PlayerData> players;
@end

@implementation ESPLayer

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
    return self;
}

- (void)start {
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)render {
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    pthread_mutex_lock(&staticData.mutex);
    vector<PlayerData> list = self.players;
    pthread_mutex_unlock(&staticData.mutex);
    
    for (auto &p : list) {
        if (p.screen.x <= 0 || p.screen.y <= 0) continue;
        
        UIColor *color = p.robot ? [UIColor cyanColor] : (p.visible ? [UIColor redColor] : [UIColor orangeColor]);
        
        // Box boyutu mesafeye göre
        float boxW = 50 * (100.0f / p.distance);
        float boxH = boxW * 2;
        
        CGRect box = CGRectMake(p.screen.x - boxW/2, p.screen.y - boxH/2, boxW, boxH);
        CGContextSetStrokeColorWithColor(ctx, color.CGColor);
        CGContextSetLineWidth(ctx, 2.0);
        CGContextStrokeRect(ctx, box);
        
        // Etiket
        NSString *label = [NSString stringWithFormat:@"[%@] %.0fm", 
                          p.robot ? @"BOT" : @"PLY", p.distance];
        [label drawAtPoint:CGPointMake(p.screen.x - 25, p.screen.y - boxH/2 - 15)
            withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10],
                            NSForegroundColorAttributeName: color}];
    }
}

@end

// ================= STATIC DATA THREAD =================
void *readStaticData(void *) {
    // Fonksiyon pointer'ları init et
    while (true) {
        sleep(3);
        
        staticData.gworld = gWorld();
        staticData.gname = gName();
        
        // PlayerController chain
        auto pc1 = memoryTools.readPtr<uintptr_t>(staticData.gworld + PubgOffset::PlayerControllerOffset[0]);
        auto pc2 = memoryTools.readPtr<uintptr_t>(pc1 + PubgOffset::PlayerControllerOffset[1]);
        staticData.playerController = memoryTools.readPtr<uintptr_t>(pc2 + PubgOffset::PlayerControllerOffset[2]);
        
        if (!staticData.playerController) continue;
        
        // Fonksiyon pointer'ları al
        uintptr_t pcVtable = memoryTools.readPtr<uintptr_t>(staticData.playerController);
        LineOfSightTo = (bool(*)(void*,void*,ImVec3,bool))memoryTools.readPtr<uintptr_t>(pcVtable + PubgOffset::PlayerControllerParam::ControllerFunction::LineOfSightToOffset);
        
        staticData.self = memoryTools.readPtr<uintptr_t>(staticData.playerController + PubgOffset::PlayerControllerParam::SelfOffset);
        staticData.cameraManager = memoryTools.readPtr<uintptr_t>(staticData.playerController + PubgOffset::PlayerControllerParam::CameraManagerOffset);
        
        if (!staticData.self) continue;
        
        // Self input fonksiyonları
        uintptr_t selfVtable = memoryTools.readPtr<uintptr_t>(staticData.self);
        AddControllerYawInput = (void(*)(void*,float))memoryTools.readPtr<uintptr_t>(selfVtable + 0x890);
        AddControllerPitchInput = (void(*)(void*,float))memoryTools.readPtr<uintptr_t>(selfVtable + 0x898);
        
        // Actor listesi
        uintptr_t uLevel = memoryTools.readPtr<uintptr_t>(staticData.gworld + PubgOffset::ULevelOffset);
        uintptr_t array = memoryTools.readPtr<uintptr_t>(uLevel + PubgOffset::ULevelParam::ObjectArrayOffset);
        int count = memoryTools.readInt(uLevel + PubgOffset::ULevelParam::ObjectCountOffset);
        
        vector<StaticPlayerData> players;
        int selfTeam = memoryTools.readInt(staticData.self + PubgOffset::ObjectParam::TeamOffset);
        
        for (int i = 0; i < count; i++) {
            uintptr_t obj = memoryTools.readPtr<uintptr_t>(array + i * 8);
            if (obj < 0x100000000 || obj == staticData.self) continue;
            
            int classId = memoryTools.readInt(obj + 0x10);
            char* name = getClassName(classId);
            
            if (!strstr(name, "Player")) continue;
            
            int team = memoryTools.readInt(obj + PubgOffset::ObjectParam::TeamOffset);
            if (team == selfTeam) continue;
            
            bool dead = false;
            memoryTools.readMemory(obj + PubgOffset::ObjectParam::DeadOffset, 1, &dead);
            if (dead) continue;
            
            StaticPlayerData p;
            p.addr = obj;
            p.coordAddr = memoryTools.readPtr<uintptr_t>(obj + PubgOffset::ObjectParam::RootComponentOffset);
            p.team = team;
            p.robot = IsBot(obj);
            players.push_back(p);
        }
        
        pthread_mutex_lock(&staticData.mutex);
        staticData.playerDataList.swap(players);
        pthread_mutex_unlock(&staticData.mutex);
    }
    return 0;
}

// ================= ESP THREAD =================
void *espThread(void *) {
    __block ESPLayer *espView = nil;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        if (!win) return;
        espView = [[ESPLayer alloc] initWithFrame:win.bounds];
        [win addSubview:espView];
        [espView start];
    });
    
    if (!espView) return 0;
    
    while (true) {
        usleep(16000); // 60 FPS
        
        if (!staticData.cameraManager) continue;
        
        MinimalViewInfo pov;
        memoryTools.readMemory(staticData.cameraManager + PubgOffset::PlayerControllerParam::CameraManagerParam::PovOffset, 
                              sizeof(pov), &pov);
        
        ImVec3 selfPos = pov.location;
        ImVec2 screenSize = {kWidth, kHeight};
        
        pthread_mutex_lock(&staticData.mutex);
        auto list = staticData.playerDataList;
        pthread_mutex_unlock(&staticData.mutex);
        
        vector<PlayerData> frame;
        for (auto &p : list) {
            ImVec3 pos;
            memoryTools.readMemory(p.coordAddr + PubgOffset::ObjectParam::CoordParam::RelativeLocation, 
                                  sizeof(ImVec3), &pos);
            
            float dist = get3dDistance(pos, selfPos, 100);
            if (dist > 400) continue;
            
            PlayerData d;
            d.addr = p.addr;
            d.robot = p.robot;
            d.team = p.team;
            d.distance = dist;
            d.screen = worldToScreen(pos, pov, screenSize);
            d.visible = (d.screen.x > 0 && d.screen.y > 0);
            
            if (d.visible) frame.push_back(d);
        }
        
        espView.players = frame;
    }
    return 0;
}

// ================= AIMBOT THREAD =================
void *aimbotThread(void *) {
    while (true) {
        usleep(16000);
        
        if (!moduleControl.mainSwitch.aimbotStatus) continue;
        if (!staticData.self || !AddControllerYawInput) continue;
        
        MinimalViewInfo pov;
        memoryTools.readMemory(staticData.cameraManager + PubgOffset::PlayerControllerParam::CameraManagerParam::PovOffset, 
                              sizeof(pov), &pov);
        
        ImVec2 screen = {kWidth, kHeight};
        ImVec3 selfPos = pov.location;
        
        pthread_mutex_lock(&staticData.mutex);
        auto list = staticData.playerDataList;
        pthread_mutex_unlock(&staticData.mutex);
        
        PlayerData best = {0};
        float minDist = 9999;
        
        for (auto &p : list) {
            if (moduleControl.playerSwitch.ignorebot && p.robot) continue;
            
            ImVec3 pos;
            memoryTools.readMemory(p.coordAddr + PubgOffset::ObjectParam::CoordParam::RelativeLocation, 
                                  sizeof(ImVec3), &pos);
            
            ImVec2 scr = worldToScreen(pos, pov, screen);
            float dist = get2dDistance(screen, scr);
            
            if (dist < minDist && dist < moduleControl.aimbotController.aimbotRadius) {
                minDist = dist;
                best.screen = scr;
                best.addr = p.addr;
            }
        }
        
        if (best.addr == 0) continue;
        
        float dx = (best.screen.x - screen.x/2) * 0.05f;
        float dy = (best.screen.y - screen.y/2) * 0.05f;
        
        AddControllerYawInput((void*)staticData.self, dx);
        AddControllerPitchInput((void*)staticData.self, dy);
    }
    return 0;
}

// ================= INIT =================
__attribute__((constructor))
static void init() {
    pthread_mutex_init(&staticData.mutex, NULL);
    
    pthread_t t1, t2, t3;
    pthread_create(&t1, 0, readStaticData, 0);
    pthread_create(&t2, 0, espThread, 0);
    pthread_create(&t3, 0, aimbotThread, 0);
}
