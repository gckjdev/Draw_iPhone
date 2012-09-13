//
//  UrgeItemAction.m
//  Draw
//
//  Created by Orange on 12-9-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UrgeItemAction.h"
#import "ItemType.h"
#import "ConfigManager.h"

@implementation UrgeItemAction

- (void)urge:(DiceGamePlayController*)controller 
        view:(UIView*)view 
{
    
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
    
}


@end
