//
//  ShareImageManager.h
//  Draw
//
//  Created by  on 12-3-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

// buttons images
#import "LocaleUtils.h"
#import "UserManager.h"
#import "ImageManagerProtocol.h"
#import "GameBasic.pb.h"

//#define DEFAULT_AVATAR_BUNDLE   ([[UserManager defaultManager] defaultAvatar])

#define SETTING_BUTTON_IMAGE    @"home_setting.png"
#define FEEDBACK_BUTTON_IMAGE   @"feedback.png"

// background
#define ROOM_BACKGROUND         @"room.png"
#define SHOWCASE_BACKGROUND         @"buyitems_bg.png"

//cell background
#define WORD_EASY_CELL_BACKGROUND @"easy.png"
#define WORD_NORMAL_CELL_BACKGROUND @"normal.png"
#define WORD_HARD_CELL_BACKGROUND @"hard.png"

@interface ShareImageManager : NSObject <ImageManagerProtocol>

+ (ShareImageManager*)defaultManager;

- (UIImage*)woodImage;
- (UIImage*)greenImage;
- (UIImage*)redImage;
- (UIImage*)orangeImage;
- (UIImage *)buyButtonImage;
- (UIImage*)showcaseBackgroundImage;
- (UIImage *)coinImage;
- (UIImage *)toolImage;
- (UIImage *)popupImage;
- (UIImage *)popupChatImageLeft;
- (UIImage *)popupChatImageRight;

- (UIImage *)whitePaperImage;
- (UIImage *)pickEasyWordCellImage;
- (UIImage *)pickNormakWordCellImage;
- (UIImage *)pickHardWordCellImage;

//- (UIImage *)blackColorImage;
//- (UIImage *)redColorImage;
//- (UIImage *)greenColorImage;
//- (UIImage *)blueColorImage;
//- (UIImage *)yellowColorImage;
//- (UIImage *)orangeColorImage;
//- (UIImage *)pinkColorImage;
//- (UIImage *)brownColorImage;
//- (UIImage *)skyColorImage;
//- (UIImage *)whiteColorImage;

- (UIImage *)addColorImage;

- (UIImage *)commentSourceBG;
- (UIImage *)drawingMarkSmallImage;
- (UIImage *)drawingMarkLargeImage;
- (UIImage *)scoreBackgroundImage;
- (UIImage *)toolNumberImage;

- (UIImage *)inputImage;
- (UIImage *)avatarUnSelectImage;
- (UIImage *)avatarSelectImage;

- (UIImage*)femaleDefaultAvatarImage;
- (UIImage*)maleDefaultAvatarImage;

- (UIImage *)savePercentImage;

- (UIImage *)penMaskImage;
- (UIImage *)colorMaskImage;

- (UIImage *)myFoucsImage;
- (UIImage *)myFoucsSelectedImage;
- (UIImage *)focusMeImage;
- (UIImage *)focusMeSelectedImage;
- (UIImage *)middleTabImage;
- (UIImage *)middleTabSelectedImage;


- (UIImage *)normalButtonImage;
- (UIImage *)highlightMaskImage;
- (UIImage *)sinaWeiboImage;
- (UIImage *)qqWeiboImage;
- (UIImage *)facebookImage;
- (UIImage *)messageImage;
//- (UIImage *)snowImage;

- (UIImage *)penImage;
- (UIImage *)pencilImage;
- (UIImage *)waterPenImage;
- (UIImage *)iceImage;
- (UIImage *)quillImage;
- (UIImage *)eraserImage;

- (UIImage *)selectedBrushPenImage;
- (UIImage *)selectedFeatherPenImage;
- (UIImage *)selectedIcePenImage;
- (UIImage *)selectedMarkPenImage;
- (UIImage *)selectedPencilImage;

- (UIImage *)selectedEraserImage;
- (UIImage *)showEraserImage;

- (UIImage *)showBrushPenImage;
- (UIImage *)showFeatherPenImage;
- (UIImage *)showIcePenImage;
- (UIImage *)showMarkPenImage;
- (UIImage *)showPencilPenImage;

- (UIImage *)goldenAvatarImage;
- (UIImage *)greenAvatarImage;
- (UIImage *)purpleAvatarImage;

- (UIImage *)friendDetailBgImage;

//for tool
- (UIImage *)toolBoxImage;

//for tool
- (UIImage*)colorBuyedImage;
- (UIImage *)buyedImage;
- (UIImage *)removeAd;
- (UIImage *)flower;

//- (UIImage *)brushPen;
//- (UIImage *)icePen;
- (UIImage *)printOil;
//- (UIImage *)quillPen;
//- (UIImage*)waterPen;


