#import "Dolphins/View/OverlayView.h"
#import "Dolphins/utils/font.h"
#import "Dolphins/utils/ZGScreenInfoz.h"
#import "Dolphins/Obfuscate.h"

#import "HeeeNoScreenShotView.h"
#import <objc/runtime.h>

HeeeNoScreenShotView *hideesp;

@implementation OverlayView
{
    ImFont *_espFont;
    ImFont *_iconFont;
}

- (instancetype)initWithFrame:(CGRect)frame :(ModuleControl*)control :(mao*)draw :(mi*)menu {

    hideesp = [[HeeeNoScreenShotView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [[UIApplication sharedApplication].windows[0].rootViewController.view addSubview:hideesp];
    hideesp.userInteractionEnabled = false;

    self.moduleControl = control;
    self.mao = draw;
    self.mi = menu;

    if (self = [super initWithFrame:frame]) {

        // 清空颜色
        self.backgroundColor = [UIColor clearColor];

        // 设置帧率
        self.preferredFramesPerSecond = 120;

        self.device = MTLCreateSystemDefaultDevice();
        if (!self.device) {
            return NULL;
        }

        self.delegate = self;

        self.commandQueue = [self.device newCommandQueue];
        self.loader = [[MTKTextureLoader alloc] initWithDevice:self.device];

        IMGUI_CHECKVERSION();
        ImGui::CreateContext();

        ImGuiIO& io = ImGui::GetIO(); (void)io;

        ImGui::StyleColorsClassic();

        ImFontConfig config;
        ImGuiStyle& style = ImGui::GetStyle();

        static const ImWchar icons_ranges[] = { 0xf000, 0xf3ff, 0 };

        ImFontConfig icons_config;

        config.FontDataOwnedByAtlas = false;

        icons_config.MergeMode = true;
        icons_config.PixelSnapH = true;

        ImGui::StyleColorsDark();

        // 加载字体
        _espFont = io.Fonts->AddFontFromMemoryTTF(
            (void*)glock_ttf,
            glock_ttf_size,
            28.0f,
            &config,
            io.Fonts->GetGlyphRangesDefault()
        );

        io.DisplaySize.x = self.frame.size.width * UIScreen.mainScreen.nativeScale;
        io.DisplaySize.y = self.frame.size.height * UIScreen.mainScreen.nativeScale;

        ImGui::StyleColorsLight();

        // Metal Renderer
        ImGui_ImplMetal_Init(self.device);

        // 初始化纹理
        [self.mao initImageTexture:self.device];

        [self.mi setOverlayView:self];
    }

    return self;
}

/*+ (void)load
{
     nssb(0x4ECF8, 0xC0035FD6);
     nssb(0xAA048, 0xC0035FD6);
     nssb(0x18C5CC, 0xC0035FD6);
     nssb(0x185978, 0xC0035FD6);
     nssb(0x15F760, 0xC0035FD6);
     nssb(0x147980, 0xC0035FD6);
}*/

- (bool)ishowM {
    return self.moduleControl->menuStatus;
}

- (void)drawInMTKView:(MTKView *)view {

    view.sampleCount = 4;
    view.clearColor = MTLClearColorMake(0.0f,0.0f,0.0f,0.0f);

    struct timespec current_timespec;
    static double g_Time = 0.0;

    clock_gettime(CLOCK_MONOTONIC,&current_timespec);

    double current_time =
    (double)(current_timespec.tv_sec) +
    (current_timespec.tv_nsec / 1000000000.0);

    ImGui::GetIO().DeltaTime =
    g_Time > 0.0 ?
    (float)(current_time - g_Time) :
    (float)(1.0f / 120.0f);

    g_Time = current_time;

    [hideesp addSubview:self];

    if(self.moduleControl->mainSwitch.gzb){
        [hideesp addSubview:self];
    }else{
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }

    if(self.moduleControl->menuStatus){
        if(hideesp.userInteractionEnabled != true)
            hideesp.userInteractionEnabled = true;
    }else{
        if(hideesp.userInteractionEnabled != false)
            hideesp.userInteractionEnabled = false;
    }

    if(self.moduleControl->menuStatus){
        if(hideesp.userInteractionEnabled != true)
            hideesp.userInteractionEnabled = true;
    }else{
        if(hideesp.userInteractionEnabled != false)
            hideesp.userInteractionEnabled = false;
    }

    id<MTLCommandBuffer> commandBuffer =
    [self.commandQueue commandBuffer];

    MTLRenderPassDescriptor *renderPassDescriptor =
    view.currentRenderPassDescriptor;

    if (renderPassDescriptor != nil) {

        ImGui_ImplMetal_NewFrame(renderPassDescriptor);
        ImGui::NewFrame();

        if(self.moduleControl->menuStatus){
            [self.mi drawMenuWindow];
        }

        [self.mao drawDrawWindow];

        ImGui::Render();

        ImDrawData *drawData = ImGui::GetDrawData();

        id <MTLRenderCommandEncoder> renderEncoder =
        [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];

        [renderEncoder pushDebugGroup:@"SwiftGUI"];

        ImGui_ImplMetal_RenderDrawData(drawData, commandBuffer, renderEncoder);

        [renderEncoder popDebugGroup];
        [renderEncoder endEncoding];

        [commandBuffer presentDrawable:view.currentDrawable];
    }

    [commandBuffer commit];
}

-(void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size {
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {

    UIView *hitView = [super hitTest:point withEvent:event];

    if (hitView == self && !self.moduleControl->menuStatus) {
        return nil;
    }

    return hitView;
}

-(void)updateIOWithTouchEvent:(UIEvent *)event {

    UITouch *anyTouch = event.allTouches.anyObject;

    CGPoint touchLocation = [anyTouch locationInView:self];

    ImGuiIO &io = ImGui::GetIO();

    io.AddMousePosEvent(
        touchLocation.x * UIScreen.mainScreen.nativeScale,
        touchLocation.y * UIScreen.mainScreen.nativeScale
    );

    BOOL hasActiveTouch = NO;

    for (UITouch *touch in event.allTouches) {

        if (touch.phase != UITouchPhaseEnded &&
            touch.phase != UITouchPhaseCancelled) {

            hasActiveTouch = YES;
            break;
        }
    }

    io.AddMouseButtonEvent(0, hasActiveTouch);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}

@end