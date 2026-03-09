//
//  MenuWindow.h
//  Dolphins
//
//  Created by xbk on 2022/4/25.
//

#import <UIKit/UIKit.h>



#include "Dolphins/imgui/imgui.h"

#include "Dolphins/utils/module_tools.h"

#include "Dolphins/utils/imgui_tools.h"

#include "Dolphins/utils/ini_rw.h"

@class OverlayView;

NS_ASSUME_NONNULL_BEGIN

@interface mi : NSObject

@property (nonatomic, assign) ModuleControl *moduleControl;


- (instancetype)initWithFrame:(ModuleControl*)control;

-(void)setOverlayView:(OverlayView*)ov;
//绘制菜单窗口
-(void)drawMenuWindow;
//显示系统信息页面
-(void)showSystemInfo;
//人物功能控制
-(void) showPlayerControl;
//物资功能控制
-(void) showMaterialControl;
//自瞄控制
-(void) showAimbotControl;

-(void) skins;
//读Ini配置
-(void)readIniConfig;

@end

NS_ASSUME_NONNULL_END
