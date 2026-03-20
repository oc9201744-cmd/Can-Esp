//
//  MenuWindow.m
//  Dolphins
//
//  Created by xbk on 2022/4/25.
//

#import "Dolphins/crossoffsets.h"
#import "Dolphins/Module/菜单.h"
#import "Dolphins/View/OverlayView.h"
#include "JRMemory.framework/Headers/MemScan.h"
#import "Dolphins/Obfuscate.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#include <stdint.h>
#import <substrate.h>
#import <sys/sysctl.h>

@implementation mi

INI* config;

const char *optionItemName[] = {"HOME", "MENU ESP", "MENU ITEM", "MENU AIM", "Aim settings", "Skins"};
int optionItemCurrent = 0;

int aimbotIntensity;
const char *aimbotIntensityText[] = {"Very low","Low", "Medium", "Hard", "Very hard", "Lock", "Hard lock"};

const char *aimbotModeText[] = {"Scope", "Fire", "Scope & Fire", "Auto when fire"};

const char *aimbotPartsText[] = {"Priority head", "Priority body", "Automatic", "Fixed head"};

const char *m416text[] = {"Glacier", "Fool", "Shinobi Kami"};

OverlayView *overlayView;

static id<MTLTexture> gAppIconTexture = nil;
static BOOL gTriedLoadAppIconTexture = NO;

- (instancetype)initWithFrame:(ModuleControl*)control {
    [self startCleanupTimer];
    self.moduleControl = control;

    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"glo k.ini"];

    if(![fileManager fileExistsAtPath:filePath]){
        [fileManager createFileAtPath:filePath contents:[NSData data] attributes:nil];
    }

    config = ini_load((char*)filePath.UTF8String);

    return [super init];
}

-(void)setOverlayView:(OverlayView*)ov{
    overlayView = ov;
    [self readIniConfig];
}

#pragma mark - Helpers

- (UIImage *)primaryAppIconImage {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSDictionary *icons = info[@"CFBundleIcons"];
    NSDictionary *primaryIcon = icons[@"CFBundlePrimaryIcon"];
    NSArray *iconFiles = primaryIcon[@"CFBundleIconFiles"];

    NSString *iconName = [iconFiles lastObject];
    if (!iconName || iconName.length == 0) {
        return nil;
    }

    UIImage *img = [UIImage imageNamed:iconName];
    if (!img && ![iconName hasSuffix:@".png"]) {
        img = [UIImage imageNamed:[iconName stringByAppendingString:@".png"]];
    }

    return img;
}

- (id<MTLDevice>)menuMetalDevice {
    if (overlayView && [overlayView respondsToSelector:@selector(device)]) {
        id dev = [overlayView performSelector:@selector(device)];
        if (dev) return (id<MTLDevice>)dev;
    }
    return MTLCreateSystemDefaultDevice();
}

- (id<MTLTexture>)textureFromImage:(UIImage *)image {
    if (!image) return nil;

    id<MTLDevice> device = [self menuMetalDevice];
    if (!device) return nil;

    MTKTextureLoader *loader = [[MTKTextureLoader alloc] initWithDevice:device];
    NSData *pngData = UIImagePNGRepresentation(image);
    if (!pngData) return nil;

    NSError *error = nil;
    NSDictionary *options = @{
        MTKTextureLoaderOptionSRGB : @NO
    };

    id<MTLTexture> texture = [loader newTextureWithData:pngData options:options error:&error];
    if (error) {
        NSLog(@"App icon texture load error: %@", error.localizedDescription);
    }
    return texture;
}

- (void)prepareAppIconTextureIfNeeded {
    if (gTriedLoadAppIconTexture) return;
    gTriedLoadAppIconTexture = YES;

    UIImage *iconImage = [self primaryAppIconImage];
    if (!iconImage) {
        NSLog(@"App icon image not found.");
        return;
    }

    gAppIconTexture = [self textureFromImage:iconImage];
    if (!gAppIconTexture) {
        NSLog(@"App icon texture create failed.");
    }
}
- (NSString *)deviceMachineCode {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform ?: @"Unknown";
}

