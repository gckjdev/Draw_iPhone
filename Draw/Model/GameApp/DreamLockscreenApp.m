//
//  DreamLockscreenApp.m
//  Draw
//
//  Created by haodong on 13-5-3.
//
//

#import "DreamLockscreenApp.h"

@implementation DreamLockscreenApp

- (NSString*)appId
{
    return DREAM_LOCKSCREEN_APP_ID;
}

- (NSString*)gameId
{
    return DREAM_LOCKSCREEN_GAME_ID;
}

- (BOOL)disableAd
{
    return YES;
}

- (NSString*)umengId
{
    return DREAM_LOCKSCREEN_UMENG_ID;
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

//ContentGameAppProtocol
- (int)sellContentType
{
    return SellContentTypeDreamLockscreen;
}

- (NSString*)domodWallId
{
    return @"96ZJ2j3gze+vLwTA1n";
}

@end