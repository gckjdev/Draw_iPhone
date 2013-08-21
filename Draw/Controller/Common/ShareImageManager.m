//
//  ShareImageManager.m
//  Draw
//
//  Created by  on 12-3-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShareImageManager.h"
#import "UIImageUtil.h"
#import "FileUtil.h"
#import "PPResourceService.h"




@interface ShareImageManager () {
    PPResourceService *_resService;
}

@end


@implementation ShareImageManager

static ShareImageManager* _defaultManager;
static UIImage* _woodButtonImage;
static UIImage* _orangeButtonImage;
static UIImage* _greenButtonImage;
static UIImage* _redButtonImage;
static UIImage *_buyButtonImage;
static UIImage* _showcaseBackgroundImage;
static UIImage* _whitePaperImage;

+ (ShareImageManager*)defaultManager
{
    if (_defaultManager == nil){
        _defaultManager = [[ShareImageManager alloc] init];
    }
    
    return _defaultManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _resService = [PPResourceService defaultService];
    }
    return self;
}

- (UIImage*)greenButtonImage:(NSString*)text
{
    return [self greenButtonImage];
}

- (UIImage*)greenButtonImage
{
    if (ISIPAD){
        return [UIThemeImageNamed(@"button_green@2x.png") defaultStretchableImage];
    }
    else{
        return [UIThemeImageNamed(@"button_green@2x.png") defaultStretchableImage];
    }
}

- (UIImage*)woodImage
{
    if (_woodButtonImage == nil){        
        _woodButtonImage = [[UIImage strectchableImageName:@"wood_button.png"] retain];
    }
    
    return _woodButtonImage;
}

- (UIImage*)greenImage
{
    if (_greenButtonImage == nil){        
        _greenButtonImage = [[UIImage strectchableImageName:@"green_button.png"] retain];
    }
    
    return _greenButtonImage;    
}

- (UIImage*)redImage
{
    if (_redButtonImage == nil){        
        _redButtonImage = [[UIImage strectchableImageName:@"red_button.png"] retain];
    }
    
    return _redButtonImage;    
}


- (UIImage*)orangeImage
{
    if (_orangeButtonImage == nil){        
        _orangeButtonImage = [[UIImage strectchableImageName:@"orange_button.png"] retain];
    }
    
    return _orangeButtonImage;    
}

- (UIImage *)buyButtonImage
{
    if(_buyButtonImage == nil)
    {
        _buyButtonImage = [[UIImage strectchableImageName:@"buybutton.png"] retain];
    }
    return _buyButtonImage;
}

- (UIImage *)savePercentImage
{
    return [UIImage strectchableImageName:@"mumber.png"];
}

- (UIImage*)showcaseBackgroundImage
{
    if (_showcaseBackgroundImage == nil) {
        _showcaseBackgroundImage = [[UIImage strectchableImageName:SHOWCASE_BACKGROUND]retain];
    }
    return _showcaseBackgroundImage;
}

- (UIImage *)whitePaperImage
{
    if (_whitePaperImage == nil) {
        _whitePaperImage = [[UIImage strectchableImageName:@"white_paper.png"]retain];
//        _whitePaperImage = [[UIImage strectchableImageName:@"white_paper.png" topCapHeight:40]retain];
    }
    return _whitePaperImage;
}

- (UIImage *)inputImage
{
    return [UIImage strectchableImageName:@"inputbg"];
}

- (UIImage *)pickEasyWordCellImage
{
    return [UIImage strectchableImageName:WORD_EASY_CELL_BACKGROUND];
}
- (UIImage *)pickNormakWordCellImage
{
    return [UIImage strectchableImageName:WORD_NORMAL_CELL_BACKGROUND];    
}
- (UIImage *)pickHardWordCellImage
{
    return [UIImage strectchableImageName:WORD_HARD_CELL_BACKGROUND];
}

- (UIImage *)avatarSelectImage
{
    return [UIImage strectchableImageName:@"user_pic_bgselected.png"];
}

- (UIImage *)avatarUnSelectImage
{
    return [UIImage strectchableImageName:@"user_picbg.png"];
}

- (UIImage *)goldenAvatarImage
{
    return [UIImage strectchableImageName:@"gold_user_picbg.png"];
}

- (UIImage *)greenAvatarImage
{
    return [UIImage strectchableImageName:@"green_user_picbg.png"];
}

- (UIImage *)purpleAvatarImage
{
    return [UIImage strectchableImageName:@"purple_user_picbg.png"];
}

