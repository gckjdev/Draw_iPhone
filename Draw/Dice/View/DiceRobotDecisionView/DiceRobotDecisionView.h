//
//  DiceRobotDecisionView.h
//  Draw
//
//  Created by Orange on 12-9-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonDialog.h"
#import "CallDiceView.h"

@interface DiceRobotDecisionView : CommonDialog

@property (assign, nonatomic) BOOL shouldOpen;
@property (assign, nonatomic) int shouldCallDiceCount;
@property (assign, nonatomic) int shouldCallDice;
@property (retain, nonatomic) CallDiceView* calldiceView;
@property (retain, nonatomic) UIButton* wildsButton;

@end
