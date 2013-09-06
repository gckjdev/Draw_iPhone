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
#import "HPThemeManager.h"
#import <QuartzCore/QuartzCore.h>


#define CONTENT_VIEW_INSERT (ISIPAD ? 10 : 5)

#define TEXT_VIEW_BORDER_WIDTH   (ISIPAD ? 6  : 3)
#define TEXT_VIEW_CORNER_RADIUS  (ISIPAD ? 15 : 8)
#define BUTTON_CORNER_RADIUS    TEXT_VIEW_CORNER_RADIUS
#define FONT_BUTTON [UIFont boldSystemFontOfSize:(ISIPAD ? 30 : 15)]
#define LOGIN_FONT_BUTTON [UIFont systemFontOfSize:(ISIPAD ? 36 : 19)]

//#define COLOR_LIGHT_YELLOW OPAQUE_COLOR(75, 63, 50) // common dialog
//#define COLOR_YELLOW OPAQUE_COLOR(255, 187, 85) // common dialog
//#define COLOR_YELLOW1 OPAQUE_COLOR(254, 198, 48) // common tab selected bg
//#define COLOR_YELLOW2 OPAQUE_COLOR(204, 131, 24) // common tab selected bg

// (浅)橙黄色按钮，用于normal状态。
#define COLOR_ORANGE OPAQUE_COLOR(238, 94, 82) 
// (深)橙黄色按钮，用于select/hightlight状态。
#define COLOR_ORANGE1 OPAQUE_COLOR(209, 66, 53) 

// (浅)黄色，用在按钮上(normal)，也用在一些背景设置上。
#define COLOR_YELLOW OPAQUE_COLOR(254, 198, 48)
// (深)黄色，用在按钮上(hightlight/select)
#define COLOR_YELLOW1 OPAQUE_COLOR(204, 131, 24)

// CommonDialog 边框的颜色。
#define COLOR_RED OPAQUE_COLOR(235, 83, 48)    

// CommonDialog 标题栏背景颜色。
#define COLOR_GREEN OPAQUE_COLOR(0, 190, 177) 

// 黄色按钮上的字体颜色。其他颜色的按钮上的字体为白色。
#define COLOR_COFFEE OPAQUE_COLOR(126, 49, 46)

// 普通label上的字体颜色。
//#define COLOR_BROWN OPAQUE_COLOR(75, 63, 50)
#define COLOR_BROWN COLOR_COFFEE


// cell的背景颜色
#define COLOR_WHITE [UIColor whiteColor] //Cell
#define COLOR_GRAY OPAQUE_COLOR(245, 245, 245) //Cell


#define IMAGE_FROM_COLOR(color) ([ShareImageManager imageWithColor:color])

#define SET_VIEW_BG(view) (view.backgroundColor = COLOR_WHITE)


#define SET_MESSAGE_LABEL_STYLE(view)                       \
{                                                           \
    [ShareImageManager setMessageLabelStyle:view];          \
}

// 输入框风格。
#define SET_INPUT_VIEW_STYLE(view)                          \
{                                                           \
    [ShareImageManager setInputViewStyle:view];             \
}

// CommonTab 按钮风格。
#define SET_BUTTON_AS_COMMON_TAB_STYLE(view)                \
{                                                           \
    [ShareImageManager setButtonCommonTabStyle:view];       \
}

// 黄色圆角按钮风格。
#define SET_BUTTON_ROUND_STYLE_YELLOW(view)                 \
{                                                           \
    [ShareImageManager setButtonYellowRoundStyle:view];     \
}    

// 黄色方角按钮风格。
#define SET_BUTTON_SQUARE_STYLE_YELLOW(view)                 \
{                                                           \
    [ShareImageManager setButtonYellowSquareStyle:view];     \
}

// 红色圆角按钮风格。
#define SET_BUTTON_ROUND_STYLE_ORANGE(view)                 \
{                                                           \
    [ShareImageManager setButtonOrangeRoundStyle:view];     \
}

