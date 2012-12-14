//
//  ZJHSoundManager.h
//  Draw
//
//  Created by Kira on 12-11-7.
//
//

#import <Foundation/Foundation.h>

@interface ZJHSoundManager : NSObject

+ (ZJHSoundManager*)defaultManager;

- (NSURL*)betSoundEffect;
- (NSURL*)betHumanSound:(BOOL)gender;
- (NSURL*)checkCardSoundEffect;
- (NSURL*)checkCardHumanSound:(BOOL)gender;
- (NSURL*)compareCardSoundEffect;
- (NSURL*)compareCardHumanSound:(BOOL)gender;
- (NSURL*)foldCardSoundEffect;
- (NSURL*)foldCardHumanSound:(BOOL)gender;
- (NSURL*)raiseBetSoundEffect;
- (NSURL*)raiseBetHumanSound:(BOOL)gender;
- (NSURL*)clickButtonSound;
- (NSURL*)dealCardAppear;
- (NSURL*)dealCard;
- (NSURL*)dealCardDisappear;
- (NSURL*)fireworks;
- (NSURL*)flee;
- (NSURL*)fullMoney;
- (NSURL*)gameBGM;
- (NSURL*)gameOver;
- (NSURL*)gameWin;
- (NSURL*)getChips;
- (NSURL*)fallingCoins;

@end