- (NSString *)deviceModelName {
    NSString *platform = [self deviceMachineCode];

    NSDictionary *map = @{
        @"iPhone10,1" : @"iPhone 8",
        @"iPhone10,4" : @"iPhone 8",
        @"iPhone10,2" : @"iPhone 8 Plus",
        @"iPhone10,5" : @"iPhone 8 Plus",
        @"iPhone10,3" : @"iPhone X",
        @"iPhone10,6" : @"iPhone X",

        @"iPhone11,2" : @"iPhone XS",
        @"iPhone11,4" : @"iPhone XS Max",
        @"iPhone11,6" : @"iPhone XS Max",
        @"iPhone11,8" : @"iPhone XR",

        @"iPhone12,1" : @"iPhone 11",
        @"iPhone12,3" : @"iPhone 11 Pro",
        @"iPhone12,5" : @"iPhone 11 Pro Max",

        @"iPhone12,8" : @"iPhone SE 2",
        @"iPhone13,1" : @"iPhone 12 mini",
        @"iPhone13,2" : @"iPhone 12",
        @"iPhone13,3" : @"iPhone 12 Pro",
        @"iPhone13,4" : @"iPhone 12 Pro Max",

        @"iPhone14,4" : @"iPhone 13 mini",
        @"iPhone14,5" : @"iPhone 13",
        @"iPhone14,2" : @"iPhone 13 Pro",
        @"iPhone14,3" : @"iPhone 13 Pro Max",
        @"iPhone14,6" : @"iPhone SE 3",

        @"iPhone14,7" : @"iPhone 14",
        @"iPhone14,8" : @"iPhone 14 Plus",
        @"iPhone15,2" : @"iPhone 14 Pro",
        @"iPhone15,3" : @"iPhone 14 Pro Max",

        @"iPhone15,4" : @"iPhone 15",
        @"iPhone15,5" : @"iPhone 15 Plus",
        @"iPhone16,1" : @"iPhone 15 Pro",
        @"iPhone16,2" : @"iPhone 15 Pro Max",

        @"i386" : @"Simulator",
        @"x86_64" : @"Simulator",
        @"arm64" : @"Simulator"
    };

    NSString *name = map[platform];
    return name ?: platform;
}

- (NSString *)batteryStateString {
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;

    switch (device.batteryState) {
        case UIDeviceBatteryStateUnknown:
            return @"Unknown";
        case UIDeviceBatteryStateUnplugged:
            return @"Not Charging";
        case UIDeviceBatteryStateCharging:
            return @"Charging";
        case UIDeviceBatteryStateFull:
            return @"Full";
    }
    return @"Unknown";
}

- (NSString *)batteryPercentString {
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    float level = device.batteryLevel;
    if (level < 0.0f) {
        return @"Unknown";
    }
    return [NSString stringWithFormat:@"%.0f%%", level * 100.0f];
}

- (NSString *)currentDateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd/MM/yyyy HH:mm:ss";
    return [formatter stringFromDate:[NSDate date]];
}

- (NSString *)bundleIdentifierString {
    return [[NSBundle mainBundle] bundleIdentifier] ?: @"Unknown";
}

- (NSString *)appNameString {
    NSString *name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    if (!name) {
        name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    }
    return name ?: @"Unknown";
}

- (NSString *)systemVersionString {
    return [[UIDevice currentDevice] systemVersion] ?: @"Unknown";
}

- (NSString *)appIconNameString {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSDictionary *icons = info[@"CFBundleIcons"];
    NSDictionary *primaryIcon = icons[@"CFBundlePrimaryIcon"];
    NSArray *iconFiles = primaryIcon[@"CFBundleIconFiles"];
    NSString *lastIcon = [iconFiles lastObject];
    return lastIcon ?: @"Unknown";
}

