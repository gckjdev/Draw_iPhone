//
//  DreamAvatarApp.m
//  Draw
//
//  Created by haodong on 13-5-3.
//
//

#import "DreamAvatarApp.h"

@implementation DreamAvatarApp

- (NSString*)appId
{
    return DREAM_AVATAR_APP_ID;
}

- (NSString*)gameId
{
    return DREAM_AVATAR_GAME_ID;
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

@end
