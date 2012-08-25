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

@end
