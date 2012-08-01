//
//  DiceImageManager.h
//  Draw
//
//  Created by 小涛 王 on 12-7-28.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiceImageManager : NSObject

+ (DiceImageManager*)defaultManager;

- (UIImage *)roomListBgImage;
- (UIImage *)createRoomBtnBgImage;
- (UIImage *)graySafaImage;
- (UIImage *)greenSafaImage;
- (UIImage *)diceImageWithDice:(int)dice;
- (UIImage *)openDiceImageWithDice:(int)dice;
- (UIImage *)toolBackground;
- (UIImage *)toolEnableCountBackground;
- (UIImage *)toolDisableCountBackground;

@end
