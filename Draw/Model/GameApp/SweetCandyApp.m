//
//  SweetCandyApp.m
//  Draw
//
//  Created by  on 12-8-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SweetCandyApp.h"

@implementation SweetCandyApp

- (NSString*)appId
{
    return CANDY_APP_ID;
}

- (NSString*)gameId
{
    return CANDY_GAME_ID;    
}

- (NSString*)umengId
{
    return CANDY_UMENG_ID;
}

- (BOOL)disableAd
{
    return NO;
}

- (NSString*)background
{
    return CANDY_BACKGROUND;
}

- (NSString*)lmwallId
{
    return CANDY_LM_WALL_ID;
}

- (NSString*)lmAdPublisherId
{
    return CANDY_LM_AD_ID;
}

- (NSString*)aderAdPublisherId
{
    return CANDY_ADER_AD_ID;
}

- (NSString*)mangoAdPublisherId
{
    return CANDY_MANGO_AD_ID;
}

@end