- (UIImage *)coinImage
{
    return [UIImage imageNamed:@"coin@2x.png"];
}

- (UIImage *)toolImage
{
    return [UIImage imageNamed:@"tool.png"];
}

- (UIImage *)toolNumberImage
{
    return [UIImage strectchableImageName:@"number.png"];
}

- (UIImage*)maleDefaultAvatarImage
{
    return [LocaleUtils isChina] ? [UIImage imageNamed:@"man1.png"] : [UIImage imageNamed:@"man2.png"];
}

- (UIImage*)femaleDefaultAvatarImage
{
    return [LocaleUtils isChina] ? [UIImage imageNamed:@"female1.png"] : [UIImage imageNamed:@"female2.png"];
}

- (UIImage*)avatarImageByGender:(BOOL)gender
{
    if (gender) {
        return [[ShareImageManager defaultManager] maleDefaultAvatarImage];
    }else{
        return [[ShareImageManager defaultManager] femaleDefaultAvatarImage];
    }
}

#pragma makr - Color Image

//- (UIImage *)redColorImage
//{
//    return [UIImage imageNamed:@"red_color.png"];
//}
//- (UIImage *)blueColorImage
//{
//    return [UIImage imageNamed:@"blue_color.png"];    
//}
//- (UIImage *)yellowColorImage
//{
//    return [UIImage imageNamed:@"yellow_color.png"];    
//}
//- (UIImage *)blackColorImage
//{
//    return [UIImage imageNamed:@"black_color.png"];    
//}
//
//- (UIImage *)orangeColorImage
//{
//    return [UIImage imageNamed:@"orange_color.png"];    
//}
//- (UIImage *)greenColorImage
//{
//    return [UIImage imageNamed:@"green_color.png"];    
//}
//- (UIImage *)pinkColorImage
//{
//    return [UIImage imageNamed:@"pink_color.png"];    
//}
//- (UIImage *)brownColorImage
//{
//    return [UIImage imageNamed:@"brown_color.png"];    
//}
//- (UIImage *)skyColorImage
//{
//    return [UIImage imageNamed:@"sky_color.png"];    
//}
//- (UIImage *)whiteColorImage
//{
//    return [UIImage imageNamed:@"white_color.png"];    
//}


- (UIImage *)addColorImage
{
    return [UIImage imageNamed:@"add_color.png"];        
}

- (UIImage *)commentSourceBG
{
    return [UIImage strectchableImageName:@"reply_bg.png"];
}
- (UIImage *)popupImage
{
    return [UIImage strectchableImageName:@"guess_popup.png" leftCapWidth:20];
}

- (UIImage *)popupChatImageLeft
{
    return [UIImage strectchableImageName:@"message_popup.png" leftCapWidth:10];
}

- (UIImage *)popupChatImageRight
{
    return [UIImage strectchableImageName:@"message_popup.png" leftCapWidth:20];
}

- (UIImage *)drawingMarkSmallImage
{
    return [UIImage imageNamed:@"my_paint_tag.png"];        
}
- (UIImage *)drawingMarkLargeImage
{
    return [UIImage imageNamed:@"my_paint_tag.png"];            
}
- (UIImage *)scoreBackgroundImage
{
    return [UIImage imageNamed:@"score.png"];            
}

- (UIImage *)penMaskImage
{
    return [UIImage imageNamed:@"pen_mask.png"];
}
- (UIImage *)colorMaskImage
{
    return [UIImage imageNamed:@"color_mask.png"];    
}

/*
 draw_tab_left_selected
 draw_tab_left_unselected
 draw_tab_mid_selected
 draw_tab_mid_unselected
 draw_tab_right_selected
 draw_tab_right_unselected
*/

- (UIImage *)myFoucsImage
{
    return [self fixedAndStrectchableImageNamed:@"draw_tab_left_unselected"];
//    return [UIImage strectchableImageName:@"draw_tab_left_unselected"];
}

- (UIImage *)myFoucsSelectedImage
{
    return [self fixedAndStrectchableImageNamed:@"draw_tab_left_selected"];
//     return [UIImage strectchableImageName:@"draw_tab_left_selected"];
}

- (UIImage *)focusMeImage
{
    return [self fixedAndStrectchableImageNamed:@"draw_tab_right_unselected"];
//    return [UIImage strectchableImageName:@"draw_tab_right_unselected"];
}

- (UIImage *)focusMeSelectedImage
{
    return [self fixedAndStrectchableImageNamed:@"draw_tab_right_selected"];
//    return [UIImage strectchableImageName:@"draw_tab_right_selected"];
}

