
//  SingApp.m
//  Draw
//
//  Created by 王 小涛 on 13-5-21.
//
//

#import "SingApp.h"
#import "SingController.h"
#import "SingImageManager.h"
#import "SongSelectController.h"

@implementation SingApp

- (PPViewController *)homeController{
    return [[[SongSelectController alloc] init] autorelease];
}

- (NSString*)umengId{
    return @"xxxxxxx";
}

- (void)createConfigData{

}

- (NSString*)gameId{
    return SING_GAME_ID;
}

- (void)HandleWithDidFinishLaunching
{
    
}

- (void)HandleWithDidBecomeActive
{
    
}

- (BOOL)supportWeixin{
    return YES;
}

- (BOOL)isAutoRegister
{
    return NO;
}

- (NSString*)appId
{
    return SING_APP_ID;
}

- (NSString*)sinaAppKey{
    return @"xxxxx";
}

- (NSString*)sinaAppSecret{
    return @"xxxxx";
}

- (NSString*)sinaAppRedirectURI{
    return @"xxxxx";
}

- (NSString*)sinaWeiboId
{
    return @"xxxxx";

}

- (NSString*)qqAppKey
{
    return @"xxxxx";
}

- (NSString*)qqAppSecret
{
    return @"xxxxx";
}

- (NSString*)qqAppRedirectURI
{
    return @"xxxxx";
}

- (NSString*)qqWeiboId
{
    return @"xxxxx";
}

- (NSString*)facebookAppKey
{
    return @"xxxxx";
}

- (NSString*)facebookAppSecret
{
    return @"xxxxx";
}

- (NSString*)lmwallId
{
    return @"";
}

- (NSString*)youmiWallId
{
    return @""; // TODO
}

- (NSString*)youmiWallSecret
{
    return @""; // TODO
}

- (NSString*)aderWallId
{
    return @"";
}

- (NSString*)domodWallId
{
    return @"";
}

- (NSString*)tapjoyWallId
{
    return @"";//TODO
}

- (NSString*)tapjoyWallSecret
{
    return @"";//TODO
}

- (BOOL)disableAd{
    return NO;
}

- (NSString *)getInputDialogXibName{
    return @"SingInputDialog";
}

- (BOOL)showLocateButton
{
    return NO;
}

@end
