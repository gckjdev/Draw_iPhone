//
//  DrawGameApp.m
//  Draw
//
//  Created by  on 12-8-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawGameApp.h"

@implementation DrawGameApp

- (NSString*)appId
{
    return DRAW_APP_ID;
}

- (NSString*)gameId
{
    return DRAW_GAME_ID;    
}

- (NSString*)umengId
{
    return DRAW_UMENG_ID;
}

- (BOOL)disableAd
{
    return NO;
}

- (NSString*)background
{
    return DRAW_BACKGROUND;
}

- (NSString*)lmwallId
{
    return DRAW_LM_WALL_ID;
}

- (NSString*)lmAdPublisherId
{
    return DRAW_LM_AD_ID;
}

- (NSString*)aderAdPublisherId
{
    return DRAW_ADER_AD_ID;
}

- (NSString*)mangoAdPublisherId
{
    return DRAW_MANGO_AD_ID;
}


@end
