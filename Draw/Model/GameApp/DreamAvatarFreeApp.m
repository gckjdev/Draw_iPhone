//
//  DreamAvatarFreeApp.m
//  Draw
//
//  Created by haodong on 13-5-3.
//
//

#import "DreamAvatarFreeApp.h"
#import "IAPProductService.h"

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
    return NO;
}

- (NSString*)umengId
{
    return DREAM_AVATAR_FREE_UMENG_ID;
}

- (BOOL)hasBGOffscreen{
    return YES;
}

- (NSString *)alipayCallBackScheme
{
    return @"alipaydreamavatarfree.gckj";
}

- (void)createIAPTestDataFile
{
    [IAPProductService createDreamAvatarFreeIngotTestDataFile];
}

@end
