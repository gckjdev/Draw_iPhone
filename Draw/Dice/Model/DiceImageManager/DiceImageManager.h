//
//  DiceImageManager.h
//  Draw
//
//  Created by 小涛 王 on 12-7-28.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageManagerProtocol.h"

@interface DiceImageManager : NSObject <ImageManagerProtocol>

+ (DiceImageManager*)defaultManager;

- (UIImage *)createRoomBtnBgImage;
- (UIImage *)graySafaImage;
- (UIImage *)greenSafaImage;
- (UIImage *)blueSafaImage;
- (UIImage *)diceImageWithDice:(int)dice;
- (UIImage *)openDiceImageWithDice:(int)dice;
- (UIImage *)toolBackgroundImage;
- (UIImage *)toolEnableCountBackground;
- (UIImage *)toolDisableCountBackground;

- (UIImage *)diceCountBtnBgImage;
- (UIImage *)diceCountSelectedBtnBgImage;

- (UIImage *)diceSeletedBgImage;
- (UIImage *)diceBottomImage;
- (UIImage *)wildsBgImage;
- (UIImage *)openDiceButtonBgImage;
- (UIImage *)whiteSofaImage;
- (UIImage *)resultDiceBgImage;
- (UIImage *)roomCellBackgroundImage;
- (UIImage *)fastGameBtnBgImage;
- (UIImage *)toolsItemBgImage;

- (UIImage *)closeButtonBackgroundImage;
- (UIImage *)faceBackgroundImage;
- (UIImage *)helpBackgroundImage;
- (UIImage *)inputBackgroundImage;
- (UIImage *)messageTipBackgroundImage;
- (UIImage *)popupBackgroundImage;
- (UIImage *)diceQuitBtnImage;
- (UIImage *)diceChatMsgBgImage;
- (UIImage *)diceExpressionBgImage;

- (UIImage *)diceMusicOnImage;
- (UIImage *)diceMusicOffImage;
- (UIImage *)diceAudioOnImage;
- (UIImage *)diceAudioOffImage;
- (UIImage *)maleImage;
- (UIImage *)femaleImage;

- (UIImage *)diceToolCutImage;
- (UIImage *)diceToolRollAgainImage;
- (UIImage *)diceToolCutImageForShop;
- (UIImage *)diceToolRollAgainImageForShop;

- (UIImage *)peekImage;
- (UIImage *)postponeImage;
- (UIImage *)urgeImage;
- (UIImage *)doubleKillImage;
- (UIImage *)turtleImage;
- (UIImage *)diceRobotImage;
- (UIImage *)reverseImage;


- (UIImage*)toShopImage:(UIImage*)image;


- (UIImage*)patriotDiceImage;
- (UIImage*)goldenDiceImage;
- (UIImage*)woodDiceImage;
- (UIImage*)blueCrystalDiceImage;
- (UIImage*)pinkCrystalDiceImage;
- (UIImage*)greenCrystalDiceImage;
- (UIImage*)purpleCrystalDiceImage;
- (UIImage*)blueDiamondDiceImage;
- (UIImage*)pinkDiamondDiceImage;
- (UIImage*)greenDiamondDiceImage;
- (UIImage*)purpleDiamondDiceImage;

- (UIImage *)betResultImage:(BOOL)win;

- (UIImage*)customDiceImageWithDiceName:(NSString*)name 
                                   dice:(int)dice;
- (UIImage*)customOpenDiceImageWithDiceName:(NSString*)name 
                                       dice:(int)dice;

- (UIImage *)diceNormalRoomListBgImage;
- (UIImage *)diceHighRoomListBgImage;
- (UIImage *)diceSuperHighRoomListBgImage;


- (UIImage *)diceNormalRoomTableImage;
- (UIImage *)diceHighRoomTableImage;
- (UIImage *)diceSuperHighRoomTableImage;

- (UIImage *)inputTextBgImage;
@end
