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
    return [UIImage imageNamed:@"coin.png"];
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
    return [UIImage imageNamed:@"print_tip.png"];        
}
- (UIImage *)drawingMarkLargeImage
{
    return [UIImage imageNamed:@"print_tipbig.png"];            
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
    return [UIImage imageNamed:@"reward_coin.png"];
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
    return [UIImage imageNamed:@"small_coin.png"];
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

- (UIImage *)drawColorBG; //draw_color_bg@2x.png
{
    return [self fixedAndStrectchableImageNamed:@"draw_color_bg"];
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
    return [UIImage imageNamed:@"logout.png"];
}
- (UIImage*)commonDialogLeftBtnImage
{
    return [self greenImage];
}
- (UIImage*)commonDialogRightBtnImage
{
    return [self redImage];
}

- (UIImage *)inputDialogBgImage
{
    return [UIImage imageNamed:@"logout.png"];
}

- (UIImage*)inputDialogInputBgImage
{
    //    return [UIImage strectchableImageName:@"zjh_input_bg.png" leftCapWidth:15 topCapHeight:15];
    return [self inputImage];
}
- (UIImage*)inputDialogLeftBtnImage
{
    return [self greenImage];
}
- (UIImage*)inputDialogRightBtnImage
{
    return [self redImage];
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
@end

