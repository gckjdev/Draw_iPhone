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

- (NSString*)defaultBroadImage
{
    return @"draw_default_board.png";
}

- (NSString*)sinaAppKey
{
    return @"2831348933";    
}

- (NSString*)sinaAppSecret
{
    return @"ff89c2f5667b0199ee7a8bad6c44b265";    
}

- (NSString*)qqAppKey
{
    return @"801123669";    
}

- (NSString*)qqAppSecret
{
    return @"30169d80923b984109ee24ade9914a5c";    
}

- (NSString*)facebookAppKey
{
    return @"352182988165711";    
}

- (NSString*)facebookAppSecret
{
    return @"51c65d7fbef9858a5d8bc60014d33ce2";
}


@end
