//
//  LittleGeeDrawApp.m
//  Draw
//
//  Created by Kira on 13-5-7.
//
//

#import "LittleGeeDrawApp.h"
#import "IAPProductService.h"
#import "HomeController.h"

@implementation LittleGeeDrawApp

- (int)getCategory{
    
    return PBOpusCategoryTypeDrawCategory;
}

//- (PPViewController*)homeController
//{
//        return [[[HomeController alloc] init] autorelease];
//}

- (NSString*)appId
{
    return LITTLE_GEE_APP_ID;
}

- (NSString*)gameId
{
    return LITTLE_GEE_GAME_ID;
}


- (BOOL)disableAd
{
    return NO;
}


- (NSString*)umengId
{
    return LITTLE_GEE_UMENG_ID;
}

- (NSString*)sinaAppKey
{
    //    return @"2831348933";
    return [MobClickUtils getStringValueByKey:@"LITTLE_GEE_SINA_APP_KEY" defaultValue:@"138708649"];
}

- (NSString*)sinaAppSecret
{
    //    return @"ff89c2f5667b0199ee7a8bad6c44b265";
    //    return @"7a88336d7290279aef4112fda83708fd";
    return [MobClickUtils getStringValueByKey:@"LITTLE_GEE_SINA_APP_SECRET" defaultValue:@"10aa2c8c0f9ce7c02d6f8f782029afee"];
}

- (NSString*)sinaAppRedirectURI
{
    return [MobClickUtils getStringValueByKey:@"LITTLE_GEE_SINA_APP_REDIRECT_URI" defaultValue:@"http://www.xiaoji.info/weibo/sina/auth"];
}

- (NSString*)qqAppKey
{
    return [MobClickUtils getStringValueByKey:@"LITTLE_GEE_QQ_APP_KEY" defaultValue:@"801357429"];
    //    return @"801123669";
}

- (NSString*)qqAppSecret
{
    return [MobClickUtils getStringValueByKey:@"LITTLE_GEE_QQ_APP_SECRET" defaultValue:@"143204e7e6b048a046ac418436a7a4e5"];
    //    return @"30169d80923b984109ee24ade9914a5c";
}

- (NSString*)qqAppRedirectURI
{
    return [MobClickUtils getStringValueByKey:@"LITTLE_GEE_QQ_REDIRECT_URI" defaultValue:@"http://www.xiaoji.info/sunny_orange.html"];
    //    return @"http://caicaihuahua.me";
}

- (NSString*)qqSpaceAppId
{
    return [MobClickUtils getStringValueByKey:@"DRAW_QQ_SPACE_APP_ID" defaultValue:@"1104375378"];
}

- (NSString*)qqSpaceAppKey
{
    return [MobClickUtils getStringValueByKey:@"DRAW_QQ_SPACE_APP_KEY" defaultValue:@"PkLldP7gzcireYvH"];
}

- (NSString*)qqSpaceAppSecret
{
    return [MobClickUtils getStringValueByKey:@"DRAW_QQ_SPACE_APP_SECRET" defaultValue:@"PkLldP7gzcireYvH"];
}


- (NSString*)facebookAppKey
{
    return [MobClickUtils getStringValueByKey:@"LITTLE_GEE_FACEBOOK_APP_SECRET" defaultValue:@"507044062701075"];
    //    return @"352182988165711";
}

- (NSString*)facebookAppSecret
{
    return [MobClickUtils getStringValueByKey:@"LITTLE_GEE_FACEBOOK_APP_SECRET" defaultValue:@"9126fc25a537461eab1738b7cbfa3afd"];
    //    return @"51c65d7fbef9858a5d8bc60014d33ce2";
}

- (NSString*)feedbackTips
{
    return NSLS(@"kLittleGeeFeedbackTips");
}

- (NSString*)getDefaultSNSSubject
{
    return NSLS(@"kLittleGeeSNSSubject");
}

