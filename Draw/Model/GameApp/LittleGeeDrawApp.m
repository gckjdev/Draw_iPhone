//
//  LittleGeeDrawApp.m
//  Draw
//
//  Created by Kira on 13-5-7.
//
//

#import "LittleGeeDrawApp.h"
#import "LittleGeeHomeController.h"

@implementation LittleGeeDrawApp

- (PPViewController*)homeController
{
    return [[[LittleGeeHomeController alloc] init] autorelease];
}

- (NSString*)appId
{
    return LITTLE_GEE_APP_ID;
}

- (NSString*)gameId
{
    return LITTLE_GEE_GAME_ID;
}


- (BOOL)disableAd
{
    return YES;
}


- (NSString*)umengId
{
    return LITTLE_GEE_UMENG_ID;
}

@end
