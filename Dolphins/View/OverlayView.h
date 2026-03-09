#import "Dolphins/View/CustomView/UIView+YYAdd.h"


#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#include "Dolphins/Module/视图.h"
#include "Dolphins/Module/菜单.h"


#include "Dolphins/imgui/imgui_impl_metal.h"

#include "Dolphins/utils/module_tools.h"

#include "Dolphins/utils/imgui_tools.h"

NS_ASSUME_NONNULL_BEGIN

@interface OverlayView : MTKView <MTKViewDelegate>
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;
@property (nonatomic, strong) MTKTextureLoader *loader;

@property (nonatomic, assign) ModuleControl *moduleControl;

@property (nonatomic, strong) mao *mao;
@property (nonatomic, strong) mi *mi;

- (instancetype)initWithFrame:(CGRect)frame :(ModuleControl*)control :(mao*)draw :(mi*)menu;

@end

NS_ASSUME_NONNULL_END
