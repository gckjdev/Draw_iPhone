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
        [_defaultManager clearFeedCache];
    }
    
    return _defaultManager;
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
    return [UIImage strectchableImageName:@"inputbg.png"];
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

- (UIImage *)myFoucsImage
{
    return [UIImage strectchableImageName:@"myfoucs.png"];
}

- (UIImage *)myFoucsSelectedImage
{
     return [UIImage strectchableImageName:@"myfoucs_selected.png"];
}

- (UIImage *)foucsMeImage
{
    return [UIImage strectchableImageName:@"foucsme.png"];
}

- (UIImage *)foucsMeSelectedImage
{
    return [UIImage strectchableImageName:@"foucsme_selected.png"];
}

- (UIImage *)middleTabImage
{
    return [UIImage strectchableImageName:@"middle_tab.png"];
}
- (UIImage *)middleTabSelectedImage
{
    return [UIImage strectchableImageName:@"middle_tab_selected.png"];
}


- (UIImage *)normalButtonImage
{
    return [UIImage strectchableImageName:@"normal_button.png"];
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
    return [UIImage imageNamed:@"pen1.png"];    
}
- (UIImage *)waterPenImage
{
    return [UIImage imageNamed:@"pen2.png"];        
}
- (UIImage *)penImage
{
    return [UIImage imageNamed:@"pen3.png"];
}
- (UIImage *)iceImage
{
    return [UIImage imageNamed:@"pen4.png"];    
}
- (UIImage *)quillImage
{
    return [UIImage imageNamed:@"pen5.png"];    
}
- (UIImage *)eraserImage
{
    return [UIImage imageNamed:@"eraser.png"];    
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

- (UIImage *)fixedImageNamed:(NSString *)name
{
    NSString *temp = name;
    if ([DeviceDetection isIPAD]) {
        temp = [NSString stringWithFormat:@"%@@2x.png",name];        
    }else{

    }
    return [UIImage imageNamed:temp];
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
- (UIImage *)brushPen
{
    return [self fixedImageNamed:@"brush_pen"];
}
- (UIImage *)removeAd
{
    return [self fixedImageNamed:@"clean_ad"];
}
- (UIImage *)icePen
{
    return [self fixedImageNamed:@"cones_pen"];
}
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
- (UIImage *)quillPen
{
    return [self fixedImageNamed:@"quill_pen"];
}

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

- (UIImage*)waterPen
{
    return [self fixedImageNamed:@"mike_pen"];
}

- (UIImage*)dice
{
    return [UIImage imageNamed:@"mike_pen"];
}

- (UIImage*)backButtonImage
{
    return [self fixedImageNamed:@"back"];
}

- (UIImage *)shareDrawButtonImage
{
    return [UIImage imageNamed:@"draw_share.png"];
}

- (UIImage *)defaultBoardImage
{
    if (isDiceApp()) {
//        return [UIImage imageNamed:@"draw_share.png"];       
    }
    return [UIImage imageNamed:@"default_board.png"];    
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

//for bottom menu image.
- (UIImage *)settingsMenuImage
{
    return [self fixedImageNamed:@"small_setting"];
}
- (UIImage *)opusMenuImage
{
    return [self fixedImageNamed:@"small_share"];    
}
- (UIImage*)friendMenuImage
{
    return [self fixedImageNamed:@"small_friend_manager"];
}
- (UIImage *)chatMenuImage
{
    return [self fixedImageNamed:@"small_chat"];
}
- (UIImage *)feedbackMenuImage
{
    return [self fixedImageNamed:@"small_feedback"];
}
- (UIImage*)checkInMenuImage
{
    return [self fixedImageNamed:@"small_sign"];
}


#pragma mark - save and get temp image.


#define TEMP_FEED_IMAGE_DIR @"feed_image"
#define TEMP_IMAGE_SUFFIX @".png"

- (NSString *)feedImageDir
{
    NSString *dir = [[FileUtil getAppHomeDir] stringByAppendingPathComponent:TEMP_FEED_IMAGE_DIR];    
    BOOL flag = [FileUtil createDir:dir];
    if (flag) {
        return dir;
    }
    return nil;
}

- (NSString *)constructImagePath:(NSString *)imageName
{
    NSString *dir = [self feedImageDir];
    if (dir) {
        NSString *imgName = [NSString stringWithFormat:@"%@%@", imageName, TEMP_IMAGE_SUFFIX];
        NSString *uniquePath=[dir stringByAppendingPathComponent:imgName];
        NSLog(@"construct path = %@",uniquePath);
        return uniquePath;        
    }
    return nil;
}


- (UIImage *)pickToolBackground
{
    return [UIImage strectchableImageName:@"popuptools_bg.png"];    
}


- (void)saveFeedImage:(UIImage *)image 
    withImageName:(NSString *)imageName 
             asyn:(BOOL)asyn
{
    if (image == nil || [imageName length] == 0) {
        return;
    }
    void (^handleBlock)()= ^(){
        NSString *uniquePath = [self constructImagePath:imageName];
        if (uniquePath == nil) {
            return;
        }
        NSData* imageData = UIImagePNGRepresentation(image);
        BOOL result=[imageData writeToFile:uniquePath atomically:YES];
        PPDebug(@"<ShareImageManager> asyn save image to path:%@ result:%d , canRead:%d", uniquePath, result, [[NSFileManager defaultManager] fileExistsAtPath:uniquePath]);
    };
    
    if (asyn) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        if (queue == NULL){
            return;
        }
        dispatch_async(queue, handleBlock);        
    }else{
        handleBlock();
    }
}
- (UIImage *)getImageWithFeedId:(NSString *)feedId
{
    PPDebug(@"<ShareImageManager> get image, image name = %@", feedId);
    if ([feedId length] == 0) {
        return nil;
    }
    NSString *uniquePath = [self constructImagePath:feedId];
    if (uniquePath == nil) {
        return nil;
    }
    UIImage *image = [UIImage imageWithContentsOfFile:uniquePath];
    return image;
}


#define CLEAR_CACHE_INTERVAL 3600 * 24 * 10
#define LAST_CLEAR_CACHE_KEY @"last_clear"

- (void)clearFeedCache
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //back ground run
    if (queue) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDate *lastClearDate = [userDefaults objectForKey:LAST_CLEAR_CACHE_KEY];
        NSDate *date = [NSDate date];
        if (lastClearDate != nil) {

            NSTimeInterval interval = [date timeIntervalSinceDate:lastClearDate];
            PPDebug(@"<clearFeedCache>: interval = %f", interval);
            if (interval < CLEAR_CACHE_INTERVAL) {
                PPDebug(@"interval = %f, < %d. need not clear date", interval, CLEAR_CACHE_INTERVAL);
                return;
            }
        }
        PPDebug(@"<clearFeedCache> start to clear the feed cache");
        [FileUtil removeFilesBelowDir:[self feedImageDir] timeIntervalSinceNow:CLEAR_CACHE_INTERVAL];    
        [userDefaults setObject:date forKey:LAST_CLEAR_CACHE_KEY];
        [userDefaults synchronize];
        
    }
}

- (UIImage *)unloadBg
{
    return [UIImage imageNamed:@"unloadbg.png"];
}


@end