//shape image

- (UIImage *)shapeLine;
- (UIImage *)shapeRectangle;
- (UIImage *)shapeEllipse;
- (UIImage *)shapeTriangle;
- (UIImage *)shapeStar;

- (UIImage *)itemOut;
- (UIImage *)itemShadow;
- (UIImage *)rewardCoin;
- (UIImage *)shopShelf;
- (UIImage *)shoppingBackground;
- (UIImage *)tipBag;
- (UIImage *)tomato;
- (UIImage *)smallCoin;

- (UIImage *)pickToolBackground;
- (UIImage *)unloadBg;
- (UIImage*)backButtonImage;

- (UIImage *)drawColorBG; //draw_color_bg@2x.png
- (UIImage *)drawToolBG;

- (UIImage *)drawSliderLoader;
- (UIImage *)drawSliderBG;
- (UIImage *)drawSliderPoint;
- (UIImage *)drawSliderDisableImage;

//player

- (UIImage *)playProgressLoader;//draw_player_progress_load@2x.png
- (UIImage *)speedProgressLoader;

//top player cup

- (UIImage*)goldenCupImage;
- (UIImage*)copperCupImage;
- (UIImage*)silverCupImage;


- (UIImage *)diceStartMenuImage;
- (UIImage*)normalRoomMenuImage;
- (UIImage*)highRoomMenuImage;
- (UIImage*)superHighRoomMenuImage;
- (UIImage *)diceHelpMenuImage;

//menu button
- (UIImage *)onlinePlayImage;
- (UIImage *)offlineDrawImage;
- (UIImage*)offlineGuessImage;
- (UIImage *)friendPlayImage;
- (UIImage *)timelineImage;
- (UIImage*)shopImage;
- (UIImage*)diceShopImage;
- (UIImage *)topImage;
- (UIImage*)contestImage;

//bottom menus image
- (UIImage*)checkInMenuImage;
- (UIImage *)opusMenuImage;

- (UIImage *)settingsMenuImageForGameAppType:(GameAppType)gameAppType;
- (UIImage*)friendMenuImageForGameAppType:(GameAppType)gameAppType;
- (UIImage *)chatMenuImageForGameAppType:(GameAppType)gameAppType;
- (UIImage *)feedbackMenuImageForGameAppType:(GameAppType)gameAppType;
- (UIImage *)bottomPanelBGForGameAppType:(GameAppType)gameAppType;
- (UIImage *)mainMenuPanelBGForGameAppType:(GameAppType)gameAppType;


- (UIImage *)shareDrawButtonImage;
- (UIImage *)defaultBoardImage;
- (UIImage *)defaultAdBoardImage;


- (UIImage *)rightImage;
- (UIImage *)myPaintImage;


- (UIImage *)leftBubbleImage;
- (UIImage *)rightBubbleImage;

#pragma mark - Feed Image manager.

- (UIImage *)pointForCurrentSelectedPage;
- (UIImage *)pointForUnSelectedPage;

- (UIImage *)shopItemAlphaImage;
- (UIImage *)shopItemPaletteImage;
- (UIImage *)autoRecoveryDraftImage;
- (UIImage *)paintPlayerImage;
- (UIImage *)strawImage;

- (UIImage *)commonRoundAavatarNoUserImage;


- (UIImage *)badgeImage;

- (UIImage *)currencyImageWithType:(PBGameCurrency)currency;
- (UIImage *)grayCurrencyImageWithType:(PBGameCurrency)currency;

- (UIImage *)dialogButtonBackgroundImage;
- (UIImage *)bulletinAccessoryImage;
- (UIImage*)freeIngotHeaderBg;


- (UIImage *)itemDetailBgImage;
- (UIImage*)userDetailGenderImage:(BOOL)isMale;
- (UIImage*)userDetailTabBgImage;
- (UIImage*)userDetailTabBgPressedImage;

- (UIImage*)userDetailFollowUserBtnBg;
- (UIImage*)userDetailUnfollowUserBtnBg;
- (UIImage*)userDetailChatToBtnBg;
- (UIImage*)userDetailDrawToBtnBg;
- (UIImage*)selfDetailBalanceBtnBg;
- (UIImage*)selfDetailIngotBtnBg;
- (UIImage*)selfDetailExpBtnBg;

- (UIImage*)customInfoViewMainBgImage;
- (UIImage *)draftsBoxBgImage;

- (UIImage*)settingCellTopBgImage;
- (UIImage*)settingCellMiddleBgImage;
- (UIImage*)settingCellBottomBgImage;
- (UIImage*)settingCellOneBgImage;

@end
