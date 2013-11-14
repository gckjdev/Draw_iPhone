
//  SingApp.m
//  Draw
//
//  Created by 王 小涛 on 13-5-21.
//
//

#import "SingApp.h"
#import "SingController.h"
#import "SingImageManager.h"
#import "SingHomeController.h"
#import "ShareImageManager.h"
#import "PPConfigManager.h"
#import "DrawGameJumpHandler.h"
#import "IAPProductService.h"

@implementation SingApp

- (PPViewController *)homeController{
    return [[[SingHomeController alloc] init] autorelease];
}

- (NSString*)umengId{
    return @"51b698e556240b357101820c";
}

- (NSString*)appId
{
    return SING_APP_ID;
}

- (NSString*)gameId
{
    return SING_GAME_ID;
}

- (BOOL)disableAd
{
    return NO;
}

- (NSString*)background
{
    return DRAW_BACKGROUND;
}

- (NSString*)lmwallId
{
    return [PPConfigManager getLimeiWallId];
}

- (NSString*)lmAdPublisherId
{
    return DRAW_LM_AD_ID;           // ueseless now
}

- (NSString*)aderAdPublisherId
{
    return DRAW_ADER_AD_ID;         // ueseless now
}

- (NSString*)mangoAdPublisherId
{
    return DRAW_MANGO_AD_ID;        // ueseless now
}

- (NSString*)defaultBroadImage
{
    return @"draw_default_board.png";
}

- (NSString*)defaultAdBoardImage
{
    //TODO use the correct board image.
    return @"draw_default_board.png";
}

- (NSString*)sinaAppKey
{
    return [MobClickUtils getStringValueByKey:@"SING_SINA_APP_KEY"
                                 defaultValue:@"596481594"];
}

- (NSString*)sinaAppSecret
{
    return [MobClickUtils getStringValueByKey:@"SING_SINA_APP_SECRET"
                                 defaultValue:@"d7e34c30176afd60590a9ff063f70836"];
}

- (NSString*)sinaAppRedirectURI
{
    return [MobClickUtils getStringValueByKey:@"SING_SINA_APP_REDIRECT_URI"
                                 defaultValue:@"http://www.xiaoji.info/sunny_orange.html"];
}

- (NSString*)qqAppKey
{
    return [MobClickUtils getStringValueByKey:@"SING_QQ_APP_KEY"
                                 defaultValue:@"801441969"];
}


- (NSString*)qqSpaceAppId
{
    return [MobClickUtils getStringValueByKey:@"SING_QQ_SPACE_APP_ID"
                                 defaultValue:@"100554944"];
}

- (NSString*)qqSpaceAppKey
{
    return [MobClickUtils getStringValueByKey:@"SING_QQ_SPACE_APP_KEY"
                                 defaultValue:@"ebd3fe27d1f0bbde37cfce3a3dffb036"];
}

- (NSString*)qqSpaceAppSecret
{
    return [MobClickUtils getStringValueByKey:@"SING_QQ_SPACE_APP_SECRET"
                                 defaultValue:@""];
}


- (NSString*)qqAppSecret
{
    return [MobClickUtils getStringValueByKey:@"SING_QQ_APP_SECRET"
                                 defaultValue:@"48f89cce70e80fb965fb36d75fd56884"];
}

- (NSString*)qqAppRedirectURI
{
    return [MobClickUtils getStringValueByKey:@"SING_QQ_REDIRECT_URI"
                                 defaultValue:@"http://www.xiaoji.info/sunny_orange.html"];
}

- (NSString*)facebookAppKey
{
    return [MobClickUtils getStringValueByKey:@"SING_FACEBOOK_APP_SECRET"
                                 defaultValue:@"325848464220092"];
}

- (NSString*)facebookAppSecret
{
    return [MobClickUtils getStringValueByKey:@"SING_FACEBOOK_APP_SECRET"
                                 defaultValue:@"03594330444a5c9f5f4e3bb0f61c1f84"];
}

- (NSString*)wanpuAdPublisherId
{
    return @"ad40c6b004a6aba16e3ad2daac9bee9b";     // useless
}

- (NSString*)removeAdProductId
{
    return [MobClickUtils getStringValueByKey:@"AD_IAP_ID" defaultValue:@"com.orange.sing.removead"];
}

- (NSString*)askFollowTitle
{
    return @"关注官方微博";
}

- (NSString*)askFollowMessage
{
    return @"关注和收听官方微博，第一时间可以看到有趣的声音作品";
}

- (NSString*)sinaWeiboId
{
    return [MobClickUtils getStringValueByKey:@"SING_SINA_WEIBO_NICKNAME" defaultValue:@"小吉大舌头"];
}

- (NSString*)qqWeiboId
{
    return [MobClickUtils getStringValueByKey:@"SING_QQ_WEIBO_ID" defaultValue:@"dashetou"];
}

- (NSString*)feedbackTips
{
    return NSLS(@"kFeedbackTips");
}

- (NSString*)shareMessageBody
{
    return NSLS(@"kShare_SingApp_message_body");
}

