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


@interface DrawToolPanel : UIView<ColorPointDelegate, UIScrollViewDelegate>
{
    
}

@property(nonatomic, assign)NSInteger timerDuration;
//@property(nonatomic, retain)NSString *drawBgId;

- (void)updateWithDrawInfo:(DrawInfo *)drawInfo;

+ (id)createViewWithDrawInfo:(DrawInfo *)drawInfo;

////


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