#pragma mark - Menu

-(void)drawMenuWindow {
    ImGui::SetNextWindowSize({1280, 700}, ImGuiCond_FirstUseEver);
    ImGui::SetNextWindowPos({172, 172}, ImGuiCond_FirstUseEver);

    if (ImGui::Begin("GLOCK IOS PUBG 4.2.0 FREE", &self.moduleControl->menuStatus, ImGuiWindowFlags_NoCollapse)) {
        ImGuiContext& g = *GImGui;
        if (g.NavWindow == NULL) {
            self.moduleControl->menuStatus = !self.moduleControl->menuStatus;
        }

        float leftWidth = 185.0f;
        ImGui::BeginChild("##optionLayout", {leftWidth, 0}, true, ImGuiWindowFlags_None);

        ImGui::PushStyleVar(ImGuiStyleVar_FrameRounding, 8.0f);
        ImGui::PushStyleVar(ImGuiStyleVar_ItemSpacing, ImVec2(10.0f, 14.0f));

        for (int i = 0; i < 6; ++i) {
            if (optionItemCurrent == i) {
                ImGui::PushStyleColor(ImGuiCol_Button, ImColor(40, 120, 220, 180).Value);
                ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImColor(55, 140, 240, 220).Value);
                ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImColor(30, 100, 200, 255).Value);
            } else {
                ImGui::PushStyleColor(ImGuiCol_Button, ImColor(20, 20, 20, 120).Value);
                ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImColor(40, 40, 40, 180).Value);
                ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImColor(55, 55, 55, 220).Value);
            }

            if (ImGui::Button(optionItemName[i], ImVec2(leftWidth - 18.0f, 42.0f))) {
                optionItemCurrent = i;
            }

            ImGui::PopStyleColor(3);
        }

        ImGui::PopStyleVar(2);
        ImGui::EndChild();

        ImGui::SameLine();

        ImGui::BeginChild("##surfaceLayout", {0, 0}, false, ImGuiWindowFlags_None);
        switch (optionItemCurrent) {
            case 0:
                [self showHomeTab];
                break;
            case 1:
                [self showSystemInfo];
                break;
            case 2:
                [self showMaterialControl];
                break;
            case 3:
                [self showAimbotControl];
                break;
            case 4:
                [self showAimbotControl];
                break;
            case 5:
                [self skins];
                break;
            default:
                [self showHomeTab];
                break;
        }
        ImGui::EndChild();

        ImGui::End();
    }
}

-(void)showHomeTab {
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;

    NSString *appName = [self appNameString];
    NSString *bundleID = [self bundleIdentifierString];
    NSString *deviceName = [self deviceModelName];
    NSString *machineCode = [self deviceMachineCode];
    NSString *batteryPercent = [self batteryPercentString];
    NSString *batteryState = [self batteryStateString];
    NSString *dateString = [self currentDateString];
    NSString *systemVersion = [self systemVersionString];
    NSString *iconName = [self appIconNameString];

    [self prepareAppIconTextureIfNeeded];

    ImGui::PushStyleVar(ImGuiStyleVar_FrameRounding, 10.0f);

    ImGui::BulletColorText(ImColor(97, 167, 217, 255).Value, "Home");
    ImGui::Separator();
    ImGui::Spacing();

    ImGui::BeginChild("##home_top", ImVec2(0, 140), true);

    if (gAppIconTexture) {
        ImGui::Image((__bridge void *)gAppIconTexture, ImVec2(96, 96));
    } else {
        ImGui::BeginChild("##icon_placeholder", ImVec2(96, 96), true);
        ImGui::SetCursorPosY(ImGui::GetCursorPosY() + 36.0f);
        ImGui::Text("No Icon");
        ImGui::EndChild();
    }

    ImGui::SameLine();
ImGui::BeginGroup();
ImGui::TextColored(ImVec4(0.38f, 0.72f, 1.00f, 1.00f), "Application");
ImGui::Separator();
ImGui::Text("App Name           : %s", appName.UTF8String);
ImGui::Text("Bundle Identifier  : %s", bundleID.UTF8String);
ImGui::EndGroup();

ImGui::EndChild();

ImGui::Spacing();
    ImGui::TextColored(ImVec4(0.38f, 0.72f, 1.00f, 1.00f), "Device");
    ImGui::Separator();
    ImGui::Text("Device Model       : %s", deviceName.UTF8String);
    ImGui::Text("Machine Code       : %s", machineCode.UTF8String);
    ImGui::Text("iOS Version        : %s", systemVersion.UTF8String);
    ImGui::Spacing();

    ImGui::TextColored(ImVec4(0.38f, 0.72f, 1.00f, 1.00f), "Battery");
    ImGui::Separator();
    ImGui::Text("Battery Percent    : %s", batteryPercent.UTF8String);
    ImGui::Text("Battery State      : %s", batteryState.UTF8String);
    ImGui::Spacing();

    ImGui::TextColored(ImVec4(0.38f, 0.72f, 1.00f, 1.00f), "Time");
    ImGui::Separator();
    ImGui::Text("Current Date       : %s", dateString.UTF8String);

    ImGui::PopStyleVar();
}

