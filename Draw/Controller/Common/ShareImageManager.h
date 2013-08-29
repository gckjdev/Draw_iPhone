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

#define FONT_MESSAGE_LABEL [UIFont boldSystemFontOfSize:(ISIPAD ? 30 : 15)]
#define FONT_INPUT_VIEW [UIFont boldSystemFontOfSize:(ISIPAD ? 28 : 14)]
#define FONT_BUTTON [UIFont boldSystemFontOfSize:(ISIPAD ? 30 : 15)]

#define TEXT_VIEW_BORDER_WIDTH   (ISIPAD ? 6  : 3)
#define TEXT_VIEW_CORNER_RADIUS  (ISIPAD ? 15 : 8)
#define BUTTON_CORNER_RADIUS    TEXT_VIEW_CORNER_RADIUS

#define COLOR_ORANGE OPAQUE_COLOR(238, 94, 82) // normal
#define COLOR_ORANGE1 OPAQUE_COLOR(209, 66, 53) // selected
#define COLOR_ORANGE2 OPAQUE_COLOR(224, 80, 67) // hightlight

#define COLOR_LIGHT_YELLOW OPAQUE_COLOR(75, 63, 50) // common dialog
#define COLOR_YELLOW OPAQUE_COLOR(255, 187, 85) // common dialog
#define COLOR_YELLOW1 OPAQUE_COLOR(254, 198, 48) // common tab selected bg
#define COLOR_YELLOW2 OPAQUE_COLOR(204, 131, 24) // common tab selected bg

#define COLOR_LIGHT_GRAY OPAQUE_COLOR(234, 231, 225) // controller bg

#define COLOR_RED OPAQUE_COLOR(235, 83, 48) // common dialog
#define COLOR_RED1 OPAQUE_COLOR(240, 78, 104)  //在线猜逃跑

#define COLOR_BROWN OPAQUE_COLOR(75, 63, 50) // common dialog

#define COLOR_GREEN OPAQUE_COLOR(0, 190, 177) // common dialog
#define COLOR_GREEN1 OPAQUE_COLOR(211, 242, 225) // common dialog

#define COLOR_DARK_BLUE OPAQUE_COLOR(92, 158, 140) //阴影
#define COLOR_BLUE1  OPAQUE_COLOR(54, 77, 197) //在线猜聊天

#define CONTENT_VIEW_INSERT (ISIPAD ? 10 : 5)
#define COLOR_COFFEE1 OPAQUE_COLOR(126, 49, 46) // common tab selected text
  

#define IMAGE_FROM_COLOR(color) ([[ShareImageManager defaultManager] imageWithColor:color])

#define SET_MESSAGE_LABEL_STYLE(view)               \
{                                                   \
    view.textColor = COLOR_BROWN;                   \
    view.font = FONT_MESSAGE_LABEL;                 \
    if ([LocaleUtils isChinese]) {                  \
        [view setLineBreakMode:UILineBreakModeCharacterWrap];              \
    } else {                                        \
        [view setLineBreakMode:UILineBreakModeWordWrap];               \
    }                                               \
}

#define SET_INPUT_VIEW_STYLE(view)                          \
{                                                           \
    view.textColor = COLOR_BROWN;                           \
    view.font = FONT_INPUT_VIEW;                            \
                                                            \
    [view.layer setCornerRadius:TEXT_VIEW_CORNER_RADIUS];   \
    [view.layer setMasksToBounds:YES];                      \
                                                            \
    view.layer.borderWidth = TEXT_VIEW_BORDER_WIDTH;        \
    view.layer.borderColor = [COLOR_YELLOW CGColor];        \
}  

#define SET_BUTTON_AS_COMMON_TAB_STYLE(view)                              \
{                                                           \
[[ShareImageManager defaultManager] setButtonStyle:view normalTitleColor:COLOR_WHITE selectedTitleColor:COLOR_BROWN highlightedTitleColor:COLOR_WHITE font:FONT_BUTTON normalColor:COLOR_ORANGE selectedColor:COLOR_YELLOW highlightedColor:COLOR_ORANGE1 round:NO];         \
}

#define SET_BUTTON_ROUND_STYLE_YELLOW(view)                              \
{                                                           \
    [[ShareImageManager defaultManager] setButtonStyle:view normalTitleColor:COLOR_WHITE selectedTitleColor:COLOR_WHITE highlightedTitleColor:COLOR_WHITE font:FONT_BUTTON normalColor:COLOR_YELLOW selectedColor:COLOR_YELLOW2 highlightedColor:COLOR_YELLOW2 round:YES];         \
} 

#define SET_BUTTON_ROUND_STYLE_ORANGE(view) \
{                                                           \
[[ShareImageManager defaultManager] setButtonStyle:view normalTitleColor:COLOR_WHITE selectedTitleColor:COLOR_BROWN highlightedTitleColor:COLOR_WHITE font:FONT_BUTTON normalColor:COLOR_ORANGE selectedColor:COLOR_YELLOW highlightedColor:COLOR_ORANGE1 round:YES];         \
}


#define SET_BUTTON_SQUARE_STYLE_YELLOW(view)                              \
{                                                           \
[[ShareImageManager defaultManager] setButtonStyle:view normalTitleColor:COLOR_WHITE selectedTitleColor:COLOR_WHITE highlightedTitleColor:COLOR_WHITE font:FONT_BUTTON normalColor:COLOR_YELLOW selectedColor:COLOR_YELLOW2 highlightedColor:COLOR_YELLOW2 round:NO];         \
}



#define SET_VIEW_ROUND_CORNER(view) \
{           \
    [view.layer setCornerRadius:TEXT_VIEW_CORNER_RADIUS];  \
    [view.layer setMasksToBounds:YES];    \
}

#define SET_VIEW_ROUND_CORNER_WIDTH(view, width) \
{           \
    [view.layer setCornerRadius:width];       \
    [view.layer setMasksToBounds:YES];    \
}

#define COLOR_WHITE [UIColor whiteColor] //Cell
#define COLOR_GRAY OPAQUE_COLOR(245, 245, 245) //Cell

#define COLOR_COFFEE OPAQUE_COLOR(60, 40, 20)


#define SET_VIEW_BG(view) (view.backgroundColor = COLOR_LIGHT_GRAY)

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

- (UIImage *)drawToolButtonBG; //draw_tool_button_bg@2x.png
- (UIImage *)drawToolButtonSelectedBG;

- (UIImage *)drawSliderLoader;
- (UIImage *)drawSliderBG;
- (UIImage *)drawSliderPoint;
- (UIImage *)drawSliderDisableImage;

- (UIImage *)drawSelectorCloseBGImage;
- (UIImage *)drawSelectorCloseImage;

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

- (UIImage *)imageWithColor:(UIColor *)color;

- (UIImage *)detailHeaderBG;

+ (UIImage *)bubleImage;

- (void)setButtonStyle:(UIButton *)button
      normalTitleColor:(UIColor *)normalTitleColor
    selectedTitleColor:(UIColor *)selectedTitleColor
 highlightedTitleColor:(UIColor *)highlightedTitleColor
                  font:(UIFont *)font
           normalColor:(UIColor *)normalColor
         selectedColor:(UIColor *)selectedColor
      highlightedColor:(UIColor *)highlightedColor
                 round:(BOOL)round;

@end
