//
//  ZJHGameApp.m
//  Draw
//
//  Created by qqn_pipi on 12-12-3.
//
//

#import "ZJHGameApp.h"
#import "MobClickUtils.h"
#import "ZJHChatMsgManager.h"
#import "ConfigManager.h"
#import "ZJHImageManager.h"
#import "ZJHGameJumpHandler.h"
#import "ZJHHomeViewController.H"
#import "CommonHelpManager.h"
#import "IAPProductService.h"

@implementation ZJHGameApp

- (NSString*)appId
{
    return ZJH_APP_ID;
}

- (NSString*)gameId
{
    return ZHAJINHUA_GAME_ID;
}

- (NSString*)umengId
{
    return ZJH_UMENG_ID;
}

- (BOOL)disableAd
{
    return NO;
}

- (NSString*)background
{
    return ZJH_BACKGROUND;
}

- (NSString*)lmwallId
{
    return ZJH_LM_WALL_ID;
}

- (NSString*)lmAdPublisherId
{
    return ZJH_LM_AD_ID;
}

- (NSString*)aderAdPublisherId
{
    return ZJH_ADER_AD_ID;
}

- (NSString*)mangoAdPublisherId
{
    return ZJH_MANGO_AD_ID;
}

- (NSString*)defaultBroadImage
{
    return @"zjh_default_board.jpg";
}

- (NSString *)defaultAdBoardImage
{
    return @"zjh_default_board_ad.jpg";
}

- (NSString*)sinaAppKey
{
    return @"3580615797";
}

- (NSString*)sinaAppSecret
{
    return @"74c79adc97a9f81cda5d69af38f5c716";
}

- (NSString*)sinaAppRedirectURI
{
    return @"http://www.drawlively.com/happypoker";
}

- (NSString*)qqAppKey
{
    return @"801281270";
}

- (NSString*)qqAppSecret
{
    return @"dd9f4acd9e875b38db72bb20fee99911";
}

- (NSString*)qqAppRedirectURI
{
    return @"http://www.drawlively.com/happy";
}

- (NSString*)facebookAppKey
{
    return @"451387761588871";
}

- (NSString*)facebookAppSecret
{
    return @"46326b19b15b3d3ab095035079a92b92";
}

- (NSString*)wanpuAdPublisherId
{
    return @"56355897c0bb3c956585f2e7ab2950af";
}

- (NSString*)removeAdProductId
{
    return [MobClickUtils getStringValueByKey:@"AD_IAP_ID" defaultValue:@"com.orange.zjh.removead"];
}

- (NSString*)askFollowTitle
{
    return @"关注官方微博";
}

- (NSString*)askFollowMessage
{
    return @"关注和收听官方微博，第一时间可以接收最新的消息";
}

- (NSString*)sinaWeiboId
{
    return @"欢乐棋牌手机版";
}

- (NSString*)qqWeiboId
{
    return @"happypoker";
}

- (NSString*)feedbackTips
{
    return NSLS(@"kZJHFeedbackTips");
}

- (NSString*)shareMessageBody
{
    return NSLS(@"kZJH_share_message_body");
}

- (NSString*)shareEmailSubject
{
    return NSLS(@"kZJH_email_subject");
}

- (NSString *)resourcesPackage
{
    return RESOURCE_PACKAGE_ZJH;
}

- (id<ChatMsgManagerProtocol>)getChatMsgManager
{
    return [ZJHChatMsgManager defaultManager];
}

- (NSString *)chatViewBgImageName
{
    return @"zjh_chat_view_bg";
}

- (NSString *)chatViewInputTextBgImageName
{
    return @"zjh_chat_view_input_text_bg";
}

- (NSString *)popupViewCloseBtnBgImageName
{
    return @"zjh_popup_view_close_btn_bg";
}

- (NSString *)chatViewMsgBgImageName
{
    return @"zjh_chat_view_msg_bg";
}

- (UIColor *)chatViewMsgTextColor
{
    return [UIColor whiteColor];
}


- (id<ImageManagerProtocol>)getImageManager
{
    return [ZJHImageManager defaultManager];
}
- (NSString*)getCommonDialogXibName
{
    return @"CommonZJHDialog";
}
- (NSString*)getInputDialogXibName
{
    return @"ZJHInputDialog";
}
- (NSString*)getPasswordDialogXibName
{
    return @"ZJHPassWordDialog";
}
- (NSString*)getRoomPasswordDialogXibName
{
    return @"ZJHRoomPasswordDialog";
}

