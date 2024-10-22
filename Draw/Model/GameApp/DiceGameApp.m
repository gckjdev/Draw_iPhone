//
//  DiceGameApp.m
//  Draw
//
//  Created by  on 12-8-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DiceGameApp.h"
#import "MobClickUtils.h"
#import "DiceChatMsgManager.h"
#import "DiceImageManager.h"
#import "DiceFontManager.h"
#import "ConfigManager.h"
#import "FileUtil.h"
#import "DiceGameJumpHandler.h"
#import "DiceHomeController.h"
#import "CommonHelpManager.h"
#import "IAPProductService.h"

@implementation DiceGameApp

- (NSString*)appId
{
    return DICE_APP_ID;
}

- (NSString*)gameId
{
    return DICE_GAME_ID;    
}

- (NSString*)umengId
{
    return DICE_UMENG_ID;
}

- (BOOL)disableAd
{
    return NO;
}

- (NSString*)background
{
    return DICE_BACKGROUND;
}

- (NSString*)lmwallId
{
    return DICE_LM_WALL_ID;
}

- (NSString*)lmAdPublisherId
{
    return DICE_LM_AD_ID;
}

- (NSString*)aderAdPublisherId
{
    return DICE_ADER_AD_ID;
}

- (NSString*)mangoAdPublisherId
{
    return DICE_MANGO_AD_ID;
}

- (NSString*)defaultBroadImage
{
    return @"dice_default_board.jpg";
}

- (NSString *)defaultAdBoardImage
{
    return @"dice_default_board_ad.jpg";
}

- (NSString*)sinaAppKey
{
//    return @"562852192";
//    return @"3163067274";
    return @"3580615797";


}

- (NSString*)sinaAppSecret
{
//    return @"6271c4259ae38213ddf6f8b1b6ba7766";
//    return @"d677917b0c2855d36674c1d0339326bd";
    
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
    return [MobClickUtils getStringValueByKey:@"AD_IAP_ID" defaultValue:@"com.orange.dice.removead"];    
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
    return NSLS(@"kDiceFeedbackTips");
}

- (NSString*)shareMessageBody
{
    return NSLS(@"kDice_share_message_body");
}

- (NSString*)shareEmailSubject
{
    return NSLS(@"kDice_email_subject");
}

- (NSString *)resourcesPackage
{
    return RESOURCE_PACKAGE_DICE;
}

- (id<ChatMsgManagerProtocol>)getChatMsgManager
{
    return [DiceChatMsgManager defaultManager];
}

- (NSString *)chatViewBgImageName
{
    return @"dice_popup_bg";
}

- (NSString *)chatViewInputTextBgImageName
{
    return @"input_text_bg";
}

- (NSString *)popupViewCloseBtnBgImageName
{
    return @"clean_input";
}

- (NSString *)chatViewMsgBgImageName
{
    return @"dice_message_tip";
}

- (UIColor *)chatViewMsgTextColor
{
    return [UIColor blackColor];
}


- (id<ImageManagerProtocol>)getImageManager
{
    return [DiceImageManager defaultManager];
}
- (NSString*)getCommonDialogXibName
{
    return @"CommonDiceDialog";
}
- (NSString*)getInputDialogXibName
{
    return @"DiceInputDialog";
}
- (NSString*)getPasswordDialogXibName
{
    return @"DicePassWordDialog";
}
- (NSString*)getRoomPasswordDialogXibName
{
    return @"DiceRoomPasswordDialog";
}

- (NSString *)helpViewBgImageName
{
    return @"dice_popup_bg";
}

- (NSString *)gameRulesButtonBgImageNameForNormal
{
    return @"dice_tableft_unselect";
}

- (NSString *)gameRulesButtonBgImageNameForSelected
{
    return @"dice_tableft_selected";
}

- (NSString *)itemsUsageButtonBgImageNameForNormal
{
    return @"dice_tabright_unselect";
}

- (NSString *)itemsUsageButtonBgImageNameForSelected
{
    return @"dice_tabright_selected";

}

- (NSString *)upgradeMessage:(int)newLevel
{
    return [NSString stringWithFormat:NSLS(@"kDiceUpgradeMsg"),newLevel,[ConfigManager diceCutAwardForLevelUp]];    
}

- (NSString *)degradeMessage:(int)newLevel
{
    return [NSString stringWithFormat:NSLS(@"kDiceDegradeMsg"),newLevel];
}

- (NSString *)popupMessageDialogBackgroundImage
{
    return @"dialogue@2x.png";
}

- (BOOL)supportWeixin
{
    return NO;
}

- (NSString *)weixinId
{
    return @"";
}

- (NSString*)homeHeaderViewId
{
    return @"DiceHomeHeaderPanel";
//    return @"ZJHHomeHeaderPanel";
}

- (NSString *)roomListCellBgImageName
{
    return @"dice_room_item";
}

- (NSString *)roomListCellDualBgImageName
{
    return @"";
}

- (NSString *)roomTitle
{
    return NSLS(@"kDiceRoomTitle");
}

- (UIColor*)popupMessageDialogFontColor
{
    return [UIColor blackColor];
}

- (id<GameJumpHandlerProtocol>)getGameJumpHandler
{
    return [DiceGameJumpHandler defaultHandler];
}

- (UIColor*)createRoomDialogRoomNameColor
{
    return [UIColor blackColor];
}
- (UIColor*)createRoomDialogRoomPasswordColor
{
    return [UIColor blackColor];
}

- (UIColor*)buttonTitleColor
{
    return [UIColor whiteColor];
}

- (NSString *)shengmengAppId
{
    return @"";
}

- (NSString*)shopTitle
{
    return NSLS(@"kDiceShop");
}

- (NSArray*)cacheArray
{
    return nil;
}

- (NSString*)getBackgroundMusicName
{
    return @"dice.m4a";
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
    return @"96ZJ0Phgze+vLwTAqY";
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
    return @"alipaydice.gckj";
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
    return [[[DiceHomeController alloc] init] autorelease];
}

- (BOOL)forceSaveDraft
{
    return NO;
}

- (void)HandleWithDidFinishLaunching
{
    [DiceFontManager unZipFiles];
    
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
    PBAppReward* zjhApp = [GameConfigDataManager zjhAppWithRewardAmount:2500 rewardCurrency:PBGameCurrencyCoin];
    
    PBRewardWall* limei = [GameConfigDataManager limeiWall];
    PBRewardWall* ader = [GameConfigDataManager aderWall];
    
    [builder addAppRewards:drawApp];
    [builder addAppRewards:zjhApp];
    
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
    [IAPProductService createDiceCoinTestDataFile];
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

@end