- (UIImage *)middleTabImage
{
    return [self fixedAndStrectchableImageNamed:@"draw_tab_mid_unselected"];
//    return [UIImage strectchableImageName:@"draw_tab_mid_unselected"];
}
- (UIImage *)middleTabSelectedImage
{
    return [self fixedAndStrectchableImageNamed:@"draw_tab_mid_selected"];
//    return [UIImage strectchableImageName:@"draw_tab_mid_selected"];
}


- (UIImage *)normalButtonImage
{
    return [UIImage strectchableImageName:@"normal_button.png"];
}

- (UIImage *)highlightMaskImage
{
    return [UIImage strectchableImageName:@"highlight_mask.png"];
}

- (UIImage *)sinaWeiboImage
{
    return [UIImage imageNamed:@"sina.png"]; 
}

- (UIImage *)qqWeiboImage
{
    return [UIImage imageNamed:@"qq.png"]; 
}

- (UIImage *)facebookImage
{
    return [UIImage imageNamed:@"facebook.png"];
}

- (UIImage *)messageImage
{
    return [UIImage strectchableImageName:@"messagebg.png"];
}

//- (UIImage *)snowImage
//{
//    return [UIImage imageNamed:@"snow.png"];
//}

- (UIImage *)pencilImage
{
    return [UIImage imageNamed:@"pen_pencil@2x"];
}
- (UIImage *)waterPenImage
{
    return [UIImage imageNamed:@"pen_mark@2x"];
}
- (UIImage *)penImage
{
    return [UIImage imageNamed:@"pen_brush@2x"];
}
- (UIImage *)iceImage
{
    return [UIImage imageNamed:@"pen_ice-cream@2x"];
}
- (UIImage *)quillImage
{
    return [UIImage imageNamed:@"pen_feather@2x"];    
}
- (UIImage *)eraserImage
{
    return [UIImage imageNamed:@"draw_rubber.png"];
}

- (UIImage *)selectedBrushPenImage
{
    return [UIImage imageNamed:@"selected_pen_brush@2x"];
}
- (UIImage *)selectedFeatherPenImage
{
    return [UIImage imageNamed:@"selected_pen_feather@2x"];
}
- (UIImage *)selectedIcePenImage
{
    return [UIImage imageNamed:@"selected_pen_ice-cream@2x"];
}
- (UIImage *)selectedMarkPenImage
{
    return [UIImage imageNamed:@"selected_pen_mark@2x"];
}
- (UIImage *)selectedPencilImage
{
    return [UIImage imageNamed:@"selected_pen_pencil@2x"];
}
- (UIImage *)selectedEraserImage
{
    return [UIImage imageNamed:@"selected_pen_rubber@2x"];
}
- (UIImage *)showEraserImage
{
    return [UIImage imageNamed:@"eraser_show@2x"];
}
- (UIImage *)showBrushPenImage
{
    return [UIImage imageNamed:@"pen_show_brush@2x"];
}

- (UIImage *)showFeatherPenImage
{
    return [UIImage imageNamed:@"pen_show_feather@2x"];
}
- (UIImage *)showIcePenImage
{
    return [UIImage imageNamed:@"pen_show_ice@2x"];
}
- (UIImage *)showMarkPenImage
{
    return [UIImage imageNamed:@"pen_show_mark@2x"];
}
- (UIImage *)showPencilPenImage
{
    return [UIImage imageNamed:@"pen_show_pencil@2x"];
}


- (UIImage *)friendDetailBgImage
{
    return [UIImage strectchableImageName:@"friend_detail_bg.png"];
}
//for toolbox
- (UIImage *)toolBoxImage
{
    return [UIImage imageNamed:@"toolbox.png"];
}

- (NSString *)fixImageName:(NSString *)name
{
    NSString *temp = name;
    if ([DeviceDetection isIPAD]) {
        temp = [NSString stringWithFormat:@"%@@2x.png",name];
    }else{
        temp = [NSString stringWithFormat:@"%@.png",name];
    }
    return temp;
}

- (UIImage *)fixedImageNamed:(NSString *)name
{
    NSString *temp = [self fixImageName:name];
    return [UIImage imageNamed:temp];
}

- (UIImage *)fixedAndStrectchableImageNamed:(NSString *)name
{
    NSString *temp = [self fixImageName:name];
    return [UIImage strectchableImageName:temp];
}

