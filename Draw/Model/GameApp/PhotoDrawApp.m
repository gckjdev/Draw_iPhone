//
//  PhotoDrawApp.m
//  Draw
//
//  Created by haodong on 13-4-19.
//
//

#import "PhotoDrawApp.h"
#import "PhotoDrawHomeController.h"

@implementation PhotoDrawApp

- (NSString*)appId
{
    return PHOTO_DRAW_APP_ID;
}

- (NSString*)gameId
{
    return PHOTO_DRAW_GAME_ID;
}


- (BOOL)disableAd
{
    return YES;
}


- (NSString*)umengId
{
    return PHOTO_DRAW_UMENG_ID;
}

- (BOOL)hasBGOffscreen
{
    return YES;
}

- (BOOL)canPayWithAlipay
{
    return NO;
}

- (PPViewController *)homeController
{
    return [[[PhotoDrawHomeController alloc] init] autorelease];
}

- (BOOL)forceSaveDraft
{
    return YES;
}

- (void)HandleWithDidFinishLaunching
{
    
}

@end
