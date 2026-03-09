//
//  DrawWindow.h
//  Dolphins
//
//  Created by xbk on 2022/4/24.
//

#import <UIKit/UIKit.h>

#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

#include <vector>

#include "Dolphins/utils/stb_image.h"

#include "Dolphins/utils/module_tools.h"

#include "Dolphins/utils/imgui_tools.h"

#include "Dolphins/dolphins.h"

#include "Dolphins/utils/log.h"

NS_ASSUME_NONNULL_BEGIN

@interface mao : NSObject

@property (nonatomic, assign) ModuleControl *moduleControl;

- (instancetype)initWithFrame:(ModuleControl*)control;

-(void)drawDrawWindow;

-(void)initImageTexture: (id<MTLDevice>)device;

-(id<MTLTexture>)loadImageTexture:(id<MTLDevice>)device :(void*) imageData :(size_t) fileDataSize;

@end

NS_ASSUME_NONNULL_END
