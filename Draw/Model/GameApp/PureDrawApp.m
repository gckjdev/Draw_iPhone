//
//  PureDrawApp.m
//  Draw
//
//  Created by haodong on 13-4-19.
//
//

#import "PureDrawApp.h"
#import "PureDrawHomeController.h"

@implementation PureDrawApp

- (NSString*)appId
{
    return PURE_DRAW_APP_ID;
}

- (NSString*)gameId
{
    return PURE_DRAW_GAME_ID;
}


- (BOOL)disableAd
{
    return YES;
}


- (NSString*)umengId
{
    return PURE_DRAW_UMENG_ID;
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
    return @"alipaypuredraw.gckj";
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
}

- (void)HandleWithDidBecomeActive
{
    
}

- (NSString*)domodWallId
{
    return @"96ZJ2rhAze+vLwTA1k";
}

@end
