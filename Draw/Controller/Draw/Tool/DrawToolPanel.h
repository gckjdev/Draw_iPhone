//
//  DrawToolPanel.h
//  Draw
//
//  Created by gamy on 12-12-24.
//
//

#import <UIKit/UIKit.h>
#import "ColorPoint.h"
#import "DrawSlider.h"
#import "PenView.h"
#import "ItemType.h"
#import "Palette.h"
#import "CMPopTipView.h"
//#import "PenBox.h"
//#import "ColorBox.h"
//#import "ColorShopView.h"
#import "DrawView.h"
//#import "WidthBox.h"
//#import "ShapeBox.h"
//#import "DrawBgBox.h"



@class ToolHandler;



@interface DrawToolPanel : UIView<ColorPointDelegate>
{
    
}
//@property(nonatomic, retain)DrawColor *color;
//@property(nonatomic, assign)CGFloat width;
//@property(nonatomic, assign)CGFloat alpha;
//@property(nonatomic, assign)ItemType penType;
//@property(nonatomic, assign)ShapeType shapeType;
@property(nonatomic, assign)NSInteger timerDuration;
@property(nonatomic, retain)NSString *drawBgId;

@property(nonatomic, retain)ToolHandler *toolHandler;


+ (id)createViewWithdelegate:(id)delegate;

+ (id)createViewWithdToolHandler:(ToolHandler *)handler;

- (void)updateView;
- (void)setPanelForOnline:(BOOL)isOnline;
- (void)updateRecentColorViewWithColor:(DrawColor *)color updateModel:(BOOL)updateModel;

#pragma mark - Timer

- (void)startTimer;
- (void)stopTimer;
@end