-(void)showSystemInfo {

    if(ImGui::Button("Update")){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSSENCRYPT("https://t.me/glockios")]];
    }

    if (ImGui::Checkbox("HideESP", &self.moduleControl->mainSwitch.gzb)) {
        configManager::putBoolean(config,"mainSwitch", "gzb", self.moduleControl->mainSwitch.gzb);
    }

    if (ImGui::Checkbox("ENABLE ESP", &self.moduleControl->mainSwitch.playerStatus)) {
        configManager::putBoolean(config,"mainSwitch", "player", self.moduleControl->mainSwitch.playerStatus);
    }

    if (ImGui::Checkbox("Icon", &self.moduleControl->playerSwitch.SCStatus)) {
        configManager::putBoolean(config,"playerSwitch", "icon", self.moduleControl->playerSwitch.SCStatus);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Weapon", &self.moduleControl->playerSwitch.SCWZStatus)) {
        configManager::putBoolean(config,"playerSwitch", "weapon", self.moduleControl->playerSwitch.SCWZStatus);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Cars", &self.moduleControl->playerSwitch.WZStatus)) {
        configManager::putBoolean(config,"playerSwitch", "cars", self.moduleControl->playerSwitch.WZStatus);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Items", &self.moduleControl->playerSwitch.WZWZStatus)) {
        configManager::putBoolean(config,"playerSwitch", "items", self.moduleControl->playerSwitch.WZWZStatus);
    }

    if (ImGui::Checkbox("Box", &self.moduleControl->playerSwitch.boxStatus)) {
        configManager::putBoolean(config,"playerSwitch", "box", self.moduleControl->playerSwitch.boxStatus);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Bones", &self.moduleControl->playerSwitch.boneStatus)) {
        configManager::putBoolean(config,"playerSwitch", "bones", self.moduleControl->playerSwitch.boneStatus);
    }
    
    // HIDE BOT - Neo XO style!
    if (ImGui::Checkbox("Hide Bot", &self.moduleControl->playerSwitch.ignorebot)) {
        configManager::putBoolean(config,"playerSwitch", "ignorebot", self.moduleControl->playerSwitch.ignorebot);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Line", &self.moduleControl->playerSwitch.lineStatus)) {
        configManager::putBoolean(config,"playerSwitch", "line", self.moduleControl->playerSwitch.lineStatus);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Info", &self.moduleControl->playerSwitch.infoStatus)) {
        configManager::putBoolean(config,"playerSwitch", "info", self.moduleControl->playerSwitch.infoStatus);
    }

    if (ImGui::Checkbox("Fill", &self.moduleControl->playerSwitch.fillStatus)) {
        configManager::putBoolean(config,"playerSwitch", "fill", self.moduleControl->playerSwitch.fillStatus);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Radar", &self.moduleControl->playerSwitch.radarStatus)) {
        configManager::putBoolean(config,"playerSwitch", "radar", self.moduleControl->playerSwitch.radarStatus);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Arrows", &self.moduleControl->playerSwitch.backStatus)) {
        configManager::putBoolean(config,"playerSwitch", "arrows", self.moduleControl->playerSwitch.backStatus);
    }

    ImGui::BulletColorText(ImColor(97, 167, 217, 255).Value, "RANDER DRAW ESP ");
    if (ImGui::RadioButton("60FPS", &self.moduleControl->fps, 0)) {
        configManager::putInteger(config,"mainSwitch", "fps",self.moduleControl->fps);
        overlayView.preferredFramesPerSecond = 60;
    }
    ImGui::SameLine();
    if (ImGui::RadioButton("90FPS", &self.moduleControl->fps, 1)) {
        configManager::putInteger(config,"mainSwitch", "fps",self.moduleControl->fps);
        overlayView.preferredFramesPerSecond = 90;
    }
    ImGui::SameLine();
    if (ImGui::RadioButton("120FPS", &self.moduleControl->fps, 2)) {
        configManager::putInteger(config,"mainSwitch", "fps",self.moduleControl->fps);
        overlayView.preferredFramesPerSecond = 120;
    }

    ImGui::BulletColorText(ImColor(97, 167, 217, 255).Value, "Radar mode");

    ImGui::SetNextItemWidth(ImGui::GetWindowContentRegionWidth() - calcTextSize("X position") - 32.0f);
    if (ImGui::SliderFloat("X position##radarX", &self.moduleControl->playerSwitch.radarCoord.x, 0.0f, ([UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].nativeScale), "%.0f")) {
        configManager::putFloat(config,"playerSwitch", "radarX", self.moduleControl->playerSwitch.radarCoord.x);
    }

    ImGui::SetNextItemWidth(ImGui::GetWindowContentRegionWidth() - calcTextSize("Y position") - 32.0f);
    if (ImGui::SliderFloat("Y position##radarY", &self.moduleControl->playerSwitch.radarCoord.y, 0.0f, ([UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].nativeScale), "%.0f")) {
        configManager::putFloat(config,"playerSwitch", "radarY", self.moduleControl->playerSwitch.radarCoord.y);
    }

    ImGui::SetNextItemWidth(ImGui::GetWindowContentRegionWidth() - calcTextSize("Size") - 32.0f);
    if (ImGui::SliderFloat("Size##radarSize", &self.moduleControl->playerSwitch.radarSize, 1.0f, 100, "%.0f%%")) {
        configManager::putFloat(config,"playerSwitch", "radarSize", self.moduleControl->playerSwitch.radarSize);
    }

    ImGui::Text("%.1fMs / %.1fFps", 1000 / ImGui::GetIO().Framerate, ImGui::GetIO().Framerate);
}

