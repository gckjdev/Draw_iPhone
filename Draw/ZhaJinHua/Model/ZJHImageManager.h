//
//  ZJHImageManager.h
//  Draw
//
//  Created by Kira on 12-10-25.
//
//

#import <Foundation/Foundation.h>
#import "Poker.h"

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

- (UIImage*)chipImageForChipValue:(int)chipValue;

- (UIImage*)chipsSelectViewBgImage;

- (UIImage*)noUserAvatarBackground;
- (UIImage*)avatarBackground;
- (UIImage*)myAvatarBackground;

- (UIImage*)moneyTreeImage;

@end
