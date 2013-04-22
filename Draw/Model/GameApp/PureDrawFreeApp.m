//
//  PureDrawFreeApp.m
//  Draw
//
//  Created by haodong on 13-4-19.
//
//

#import "PureDrawFreeApp.h"

@implementation PureDrawFreeApp

- (NSString*)appId
{
    return LEARN_DRAW_APP_ID;
}

- (NSString*)gameId
{
    return PURE_DRAW_FREE_GAME_ID;
}


- (BOOL)disableAd
{
    return NO;
}


- (NSString*)umengId
{
    return LEARN_DRAW_UMENG_ID;
}

@end
