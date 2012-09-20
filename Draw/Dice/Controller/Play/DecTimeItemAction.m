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
#import "UserManager.h"
#import "DiceAvatarView.h"

@implementation DecTimeItemAction

- (void)showItemAnimation:(NSString *)userId 
                 itemType:(int)itemType 
               controller:(DiceGamePlayController *)controller
                     view:(UIView *)view
{
    return;
}

- (void)useItemSuccess:(DiceGamePlayController *)controller
                  view:(UIView *)view
{
    [controller urgeUser:[_gameService.session getNextSeatPlayerByUserId:_userManager.userId].userId];
}

- (void)someoneUseItem:(NSString *)userId
            controller:(DiceGamePlayController *)controller
                  view:(UIView *)view
{

    PBGameUser* itemTarget = [_gameService.session getNextSeatPlayerByUserId:userId];
//    PBGameUser* itemUser = [_gameService.session getUserByUserId:userId];
//    PPDebug(@"<test> %@(sit at %d) use an urge item, urge user %@(sit ad %d)", itemUser.nickName, itemUser.seatId,  itemTarget.nickName, itemTarget.seatId);
    [controller urgeUser:itemTarget.userId];
}
@end
