//
//  PureDrawFreeApp.m
//  Draw
//
//  Created by haodong on 13-4-19.
//
//

#import "PureDrawFreeApp.h"
#import "PureDrawHomeController.h"
#import "IAPProductService.h"

@implementation PureDrawFreeApp

- (NSString*)appId
{
    return PURE_DRAW_FREE_APP_ID;
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
    return PURE_DRAW_FREE_UMENG_ID;
}

- (BOOL)hasBGOffscreen
{
    return NO;
}

- (BOOL)canPayWithAlipay
{
    return NO;
}

- (NSString *)alipayCallBackScheme
{
    return @"alipaypuredrawfree.gckj";
}


- (PPViewController *)homeController
{
    return [[[PureDrawHomeController alloc] init] autorelease];
}

- (BOOL)forceSaveDraft
{
    return NO;
}

- (void)HandleWithDidFinishLaunching
{
    
}

- (void)HandleWithDidBecomeActive
{
    
}

- (NSString*)domodWallId
{
    return @"96ZJ2rhAze+vLwTA1k";
}

- (void)createIAPTestDataFile
{
    [IAPProductService createPureDrawFreeIngotTestDataFile];
}

@end
