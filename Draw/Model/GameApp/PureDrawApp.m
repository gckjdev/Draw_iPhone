//
//  PureDrawApp.m
//  Draw
//
//  Created by haodong on 13-4-19.
//
//

#import "PureDrawApp.h"

@implementation PureDrawApp

- (NSString*)appId
{
    return PURE_DRAW_APP_ID;
}

- (NSString*)gameId
{
    return PURE_DRAW_GAME_ID;
}


- (BOOL)disableAd
{
    return YES;
}


- (NSString*)umengId
{
    return PURE_DRAW_UMENG_ID;
}

- (BOOL)hasBGOffscreen
{
    return NO;
}


@end
