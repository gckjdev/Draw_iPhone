//
//  DiceRobotDecisionView.m
//  Draw
//
//  Created by Orange on 12-9-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DiceRobotDecisionView.h"

@implementation DiceRobotDecisionView
@synthesize shouldOpen;
@synthesize shouldCallDice;
@synthesize shouldCallDiceCount;
@synthesize wildsButton;
@synthesize calldiceView = _calldiceView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (DiceRobotDecisionView*)createDialogWithTitle:(NSString *)title 
                               message:(NSString *)message 
                                 style:(CommonDialogStyle)aStyle 
                              delegate:(id<CommonDialogDelegate>)aDelegate 
                                 theme:(CommonDialogTheme)theme 
{
    DiceRobotDecisionView* view = (DiceRobotDecisionView*)[super createDialogWithTitle:title 
                                                                               message:message 
                                                                                 style:aStyle 
                                                                              delegate:aDelegate 
                                                                                 theme:theme];
    
//    view.calldiceView = [[CallDiceView alloc] initWithDice:_robotManager.result.dice count:_robotManager.result.diceCount];
//    [_diceRobotDecision.contentView addSubview:view];
//    [view setCenter:CGPointMake(_diceRobotDecision.contentView.frame.size.width/2, _diceRobotDecision.contentView.frame.size.height/2)];
//    
//    FontButton* btn = [[[FontButton alloc] initWithFrame:self.wildsFlagButton.frame] autorelease];
//    [btn setBackgroundImage:[UIImage imageNamed:@"zhai_bg.png"] forState:UIControlStateNormal];
//    [btn.fontLable setText:NSLS(@"kDiceWilds")];
//    [btn setTitle:NSLS(@"kDiceWilds") forState:UIControlStateNormal];
//    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [_diceRobotDecision.contentView addSubview:btn];
//    [btn setCenter:CGPointMake(view.frame.origin.x - btn.frame.size.width, view.center.y)];
//    
//    [_diceRobotDecision.oKButton.fontLable setText:NSLS(@"kDoItLikeThis")];
//    [_diceRobotDecision.backButton.fontLable setText:NSLS(@"kThinkMyself")];
}

- (void)setShouldOpen:(BOOL)shouldOpen 
                 dice:(int)dice 
            diceCount:(int)diceCount
{
    
}

- (void)dealloc
{
    [wildsButton release];
    [_calldiceView release];
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
