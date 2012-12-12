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
    return @"ZJHPasswordDialog";
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
    return @"dialogue@2x.png";
}

- (BOOL)supportWeixin
{
    return YES;
}

- (NSString*)homeHeaderViewId
{
    return @"ZJHHomeHeaderPanel";
}


@end
