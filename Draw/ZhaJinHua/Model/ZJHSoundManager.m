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

- (NSString*)getBetSoundEffect
{
    
}

- (NSString*)getBetHumanSound:(BOOL)gender
{
    
}

- (NSString*)getCheckCardSoundEffect
{
    
}

- (NSString*)getCheckCardHumanSound:(BOOL)gender
{
    
}

- (NSString*)getCompareCardSoundEffect
{
    
}

- (NSString*)getCompareCardHumanSound:(BOOL)gender
{
    
}

- (NSString*)getFoldCardSoundEffect
{
    
}

- (NSString*)getFoldCardHumanSound:(BOOL)gender
{
    
}

- (NSString*)getRaiseBetSoundEffect
{
    
}

- (NSString*)getRaiseBetHumanSound:(BOOL)gender
{
    
}

- (NSString*)getClickButtonSound
{
    
}



@end
