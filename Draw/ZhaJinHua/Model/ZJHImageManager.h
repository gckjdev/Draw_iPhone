//
//  ZJHImageManager.h
//  Draw
//
//  Created by Kira on 12-10-25.
//
//

#import <Foundation/Foundation.h>
#import "Poker.h"


typedef enum {
    UserPositionCenter = 0,
    UserPositionRight,
    UserPositionRightTop,
    UserPositionLeftTop,
    UserPositionLeft,
    UserPositionMax
}UserPosition;

@interface ZJHImageManager : NSObject

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
- (UIImage*)showCardButtonDisableBgImage;

- (UIImage*)chipImageForChipValue:(int)chipValue;

- (UIImage*)chipsSelectViewBgImage;

- (UIImage*)noUserAvatarBackground;
- (UIImage*)avatarBackground;
- (UIImage*)myAvatarBackground;


- (UIImage*)moneyTreeImage;

- (UIImage*)betBtnBgImage;
- (UIImage*)raiseBetBtnBgImage;
- (UIImage*)autoBetBtnBgImage;
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

- (UIImage*)vsImage;

- (UIImage *)betActionImage:(UserPosition)position;
- (UIImage *)raiseBetActionImage:(UserPosition)position;
- (UIImage *)checkCardActionImage:(UserPosition)position;
- (UIImage *)compareCardActionImage:(UserPosition)position;
- (UIImage *)foldCardActionImage:(UserPosition)position;



@end
