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

#define ANIMATION_GROUP_MOVE_TO_CENTER @"ANIMATION_GROUP_MOVE_TO_CENTER"
#define ANIMATION_GROUP_STAY @"ANIMATION_GROUP_STAY"
#define ANIMATION_GROUP_MOVE_BACK @"ANIMATION_GROUP_MOVE_BACK"



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

- (void)setDices:(NSArray *)diceList
      resultDice:(int)resultDice
           wilds:(BOOL)wilds
        ruleType:(DiceGameRuleType)ruleType;

- (void)showAnimation:(CGPoint)center;

@end
