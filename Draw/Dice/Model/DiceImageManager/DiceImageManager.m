//
//  DiceImageManager.m
//  Draw
//
//  Created by 小涛 王 on 12-7-28.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceImageManager.h"
#import "UIImageUtil.h"

static DiceImageManager *_defaultManager = nil;

@implementation DiceImageManager

+ (DiceImageManager*)defaultManager
{
    if (_defaultManager == nil){
        _defaultManager = [[DiceImageManager alloc] init];
    }
    
    return _defaultManager;
}

- (UIImage *)roomListBgImage
{
    return [UIImage imageNamed:@"dice_room_background.png"];
}

- (UIImage *)createRoomBtnBgImage
{
    return [UIImage strectchableImageName:@"dice_create_room.png" leftCapWidth:15];
}

- (UIImage *)graySafaImage
{
    return [UIImage strectchableImageName:@"dice_gray_safa@2x.png"];
}

- (UIImage *)greenSafaImage
{
    return [UIImage strectchableImageName:@"dice_green_safa@2x.png"];
}

- (UIImage *)blueSafaImage
{
    return [UIImage strectchableImageName:@"dice_blue_safa@2x.png"];
}

- (UIImage *)diceImageWithDice:(int)dice
{
    UIImage *image = nil;
    
    switch (dice) {
        case 1:
            image = [UIImage imageNamed:@"bell_1@2x.png"];
            break;
            
        case 2:
            image = [UIImage imageNamed:@"bell_2@2x.png"];
            break;
            
        case 3:
            image = [UIImage imageNamed:@"bell_3@2x.png"];
            break;
            
        case 4:
            image = [UIImage imageNamed:@"bell_4@2x.png"];
            break;
            
        case 5:
            image = [UIImage imageNamed:@"bell_5@2x.png"];
            break;
            
        case 6:
            image = [UIImage imageNamed:@"bell_6@2x.png"];
            break;
            
        default:
            break;
    }
    
    return image;
}

- (UIImage *)openDiceImageWithDice:(int)dice
{
    UIImage *image = nil;
    
    switch (dice) {
        case 1:
            image = [UIImage imageNamed:@"open_bell_1bigx2.png"];
            break;
            
        case 2:
            image = [UIImage imageNamed:@"open_bell_2bigx2.png"];
            break;
            
        case 3:
            image = [UIImage imageNamed:@"open_bell_3bigx2.png"];
            break;
            
        case 4:
            image = [UIImage imageNamed:@"open_bell_4bigx2.png"];
            break;
            
        case 5:
            image = [UIImage imageNamed:@"open_bell_5bigx2.png"];
            break;
            
        case 6:
            image = [UIImage imageNamed:@"open_bell_6bigx2.png"];
            break;
            
        default:
            break;
    }
    
    return image;
}

- (UIImage *)toolBackground
{
    return [UIImage strectchableImageName:@"tools_bg.png" leftCapWidth:14 topCapHeight:14];    
}

- (UIImage *)toolEnableCountBackground
{
    return [UIImage imageNamed:@"tools_enable.png"];
}

- (UIImage *)toolDisableCountBackground
{
    return [UIImage imageNamed:@"tools_disable.png"];
}

- (UIImage *)diceCountBtnBgImage
{
    return [UIImage imageNamed:@"bell_amount@2x.png"];
}

- (UIImage *)diceCountSelectedBtnBgImage
{
    return [UIImage imageNamed:@"bell_amount_selected@2x.png"];

}

- (UIImage *)diceSeletedBgImage
{
    return [UIImage imageNamed:@"bell_selectedbg.png"];
}

- (UIImage *)diceBottomImage
{
    return [UIImage imageNamed:@"dice_bottombig.png"];
}

- (UIImage *)wildsBgImage
{
    return [UIImage imageNamed:@"zhai_bg.png"];
}

- (UIImage *)openDiceButtonBgImage
{
    return [UIImage strectchableImageName:@"open.png" leftCapWidth:15];
}

- (UIImage *)whiteSofaImage
{
    return [UIImage imageNamed:@"waiting_user.png"];
}

- (UIImage *)resultDiceBgImage
{
    return [UIImage imageNamed:@"open_bell_counton.png"];
}


@end
