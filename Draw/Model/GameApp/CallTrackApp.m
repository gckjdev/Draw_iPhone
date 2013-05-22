//
//  CallTrackApp.m
//  Draw
//
//  Created by haodong on 13-5-22.
//
//

#import "CallTrackApp.h"
#import "CallTrackHomeController.h"

@implementation CallTrackApp

- (NSString*)appId
{
    return CALL_TRACK_APP_ID;
}

- (NSString*)gameId
{
    return CALL_TRACK_GAME_ID;
}

- (BOOL)disableAd
{
    return NO;
}

- (NSString*)umengId
{
    return DREAM_AVATAR_UMENG_ID;
}

- (BOOL)hasBGOffscreen{
    return YES;
}

- (PPViewController *)homeController
{
    return [[[CallTrackHomeController alloc] init] autorelease];
}

@end
