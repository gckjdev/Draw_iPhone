//
//  SecureSmsApp.m
//  Draw
//
//  Created by haodong on 13-5-22.
//
//

#import "SecureSmsApp.h"
#import "SecureSmsHomeController.h"

@interface SecureSmsApp()

@property (retain, nonatomic) SecureSmsHomeController *homeController;

@end

@implementation SecureSmsApp

- (void)dealloc
{
    [_homeController release];
    [super dealloc];
}

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
    return @"51aed40756240b1b90001c78";
}

- (BOOL)hasBGOffscreen{
    return YES;
}

- (BOOL)canSubmitDraw
{
    return YES;
}

- (PPViewController *)homeController
{
    if (_homeController == nil) {
        self.homeController = [[[SecureSmsHomeController alloc] initWithType:PureChatTypeSecureSms] autorelease];
    }
    return _homeController;
}

- (void)HandleWithDidFinishLaunching
{
    [(SecureSmsHomeController *)[self homeController] showInputView:nil];
}

- (void)HandleWithDidBecomeActive
{
    [(SecureSmsHomeController *)[self homeController] showInputView:nil];
}

- (NSString *)alipayCallBackScheme
{
    return @"alipaysecuresms.gckj";
}

- (NSString*)iapResourceFileName
{
    return [self gameId];
}

- (BOOL)showLocateButton
{
    return NO;
}

@end
