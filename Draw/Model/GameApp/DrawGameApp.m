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
    return @"4285743836";
}

- (NSString*)sinaAppSecret
{
//    return @"ff89c2f5667b0199ee7a8bad6c44b265";    
    return @"7a88336d7290279aef4112fda83708fd";
}

- (NSString*)sinaAppRedirectURI
{
    return @"http://www.drawlively.com/draw";
}

- (NSString*)qqAppKey
{
    return @"801123669";    
}

- (NSString*)qqAppSecret
{
    return @"30169d80923b984109ee24ade9914a5c";    
}

- (NSString*)qqAppRedirectURI
{
    return @"http://caicaihuahua.me";    
}

- (NSString*)facebookAppKey
{
    return @"352182988165711";    
}

- (NSString*)facebookAppSecret
{
    return @"51c65d7fbef9858a5d8bc60014d33ce2";
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
    return @"猜猜画画手机版";
}

- (NSString*)qqWeiboId
{
    return @"drawlively";
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
    return @"dialogue@2x.png";
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

@end
