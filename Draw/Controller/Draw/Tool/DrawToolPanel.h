//
//  DrawToolPanel.h
//  Draw
//
//  Created by gamy on 12-12-24.
//
//

#import <UIKit/UIKit.h>
#import "ColorPoint.h"
#import "PenView.h"
#import "ItemType.h"
#import "Palette.h"
#import "DrawInfo.h"

@class ToolHandler;



@interface DrawToolPanel : UIView<ColorPointDelegate, UIScrollViewDelegate>
{
    
}

@property(nonatomic, assign)NSInteger timerDuration;
//@property(nonatomic, retain)NSString *drawBgId;
@property(nonatomic, retain)ToolHandler *toolHandler;

- (void)updateWithDrawInfo:(DrawInfo *)drawInfo;

+ (id)createViewWithDrawInfo:(DrawInfo *)drawInfo;

////


///deprecated method
+ (id)createViewWithdToolHandler:(ToolHandler *)handler;

- (void)updateView;
- (void)setPanelForOnline:(BOOL)isOnline;
- (void)updateRecentColorViewWithColor:(DrawColor *)color updateModel:(BOOL)updateModel;

- (void)registerToolCommands;
- (IBAction)clickTool:(UIButton *)sender;
- (void)hideColorPanel:(BOOL)hide;

#pragma mark - Timer

- (void)startTimer;
- (void)stopTimer;
@end
