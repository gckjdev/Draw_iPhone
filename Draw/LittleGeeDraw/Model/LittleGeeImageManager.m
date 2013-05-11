//
//  LittleGeeImageManager.m
//  Draw
//
//  Created by Kira on 13-5-10.
//
//

#import "LittleGeeImageManager.h"
#import "SynthesizeSingleton.h"
#import "UIImageUtil.h"

@implementation LittleGeeImageManager

SYNTHESIZE_SINGLETON_FOR_CLASS(LittleGeeImageManager)

- (UIImage*)drawToBtnBackgroundImage
{
    return [UIImage imageNamed:@"self_detail_ingot_btn_bg.png"];
}
- (UIImage*)draftBtnBackgroundImage
{
    return [UIImage imageNamed:@"self_detail_exp_btn_bg.png"];
}
- (UIImage*)beginBtnBackgroundImage
{
    return [UIImage imageNamed:@"self_detail_balance_btn_bg.png"];
}
- (UIImage*)contestBtnBackgroundImage
{
    return [UIImage imageNamed:@"user_detail_btn_bg.png"];
}
- (UIImage*)popOptionsBackgroundImage
{
    return [UIImage imageNamed:@"little_gee_pop_options_bg.png"];
}

- (UIImage*)popOptionsBbsImage
{
    return [UIImage imageNamed:@"little_gee_pop_options_bbs.png"];
}
- (UIImage*)popOptionsContestImage
{
    return [UIImage imageNamed:@"little_gee_pop_options_contest.png"];
}
- (UIImage*)popOptionsGameImage
{
    return [UIImage imageNamed:@"little_gee_pop_options_game.png"];
}
- (UIImage*)popOptionsIngotImage
{
    return [UIImage imageNamed:@"little_gee_pop_options_ingot.png"];
}
- (UIImage*)popOptionsMoreImage
{
    return [UIImage imageNamed:@"little_gee_pop_options_more.png"];
}
- (UIImage*)popOptionsNoticeImage
{
    return [UIImage imageNamed:@"little_gee_pop_options_notice.png"];
}
- (UIImage*)popOptionsSearchImage
{
    return [UIImage imageNamed:@"little_gee_pop_options_search.png"];
}
- (UIImage*)popOptionsShopImage
{
    return [UIImage imageNamed:@"little_gee_pop_options_shop.png"];
    
}

@end
