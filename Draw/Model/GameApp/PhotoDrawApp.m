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

- (NSString *)alipayCallBackScheme
{
    return @"alipayphotodraw.gckj";
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
#ifdef DEBUG
    NSString* root = @"/gitdata/Draw_iPhone/Draw/CommonResource/Config/";
    NSString* path = [root stringByAppendingString:[GameConfigDataManager configFileName]];
    NSString* versionPath = [root stringByAppendingString:[PPSmartUpdateDataUtils getVersionFileName:[GameConfigDataManager configFileName]]];
    
    PBConfig_Builder* builder = [PBConfig builder];
    
    PBAppReward* diceApp = [GameConfigDataManager diceAppWithRewardAmount:5 rewardCurrency:PBGameCurrencyIngot];
    PBAppReward* zjhApp = [GameConfigDataManager zjhAppWithRewardAmount:8 rewardCurrency:PBGameCurrencyIngot];
    
    [builder addAppRewards:diceApp];
    [builder addAppRewards:zjhApp];
    
    PBConfig* config = [builder build];
    NSData* data = [config data];
    
    [data writeToFile:path atomically:YES];
    
    NSString* version = @"1.0";
    [version writeToFile:versionPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
#endif
}

- (void)HandleWithDidBecomeActive
{
    
}

- (NSString*)domodWallId
{
    return @"96ZJ2rhAze+vLwTA1k";
}


@end
