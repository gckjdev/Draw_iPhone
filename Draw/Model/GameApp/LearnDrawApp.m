//
//  LearnDrawApp.m
//  Draw
//
//  Created by gamy on 13-4-11.
//
//

#import "LearnDrawApp.h"
#import "MobClickUtils.h"
#import "ConfigManager.h"
#import "ShareImageManager.h"
#import "DrawGameJumpHandler.h"
#import "LearnDrawHomeController.h"
#import "LearnDrawManager.h"

@implementation LearnDrawApp

- (NSString*)appId
{
    return LEARN_DRAW_APP_ID;
}

- (NSString*)gameId
{
    return LEARN_DRAW_GAME_ID;
}

- (BOOL)disableAd
{
    return YES;
}

- (NSString*)umengId
{
    return LEARN_DRAW_UMENG_ID;
}

- (BOOL)hasBGOffscreen
{
    return NO;
}

- (BOOL)canPayWithAlipay
{
    return YES;
}

- (PPViewController *)homeController
{
    return [[[LearnDrawHomeController alloc] init] autorelease];
}

- (BOOL)forceSaveDraft
{
    return NO;
}

- (void)HandleWithDidFinishLaunching
{
    
}

- (void)createConfigData
{
    NSString* root = @"/gitdata/Draw_iPhone/Draw/CommonResource/Config/";
    NSString* path = [root stringByAppendingString:[GameConfigDataManager configFileName]];
    NSString* versionPath = [root stringByAppendingString:[PPSmartUpdateDataUtils getVersionFileName:[GameConfigDataManager configFileName]]];
    
    PBConfig_Builder* builder = [PBConfig builder];
    
    PBAppReward* diceApp = [GameConfigDataManager oldDiceAppWithRewardAmount:5 rewardCurrency:PBGameCurrencyIngot];
    
    [builder addAppRewards:diceApp];
    
    PBConfig* config = [builder build];
    NSData* data = [config data];
    
    [data writeToFile:path atomically:YES];
    
    NSString* version = @"1.0";
    [version writeToFile:versionPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (BOOL)showPaintCategory
{
    return YES;
}

- (int)sellContentType
{
    return SellContentTypeLearnDraw;
}


- (NSArray *)homeTabIDList
{
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:LearnDrawTypeAll],
            [NSNumber numberWithInt:LearnDrawTypeCartoon],
            [NSNumber numberWithInt:LearnDrawTypeCharater],
            [NSNumber numberWithInt:LearnDrawTypeScenery],
            [NSNumber numberWithInt:LearnDrawTypeOther],nil];
}

- (NSArray *)homeTabTitleList
{
    return [NSArray arrayWithObjects:NSLS(@"kLearnDrawAll"),
            NSLS(@"kLearnDrawCartoon"),
            NSLS(@"kLearnDrawCharater"),
            NSLS(@"kLearnDrawScenery"),
            NSLS(@"kLearnDrawOther"), nil];
}

@end
