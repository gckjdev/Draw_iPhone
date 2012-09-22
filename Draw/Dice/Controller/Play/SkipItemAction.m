//
//  SkipItemAction.m
//  Draw
//
//  Created by Orange on 12-9-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SkipItemAction.h"

@implementation SkipItemAction

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
                          gifFile:@"tortoise.gif"
                       controller:controller
                             view:view];
}

- (void)useItemSuccess:(DiceGamePlayController *)controller
                  view:(UIView *)view
{
    
}

- (void)someoneUseItem:(NSString *)userId
            controller:(DiceGamePlayController *)controller
                  view:(UIView *)view
{
    
}

@end