- (NSString *)helpViewBgImageName
{
    return @"zjh_help_view_bg";
}

- (NSString *)gameRulesButtonBgImageNameForNormal
{
    return nil;
}

- (NSString *)gameRulesButtonBgImageNameForSelected
{
    return @"zjh_game_rule_btn_bg_selected";
}

- (NSString *)itemsUsageButtonBgImageNameForNormal
{
    return nil;
}

- (NSString *)itemsUsageButtonBgImageNameForSelected
{
    return nil;

}

- (NSString *)upgradeMessage:(int)newLevel
{
    return [NSString stringWithFormat:NSLS(@"kZJHUpgradeMsg"),newLevel];
}

- (NSString *)degradeMessage:(int)newLevel
{
    return [NSString stringWithFormat:NSLS(@"kZJHDegradeMsg"),newLevel];
}

- (NSString *)popupMessageDialogBackgroundImage
{
//    return @"dialogue@2x.png";
    return @"zjh_dialog_bg@2x.png";
}

- (BOOL)supportWeixin
{
    return NO;
}

- (NSString*)homeHeaderViewId
{
    return @"ZJHHomeHeaderPanel";
}
    
- (NSString *)roomListCellBgImageName
{
    return @"zjh_room_item";
}

- (NSString *)roomListCellDualBgImageName
{
    return @"zjh_room_list_cell_bg_dual";
}

- (NSString *)roomTitle
{
    return NSLS(@"kZJHRoomTitle");
}

- (UIColor*)popupMessageDialogFontColor
{
    return [UIColor whiteColor];
}

- (id<GameJumpHandlerProtocol>)getGameJumpHandler
{
    return [ZJHGameJumpHandler defaultHandler];
}

- (NSString *)shengmengAppId
{
    return @"0cfe32a7b2183b22ff8e26b5796e00fb";
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
    return [UIColor whiteColor];
}

- (NSString*)shopTitle
{
    return NSLS(@"kZJHShopTitle");
}

- (NSArray*)cacheArray
{
    return nil;
}

- (NSString*)getBackgroundMusicName
{
    return @"game_bg.mp3";
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
    return NO;
}

- (BOOL)hasCoinBalance
{
    return YES;
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
    return @"661f38bed5974599abfad68e6ef402a3";
}

- (NSString*)domodWallId
{
    return @"96ZJ37fAze+vLwTAqb";
}

- (NSString*)tapjoyWallId
{
    return @"";//TODO
}

- (NSString*)tapjoyWallSecret
{
    return @"";//TODO
}

- (NSString *)alipayCallBackScheme
{
    return @"alipayzjh.gckj";
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
    return [UIColor whiteColor];
}

- (BOOL)canSubmitDraw
{
    return NO;
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
    return NO;
}

- (PPViewController *)homeController
{
    return [[[ZJHHomeViewController alloc] init] autorelease];
}

- (BOOL)forceSaveDraft
{
    return NO;
}

- (void)HandleWithDidFinishLaunching
{
    [[CommonHelpManager defaultManager] unzipHelpFiles];
}

- (void)HandleWithDidBecomeActive
{
    
}

- (void)createConfigData
{
    NSString* root = @"/Users/Linruin/gitdata/Draw_iPhone/Draw/CommonResource/Config/";
    NSString* path = [root stringByAppendingString:[GameConfigDataManager configFileName]];
    NSString* versionPath = [root stringByAppendingString:[PPSmartUpdateDataUtils getVersionFileName:[GameConfigDataManager configFileName]]];
    
    PBConfig_Builder* builder = [PBConfig builder];
    
    PBAppReward* drawApp = [GameConfigDataManager drawAppWithRewardAmount:3000 rewardCurrency:PBGameCurrencyCoin];
    PBAppReward* diceApp = [GameConfigDataManager diceAppWithRewardAmount:2000 rewardCurrency:PBGameCurrencyCoin];
    
    PBRewardWall* limei = [GameConfigDataManager limeiWall];
    PBRewardWall* ader = [GameConfigDataManager aderWall];    
    
    [builder addAppRewards:drawApp];
    [builder addAppRewards:diceApp];
    
    [builder addRewardWalls:limei];
    [builder addRewardWalls:ader];
    
    PBConfig* config = [builder build];
    NSData* data = [config data];
    
    [data writeToFile:path atomically:YES];
    
    NSString* version = @"1.0";
    [version writeToFile:versionPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (BOOL)showPaintCategory
{
    return NO;
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

- (void)createIAPTestDataFile
{
    [IAPProductService createZJHCoinTestDataFile];
}
@end
