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
    return [UIImage imageNamed:[UIImage fixImageName:@"little_gee_pop_options_bbs"]];
}
- (UIImage*)popOptionsContestImage
{
    return [UIImage imageNamed:[UIImage fixImageName:@"little_gee_pop_options_contest"]];
}
- (UIImage*)popOptionsGameImage
{
    return [UIImage imageNamed:[UIImage fixImageName:@"little_gee_pop_options_game"]];
}
- (UIImage*)popOptionsIngotImage
{
    return [UIImage imageNamed:[UIImage fixImageName:@"little_gee_pop_options_ingot"]];
}
- (UIImage*)popOptionsMoreImage
{
    return [UIImage imageNamed:[UIImage fixImageName:@"little_gee_pop_options_more"]];
}
- (UIImage*)popOptionsNoticeImage
{
    return [UIImage imageNamed:[UIImage fixImageName:@"little_gee_pop_options_notice"]];
}
- (UIImage*)popOptionsSearchImage
{
    return [UIImage imageNamed:[UIImage fixImageName:@"little_gee_pop_options_search"]];
}
- (UIImage*)popOptionsShopImage
{
    return [UIImage imageNamed:[UIImage fixImageName:@"little_gee_pop_options_shop"]];
    
}

- (UIImage*)popOptionsSelfImage
{
    return [UIImage imageNamed:[UIImage fixImageName:@"little_gee_pop_options_self"]];
}

@end
