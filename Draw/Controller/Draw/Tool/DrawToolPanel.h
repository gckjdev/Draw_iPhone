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
#import "DrawView.h"
#import "MyFriend.h"


@class ToolHandler;



@interface DrawToolPanel : UIView<ColorPointDelegate>
{
    
}

@property(nonatomic, assign)NSInteger timerDuration;
@property(nonatomic, retain)NSString *drawBgId;
@property(nonatomic, retain)ToolHandler *toolHandler;


+ (id)createViewWithdelegate:(id)delegate;

+ (id)createViewWithdToolHandler:(ToolHandler *)handler;

- (void)updateView;
- (void)setPanelForOnline:(BOOL)isOnline;
- (void)updateRecentColorViewWithColor:(DrawColor *)color updateModel:(BOOL)updateModel;

- (void)updateDrawToUser:(MyFriend *)user;

#pragma mark - Timer

- (void)startTimer;
- (void)stopTimer;
@end