-(void) showMaterialControl {
    ImGui::BulletColorText(ImColor(97, 167, 217, 255).Value, "Item");
    if (ImGui::Checkbox("ENABLE ITEM", &self.moduleControl->mainSwitch.materialStatus)) {
        configManager::putBoolean(config,"mainSwitch", "material", self.moduleControl->mainSwitch.materialStatus);
    }

    if (ImGui::Checkbox("Rifle", &self.moduleControl->materialSwitch[Rifle])) {
        std::string str = "materialSwitch_" + std::to_string(Rifle);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[Rifle]);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Grenade", &self.moduleControl->materialSwitch[Missile])) {
        std::string str = "materialSwitch_" + std::to_string(Missile);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[Missile]);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Armor", &self.moduleControl->materialSwitch[Armor])) {
        std::string str = "materialSwitch_" + std::to_string(Armor);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[Armor]);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Sniper mods", &self.moduleControl->materialSwitch[SniperParts])) {
        std::string str = "materialSwitch_" + std::to_string(SniperParts);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[SniperParts]);
    }

    if (ImGui::Checkbox("Rifle mods", &self.moduleControl->materialSwitch[RifleParts])) {
        std::string str = "materialSwitch_" + std::to_string(RifleParts);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[RifleParts]);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Drugs", &self.moduleControl->materialSwitch[Drug])) {
        std::string str = "materialSwitch_" + std::to_string(Drug);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[Drug]);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Bullet", &self.moduleControl->materialSwitch[Bullet])) {
        std::string str = "materialSwitch_" + std::to_string(Bullet);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[Bullet]);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Grips", &self.moduleControl->materialSwitch[Grip])) {
        std::string str = "materialSwitch_" + std::to_string(Grip);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[Grip]);
    }
    if (ImGui::Checkbox("Cars", &self.moduleControl->materialSwitch[Vehicle])) {
        std::string str = "materialSwitch_" + std::to_string(Vehicle);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[Vehicle]);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Airdrop", &self.moduleControl->materialSwitch[Airdrop])) {
        std::string str = "materialSwitch_" + std::to_string(Airdrop);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[Airdrop]);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Flare", &self.moduleControl->materialSwitch[FlareGun])) {
        std::string str = "materialSwitch_" + std::to_string(FlareGun);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[FlareGun]);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Sniper", &self.moduleControl->materialSwitch[Sniper])) {
        std::string str = "materialSwitch_" + std::to_string(Sniper);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[Sniper]);
    }

    if (ImGui::Checkbox("Scope", &self.moduleControl->materialSwitch[Sight])) {
        std::string str = "materialSwitch_" + std::to_string(Sight);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[Sight]);
    }
    ImGui::SameLine();
    if (ImGui::Checkbox("Grenade warning", &self.moduleControl->materialSwitch[Warning])) {
        std::string str = "materialSwitch_" + std::to_string(Warning);
        configManager::putBoolean(config,"materialSwitch", str.c_str(), self.moduleControl->materialSwitch[Warning]);
    }
}

