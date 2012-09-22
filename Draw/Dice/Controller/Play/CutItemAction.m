//
//  CutItemAction.m
//  Draw
//
//  Created by 小涛 王 on 12-9-22.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "CutItemAction.h"

@implementation CutItemAction

// Left to be realize for sub class.
- (BOOL)useScene
{
    BOOL enabled;
        
    if (_gameService.lastCallUserId != nil 
        && ![_userManager isMe:_gameService.lastCallUserId])
    {
        enabled = YES;
    }else {
        enabled = NO;
    }

    return enabled;
}

- (void)showItemAnimation:(NSString *)userId 
                 itemType:(int)itemType 
               controller:(DiceGamePlayController *)controller
                     view:(UIView *)view
{
    [self showGifViewOnUserAvatar:userId
                          gifFile:@"cut.gif"
                       controller:controller
                             view:view];
}

@end
