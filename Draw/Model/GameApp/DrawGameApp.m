//
//  DrawGameApp.m
//  Draw
//
//  Created by  on 12-8-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawGameApp.h"
#import "MobClickUtils.h"
#import "PPConfigManager.h"
#import "ShareImageManager.h"
#import "DrawGameJumpHandler.h"
#import "HomeController.h"
#import "WordManager.h"
#import "DrawBgManager.h"
#import "IAPProductService.h"
#import "ImageShapeManager.h"
#import "MetroHomeController.h"

@implementation DrawGameApp

- (int)getCategory{
    
    return PBOpusCategoryTypeDrawCategory;
}

- (NSString*)appId
{
    return DRAW_APP_ID;
}

- (NSString*)gameId
{
    return DRAW_GAME_ID;    
}

- (NSString*)umengId
{
    return DRAW_UMENG_ID;
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
    return DRAW_LM_AD_ID;
}

- (NSString*)aderAdPublisherId
{
    return DRAW_ADER_AD_ID;
}

- (NSString*)mangoAdPublisherId
{
    return DRAW_MANGO_AD_ID;
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
//    return @"2831348933";
    return [MobClickUtils getStringValueByKey:@"DRAW_SINA_APP_KEY" defaultValue:@"4285743836"];
}

- (NSString*)sinaAppSecret
{
//    return @"ff89c2f5667b0199ee7a8bad6c44b265";    
//    return @"7a88336d7290279aef4112fda83708fd";
    return [MobClickUtils getStringValueByKey:@"DRAW_SINA_APP_SECRET" defaultValue:@"7a88336d7290279aef4112fda83708fd"];
}

- (NSString*)sinaAppRedirectURI
{
    return [MobClickUtils getStringValueByKey:@"DRAW_SINA_APP_REDIRECT_URI" defaultValue:@"http://www.drawlively.com/draw"];
}

- (NSString*)qqAppKey
{
    return [MobClickUtils getStringValueByKey:@"DRAW_QQ_APP_KEY" defaultValue:@"801123669"];
}


- (NSString*)qqSpaceAppId
{
    return [MobClickUtils getStringValueByKey:@"DRAW_QQ_SPACE_APP_ID" defaultValue:@"100550661"];
}

- (NSString*)qqSpaceAppKey
{
    return [MobClickUtils getStringValueByKey:@"DRAW_QQ_SPACE_APP_KEY" defaultValue:@"7687417d49a2a14c3dd9434d05c29662"];
}

- (NSString*)qqSpaceAppSecret
{
    return [MobClickUtils getStringValueByKey:@"DRAW_QQ_SPACE_APP_SECRET" defaultValue:@"7687417d49a2a14c3dd9434d05c29662"];
}


- (NSString*)qqAppSecret
{
    return [MobClickUtils getStringValueByKey:@"DRAW_QQ_APP_SECRET" defaultValue:@"30169d80923b984109ee24ade9914a5c"];
//    return @"30169d80923b984109ee24ade9914a5c";
}

- (NSString*)qqAppRedirectURI
{
    return [MobClickUtils getStringValueByKey:@"DRAW_QQ_REDIRECT_URI" defaultValue:@"http://caicaihuahua.me"];
//    return @"http://caicaihuahua.me";
}

- (NSString*)facebookAppKey
{
    return [MobClickUtils getStringValueByKey:@"DRAW_FACEBOOK_APP_SECRET" defaultValue:@"352182988165711"];
//    return @"352182988165711";
}

- (NSString*)facebookAppSecret
{
    return [MobClickUtils getStringValueByKey:@"DRAW_FACEBOOK_APP_SECRET" defaultValue:@"51c65d7fbef9858a5d8bc60014d33ce2"];
//    return @"51c65d7fbef9858a5d8bc60014d33ce2";
}

- (NSString*)wanpuAdPublisherId
{
    return @"ad40c6b004a6aba16e3ad2daac9bee9b";
}

- (NSString*)removeAdProductId
{
    return [MobClickUtils getStringValueByKey:@"AD_IAP_ID" defaultValue:@"com.orange.draw.removead"];
}

- (NSString*)askFollowTitle
{
    return @"关注官方微博";    
}

- (NSString*)askFollowMessage
{
    return @"关注和收听官方微博，第一时间可以看到唯美的画画作品";
}

- (NSString*)sinaWeiboId
{
    return [MobClickUtils getStringValueByKey:@"DRAW_SINA_WEIBO_NICKNAME" defaultValue:@"小吉画画"];
}

- (NSString*)qqWeiboId
{
    return [MobClickUtils getStringValueByKey:@"DRAW_QQ_WEIBO_ID" defaultValue:@"drawlively"];
}

- (NSString*)feedbackTips
{
    return NSLS(@"kFeedbackTips");
}

