//
//  DiceRobotDecisionView.h
//  Draw
//
//  Created by Orange on 12-9-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonDialog.h"
#import "CallDiceView.h"
@class FontButton;

@interface DiceRobotDecisionView : CommonDialog

@property (retain, nonatomic) CallDiceView* calldiceView;
@property (retain, nonatomic) FontButton* wildsButton;

+ (DiceRobotDecisionView*)createDialogWithTitle:(NSString *)title 
                                        message:(NSString *)message 
                                       delegate:(id<CommonDialogDelegate>)aDelegate 
                                          theme:(CommonDialogTheme)theme;

- (void)setShouldOpen:(BOOL)shouldOpen 
                 dice:(int)dice 
            diceCount:(int)diceCount 
              isWilds:(BOOL)isWilds;

@end
