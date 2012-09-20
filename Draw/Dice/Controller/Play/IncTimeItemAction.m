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
    return;
}

- (void)useItemSuccess:(DiceGamePlayController *)controller
                  view:(UIView *)view
{
    [self postpone:controller view:view];
}

- (void)someoneUseItem:(NSString *)userId
            controller:(DiceGamePlayController *)controller
                  view:(UIView *)view
{
    DiceAvatarView* avatar = [controller avatarViewOfUser:userId];
    [self postponeAvatar:avatar];
}


@end
