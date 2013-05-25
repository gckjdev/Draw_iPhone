//
//  PhotoDrawFreeApp.m
//  Draw
//
//  Created by haodong on 13-4-19.
//
//

#import "PhotoDrawFreeApp.h"
#import "PhotoDrawHomeController.h"

@implementation PhotoDrawFreeApp

- (NSString*)appId
{
    return PHOTO_DRAW_FREE_APP_ID;
}

- (NSString*)gameId
{
    return PHOTO_DRAW_FREE_GAME_ID;
}


- (BOOL)disableAd
{
    return NO;
}


- (NSString*)umengId
{
    return PHOTO_DRAW_FREE_UMENG_ID;
}

- (BOOL)hasBGOffscreen
{
    return YES;
}

- (BOOL)canPayWithAlipay
{
    return YES;
}

- (NSString *)alipayCallBackScheme
{
    return @"alipayphotodrawfree.gckj";
}

- (PPViewController *)homeController
{
    return [[[PhotoDrawHomeController alloc] init] autorelease];
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






@end
