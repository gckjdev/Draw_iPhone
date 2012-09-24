//
//  DiceRobotItemAction.m
//  Draw
//
//  Created by Orange on 12-9-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DiceRobotItemAction.h"
#import "DiceGamePlayController.h"
#import "DiceRobotManager.h"
#import "CallDiceView.h"

@implementation DiceRobotItemAction

- (BOOL)useScene
{
    return [self isMyTurn];
}

- (void)showItemAnimation:(NSString *)userId 
                 itemType:(int)itemType 
               controller:(DiceGamePlayController *)controller
                     view:(UIView *)view
{
    [self showGifViewOnUserAvatar:userId
                          gifFile:@"diceRobot.gif"
                       controller:controller
                             view:view];
}

- (void)useItemSuccess:(DiceGamePlayController *)controller
                  view:(UIView *)view
{
    [self showRobotDecision:controller view:view];
}

- (void)someoneUseItem:(NSString *)userId
            controller:(DiceGamePlayController *)controller
                  view:(UIView *)view
{
    
}

- (void)showRobotDecision:(DiceGamePlayController *)controller
                     view:(UIView *)view
{
    [controller showRobotDecision];
//    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kCallTips") 
//                                                       message:nil 
//                                                         style:CommonDialogStyleDoubleButton 
//                                                      delegate:controller 
//                                                         theme:CommonDialogThemeDice];
//    dialog.tag = ROBOT_CALL_TIPS_DIALOG_TAG;
//    if ([DiceRobotManager defaultManager].result.shouldOpen) {
//        [dialog.messageLabel setText:NSLS(@"kJustOpen")];
//    } else {
//        CallDiceView* view = [[CallDiceView alloc] initWithDice:[DiceRobotManager defaultManager].result.dice count:[DiceRobotManager defaultManager].result.diceCount];
//        [dialog.contentView addSubview:view];
//        [view setCenter:CGPointMake(dialog.contentView.frame.size.width/2, dialog.contentView.frame.size.height/2)];
//        if ([DiceRobotManager defaultManager].result.isWild) {
//            FontButton* btn = [[[FontButton alloc] initWithFrame:controller.wildsFlagButton.frame] autorelease];
//            [btn setBackgroundImage:[UIImage imageNamed:@"zhai_bg.png"] forState:UIControlStateNormal];
//            [btn.fontLable setText:NSLS(@"kDiceWilds")];
//            [btn setTitle:NSLS(@"kDiceWilds") forState:UIControlStateNormal];
//            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            [dialog.contentView addSubview:btn];
//            [btn setCenter:CGPointMake(view.frame.origin.x - btn.frame.size.width, view.center.y)];
//            
//        }
//        
//    }
//    [dialog.oKButton.fontLable setText:NSLS(@"kDoItLikeThis")];
//    [dialog.backButton.fontLable setText:NSLS(@"kThinkMyself")];
//    [dialog showInView:view];
}

@end
