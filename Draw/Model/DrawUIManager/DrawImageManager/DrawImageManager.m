//
//  DrawImageManager.m
//  Draw
//
//  Created by gamy on 12-12-8.
//
//

#import "DrawImageManager.h"
//#import "PPResourceService.h"
//#import "GameResource.h"
#import "ShareImageManager.h"
#import "UIImageUtil.h"

//DrawImageManager *_staticDrawImageManager;
static DrawImageManager * _staticDrawImageManager;

@interface DrawImageManager ()
{
 
}
@end

@implementation DrawImageManager

+ (id)defaultManager
{
    if (_staticDrawImageManager == nil) {
        _staticDrawImageManager = [[DrawImageManager alloc] init];
    }
    return _staticDrawImageManager;
}

- (id)init
{
    if (self = [super init]) {

    }
    return self;
}



- (NSString *)fixImageName:(NSString *)imageName
{
    if([DeviceDetection isIPAD]){
        return [NSString stringWithFormat:@"%@@2x",imageName];
    }
    return imageName;
}



- (UIImage *)stretchableImageWithImageName:(NSString *)name
                         leftCapWidthScale:(CGFloat)leftCapWidthScale //0.0-1.0
                         topCapHeightScale:(CGFloat)topCapHeightScale //0.0-1.0
{
    NSString *imageName = [self fixImageName:name];
    UIImage *image = [UIImage imageNamed:imageName];
    return [image stretchableImageWithLeftCapWidth:image.size.width * leftCapWidthScale
                                      topCapHeight:image.size.height * topCapHeightScale];
}