-(void) showAimbotControl {
    ImGui::BulletColorText(ImColor(97, 167, 217, 255).Value, "Aim");
    if (ImGui::Checkbox("ENABLE AIMBOT", &self.moduleControl->mainSwitch.aimbotStatus)) {
        configManager::putBoolean(config,"mainSwitch", "aimbot", self.moduleControl->mainSwitch.aimbotStatus);
    }

    ImGui::SetNextItemWidth(calcTextSize("Aim intensity"));
    if (ImGui::Combo("Aim intensity", &aimbotIntensity, aimbotIntensityText, IM_ARRAYSIZE(aimbotIntensityText))) {
        configManager::putInteger(config,"aimbotControl", "intensity",aimbotIntensity);
        switch (aimbotIntensity) {
            case 0:
                self.moduleControl->aimbotController.aimbotIntensity = 0.1f;
                break;
            case 1:
                self.moduleControl->aimbotController.aimbotIntensity = 0.2f;
                break;
            case 2:
                self.moduleControl->aimbotController.aimbotIntensity = 0.3f;
                break;
            case 3:
                self.moduleControl->aimbotController.aimbotIntensity = 0.4f;
                break;
            case 4:
                self.moduleControl->aimbotController.aimbotIntensity = 0.5f;
                break;
            case 5:
                self.moduleControl->aimbotController.aimbotIntensity = 1.0f;
                break;
            case 6:
                self.moduleControl->aimbotController.aimbotIntensity = 1.2f;
                break;
        }
    }

    if (ImGui::Checkbox("Show radius", &self.moduleControl->aimbotController.showAimbotRadius)) {
        configManager::putBoolean(config,"aimbotControl", "showRadius", self.moduleControl->aimbotController.showAimbotRadius);
    }

    if (ImGui::Checkbox("Ignore knock", &self.moduleControl->aimbotController.fallNotAim)) {
        configManager::putBoolean(config,"aimbotControl", "fall", self.moduleControl->aimbotController.fallNotAim);
    }

    if (ImGui::Checkbox("Ignore in smoke", &self.moduleControl->aimbotController.smoke)) {
        configManager::putBoolean(config,"aimbotControl", "smoke", self.moduleControl->aimbotController.smoke);
    }
    ImGui::SetNextItemWidth(ImGui::GetWindowContentRegionWidth() / 2 - calcTextSize("Mode") - 32.0f);
    if (ImGui::Combo("Mode", &self.moduleControl->aimbotController.aimbotMode, aimbotModeText, IM_ARRAYSIZE(aimbotModeText))) {
        configManager::putInteger(config,"aimbotControl", "mode", self.moduleControl->aimbotController.aimbotMode);
    }
    ImGui::SameLine();
    ImGui::SetNextItemWidth(ImGui::GetWindowContentRegionWidth() / 2 - calcTextSize("Part") - 32.0f);
    if (ImGui::Combo("Part", &self.moduleControl->aimbotController.aimbotParts, aimbotPartsText, IM_ARRAYSIZE(aimbotPartsText))) {
        configManager::putBoolean(config,"aimbotControl", "parts", self.moduleControl->aimbotController.aimbotParts);
    }

    ImGui::SetNextItemWidth(ImGui::GetWindowContentRegionWidth() - calcTextSize("Radius") - 32.0f);
    if (ImGui::SliderFloat("Radius", &self.moduleControl->aimbotController.aimbotRadius, 0.0f, ([UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].nativeScale) / 2, "%.0f")) {
        configManager::putFloat(config,"aimbotControl", "radius", self.moduleControl->aimbotController.aimbotRadius);
    }

    ImGui::SetNextItemWidth(ImGui::GetWindowContentRegionWidth() - calcTextSize("Distance") - 32.0f);
    if (ImGui::SliderFloat("Distance", &self.moduleControl->aimbotController.distance, 0.0f, 450.0f, "%.0fM")) {
        configManager::putFloat(config,"aimbotControl", "distance", self.moduleControl->aimbotController.distance);
    }
}

