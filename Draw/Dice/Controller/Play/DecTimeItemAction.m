//
//  DecTimeItemAction.m
//  Draw
//
//  Created by Orange on 12-9-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DecTimeItemAction.h"
#import "ItemType.h"
#import "ConfigManager.h"
#import "DiceGamePlayController.h"

@implementation DecTimeItemAction
- (void)urge:(DiceGamePlayController*)controller 
        view:(UIView*)view 
{
    PBGameUser* user = [_gameService.diceSession getNextSeatPlayerByUserId:_gameService.userId];
    PPDebug(@"urge user <%@> sitting at %d", user.nickName, user.seatId);
    [controller urgeUser:user.userId];
}

- (BOOL)isShowNameAnimation
{
    return YES;
}

- (void)useItemSuccess:(DiceGamePlayController *)controller
                  view:(UIView *)view
{
    [self urge:controller view:view];
}

- (void)someoneUseItem:(NSString *)userId
            controller:(DiceGamePlayController *)controller
                  view:(UIView *)view
{
    [controller urgeUser:[_gameService.session getNextSeatPlayerByUserId:userId].userId];
}
@end
