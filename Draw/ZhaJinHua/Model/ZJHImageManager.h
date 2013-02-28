//
//  ZJHImageManager.h
//  Draw
//
//  Created by Kira on 12-10-25.
//
//

#import <Foundation/Foundation.h>
#import "Poker.h"
#import "ZJHConstance.h"
#import "ImageManagerProtocol.h"

@interface ZJHImageManager : NSObject <ImageManagerProtocol>

+ (ZJHImageManager*)defaultManager;

- (UIImage*)pokerRankImage:(Poker*)poker;
- (UIImage*)pokerSuitImage:(Poker*)poker;
- (UIImage*)pokerBodyImage:(Poker*)poker;

- (UIImage*)pokerTickImage;
- (UIImage*)pokerFrontBgImage;
- (UIImage*)pokerBackImage;
- (UIImage*)pokerFoldBackImage;
- (UIImage*)pokerLoseBackImage;

- (UIImage*)showCardButtonBgImage;
- (UIImage *)twoButtonsHolderBgImage;
- (UIImage *)oneButtonHolderBgImage;
//- (UIImage*)showCardButtonDisableBgImage;
- (UIImage *)showCardFlagImage;


- (UIImage*)chipImageForChipValue:(int)chipValue;

- (UIImage*)chipsSelectViewBgImage;

- (UIImage*)noUserAvatarBackground;
- (UIImage*)noUserBigAvatarBackground;
- (UIImage*)avatarBackground;
- (UIImage*)myAvatarBackground;


- (UIImage*)moneyTreeImage;
- (UIImage*)bigMoneyTreeImage;
- (UIImage*)moneyTreeCoinLightImage;
- (UIImage*)moneyTreeCoinImage;

- (UIImage*)betBtnBgImage;
- (UIImage*)raiseBetBtnBgImage;
- (UIImage*)autoBetBtnBgImage;
- (UIImage*)autoBetBtnOnBgImage;
- (UIImage*)compareCardBtnBgImage;
- (UIImage*)checkCardBtnBgImage;
- (UIImage*)foldCardBtnBgImage;

- (UIImage*)betBtnDisableBgImage;
- (UIImage*)raiseBetBtnDisableBgImage;
- (UIImage*)autoBetBtnDisableBgImage;
- (UIImage*)compareCardBtnDisableBgImage;
- (UIImage*)checkCardBtnDisableBgImage;
- (UIImage*)foldCardBtnDisableBgImage;

- (UIImage*)bombImage;
- (UIImage*)bombImageLight;

- (UIImage*)vsImage;

- (UIImage *)chatMesssgeBgImage:(UserPosition)position;
- (UIImage *)betActionImage:(UserPosition)position;
- (UIImage *)raiseBetActionImage:(UserPosition)position;
- (UIImage *)checkCardActionImage:(UserPosition)position;
- (UIImage *)compareCardActionImage:(UserPosition)position;
- (UIImage *)foldCardActionImage:(UserPosition)position;

- (UIImage *)gameBgImage;
- (UIImage *)dualGameBgImage;

- (UIImage *)totalBetBgImage;
- (UIImage *)userTotalBetBgImage;
- (UIImage *)buttonsHolderBgImage;
- (UIImage *)runawayButtonImage;
- (UIImage *)settingButtonImage;
- (UIImage *)chatButtonImage;
- (UIImage *)cardTypeBgImage;

- (UIImage *)roomBackgroundImage;
- (UIImage *)roomTitleBgImage;
- (UIImage *)moneyTreePopupMessageBackground;

- (UIImage *)zjhCardTypesNoteBgImage;
- (UIImage *)specialCardTypeImage;

- (UIImage *)dispatcherImage;
- (UIImage*)ZJHUserInfoBackgroundImage;
- (UIImage *)coinsImage;

- (UIImage *)dialogBgImage;
- (UIImage *)dialogBtnImage;

- (UIImage *)inputDialogBgImage;

- (UIImage *)timeoutActionBetImage;
- (UIImage *)timeoutActionFoldImage;

@end
