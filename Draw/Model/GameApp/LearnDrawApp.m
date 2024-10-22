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
#import "IAPProductService.h"

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

- (void)HandleWithDidBecomeActive
{
    
}

- (void)createConfigData
{
    NSString* root = @"/gitdata/Draw_iPhone/Draw/CommonResource/Config/";
    NSString* path = [root stringByAppendingString:[GameConfigDataManager configFileName]];
    NSString* versionPath = [root stringByAppendingString:[PPSmartUpdateDataUtils getVersionFileName:[GameConfigDataManager configFileName]]];
    
    PBConfig_Builder* builder = [PBConfig builder];
    
    PBAppReward* diceApp = [GameConfigDataManager oldDiceAppWithRewardAmount:3 rewardCurrency:PBGameCurrencyIngot];
    [builder addAppRewards:diceApp];
    
    PBRewardWall* limei = [GameConfigDataManager limeiWall];
    PBRewardWall* youmi = [GameConfigDataManager youmiWall];
    PBRewardWall* ader = [GameConfigDataManager aderWall];
//    PBRewardWall* domod = [GameConfigDataManager domodWall];
    
    [builder addRewardWalls:limei];
    [builder addRewardWalls:ader];
    [builder addRewardWalls:youmi];
//    [builder addRewardWalls:domod];
    
    
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

- (NSString*)getDefaultSNSSubject
{
    return nil;
}

- (NSString*)appItuneLink
{
    return nil;
}
- (NSString*)appLinkUmengKey
{
    return nil;
}

//- (NSString *)alipayCallBackScheme
//{
//    return @"alipaylearndraw.gckj";
//}

//ContentGameAppProtocol
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

- (BOOL)forceChineseOpus
{
    return NO;
}
- (BOOL)disableEnglishGuess
{
    return NO;
}

- (NSString*)iapResourceFileName
{
    return [self gameId];
}

- (BOOL)showLocateButton
{
    return NO;
}

- (void)createIAPTestDataFile
{
    [IAPProductService createLearnDrawIngotTestDataFile];
}

- (int)photoUsage
{
    return PBPhotoUsageForDraw;
}
- (NSString*)keywordSmartDataCn
{
    return @"keywords.txt";
}
- (NSString*)keywordSmartDataEn
{
    return @"keywords_en.txt";
}
- (NSString*)photoTagsCn
{
    return @"photo_tags.txt";
}
- (NSString*)photoTagsEn
{
    return @"photo_tags_en.txt";
}

@end
