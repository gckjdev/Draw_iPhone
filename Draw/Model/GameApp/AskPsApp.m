//
//  AskPsApp.m
//  Draw
//
//  Created by haodong on 13-6-6.
//
//

#import "AskPsApp.h"
#import "AskPsHomeController.h"

@implementation AskPsApp

- (NSString*)appId
{
    return ASK_PS_APP_ID;
}

- (NSString*)gameId
{
    return ASK_PS_GAME_ID;
}

- (NSString*)umengId
{
    return @"51b69e3b56240b6eec041d7c";
}

- (BOOL)disableAd
{
    return NO;
}

- (PPViewController *)homeController;
{
    return [[[AskPsHomeController alloc] init] autorelease];
}

- (NSString*)background
{
    return DRAW_BACKGROUND;
}

- (NSString*)lmwallId
{
    return DRAW_LM_WALL_ID;
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
    //    return @"801123669";
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
    return [MobClickUtils getStringValueByKey:@"DRAW_QQ_WEIBO_ID" defaultValue:@"LittleGee"];
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
    return nil;
}

- (NSString *)degradeMessage:(int)newLevel
{
    return nil;
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
    return ASK_PS_WEIXIN_ID;
}

- (NSString*)homeHeaderViewId
{
    return @"DrawHomeHeaderPanel";
}


- (id<ImageManagerProtocol>)getImageManager
{
    return nil;
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
    return nil;
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
    return [NSArray arrayWithObjects:@"feed_image", @"feedCache", @"ImageCache", @"imgcache", @"bbs/drawData", @"message", nil];
}

- (NSString*)getBackgroundMusicName
{
    return @"cannon.mp3";
}

- (PBGameCurrency)wallRewardCurrencyType
{
    return PBGameCurrencyIngot;
}

- (PBGameCurrency)saleCurrency
{
    return PBGameCurrencyIngot;
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
    return [UIColor colorWithRed:61.0/255.0 green:43.0/255.0 blue:23.0/255.0 alpha:1];
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
    //    PBAppReward* zjhApp = [GameConfigDataManager zjhAppWithRewardAmount:5 rewardCurrency:PBGameCurrencyIngot];
    //    PBAppReward* drawApp = [self drawAppWithRewardAmount:8 rewardCurrency:PBGameCurrencyIngot];
    PBAppReward* xiaojiDrawApp = [GameConfigDataManager xiaojiDrawAppWithRewardAmount:5 rewardCurrency:PBGameCurrencyIngot];
    
    PBRewardWall* limei = [GameConfigDataManager limeiWall];
    //    PBRewardWall* youmi = [GameConfigDataManager youmiWall];
    //    PBRewardWall* ader = [GameConfigDataManager aderWall];
    //    PBRewardWall* domod = [GameConfigDataManager domodWall];
    //    PBRewardWall* tapjoy = [GameConfigDataManager tapjoyWall];
    
    [builder addAppRewards:xiaojiDrawApp];
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
    
    NSString* version = @"1.0";
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
    return NO;
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
    
}

- (BOOL)showLocateButton
{
    return NO;
}

- (int)photoUsage
{
    return PBPhotoUsageForPs;
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

- (NSString *)createOpusDesc
{
    NSString *kCreateDesc = NSLS(@"kCreateDesc");
    return kCreateDesc;
}

- (NSString *)createOpusDescNoName
{
    NSString *kCreateDescNoName = NSLS(@"kCreateDescNoName");
    return kCreateDescNoName;
}

@end
