//
//  GameAppProtocol.h
//  Draw
//
//  Created by  on 12-8-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatMsgManagerProtocol.h"
#import "ImageManagerProtocol.h"
#import "GameJumpHandlerProtocol.h"
#import "GameBasic.pb.h"
#import "PPViewController.h"
#import "GameConfigDataManager.h"
#import "PPSmartUpdateDataUtils.h"
#import "Config.pb.h"

@protocol GameAppProtocol <NSObject>

- (NSString*)appId;
- (NSString*)gameId;
- (NSString*)umengId;
- (BOOL)disableAd;

// image resources
- (NSString*)background;
- (NSString*)defaultBroadImage;
- (NSString*)defaultAdBoardImage;
- (NSString*)lmwallId;
- (NSString*)lmAdPublisherId;
- (NSString*)aderAdPublisherId;
- (NSString*)mangoAdPublisherId;
- (NSString*)wanpuAdPublisherId;

- (NSString*)sinaAppKey;
- (NSString*)sinaAppSecret;
- (NSString*)sinaAppRedirectURI;

- (NSString*)qqAppKey;
- (NSString*)qqAppSecret;
- (NSString*)qqAppRedirectURI;

- (NSString*)facebookAppKey;
- (NSString*)facebookAppSecret;

- (NSString*)removeAdProductId;

- (NSString*)askFollowTitle;
- (NSString*)askFollowMessage;
- (NSString*)sinaWeiboId;
- (NSString*)qqWeiboId;

- (NSString*)shareMessageBody;
- (NSString*)shareEmailSubject;
- (NSString*)feedbackTips;

- (NSString *)resourcesPackage;
- (id<ChatMsgManagerProtocol>)getChatMsgManager;
- (NSString *)chatViewBgImageName;
- (NSString *)chatViewInputTextBgImageName;
- (NSString *)popupViewCloseBtnBgImageName;
- (NSString *)chatViewMsgBgImageName;
- (UIColor *)chatViewMsgTextColor;


- (id<ImageManagerProtocol>)getImageManager;
- (NSString*)getCommonDialogXibName;
- (NSString*)getInputDialogXibName;
- (NSString*)getPasswordDialogXibName;
- (NSString*)getRoomPasswordDialogXibName;



- (NSString *)helpViewBgImageName;
- (NSString *)gameRulesButtonBgImageNameForNormal;
- (NSString *)gameRulesButtonBgImageNameForSelected;
- (NSString *)itemsUsageButtonBgImageNameForNormal;
- (NSString *)itemsUsageButtonBgImageNameForSelected;

- (NSString *)upgradeMessage:(int)newLevel;
- (NSString *)degradeMessage:(int)newLevel;

- (NSString *)popupMessageDialogBackgroundImage;

- (BOOL)supportWeixin;
- (NSString*)homeHeaderViewId;

- (NSString *)roomListCellBgImageName;
- (NSString *)roomListCellDualBgImageName;
- (NSString *)roomTitle;

- (UIColor*)popupMessageDialogFontColor;

- (id<GameJumpHandlerProtocol>)getGameJumpHandler;

- (NSString *)shengmengAppId;

//create room dialog color
- (UIColor*)createRoomDialogRoomNameColor;
- (UIColor*)createRoomDialogRoomPasswordColor;
- (UIColor*)buttonTitleColor;

- (NSString*)shopTitle;
- (NSArray*)cacheArray;

- (NSString*)getBackgroundMusicName;

- (PBGameCurrency)wallRewardCurrencyType;

- (NSString*)youmiWallId;
- (NSString*)youmiWallSecret;
- (NSString*)aderWallId;
- (NSString*)domodWallId;
- (NSString*)tapjoyWallId;
- (NSString*)tapjoyWallSecret;

- (PBGameCurrency)saleCurrency;
- (BOOL)hasIngotBalance;
- (BOOL)hasCoinBalance;


- (NSString *)alipayCallBackScheme;

- (BOOL)isAutoRegister;

- (BOOL)canShareViaSNS;

- (BOOL)hasBBS;

- (BOOL)hasAllColorGroups;

- (UIColor *)homeMenuColor;

- (BOOL)canSubmitDraw;

- (BOOL)hasBGOffscreen;

- (BOOL)canPayWithAlipay;

- (BOOL)canGift;

- (PPViewController *)homeController;

- (BOOL)forceSaveDraft;

- (void)HandleWithDidFinishLaunching;

- (void)createConfigData;

- (BOOL)showPaintCategory;

@end

@protocol ContentGameAppProtocol <GameAppProtocol>

- (int)sellContentType;

- (NSArray *)homeTabIDList;
- (NSArray *)homeTabTitleList;

@end