//for tool
- (UIImage*)colorBuyedImage
{
    return [UIImage imageNamed:@"right.png"];
}
- (UIImage *)buyedImage
{
    return [UIImage imageNamed:@"buyed.png"];
}
//- (UIImage *)brushPen
//{
//    return [self fixedImageNamed:@"draw_pen1"];
//}
- (UIImage *)removeAd
{
    return [self fixedImageNamed:@"clean_ad"];
}
//- (UIImage *)icePen
//{
//    return [self fixedImageNamed:@"draw_pen3"];
//}
//set button image not background image.
- (UIImage *)flower
{
    return [self fixedImageNamed:@"flower"];
}
- (UIImage *)tomato
{
    return [self fixedImageNamed:@"tomato"];
}
- (UIImage *)tipBag
{
    return [self fixedImageNamed:@"tipbag"];
}


- (UIImage *)shapeLine
{
    return [self fixedImageNamed:@"draw_line"];
}
- (UIImage *)shapeRectangle
{
    return [self fixedImageNamed:@"draw_rectangle"];
}
- (UIImage *)shapeEllipse
{
        return [self fixedImageNamed:@"draw_ellipse"];
}
- (UIImage *)shapeTriangle
{
   return [self fixedImageNamed:@"draw_triangle"];
}
- (UIImage *)shapeStar
{
    return [self fixedImageNamed:@"draw_star"];
}


- (UIImage *)itemOut
{
    return [UIImage imageNamed:@"itemOut.png"];
}
- (UIImage *)itemShadow
{
    return [UIImage imageNamed:@"item_shadow.png"];
}
- (UIImage *)printOil
{
    return [self fixedImageNamed:@"print_oil"];
}
//- (UIImage *)quillPen
//{
//    return [self fixedImageNamed:@"draw_pen4"];
//}

- (UIImage *)rewardCoin
{
    return [UIImage imageNamed:@"coin@2x.png"];
}
- (UIImage *)shopShelf
{
    return [UIImage imageNamed:@"shop_shelf.png"];
}
- (UIImage *)shoppingBackground
{
    return [UIImage imageNamed:@"shopping_bg.png"];
}
- (UIImage *)smallCoin
{
    return [UIImage imageNamed:@"coin@2x.png"];
}

//- (UIImage*)waterPen
//{
//    return [self fixedImageNamed:@"draw_pen2"];
//}

- (UIImage*)dice
{
    return [UIImage imageNamed:@"mike_pen"];
}

- (UIImage*)backButtonImage
{
    return [self fixedImageNamed:@"back"];
}

- (UIImage*)goldenCupImage
{
    return [UIImage imageNamed:@"gold_cup"];
}
- (UIImage*)silverCupImage
{
    return [UIImage imageNamed:@"silver_cup"];
}
- (UIImage*)copperCupImage
{
    return [UIImage imageNamed:@"copper_cup"];
}

- (UIImage *)shareDrawButtonImage
{
    return [UIImage imageNamed:@"draw_share.png"];
}

- (UIImage *)defaultBoardImage
{
    return [UIImage imageNamed:[GameApp defaultBroadImage]];
}

- (UIImage *)defaultAdBoardImage
{
    return [UIImage imageNamed:[GameApp defaultAdBoardImage]];
}

- (UIImage *)rightImage
{
    return [UIImage imageNamed:@"guessed@2x.png"];
}
- (UIImage *)myPaintImage
{
    return [UIImage strectchableImageName:@"print_tipbig.png"];
}

- (UIImage *)leftBubbleImage
{
    return [UIImage strectchableImageName:@"receive_message@2x.png"];
}
- (UIImage *)rightBubbleImage
{
    return [UIImage strectchableImageName:@"sent_message@2x.png"];
}

#pragma mark - menu button image
- (UIImage *)onlinePlayImage
{
    return [self fixedImageNamed:@"h_play"];
}
- (UIImage *)offlineDrawImage
{
    return [self fixedImageNamed:@"h_draw"];    
}
- (UIImage*)offlineGuessImage
{
    return [self fixedImageNamed:@"h_guess"];
}
- (UIImage *)friendPlayImage
{
    return [self fixedImageNamed:@"h_friends"];
}
- (UIImage *)timelineImage
{
    return [self fixedImageNamed:@"h_feed"];
}

- (UIImage*)shopImage
{
    return [self fixedImageNamed:@"h_shop"]; 
}

- (UIImage *)topImage
{
    return [self fixedImageNamed:@"h_top"];
}

