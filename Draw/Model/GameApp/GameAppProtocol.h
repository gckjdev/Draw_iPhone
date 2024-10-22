//
//  GameAppProtocol.h
//  Draw
//
//  Created by  on 12-8-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ChatMsgManagerProtocol.h"
#import "ImageManagerProtocol.h"
#import "GameJumpHandlerProtocol.h"
#import "GameBasic.pb.h"
#import "PPViewController.h"
#import "GameConfigDataManager.h"
#import "PPSmartUpdateDataUtils.h"
#import "Config.pb.h"
#import "Photo.pb.h"

@protocol GameAppProtocol <NSObject>

- (int)getCategory;
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

- (NSString*)qqSpaceAppId;
- (NSString*)qqSpaceAppKey;
- (NSString*)qqSpaceAppSecret;

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
//- (id<ChatMsgManagerProtocol>)getChatMsgManager;
- (NSString *)chatViewBgImageName;
- (NSString *)chatViewInputTextBgImageName;
- (NSString *)popupViewCloseBtnBgImageName;
- (NSString *)chatViewMsgBgImageName;
- (UIColor *)chatViewMsgTextColor;


- (id<ImageManagerProtocol>)getImageManager;



- (NSString *)helpViewBgImageName;
- (NSString *)gameRulesButtonBgImageNameForNormal;
- (NSString *)gameRulesButtonBgImageNameForSelected;
- (NSString *)itemsUsageButtonBgImageNameForNormal;
- (NSString *)itemsUsageButtonBgImageNameForSelected;

- (NSString *)upgradeMessage:(int)newLevel;
- (NSString *)degradeMessage:(int)newLevel;

- (NSString *)popupMessageDialogBackgroundImage;

- (BOOL)supportWeixin;

- (NSString *)weixinId;

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


- (BOOL)isAutoRegister;

- (BOOL)canShareViaSNS;

- (BOOL)hasBBS;

- (BOOL)hasAllColorGroups;

- (UIColor *)homeMenuColor;

- (BOOL)canSubmitDraw;

- (BOOL)hasBGOffscreen;

- (BOOL)canGift;

- (PPViewController *)homeController;
- (Class)homeControllerClass;

- (BOOL)forceSaveDraft;

- (void)HandleWithDidFinishLaunching;

- (void)HandleWithDidBecomeActive;

- (void)createConfigData;

- (BOOL)showPaintCategory;

- (NSString*)getDefaultSNSSubject;

- (NSString*)appItuneLink;
- (NSString*)appLinkUmengKey;

- (BOOL)forceChineseOpus;
- (BOOL)disableEnglishGuess;

- (NSString*)iapResourceFileName;

- (void)createIAPTestDataFile;

- (BOOL)showLocateButton;

- (int)photoUsage;
- (NSString*)keywordSmartDataCn;
- (NSString*)keywordSmartDataEn;
- (NSString*)photoTagsCn;
- (NSString*)photoTagsEn;

- (NSString *)opusClassName;
- (NSString *)shareSDKDefaultAppId;



- (NSString *)shareMyOpusWithDescText;
- (NSString *)shareMyOpusWithoutDescText;
- (NSString *)shareOtherOpusWithDescText;
- (NSString *)shareOtherOpusWithoutDescText;

- (NSString *)createOpusDesc;
- (NSString *)createOpusDescNoName;

- (UIImage *)getGiftToSbImage;

- (NSString *)painterName;

- (NSString *)zeroQianAppKey;
- (NSString *)zeroQianAppSecret;

- (NSString *)defaultImage;
- (NSString *)defaultImageIPAD;
- (NSString *)defaultImageRetina;

@end

@protocol ContentGameAppProtocol <GameAppProtocol>

- (int)sellContentType;

- (NSArray *)homeTabIDList;
- (NSArray *)homeTabTitleList;

@end
