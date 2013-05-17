//
//  DreamLockscreenFreeApp.m
//  Draw
//
//  Created by haodong on 13-5-3.
//
//

#import "DreamLockscreenFreeApp.h"

@implementation DreamLockscreenFreeApp

- (NSString*)appId
{
    return DREAM_LOCKSCREEN_FREE_APP_ID;
}

- (NSString*)gameId
{
    return DREAM_LOCKSCREEN_FREE_GAME_ID;
}

- (BOOL)disableAd
{
    return NO;
}

- (NSString*)umengId
{
    return DREAM_LOCKSCREEN_FREE_UMENG_ID;
}

- (BOOL)showPaintCategory
{
    return NO;
}

- (NSString*)getDefaultSNSSubject
{
    return nil;
}

- (NSString*)appItuneLink
{
    return nil;
}
- (NSString*)appLinkUmengKey
{
    return nil;
}

@end