- (UIImage*)contestImage
{
    return [self fixedImageNamed:@"h_match"]; 
}

- (UIImage *)pickToolBackground
{
    return [UIImage strectchableImageName:@"popuptools_bg.png"];    
}

- (UIImage *)drawToolButtonBG
{
    return [UIImage strectchableImageName:@"draw_tool_button_bg"];
}

- (UIImage *)drawToolButtonSelectedBG
{
    return [UIImage strectchableImageName:@"draw_tool_button_selected_bg"];
}

- (UIImage *)drawColorBG //draw_color_bg@2x.png
{
//    return [self fixedAndStrectchableImageNamed:@"draw_color_bg"];
    return [UIImage strectchableImageName:@"draw_color_bg"];
}

- (UIImage *)drawToolBG //draw_tool_bg@2x.png
{
    return [UIImage strectchableImageName:@"draw_tool_bg"];
//    return [self fixedAndStrectchableImageNamed:@"draw_tool_bg"];
}


- (UIImage *)drawSliderLoader
{
//    NSString *name = [self fixImageName:@"draw_slider_load"];
//    return [UIImage strectchableImageName:name topCapHeight:<#(int)#>]
    UIImage*image = [self fixedImageNamed:@"draw_slider_load"];
    NSInteger height = image.size.height / 2;
    NSInteger width = image.size.width - 2;
    return [image stretchableImageWithLeftCapWidth:width topCapHeight:height];
}
- (UIImage *)drawSliderBG
{
    return [self fixedAndStrectchableImageNamed:@"draw_slider_bg"];
}
- (UIImage *)drawSliderPoint
{
    return [self fixedAndStrectchableImageNamed:@"draw_slider_point"];
}
- (UIImage *)drawSliderDisableImage
{
    return [self fixedImageNamed:@"draw_slider_disable"];
}

- (UIImage *)drawSelectorCloseBGImage
{
    return [self fixedImageNamed:@"selector_close_bg"];
}
- (UIImage *)drawSelectorCloseImage
{
    return [self fixedImageNamed:@"selector_close"];    
}

- (UIImage *)playProgressLoader
{
    return [self fixedAndStrectchableImageNamed:@"draw_player_progress_load"];
}

- (UIImage *)speedProgressLoader
{
    return [self fixedAndStrectchableImageNamed:@"draw_player_speed_load"];
}

//for dice main menu
- (UIImage*)diceShopImage
{
    return [UIImage shrinkImage:[self fixedImageNamed:@"dice_shop"] withRate:1.2];

}


- (UIImage *)diceStartMenuImage
{
    return [UIImage shrinkImage:[self fixedImageNamed:@"dice_start"] withRate:1.2];
}

- (UIImage*)normalRoomMenuImage
{
    return [UIImage shrinkImage:[self fixedImageNamed:@"normal_room"] withRate:1.2];
    
}

- (UIImage*)highRoomMenuImage
{
    return [UIImage shrinkImage:[self fixedImageNamed:@"high_room"] withRate:1.2];
}

- (UIImage*)superHighRoomMenuImage
{
    return [UIImage shrinkImage:[self fixedImageNamed:@"super_high_room"] withRate:1.2];
}

- (UIImage *)diceHelpMenuImage
{
    return [UIImage shrinkImage:[self fixedImageNamed:@"dice_help"] withRate:1.2];
}



//for bottom menu image.

- (UIImage *)opusMenuImage
{
    return [self fixedImageNamed:@"small_share"];    
}

- (UIImage*)checkInMenuImage
{
    return [self fixedImageNamed:@"small_sign"];
}



- (UIImage *)settingsMenuImageForGameAppType:(GameAppType)gameAppType
{
    if (gameAppType == GameAppTypeDraw) {
        return [self fixedImageNamed:@"small_setting"]; 
    }
    return [self fixedImageNamed:@"bm_setting"];
}
- (UIImage *)friendMenuImageForGameAppType:(GameAppType)gameAppType
{
    if (gameAppType == GameAppTypeDraw) {
        return [self fixedImageNamed:@"small_friend_manager"]; 
    }
    return [self fixedImageNamed:@"bm_friend"];
}
- (UIImage *)chatMenuImageForGameAppType:(GameAppType)gameAppType
{
    if (gameAppType == GameAppTypeDraw) {
        return [self fixedImageNamed:@"small_chat"]; 
    }
    return [self fixedImageNamed:@"bm_chat"];
}
- (UIImage *)feedbackMenuImageForGameAppType:(GameAppType)gameAppType
{
    if (gameAppType == GameAppTypeDraw) {
        return [self fixedImageNamed:@"small_feedback"]; 
    }
    return [self fixedImageNamed:@"bm_feedback"];
}

