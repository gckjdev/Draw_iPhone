//
//  AskPsApp.m
//  Draw
//
//  Created by haodong on 13-6-6.
//
//

#import "AskPsApp.h"
#import "AskPsHomeController.h"

@implementation AskPsApp

- (NSString*)appId
{
    return ASK_PS_APP_ID;
}

- (NSString*)gameId
{
    return ASK_PS_GAME_ID;
}

- (NSString*)umengId
{
    return DRAW_UMENG_ID;
}

- (BOOL)disableAd
{
    return NO;
}

- (PPViewController *)homeController;
{
    return [[[AskPsHomeController alloc] init] autorelease];
}

@end
