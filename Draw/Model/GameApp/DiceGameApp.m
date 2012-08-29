//
//  DiceGameApp.m
//  Draw
//
//  Created by  on 12-8-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DiceGameApp.h"

@implementation DiceGameApp

- (NSString*)appId
{
    return DICE_APP_ID;
}

- (NSString*)gameId
{
    return DICE_GAME_ID;    
}

- (NSString*)umengId
{
    return DICE_UMENG_ID;
}

- (BOOL)disableAd
{
    return NO;
}

- (NSString*)background
{
    return DICE_BACKGROUND;
}

- (NSString*)lmwallId
{
    return DICE_LM_WALL_ID;
}

- (NSString*)lmAdPublisherId
{
    return DICE_LM_AD_ID;
}

- (NSString*)aderAdPublisherId
{
    return DICE_ADER_AD_ID;
}

- (NSString*)mangoAdPublisherId
{
    return DICE_MANGO_AD_ID;
}


@end
