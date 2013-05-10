//
//  LittleGeeImageManager.m
//  Draw
//
//  Created by Kira on 13-5-10.
//
//

#import "LittleGeeImageManager.h"
#import "SynthesizeSingleton.h"

@implementation LittleGeeImageManager

SYNTHESIZE_SINGLETON_FOR_CLASS(LittleGeeImageManager)

- (UIImage*)drawToBtnBackgroundImage
{
    return [UIImage imageNamed:@"user_detail_purple_btn_bg.png"];
}
- (UIImage*)draftBtnBackgroundImage
{
    return [UIImage imageNamed:@"user_detail_yellow_btn_bg.png"];
}
- (UIImage*)beginBtnBackgroundImage
{
    return [UIImage imageNamed:@"user_detail_btn_bg.png"];
}
- (UIImage*)contestBtnBackgroundImage
{
    return [UIImage imageNamed:@"user_detail_red_btn_bg.png"];
}

@end