- (UIImage *)bottomPanelBGForGameAppType:(GameAppType)gameAppType
{
    if (gameAppType == GameAppTypeDraw) {
        return [UIImage imageNamed:@"bottom_menubg.png"]; 
    }
    return [UIImage imageNamed:@"dice_bottom_bg.png"]; 
}


- (UIImage *)mainMenuPanelBGForGameAppType:(GameAppType)gameAppType
{
    if (gameAppType == GameAppTypeDraw) {
        return [UIImage imageNamed:@"main_menubg"];        
    }else if (gameAppType == GameAppTypeDice) {
        return [UIImage imageNamed:@"dice_main_menubg"];        
    }
    
    return nil;
}


- (UIImage *)unloadBg
{
    return [self fixedImageNamed:@"unloadbg"];
}

- (UIImage *)pointForCurrentSelectedPage
{
    return  [UIImage strectchableImageName:@"point_pic3.png"];
}

- (UIImage *)pointForUnSelectedPage
{
    return  [UIImage strectchableImageName:@"point_pic4.png"];
}

#pragma mark - dialog image manager protocol

- (UIImage*)commonDialogBgImage
{
    return [UIImage imageNamed:@"common_dialog_bg.png"];
}
- (UIImage*)commonDialogLeftBtnImage
{
    return [UIImage imageNamed:@"common_dialog_btn_bg.png"];
}
- (UIImage*)commonDialogRightBtnImage
{
    return [UIImage imageNamed:@"common_dialog_btn_bg.png"];
}

- (UIImage *)inputDialogBgImage
{
    return [UIImage imageNamed:@"common_dialog_bg.png"];
}

- (UIImage*)inputDialogInputBgImage
{
    //    return [UIImage strectchableImageName:@"zjh_input_bg.png" leftCapWidth:15 topCapHeight:15];
    return [UIImage strectchableImageName:@"common_dialog_input_bg.png"];
}
- (UIImage*)inputDialogLeftBtnImage
{
    return [UIImage imageNamed:@"common_dialog_btn_bg.png"];
}
- (UIImage*)inputDialogRightBtnImage
{
    return [UIImage imageNamed:@"common_dialog_btn_bg.png"];
}

