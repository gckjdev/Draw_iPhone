//
//  ZJHSoundManager.m
//  Draw
//
//  Created by Kira on 12-11-7.
//
//

#import "ZJHSoundManager.h"

static ZJHSoundManager* shareInstance;

@implementation ZJHSoundManager

+ (ZJHSoundManager*)defaultManager
{
    if (shareInstance == nil) {
        shareInstance = [[ZJHSoundManager alloc] init];
    }
    return shareInstance;
}

- (NSString*)betSoundEffect
{
    
}

- (NSString*)betHumanSound:(BOOL)gender
{
    
}

- (NSString*)checkCardSoundEffect
{
    
}

- (NSString*)checkCardHumanSound:(BOOL)gender
{
    
}

- (NSString*)compareCardSoundEffect
{
    
}

- (NSString*)compareCardHumanSound:(BOOL)gender
{
    
}

- (NSString*)foldCardSoundEffect
{
    
}

- (NSString*)foldCardHumanSound:(BOOL)gender
{
    
}

- (NSString*)raiseBetSoundEffect
{
    
}

- (NSString*)raiseBetHumanSound:(BOOL)gender
{
    
}

- (NSString*)clickButtonSound
{
    
}

- (NSString*)dealCardAppear
{
    
}

- (NSString*)dealCard
{
    
}

- (NSString*)dealCardDisappear
{
    
}

- (NSString*)fireworks
{
    
}

- (NSString*)flee
{
    
}

- (NSString*)fullMoney
{
    
}

- (NSString*)gameBGM
{
    
}

- (NSString*)gameOver
{
    
}

- (NSString*)gameWin
{
    
}

- (NSString*)getChips
{
    
}

@end