- (NSString*)shareEmailSubject
{
    return [NSString stringWithFormat:NSLS(@"kEmail_subject"), [UIUtils getAppName]];
}

- (NSString *)upgradeMessage:(int)newLevel
{
    return [NSString stringWithFormat:NSLS(@"kUpgradeMsg"),newLevel,[PPConfigManager flowerAwardFordLevelUp]];
}

- (NSString *)degradeMessage:(int)newLevel
{
    return [NSString stringWithFormat:NSLS(@"kDegradeMsg"),newLevel,[PPConfigManager flowerAwardFordLevelUp]];
}

- (NSString *)popupMessageDialogBackgroundImage
{
    return @"common_dialog_bg@2x.png";
}

- (BOOL)supportWeixin
{
    return YES;
}

- (NSString *)weixinId
{
    return SING_WEIXIN_ID;
}


- (id<ImageManagerProtocol>)getImageManager
{
    return [ShareImageManager defaultManager];
}

- (UIColor*)popupMessageDialogFontColor
{
    return [UIColor colorWithRed:62/255.0 green:43/255.0 blue:23/255.0 alpha:1];;
}

- (NSString *)resourcesPackage
{
    return nil;
}
/*
 - (id<ChatMsgManagerProtocol>)getChatMsgManager
 {
 return nil;
 }
 */
- (NSString *)chatViewBgImageName
{
    return nil;
}

- (NSString *)chatViewInputTextBgImageName
{
    return nil;
}
- (NSString *)popupViewCloseBtnBgImageName
{
    return nil;
}
- (NSString *)chatViewMsgBgImageName
{
    return nil;
}
- (UIColor *)chatViewMsgTextColor
{
    return nil;
}

- (NSString *)helpViewBgImageName
{
    return nil;
}
- (NSString *)gameRulesButtonBgImageNameForNormal
{
    return nil;
}
- (NSString *)gameRulesButtonBgImageNameForSelected
{
    return nil;
}
- (NSString *)itemsUsageButtonBgImageNameForNormal
{
    return nil;
}
- (NSString *)itemsUsageButtonBgImageNameForSelected
{
    return nil;
}

- (NSString *)roomListCellBgImageName
{
    return nil;
}
- (NSString *)roomListCellDualBgImageName
{
    return nil;
}

- (NSString *)roomTitle
{
    return NSLS(@"kDrawRoomTitle");
}

- (id<GameJumpHandlerProtocol>)getGameJumpHandler
{
    return [DrawGameJumpHandler defaultHandler];
}

- (NSString *)shengmengAppId
{
    return @"90386ecaab5c85559c569ab7c79a61e2";
}

- (UIColor*)createRoomDialogRoomNameColor
{
    return [UIColor whiteColor];
}
- (UIColor*)createRoomDialogRoomPasswordColor
{
    return [UIColor whiteColor];
}

- (UIColor*)buttonTitleColor
{
    return [UIColor colorWithRed:83/255.0 green:52/255.0 blue:20/255.0 alpha:1];
}

- (NSString*)shopTitle
{
    return nil;
}

- (NSArray*)cacheArray
{
    return [NSArray arrayWithObjects:@"feed_image", @"feedCache", @"ImageCache", @"imgcache", @"bbs/drawData", @"message", @"com.hackemist.SDWebImageCache.default", nil];
}

- (NSString*)getBackgroundMusicName
{
    return @"cannon.mp3";
}

- (PBGameCurrency)wallRewardCurrencyType
{
    return PBGameCurrencyCoin;
}

- (PBGameCurrency)saleCurrency
{
    return PBGameCurrencyCoin;
}

- (BOOL)hasIngotBalance
{
    return YES;
}

- (BOOL)hasCoinBalance
{
    return YES;
}

- (NSString*)youmiWallId
{
    return @"c278f8dc80295b18"; // TODO
}

- (NSString*)youmiWallSecret
{
    return @"30c93a1226f94496";
}

- (NSString*)aderWallId
{
    return @"3b47607e44f94d7c948c83b7e6eb800e";
}

- (NSString*)domodWallId
{
    //    return @"96ZJ06UgzeimTwTAs3"; // official test ID
    return @"96ZJ3ySQze+vLwTAqZ";
}

- (NSString*)tapjoyWallId
{
    return @"9df947d7-f864-4e2c-85c5-b6b73200ee7a";
}

- (NSString*)tapjoyWallSecret
{
    return @"5y0b3iTlsJJdOUu1JmhJ";
}

- (NSString *)alipayCallBackScheme
{
    return @"alipaycchh.gckj";
}

- (BOOL)isAutoRegister
{
    return NO;
}

- (BOOL)canShareViaSNS
{
    return YES;
}

- (BOOL)hasBBS
{
    return YES;
}

- (BOOL)hasAllColorGroups
{
    return NO;
}

- (UIColor *)homeMenuColor
{
    return OPAQUE_COLOR(29, 124, 77);
}