- (NSString*)shareMessageBody
{
    return NSLS(@"kShare_message_body");
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
    return DRAW_WEIXIN_ID;
}

- (NSString*)homeHeaderViewId
{
    return @"DrawHomeHeaderPanel";
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
    return @"c278f8dc80295b18";
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

- (BOOL)canGift
{
    return YES;
}

- (PPViewController *)homeController;
{
    return [[[HomeController alloc] init] autorelease];
    
    /*
    int style = [[UserManager defaultManager] homeStyle];    
    if (style == HOME_STYLE_CLASSICAL){
        return [[[HomeController alloc] init] autorelease];
    }
    else{
        return [[[MetroHomeController alloc] init] autorelease];
    }
     */
}

- (Class)homeControllerClass
{
    return [HomeController class];
}

- (BOOL)forceSaveDraft
{
    return NO;
}

- (void)HandleWithDidFinishLaunching
{
//    [WordManager defaultManager];
//    [DrawBgManager defaultManager];
//    [ImageShapeManager defaultManager];
    
}

- (void)HandleWithDidBecomeActive
{
    
}

- (void)createConfigData
{
    NSString* root = @"/gitdata/Draw_iPhone/Draw/CommonResource/Config/";
    NSString* path = [root stringByAppendingString:[GameConfigDataManager configFileName]];
    NSString* versionPath = [root stringByAppendingString:[PPSmartUpdateDataUtils getVersionFileName:[GameConfigDataManager configFileName]]];
    
    PBConfigBuilder* builder = [PBConfig builder];
    
//    PBAppReward* diceApp = [GameConfigDataManager diceAppWithRewardAmount:3 rewardCurrency:PBGameCurrencyIngot];
//    PBAppReward* zjhApp = [GameConfigDataManager zjhAppWithRewardAmount:3000 rewardCurrency:PBGameCurrencyCoin];
//    PBAppReward* singApp = [GameConfigDataManager singAppWithRewardAmount:3000 rewardCurrency:PBGameCurrencyCoin];

    
    //    PBAppReward* drawApp = [self drawAppWithRewardAmount:8 rewardCurrency:PBGameCurrencyIngot];
//    PBAppReward* xiaojiDrawApp = [GameConfigDataManager xiaojiDrawAppWithRewardAmount:500 rewardCurrency:PBGameCurrencyCoin];
    
    PBRewardWall* limei = [GameConfigDataManager limeiWall];
    PBRewardWall* youmi = [GameConfigDataManager youmiWall];
//    PBRewardWall* ader = [GameConfigDataManager aderWall];
//    PBRewardWall* domod = [GameConfigDataManager domodWall];
//    PBRewardWall* tapjoy = [GameConfigDataManager tapjoyWall];
    
//    [builder addAppRewards:xiaojiDrawApp];
//    [builder addAppRewards:singApp];
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
    return NSLS(@"kSNSSubject");
}

- (NSString*)appItuneLink
{
    return NSLS(@"kDrawAppLink");
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

- (NSString *)opusClassName{
    
    return @"DrawOpus";
}

- (NSString *)shareSDKDefaultAppId
{
    return @"c16e3fe5e0b";
}


- (NSString *)shareMyOpusWithDescText
{
    return NSLS(@"kShareMyOpusWithDescriptionText");
}

- (NSString *)shareMyOpusWithoutDescText
{
    return NSLS(@"kShareMyOpusWithoutDescriptionText");
}

- (NSString *)shareOtherOpusWithDescText
{
    return NSLS(@"kShareOtherOpusWithDescriptionText");
}

- (NSString *)shareOtherOpusWithoutDescText
{
    return NSLS(@"kShareOtherOpusWithoutDescriptionText");
}

- (NSString *)createOpusDesc
{
    NSString *kCreateDesc = NSLS(@"kDrawDesc");
    return kCreateDesc;
}

- (NSString *)createOpusDescNoName
{
    NSString *kCreateDescNoName = NSLS(@"kDrawDescNoWord");
    return kCreateDescNoName;
}

- (UIImage *)getGiftToSbImage{
    
    return [UIImage imageNamed:@"user_detail_draw_to_bg@2x.png"];
}

- (NSString *)painterName{
    return NSLS(@"kPainter");
}

- (NSString *)zeroQianAppKey
{
    return [MobClickUtils getStringValueByKey:@"0QIAN_APPKEY" defaultValue:@"023a559d2257eb2febe24d110949beed"];
}

- (NSString *)zeroQianAppSecret
{
    return [MobClickUtils getStringValueByKey:@"0QIAN_SECRET" defaultValue:@"c361a4d55a87a7a7f35756516846587a"];
}

- (NSString *)defaultImage
{
    return @"DrawDefault";
    
}

- (NSString *)defaultImageIPAD
{
    return @"DrawDefault~ipad";
    
}

- (NSString *)defaultImageRetina
{
    return @"DrawDefault-568h";
}



@end
