//
//  PostponeItemAction.m
//  Draw
//
//  Created by Orange on 12-9-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PostponeItemAction.h"
#import "ItemType.h"
#import "ConfigManager.h"
#import "DiceAvatarView.h"
#import "DiceGamePlayController.h"

@implementation PostponeItemAction

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

- (BOOL)isShowNameAnimation
{
    return YES;
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