- (BOOL)canSubmitDraw
{
    return YES;
}

- (BOOL)hasBGOffscreen
{
    return NO;
}

- (BOOL)canPayWithAlipay
{
    return YES;
}

- (BOOL)canGift
{
    return YES;
}

- (BOOL)forceSaveDraft
{
    return NO;
}

- (void)HandleWithDidFinishLaunching
{
    /*
    [DrawBgManager defaultManager];
    [ImageShapeManager defaultManager];
    */
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
    
    //    PBAppReward* diceApp = [GameConfigDataManager diceAppWithRewardAmount:3 rewardCurrency:PBGameCurrencyIngot];
    PBAppReward* zjhApp = [GameConfigDataManager zjhAppWithRewardAmount:3000 rewardCurrency:PBGameCurrencyCoin];
    //    PBAppReward* drawApp = [self drawAppWithRewardAmount:8 rewardCurrency:PBGameCurrencyIngot];
    //    PBAppReward* xiaojiDrawApp = [GameConfigDataManager xiaojiDrawAppWithRewardAmount:500 rewardCurrency:PBGameCurrencyCoin];
    
    PBRewardWall* limei = [GameConfigDataManager limeiWall];
    PBRewardWall* youmi = [GameConfigDataManager youmiWall];
    //    PBRewardWall* ader = [GameConfigDataManager aderWall];
    //    PBRewardWall* domod = [GameConfigDataManager domodWall];
    //    PBRewardWall* tapjoy = [GameConfigDataManager tapjoyWall];
    
    //    [builder addAppRewards:xiaojiDrawApp];
    [builder addAppRewards:zjhApp];
    //    [builder addAppRewards:diceApp];
    
    [builder addRewardWalls:limei];
    [builder addRewardWalls:youmi];
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


- (int)sellContentType
{
    return SellContentTypeLearnDraw;
}

- (BOOL)showPaintCategory
{
    return YES;
}

- (NSString*)getDefaultSNSSubject
{
    return NSLS(@"kSingSNSSubject");
}

- (NSString*)appItuneLink
{
    return [UIUtils getAppLink:[GameApp appId]];
//    return NSLS(@"SingAppLink");
}
- (NSString*)appLinkUmengKey
{
    return @"DRAW_APP_LINK";
}

- (NSArray *)homeTabIDList
{
    return nil;
}

- (NSArray *)homeTabTitleList
{
    return nil;
}

- (BOOL)forceChineseOpus
{
    return YES; //edit by gamy 2013.10.10 for skiping choose word.
}
- (BOOL)disableEnglishGuess
{
    return NO;
}

- (NSString*)iapResourceFileName
{
    return [self appId];
}

- (void)createIAPTestDataFile
{
    [IAPProductService createDrawIngotTestDataFile];
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


/*


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

- (NSString *)weixinId
{
    return SING_WEIXIN_ID;
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

- (NSString *)iapResourceFileName{
    return [self appId];
}

- (BOOL)showLocateButton
{
    return NO;
}
 */

- (NSString*)homeHeaderViewId
{
    return @"SingHomeHeaderPanel";
}

//- (NSString*)getBackgroundMusicName
//{
//    return @"";
//}
//
//- (UIColor *)homeMenuColor
//{
//    return OPAQUE_COLOR(29, 124, 77);
//}
//
//- (NSString *)popupMessageDialogBackgroundImage
//{
//    return @"common_dialog_bg@2x.png";
//}
//
//- (UIColor*)popupMessageDialogFontColor
//{
//    return [UIColor colorWithRed:62/255.0 green:43/255.0 blue:23/255.0 alpha:1];;
//}
//
//- (id<ImageManagerProtocol>)getImageManager
//{
//    return [ShareImageManager defaultManager];
//}
//
//- (NSString*)background
//{
//    return DRAW_BACKGROUND;
//}
//
//- (int)photoUsage
//{
//    return PBPhotoUsageForPs;
//}

//- (NSString*)keywordSmartDataCn
//{
//    return @"keywords.txt";
//}
//- (NSString*)keywordSmartDataEn
//{
//    return @"keywords_en.txt";
//}
//- (NSString*)photoTagsCn
//{
//    return @"photo_tags.txt";
//}
//- (NSString*)photoTagsEn
//{
//    return @"photo_tags_en.txt";
//}

- (NSString *)opusClassName{
    
    return @"SingOpus";
}

- (NSString *)shareSDKDefaultAppId
{
    return @"c17367be400";
}


- (NSString *)shareMyOpusWithDescText
{
    return NSLS(@"kShareMySingOpusWithDescriptionText");
}

- (NSString *)shareMyOpusWithoutDescText
{
    return NSLS(@"kShareMySingOpusWithoutDescriptionText");
}

- (NSString *)shareOtherOpusWithDescText
{
    return NSLS(@"kShareOtherSingOpusWithDescriptionText");
}

- (NSString *)shareOtherOpusWithoutDescText
{
    return NSLS(@"kShareOtherSingOpusWithoutDescriptionText");
}


@end
