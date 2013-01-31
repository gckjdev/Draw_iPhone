//
//  DiceRobotDecisionView.m
//  Draw
//
//  Created by Orange on 12-9-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DiceRobotDecisionView.h"

#define COMMON_DIALOG_THEME_DRAW    @"CommonDialog"
#define COMMON_DIALOG_THEME_DICE    @"CommonDiceDialog"
#define WILDS_BUTTON_FRAME ([DeviceDetection isIPAD]?(CGRectMake(0, 0, 40, 40)):(CGRectMake(0, 0, 80, 80)))

@implementation DiceRobotDecisionView
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

+ (DiceRobotDecisionView *)createDialogWithTheme:(CommonDialogTheme)theme
{
    DiceRobotDecisionView* view;
    switch (theme) {
        case CommonDialogThemeDice: {
            view = (DiceRobotDecisionView*)[self createInfoViewByXibName:COMMON_DIALOG_THEME_DICE]; 
        } break;
        case CommonDialogThemeDraw: {
            view = (DiceRobotDecisionView*)[self createInfoViewByXibName:COMMON_DIALOG_THEME_DRAW];
        } break;
        default:
            PPDebug(@"<CommonDialog> theme %d do not exist",theme);
            view = nil;
    }   
    return view;
}



+ (DiceRobotDecisionView*)createDialogWithTitle:(NSString *)title 
                               message:(NSString *)message
                              delegate:(id<CommonDialogDelegate>)aDelegate 
                                 theme:(CommonDialogTheme)theme 
{
    DiceRobotDecisionView* view = (DiceRobotDecisionView*)[DiceRobotDecisionView createDialogWithTheme:theme];
    [view initButtonsWithTheme:theme];
    
    view.calldiceView = [[[CallDiceView alloc] initWithDice:1 count:1] autorelease];
    [view.contentView addSubview:view.calldiceView];
    [view.calldiceView setCenter:CGPointMake(view.contentView.frame.size.width/2, view.contentView.frame.size.height/2)];
//    
    view.wildsButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)] autorelease];
    [view.wildsButton setBackgroundImage:[UIImage imageNamed:@"zhai_bg.png"] forState:UIControlStateNormal];
    [view.wildsButton.titleLabel setText:NSLS(@"kDiceWilds")];
    [view.wildsButton setTitle:NSLS(@"kDiceWilds") forState:UIControlStateNormal];
    [view.wildsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [view.contentView addSubview:view.wildsButton];
    [view.wildsButton setCenter:CGPointMake(view.frame.origin.x - view.wildsButton.frame.size.width, view.center.y)];
    
    [view.oKButton.titleLabel setText:NSLS(@"kDoItLikeThis")];
    [view.backButton.titleLabel setText:NSLS(@"kThinkMyself")];
    return view;
}

- (void)setShouldOpen:(BOOL)shouldOpen 
                 dice:(int)dice 
            diceCount:(int)diceCount 
              isWilds:(BOOL)isWilds
{
    if (shouldOpen) {
        [self.messageLabel setText:NSLS(@"kJustOpen")];
        self.calldiceView.hidden = YES;
        self.wildsButton.hidden = YES;
    } else {
        self.calldiceView.hidden = NO;
        if (isWilds) {
            self.wildsButton.hidden = NO;
        }
        [self.calldiceView setDice:dice count:diceCount];
    }
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
