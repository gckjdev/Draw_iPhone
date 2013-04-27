//
//  DrawGameApp.m
//  Draw
//
//  Created by  on 12-8-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawGameApp.h"
#import "MobClickUtils.h"
#import "ConfigManager.h"
#import "ShareImageManager.h"
#import "DrawGameJumpHandler.h"


@implementation DrawGameApp

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
//    return @"http://www.drawlively.com/draw";
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
    return @"关注和收听猜猜画画官方微博，第一时间可以看到唯美的猜猜画画作品";
}

- (NSString*)sinaWeiboId
{
    return [MobClickUtils getStringValueByKey:@"DRAW_SINA_WEIBO_NICKNAME" defaultValue:@"猜猜画画手机版"];
//    return @"猜猜画画手机版";
}

- (NSString*)qqWeiboId
{
    return [MobClickUtils getStringValueByKey:@"DRAW_QQ_WEIBO_ID" defaultValue:@"drawlively"];
//    return @"drawlively";
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
    return NSLS(@"kEmail_subject");    
}

- (NSString *)upgradeMessage:(int)newLevel
{
    return [NSString stringWithFormat:NSLS(@"kUpgradeMsg"),newLevel,[ConfigManager flowerAwardFordLevelUp]];
}

- (NSString *)degradeMessage:(int)newLevel
{
    return [NSString stringWithFormat:NSLS(@"kDegradeMsg"),newLevel,[ConfigManager flowerAwardFordLevelUp]];
}

- (NSString *)popupMessageDialogBackgroundImage
{
    return @"common_dialog_bg@2x.png";
}

- (BOOL)supportWeixin
{
    return YES;
}

- (NSString*)homeHeaderViewId
{
    return @"DrawHomeHeaderPanel";
}

- (NSString*)getCommonDialogXibName
{
    return @"CommonDialog";
}
- (NSString*)getInputDialogXibName
{
    return @"InputDialog";
}
- (NSString*)getPasswordDialogXibName
{
    return @"PassWordDialog";
}
- (NSString*)getRoomPasswordDialogXibName
{
    return @"RoomPasswordDialog";
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
- (id<ChatMsgManagerProtocol>)getChatMsgManager
{
    return nil;
}
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
    return @"96ZJ06UgzeimTwTAs3";
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

@end