#define SET_VIEW_ROUND_CORNER(view) \
{           \
    [view.layer setCornerRadius:TEXT_VIEW_CORNER_RADIUS];  \
    [view.layer setMasksToBounds:YES];    \
}

#define SET_CELL_BG_IN_CONTROLLER                     \
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:       (NSIndexPath *)indexPath {                          \
    if (indexPath.row % 2 == 0) {                       \
        cell.backgroundColor = COLOR_GRAY;              \
    }else{                                              \
        cell.backgroundColor = COLOR_WHITE;             \
    }                                                   \
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath]; \
}

#define SET_CELL_BG_IN_VIEW                     \
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:       (NSIndexPath *)indexPath {                          \
    if (indexPath.row % 2 == 0) {                       \
    cell.backgroundColor = COLOR_GRAY;              \
    }else{                                              \
    cell.backgroundColor = COLOR_WHITE;             \
    }                                                   \
}


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

- (UIImage*)greenButtonImage:(NSString*)text;
- (UIImage*)greenButtonImage;


- (UIImage*)woodImage;
- (UIImage*)greenImage;
- (UIImage*)redImage;
- (UIImage*)orangeImage;
- (UIImage *)buyButtonImage;
- (UIImage*)showcaseBackgroundImage;
- (UIImage *)coinImage;
- (UIImage *)toolImage;
- (UIImage *)popupImage;

- (UIImage *)whitePaperImage;
- (UIImage *)pickEasyWordCellImage;
- (UIImage *)pickNormakWordCellImage;
- (UIImage *)pickHardWordCellImage;

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
- (UIImage*)avatarImageByGender:(BOOL)gender;

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

- (UIImage *)printOil;

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

- (UIImage *)drawToolButtonBG; //draw_tool_button_bg@2x.png
- (UIImage *)drawToolButtonSelectedBG;

- (UIImage *)drawSliderLoader;
- (UIImage *)drawSliderBG;
- (UIImage *)drawSliderPoint;
- (UIImage *)drawSliderDisableImage;

- (UIImage *)drawSelectorCloseBGImage;
- (UIImage *)drawSelectorCloseImage;

//player

- (UIImage *)playProgressPoint;
- (UIImage *)speedProgressPoint;

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

- (UIImage *)draftsBoxBgImage;

- (UIImage*)settingCellTopBgImage;
- (UIImage*)settingCellMiddleBgImage;
- (UIImage*)settingCellBottomBgImage;
- (UIImage*)settingCellOneBgImage;
- (UIImage*)navigatorRightBtnImage;

- (UIImage *)splitPhoto;
- (UIImage *)placeholderPhoto;

- (UIImage *)drawToolUpPanelLeftArrowBg;
- (UIImage *)drawToolUpPanelRightArrowBg;

- (UIImage *)polygonSelectorImage;
- (UIImage *)pathSelectorImage;
- (UIImage *)ellipseSelectorImage;
- (UIImage *)rectangeSelectorImage;
- (UIColor *)drawBGColor;
- (UIImage *)drawBackImage;
- (UIImage *)runAwayImage;

+ (UIImage *)imageWithColor:(UIColor *)color;

- (UIImage *)detailHeaderBG;

+ (UIImage *)bubleImage;

+ (void)setButtonStyle:(UIButton *)button
      normalTitleColor:(UIColor *)normalTitleColor
    selectedTitleColor:(UIColor *)selectedTitleColor
 highlightedTitleColor:(UIColor *)highlightedTitleColor
                  font:(UIFont *)font
           normalColor:(UIColor *)normalColor
         selectedColor:(UIColor *)selectedColor
      highlightedColor:(UIColor *)highlightedColor
                 round:(BOOL)round;

     
+ (void)setMessageLabelStyle:(UILabel *)label;
+ (void)setInputViewStyle:(id)iv;

+ (void)setButtonYellowRoundStyle:(UIButton *)button;
+ (void)setButtonYellowSquareStyle:(UIButton *)button;

+ (void)setButtonCommonTabStyle:(UIButton *)button;
+ (void)setButtonOrangeRoundStyle:(UIButton *)button;

@end
