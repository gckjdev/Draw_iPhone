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

- (UIImage*)showCardButtonBgImage;

- (UIImage*)counterImageForCounter:(int)counter;

@end
