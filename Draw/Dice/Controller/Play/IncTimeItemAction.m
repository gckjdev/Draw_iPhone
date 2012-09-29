//
//  IncTimeItemAction.m
//  Draw
//
//  Created by Orange on 12-9-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "IncTimeItemAction.h"
#import "ItemType.h"
#import "ConfigManager.h"
#import "DiceAvatarView.h"
#import "DiceGamePlayController.h"

@implementation IncTimeItemAction

- (BOOL)useScene
{
    return [self isMyTurn] && ([_gameService.diceSession itemUseCount:_itemType] < 1);
}

- (void)postponeAvatar:(DiceAvatarView*)avatar 
{
    float postponeTime = [ConfigManager getPostponeTime];
    float currentProgress = [avatar getCurrentProgress];
    float newProgress = (MIN(1, currentProgress+postponeTime/USER_THINK_TIME_INTERVAL));
    [avatar setCurrentProgress:newProgress];
}

- (void)postpone:(DiceGamePlayController*)controller 
            view:(UIView*)view 
{    
    DiceAvatarView* avatar = [controller selfAvatarView];
    [self postponeAvatar:avatar];
}

- (void)showItemAnimation:(NSString *)userId 
                 itemType:(int)itemType 
               controller:(DiceGamePlayController *)controller 
                     view:(UIView *)view
{
    [self showGifViewOnUserAvatar:userId
                          gifFile:@"delay.gif"
                       controller:controller
                             view:view];
}

- (void)useItemSuccess:(DiceGamePlayController *)controller
                  view:(UIView *)view 
              response:(UseItemResponse *)response
{
    [self postpone:controller view:view];
}

- (void)someoneUseItem:(NSString *)userId
            controller:(DiceGamePlayController *)controller
                  view:(UIView *)view 
               request:(UseItemRequest *)request
{
    DiceAvatarView* avatar = [controller avatarViewOfUser:userId];
    [self postponeAvatar:avatar];
}

- (void)useItem:(DiceGamePlayController *)controller
           view:(UIView *)view
{
    DiceAvatarView* selfAvatar = (DiceAvatarView*)[controller selfAvatarView];
    float incTime =MIN(USER_THINK_TIME_INTERVAL*(1-selfAvatar.getCurrentProgress), [ConfigManager getPostponeTime]);
    [_gameService userTimeItem:ItemTypeIncTime time:incTime];
    PPDebug(@"<test> I use item and delay time for %f", incTime);
}


@end