- (UIImage *)roomListBgImage
{
    return [_resService imageByName:@"draw_room_bg" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}
- (UIImage *)roomListLeftBtnSelectedImage
{
    return [_resService imageByName:@"draw_tab_left_selected" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}
- (UIImage *)roomListLeftBtnUnselectedImage
{
    return [_resService imageByName:@"draw_tab_left_unselected" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}
- (UIImage *)roomListRightBtnSelectedImage
{
    return [_resService imageByName:@"draw_tab_right_selected" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}
- (UIImage *)roomListRightBtnUnselectedImage
{
    return [_resService imageByName:@"draw_tab_right_unselected" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}

- (UIImage *)roomListCenterBtnSelectedImage
{
    return [_resService imageByName:@"tab_center_selected" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}
- (UIImage *)roomListCenterBtnUnselectedImage
{
    return [_resService imageByName:@"tab_center_unselect" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}

- (UIImage *)roomListCellBgImage
{
    return [_resService imageByName:@"draw_room_cell_bg" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}
- (UIImage *)roomListBackBtnImage
{
    return [_resService imageByName:@"draw_room_back" inResourcePackage:RESOURCE_PACKAGE_DRAW];
}

- (UIImage *)roomListCreateRoomBtnBgImage
{
    return [_resService imageByName:@"draw_room_button" inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)roomListFastEntryBtnBgImage
{
    return [_resService imageByName:@"draw_room_button" inResourcePackage:RESOURCE_PACKAGE_DRAW];
}

- (UIImage *)headerBgImage
{
    return [_resService imageByName:@"draw_room_title_bg" inResourcePackage:RESOURCE_PACKAGE_DRAW];
}

- (UIImage *)userInfoFollowBtnImage
{
    return nil;
}
- (UIImage *)userInfoTalkBtnImage
{
    return nil;
}

- (UIImage *)audioOff
{
    return nil;
}
- (UIImage *)audioOn
{
    return nil;
}
- (UIImage *)musicOn
{
    return nil;
}
- (UIImage *)musicOff
{
    return nil;
}
- (UIImage *)settingsBgImage
{
    return nil;
}
- (UIImage *)settingsLeftSelected
{
    return nil;
}
- (UIImage *)settingsLeftUnselected
{
    return nil;
}
- (UIImage *)settingsRightSelected
{
    return nil;
}
- (UIImage *)settingsRightUnselected
{
    return nil;
}

- (UIImage *)bulletinAccessoryImage
{
    return [_resService imageByName:@"bulletin_accessory" inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)bulletinBackgroundImage
{
    return [_resService stretchableImageWithImageName:@"bulletin_bg" inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)bulletinButtomImage
{
    return [_resService imageByName:@"bulletin_buttom" inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)bulletinDateBackgroundImage
{
    return [_resService imageByName:@"bulletin_date_bg" inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)bulletinTimeBackgroundImage
{
    return [_resService stretchableImageWithImageName:@"bulletin_bg" inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)bulletinTopImage
{
    return [_resService imageByName:@"bulletin_top" inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)bulletinCloseImage
{
    return [_resService imageByName:@"close_bulletin" inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)bulletinNewImage
{
    return [_resService imageByName:@"new_bulletin" inResourcePackage:RESOURCE_PACKAGE_DRAW];
}
- (UIImage *)shopItemAlphaImage
{
    return [self fixedAndStrectchableImageNamed:@"shop_item_alpha"];
}
- (UIImage *)shopItemPaletteImage
{
    return [self fixedAndStrectchableImageNamed:@"shop_item_palette"];
}

- (UIImage *)autoRecoveryDraftImage
{
    return [_resService imageByName:@"auto_recovery" inResourcePackage:RESOURCE_PACKAGE_DRAW];
}

- (UIImage *)paintPlayerImage
{
    return [self fixedAndStrectchableImageNamed:@"shop_item_paint_player"];
}

- (UIImage *)strawImage
{
    return [self fixedAndStrectchableImageNamed:@"shop_item_straw"];
}

- (UIImage *)commonRoundAavatarNoUserImage
{
    return [UIImage imageNamed:@"common_round_avatar_waiting_user.png"];
}

- (UIImage *)badgeImage{
    return [UIImage imageNamed:@"common_home_badge@2x.png"];
}

- (UIImage *)currencyImageWithType:(PBGameCurrency)currency
{
    switch (currency) {
        case PBGameCurrencyCoin:
            return [UIImage imageNamed:@"coin@2x.png"];
            break;
            
        case PBGameCurrencyIngot:
            return [UIImage imageNamed:@"ingot@2x.png"];
            break;
            
        default:
            break;
    }
}

- (UIImage *)grayCurrencyImageWithType:(PBGameCurrency)currency
{
    switch (currency) {
        case PBGameCurrencyCoin:
            return [UIImage imageNamed:@"gray_coin@2x.png"];
            break;
            
        case PBGameCurrencyIngot:
            return [UIImage imageNamed:@"gray_ingot@2x.png"];
            break;
            
        default:
            break;
    }
}

- (UIImage *)dialogButtonBackgroundImage
{
    return [UIImage strectchableImageName:@"common_dialog_btn_bg.png"];
}

- (UIImage*)freeIngotHeaderBg
{
    return [UIImage imageNamed:@"balance_bg.png"];
}



- (UIImage *)itemDetailBgImage
{
    return [[self fixedImageNamed:@"item_detail_bg"] stretchableImageWithLeftCapWidth:0 topCapHeight:(ISIPAD ? 120 : 60)];
}

- (UIImage*)userDetailGenderImage:(BOOL)isMale
{
    if (isMale) {
        return [UIImage imageNamed:@"user_detail_gender_male.png"];
    } else {
        return [UIImage imageNamed:@"user_detail_gender_female.png"];
    }
}

- (UIImage*)userDetailTabBgImage
{
    return [UIImage strectchableImageName:@"user_detail_tab_bg.png"];
}

- (UIImage*)userDetailTabBgPressedImage
{
    return [UIImage strectchableImageName:@"user_detail_tab_bg_pressed.png"];
}

- (UIImage*)userDetailFollowUserBtnBg
{
    return [UIImage imageNamed:@"user_detail_follow_bg.png"];
}

- (UIImage*)userDetailUnfollowUserBtnBg
{
    return [UIImage imageNamed:@"user_detail_unfollow_bg.png"];
}

- (UIImage*)userDetailChatToBtnBg
{
    return [UIImage imageNamed:@"user_detail_message_bg.png"];
}
- (UIImage*)userDetailDrawToBtnBg
{
    return [UIImage imageNamed:@"user_detail_unfollow_bg.png"];
}
- (UIImage*)selfDetailBalanceBtnBg
{
    return [UIImage imageNamed:@"self_detail_balance_btn_bg.png"];
}
- (UIImage*)selfDetailIngotBtnBg
{
    return [UIImage imageNamed:@"self_detail_ingot_btn_bg.png"];
}
- (UIImage*)selfDetailExpBtnBg
{
    return [UIImage imageNamed:@"self_detail_exp_btn_bg.png"];
}

- (UIImage*)customInfoViewMainBgImage;
{
    return [[self fixedImageNamed:@"common_dialog_bg"] stretchableImageWithLeftCapWidth:0 topCapHeight:60];
}

- (UIImage *)draftsBoxBgImage
{
    return [[self fixedImageNamed:@"all_my_words_bg"] stretchableImageWithLeftCapWidth:0 topCapHeight:240];
}

- (UIImage*)settingCellTopBgImage
{
    return [UIImage imageNamed:@"user_setting_cell_up.png"];
}
- (UIImage*)settingCellMiddleBgImage
{
    return [UIImage imageNamed:@"user_setting_cell_middle.png"];
}
- (UIImage*)settingCellBottomBgImage
{
    return [UIImage imageNamed:@"user_setting_cell_down.png"];
}
- (UIImage*)settingCellOneBgImage
{
    return [UIImage imageNamed:@"user_setting_cell_one.png"];
}
- (UIImage*)navigatorRightBtnImage
{
    return [UIImage imageNamed:@"draw_button_normal@2x.png"];
}

- (UIImage *)splitPhoto
{
    return [UIImage imageNamed:@"split_photo@2x.png"];
}

- (UIImage *)placeholderPhoto
{
    return [UIImage imageNamed:@"placeholder_photo@2x.png"];
}

- (UIImage *)commonDialogHeaderImage
{
    return [UIImage imageNamed:@"common_dialog_head_bg@2x.png"];
}

- (UIImage *)drawToolUpPanelLeftArrowBg
{
    return [UIImage imageNamed:@"draw_up_panel_bg_left_arrow@2x.png"];
}
- (UIImage *)drawToolUpPanelRightArrowBg
{
    return [UIImage imageNamed:@"draw_up_panel_bg_right_arrow@2x.png"];
}


- (UIImage *)polygonSelectorImage
{
    return [UIImage imageNamed:@"selector_polygon@2x.png"];
}
- (UIImage *)pathSelectorImage
{
    return [UIImage imageNamed:@"selector_path@2x.png"];
}
- (UIImage *)ellipseSelectorImage
{
    return [UIImage imageNamed:@"selector_ellipse@2x.png"];
}
- (UIImage *)rectangeSelectorImage
{
    return [UIImage imageNamed:@"selector_rectangle@2x.png"];
}

- (UIColor *)drawBGColor
{
    UIImage *image = [UIImage imageNamed:@"draw_main_bg@2x.jpg"];
    return [UIColor colorWithPatternImage:image];
}

- (UIImage *)drawBackImage
{
    return [UIImage imageNamed:@"draw_page_back@2x.png"];
}

- (UIImage *)runAwayImage
{
    return [UIImage imageNamed:@"run@2x.png"];
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGSize size = CGSizeMake(2, 2);
    UIImage *image;
    UIGraphicsBeginImageContext(size);
    [color setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, size.width, size.height));
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image stretchableImageWithLeftCapWidth:size.width/2 topCapHeight:size.height/2];
}

- (void)setButtonStyle:(UIButton *)button
            titleColor:(UIColor *)titleColor
                  font:(UIFont *)font
           normalColor:(UIColor *)normalColor
         selectedColor:(UIColor *)selectedColor
      highlightedColor:(UIColor *)highlightedColor;
{                                                           
    [button setTitleColor:titleColor
               forState:UIControlStateNormal];              
    button.titleLabel.font = font;                     
    
    [button.layer setCornerRadius:TEXT_VIEW_CORNER_RADIUS];   
    [button.layer setMasksToBounds:YES];                      
    [button setBackgroundImage:IMAGE_FROM_COLOR(normalColor) forState:UIControlStateNormal];           
    [button setBackgroundImage:IMAGE_FROM_COLOR(selectedColor) forState:UIControlStateSelected];        
    [button setBackgroundImage:IMAGE_FROM_COLOR(highlightedColor) forState:UIControlStateHighlighted];    
}

@end

