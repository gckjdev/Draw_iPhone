//
//  DicesResultView.h
//  Draw
//
//  Created by haodong on 12-8-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dice.pb.h"
#import "GameConstants.pb.h"
#import "CustomDiceManager.h"

#define ANIMATION_GROUP_MOVE_TO_CENTER @"ANIMATION_GROUP_MOVE_TO_CENTER"
#define ANIMATION_GROUP_STAY @"ANIMATION_GROUP_STAY"
#define ANIMATION_GROUP_MOVE_BACK @"ANIMATION_GROUP_MOVE_BACK"

#define DURATION_SHOW_RESULT_PER_PLAYER (DURATION_MOVE_TO_CENTER+DURATION_MOVE_TO_BACK+DURATION_STAY)

#define DURATION_MOVE_TO_CENTER 0.75
#define DURATION_MOVE_TO_BACK 0.75
#define DURATION_STAY 2

@protocol DicesResultViewAnimationDelegate <NSObject>

@optional
- (void)moveToCenterDidStart:(int)resultDiceCount;
- (void)stayDidStart:(int)resultDiceCount;
- (void)moveBackDidStart:(int)resultDiceCount;
- (void)moveToCenterDidStop:(int)resultDiceCount;
- (void)stayDidStop:(int)resultDiceCount;
- (void)moveBackDidStop:(int)resultDiceCount;

@end

@interface DicesResultView : UIView

@property (assign, nonatomic) id<DicesResultViewAnimationDelegate> delegate;

- (void)showUserResult:(NSString *)userId toCenter:(CGPoint)center customDiceType:(CustomDiceType)type;

@end
