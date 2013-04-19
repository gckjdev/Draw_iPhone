//
//  LearnDrawApp.m
//  Draw
//
//  Created by gamy on 13-4-11.
//
//

#import "LearnDrawApp.h"
#import "MobClickUtils.h"
#import "ConfigManager.h"
#import "ShareImageManager.h"
#import "DrawGameJumpHandler.h"


//Copy From DrawGameApp.m

@implementation LearnDrawApp

- (NSString*)appId
{
    return LEARN_DRAW_APP_ID;
}

- (NSString*)gameId
{
    return LEARN_DRAW_GAME_ID;
}

- (BOOL)disableAd
{
    return YES;
}

- (NSString*)umengId
{
    return LEARN_DRAW_UMENG_ID;
}

@end