//Common
- (UIImage *)drawHomeBbs
{
    NSString *imageName = [self fixImageName:@"common_home_bbs"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)drawHomeHome{
    NSString *imageName = [self fixImageName:@"common_home_home"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)drawHomeMessage{
    NSString *imageName = [self fixImageName:@"common_home_message"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)drawHomeSetting{
    NSString *imageName = [self fixImageName:@"common_home_setting"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)drawHomeMe
{
    NSString *imageName = [self fixImageName:@"common_home_me"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)drawHomeFriend
{
    NSString *imageName = [self fixImageName:@"common_home_friend"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)drawHomeShop{
    NSString *imageName = [self fixImageName:@"draw_home_shop"];
    return [UIImage imageNamed:imageName];
}
- (UIImage*)drawHomeBigShop
{
    NSString *imageName = [self fixImageName:@"common_home_shop"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)diceHomeShop{
    NSString *imageName = [self fixImageName:@"common_home_shop"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)drawHomeMore
{
    NSString *imageName = [self fixImageName:@"draw_home_more"];
    return [UIImage imageNamed:imageName];
}

//Draw
- (UIImage *)drawHomeContest{
    NSString *imageName = [self fixImageName:@"draw_home_contest"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)drawHomeDraw{
    NSString *imageName = [self fixImageName:@"draw_home_draw"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)drawHomeGuess{
    NSString *imageName = [self fixImageName:@"draw_home_guess"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)drawHomeOnlineGuess{
    NSString *imageName = [self fixImageName:@"draw_home_online_guess"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)drawHomeOpus{
    NSString *imageName = [self fixImageName:@"draw_home_opus"];
    return [UIImage imageNamed:imageName];
}

- (UIImage *)drawHomeTimeline{
    NSString *imageName = [self fixImageName:@"draw_home_timeline"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)drawHomeTop{
    NSString *imageName = [self fixImageName:@"draw_home_top"];
    return [UIImage imageNamed:imageName];
}

- (UIImage *)drawAppsRecommand
{
    NSString *imageName = [self fixImageName:@"draw_home_apps"];
    return [UIImage imageNamed:imageName];
}

- (UIImage *)drawFreeCoins
{
    NSString *imageName = [self fixImageName:@"draw_home_free_coins"];
    return [UIImage imageNamed:imageName];
}

- (UIImage *)drawPlayWithFriend
{
    NSString *imageName = [self fixImageName:@"draw_home_play_with_friend"];
    return [UIImage imageNamed:imageName];
}

- (UIImage *)drawHomeBG
{
    return [self stretchableImageWithImageName:@"draw_home_bg"
                             leftCapWidthScale:0.5 topCapHeightScale:0.5];

}

//stretcable
- (UIImage *)drawHomeSplitline{
    return [self stretchableImageWithImageName:@"common_home_splitline"
                             leftCapWidthScale:0.5 topCapHeightScale:0.5];
}

- (UIImage *)drawHomeSplitline1{
    return [self stretchableImageWithImageName:@"draw_home_bottom_split"
                             leftCapWidthScale:0.5 topCapHeightScale:0.5];
}

- (UIImage *)drawHomeDisplayBG
{
    return [UIImage strectchableImageName:@"draw_home_displaybg@2x"];
}

- (UIImage *)zjhHomeHelp{
    NSString *imageName = [self fixImageName:@"zjh_home_help"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)zjhHomeNormalSite{
    NSString *imageName = [self fixImageName:@"zjh_home_normal_site"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)zjhHomeRichSite{
    NSString *imageName = [self fixImageName:@"zjh_home_rich_site"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)zjhHomeStart{
    NSString *imageName = [self fixImageName:@"zjh_home_start"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)zjhHomeVSSite{
    NSString *imageName = [self fixImageName:@"zjh_home_vs_site"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)zjhHomeCharge{
    NSString *imageName = [self fixImageName:@"zjh_home_charge"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)zjhHomeMore
{
    NSString *imageName = [self fixImageName:@"common_home_more"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)diceHomeMore
{
    NSString *imageName = [self fixImageName:@"common_home_more"];
    return [UIImage imageNamed:imageName];
}

- (UIImage *)zjhHomeFreeCoinBG
{
    return [self stretchableImageWithImageName:@"zjh_home_freecoin_bg"
                             leftCapWidthScale:0.5 topCapHeightScale:0.5];    
}



- (UIImage *)learnDrawBg
{
    NSString *imageName = [self fixImageName:@"learndraw_bg"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)learnDrawBottomBar
{
    NSString *imageName = [self fixImageName:@"learndraw_bottom_bar"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)learnDrawBottomSplit
{
    NSString *imageName = [self fixImageName:@"learndraw_bottom_split"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)learnDrawBought
{
    NSString *imageName = [self fixImageName:@"learndraw_bought"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)learnDrawDraft
{
    NSString *imageName = [self fixImageName:@"learndraw_draft"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)learnDrawDraw
{
    NSString *imageName = [self fixImageName:@"learndraw_draw"];
    return [UIImage imageNamed:imageName];
}
//- (UIImage *)learnDrawHome
//{
//    NSString *imageName = [self fixImageName:@"learndraw_home"];
//    return [UIImage imageNamed:imageName];
//}
- (UIImage *)learnDrawMark
{
    NSString *imageName = [self fixImageName:@"learndraw_mark"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)learnDrawMore
{
    NSString *imageName = [self fixImageName:@"learndraw_more"];
    return [UIImage imageNamed:imageName];
}
- (UIImage *)learnDrawShop
{
    NSString *imageName = [self fixImageName:@"learndraw_shop"];
    return [UIImage imageNamed:imageName];
}

//dream avatar
- (UIImage *)dreamAvatarDraw
{
    NSString *imageName = [self fixImageName:@"learndraw_draw"];
    return [UIImage imageNamed:imageName];
}

- (UIImage *)dreamAvatarDraft
{
    NSString *imageName = [self fixImageName:@"learndraw_draft"];
    return [UIImage imageNamed:imageName];
}

- (UIImage *)dreamAvatarShop
{
    NSString *imageName = [self fixImageName:@"learndraw_shop"];
    return [UIImage imageNamed:imageName];
}

- (UIImage *)dreamAvatarFreeIngot
{
    NSString *imageName = [self fixImageName:@"Learndraw_ingot"];
    return [UIImage imageNamed:imageName];
}

- (UIImage *)dreamAvatarMore
{
    NSString *imageName = [self fixImageName:@"learndraw_more"];
    return [UIImage imageNamed:imageName];
}


//dream lockscreen
- (UIImage *)dreamLockscreenDraft
{
    NSString *imageName = [self fixImageName:@"learndraw_draft"];
    return [UIImage imageNamed:imageName];
}

- (UIImage *)dreamLockscreenShop
{
    NSString *imageName = [self fixImageName:@"learndraw_shop"];
    return [UIImage imageNamed:imageName];
}

- (UIImage *)dreamLockscreenFreeIngot
{
    NSString *imageName = [self fixImageName:@"Learndraw_ingot"];
    return [UIImage imageNamed:imageName];
}

- (UIImage *)dreamLockscreenMore
{
    NSString *imageName = [self fixImageName:@"learndraw_more"];
    return [UIImage imageNamed:imageName];
}

- (UIImage*)littleGeeBottomSplit
{
    return nil;
}

@end