- (NSString*)appItuneLink
{
    return NSLS(@"kLittleGeeAppLink");
}
- (NSString*)appLinkUmengKey
{
    return @"LITTLE_GEE_APP_LINK";
}

- (NSString*)sinaWeiboId
{
    return [MobClickUtils getStringValueByKey:@"LITTLE_GEE_SINA_WEIBO_NICKNAME" defaultValue:@"小吉画画"];
}

- (NSString*)qqWeiboId
{
    return [MobClickUtils getStringValueByKey:@"LITTLE_GEE_QQ_WEIBO_ID" defaultValue:@"xiaojihuahua"];
}

- (BOOL)forceChineseOpus
{
    return YES;
}
- (BOOL)disableEnglishGuess
{
    return YES;
}

- (void)createIAPTestDataFile
{
    [IAPProductService createLittlegeeIngotTestDataFile];
}

- (void)createConfigData
{
    NSString* root = @"/gitdata/Draw_iPhone/Draw/CommonResource/Config/";
    NSString* path = [root stringByAppendingString:[GameConfigDataManager configFileName]];
    NSString* versionPath = [root stringByAppendingString:[PPSmartUpdateDataUtils getVersionFileName:[GameConfigDataManager configFileName]]];
    
    PBConfigBuilder* builder = [PBConfig builder];
    
//    PBAppReward* zjhApp = [GameConfigDataManager zjhAppWithRewardAmount:3000 rewardCurrency:PBGameCurrencyCoin];
//    PBAppReward* drawApp = [GameConfigDataManager drawAppWithRewardAmount:3000 rewardCurrency:PBGameCurrencyCoin];
//    PBAppReward* diceApp = [GameConfigDataManager diceAppWithRewardAmount:2000 rewardCurrency:PBGameCurrencyCoin];
    
    PBRewardWall* limei = [GameConfigDataManager limeiWall];
    PBRewardWall* youmi = [GameConfigDataManager youmiWall];
//    PBRewardWall* ader = [GameConfigDataManager aderWall];
    //    PBRewardWall* domod = [GameConfigDataManager domodWall];
    //    PBRewardWall* tapjoy = [GameConfigDataManager tapjoyWall];
    
//    [builder addAppRewards:drawApp];
//    [builder addAppRewards:zjhApp];
//    [builder addAppRewards:diceApp];
    
    [builder addRewardWalls:limei];
//    [builder addRewardWalls:youmi];
//    [builder addRewardWalls:ader];
    //    [builder addRewardWalls:domod];
    //    [builder addRewardWalls:tapjoy];
    
    PBConfig* config = [builder build];
    NSData* data = [config data];
    
    BOOL result = [data writeToFile:path atomically:YES];
    PPDebug(@"<createConfigFile> data file result=%d, file=%@", result, path);
    
    NSString* version = @"2.2";
    NSError* error = nil;
    result = [version writeToFile:versionPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    PPDebug(@"<createConfigFile> version txt file result=%d error=%@ file=%@", result, [error description], versionPath);
}

- (BOOL)showLocateButton
{
    return NO;
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

- (BOOL)supportWeixin
{
    return YES;
}

- (NSString *)weixinId
{
    return LITTLE_GEE_WEIXIN_ID;
}

- (UIImage *)getGiftToSbImage{
    
    return [UIImage imageNamed:@"user_detail_draw_to_bg@2x.png"];
}

- (NSString *)zeroQianAppKey
{
    return [MobClickUtils getStringValueByKey:@"0QIAN_APPKEY" defaultValue:@"ac8e8ea505db87e569e43899c510f810"];
}

- (NSString *)zeroQianAppSecret
{
    return [MobClickUtils getStringValueByKey:@"0QIAN_SECRET" defaultValue:@"ca23464034492db669d8a453cfad9976"];
}

- (NSString *)defaultImage
{
    return @"LittleGeeDefault";
    
}

- (NSString *)defaultImageIPAD
{
    return @"LittleGeeDefault~ipad";
    
}

- (NSString *)defaultImageRetina
{
    return @"LittleGeeDefault-568h";
}


@end