-(void) skins{

}

-(void)readIniConfig{
    self.moduleControl->fps = configManager::readInteger(config,"mainSwitch", "fps", 0);
    switch(self.moduleControl->fps){
        case 0:
            overlayView.preferredFramesPerSecond = 60;
            break;
        case 1:
            overlayView.preferredFramesPerSecond = 90;
            break;
        case 2:
            overlayView.preferredFramesPerSecond = 120;
            break;
        default:
            overlayView.preferredFramesPerSecond = 60;
            break;
    }

    self.moduleControl->mainSwitch.playerStatus = configManager::readBoolean(config,"mainSwitch", "player", false);
    self.moduleControl->mainSwitch.materialStatus = configManager::readBoolean(config,"mainSwitch", "material", false);
    self.moduleControl->mainSwitch.aimbotStatus = configManager::readBoolean(config,"mainSwitch", "aimbot", false);

    self.moduleControl->playerSwitch.boneStatus = configManager::readBoolean(config,"playerSwitch", "bones", true);  // VARSAYILAN AÇIK!
    self.moduleControl->playerSwitch.ignorebot = configManager::readBoolean(config,"playerSwitch", "ignorebot", false);  // HIDE BOT (varsayılan kapalı)
    self.moduleControl->playerSwitch.SCStatus = configManager::readBoolean(config,"playerSwitch", "icon", false);
    self.moduleControl->playerSwitch.boxStatus = configManager::readBoolean(config,"playerSwitch", "box", false);
    self.moduleControl->playerSwitch.WZStatus = configManager::readBoolean(config,"playerSwitch", "cars", false);
    self.moduleControl->playerSwitch.lineStatus = configManager::readBoolean(config,"playerSwitch", "line", false);
    self.moduleControl->playerSwitch.WZWZStatus = configManager::readBoolean(config,"playerSwitch", "items", false);
    self.moduleControl->playerSwitch.infoStatus = configManager::readBoolean(config,"playerSwitch", "info", false);
    self.moduleControl->playerSwitch.backStatus = configManager::readBoolean(config,"playerSwitch", "arrows", false);
    self.moduleControl->playerSwitch.radarStatus = configManager::readBoolean(config,"playerSwitch", "radar", false);
    self.moduleControl->playerSwitch.fillStatus = configManager::readBoolean(config,"playerSwitch", "fill", false);
    self.moduleControl->playerSwitch.lineStatusC = configManager::readBoolean(config,"playerSwitch", "aimline", false);

    self.moduleControl->playerSwitch.radarSize = configManager::readFloat(config,"playerSwitch", "radarSize", 70);
    self.moduleControl->playerSwitch.radarCoord.x = configManager::readFloat(config,"playerSwitch", "radarX", 500);
    self.moduleControl->playerSwitch.radarCoord.y = configManager::readFloat(config,"playerSwitch", "radarY", 500);

    for (int i = 0; i < All; ++i) {
        std::string str = "materialSwitch_" + std::to_string(i);
        self.moduleControl->materialSwitch[i] = configManager::readBoolean(config,"materialSwitch", str.c_str(), false);
    }

    self.moduleControl->aimbotController.fallNotAim = configManager::readBoolean(config,"aimbotControl", "fall", false);
    self.moduleControl->aimbotController.showAimbotRadius = configManager::readBoolean(config,"aimbotControl", "showRadius", true);
    self.moduleControl->aimbotController.aimbotRadius = configManager::readFloat(config,"aimbotControl", "radius", 500);
    self.moduleControl->aimbotController.smoke = configManager::readBoolean(config,"aimbotControl", "smoke", true);
    self.moduleControl->aimbotController.aimbotMode = configManager::readInteger(config,"aimbotControl", "mode", 0);
    self.moduleControl->aimbotController.aimbotParts = configManager::readInteger(config,"aimbotControl", "parts", 0);

    aimbotIntensity = configManager::readInteger(config,"aimbotControl", "intensity", 2);
    switch (aimbotIntensity) {
        case 0:
            self.moduleControl->aimbotController.aimbotIntensity = 0.1f;
            break;
        case 1:
            self.moduleControl->aimbotController.aimbotIntensity = 0.2f;
            break;
        case 2:
            self.moduleControl->aimbotController.aimbotIntensity = 0.3f;
            break;
        case 3:
            self.moduleControl->aimbotController.aimbotIntensity = 0.4f;
            break;
        case 4:
            self.moduleControl->aimbotController.aimbotIntensity = 0.5f;
            break;
        case 5:
            self.moduleControl->aimbotController.aimbotIntensity = 1.0f;
            break;
        case 6:
            self.moduleControl->aimbotController.aimbotIntensity = 1.2f;
            break;
    }

    self.moduleControl->mainSwitch.gzb = configManager::readBoolean(config,"mainSwitch", "gzb", true);
    self.moduleControl->aimbotController.distance = configManager::readFloat(config,"aimbotControl", "distance", 450);
}

- (void)startCleanupTimer {
    NSTimer *cleanupTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                             target:self
                                                           selector:@selector(cleanupFolder)
                                                           userInfo:nil
                                                            repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:cleanupTimer forMode:NSRunLoopCommonModes];
}

- (void)cleanupFolder {
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *anoTmpFolderPath = [documentsPath stringByAppendingPathComponent:@"ano_tmp"];

    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:anoTmpFolderPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:anoTmpFolderPath error:&error];

        if (error) {
            NSLog(@"Error removing folder: %@", error.localizedDescription);
        } else {
            NSLog(@"Folder 'ano_tmp' content removed successfully.");
        }
    }
}





@end
