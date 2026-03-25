//
//  OverlayView.h
//  Dolphins
//

#import <UIKit/UIKit.h>
#import "Dolphins/utils/module_tools.h"

@class mao;
@class mi;

@interface OverlayView : UIView
- (instancetype)initWithFrame:(CGRect)frame :(ModuleControl*)control :(mao*)drawWindow :(mi*)menuWindow;
@end