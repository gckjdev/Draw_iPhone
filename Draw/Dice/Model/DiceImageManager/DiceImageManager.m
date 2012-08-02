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
    return [UIImage strectchableImageName:@"dice_gray_safa.png"];
}

- (UIImage *)greenSafaImage
{
    return nil;
}

- (UIImage *)diceImageWithDice:(int)dice
{
    UIImage *image;
    
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

- (UIImage *)toolBackgroundImage
{
    return [UIImage strectchableImageName:@"tools_bg.png" leftCapWidth:14 topCapHeight:14];    
}

- (UIImage *)diceCountSelectedBtnBgImage
{
    return [UIImage imageNamed:@"bell_amount.png"];
}

- (UIImage *)diceSeletedBgImage
{
    return [UIImage imageNamed:@"bell_selectedbg.png"];

}


@end
