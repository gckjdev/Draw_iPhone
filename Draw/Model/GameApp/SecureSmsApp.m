//
//  SecureSmsApp.m
//  Draw
//
//  Created by haodong on 13-5-22.
//
//

#import "SecureSmsApp.h"
#import "SecureSmsHomeController.h"

@implementation SecureSmsApp

- (NSString*)appId
{
    return SECURE_SMS_APP_ID;
}

- (NSString*)gameId
{
    return SECURE_SMS_GAME_ID;
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
    return [[[SecureSmsHomeController alloc] initWithType:PureChatTypeSecureSms] autorelease];
}

- (NSString *)alipayCallBackScheme
{
    return @"alipaysecuresms.gckj";
}

@end
