//
//  DreamAvatarFreeApp.m
//  Draw
//
//  Created by haodong on 13-5-3.
//
//

#import "DreamAvatarFreeApp.h"

@implementation DreamAvatarFreeApp

- (NSString*)appId
{
    return DREAM_AVATAR_FREE_APP_ID;
}

- (NSString*)gameId
{
    return DREAM_AVATAR_FREE_GAME_ID;
}

- (BOOL)disableAd
{
    return YES;
}

- (NSString*)umengId
{
    return DREAM_AVATAR_FREE_UMENG_ID;
}

- (BOOL)hasBGOffscreen{
    return YES;
}

@end
