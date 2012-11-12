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
    return @"bet.mp3";
}

- (NSString*)betHumanSound:(BOOL)gender
{
    if (gender) {
        return [NSString stringWithFormat:@"bet%d_M.mp3",rand()%3+1];
    } else {
        return [NSString stringWithFormat:@"bet%d_F.mp3",rand()%4+1];
    }
}

- (NSString*)checkCardSoundEffect
{
    return @"check_card.mp3";
}

- (NSString*)checkCardHumanSound:(BOOL)gender
{
    if (gender) {
        return @"check_card1_M.mp3";
    } else {
        return [NSString stringWithFormat:@"check_card%d_F.mp3",rand()%2+1];
    }
}

- (NSString*)compareCardSoundEffect
{
    return nil;
}

- (NSString*)compareCardHumanSound:(BOOL)gender
{
    if (gender) {
        return @"compare_card1_M.mp3";
    } else {
        return @"compare_card1_F.mp3";
    }
}

- (NSString*)foldCardSoundEffect
{
    return nil;
}

- (NSString*)foldCardHumanSound:(BOOL)gender
{
    if (gender) {
        return @"fold_card1_M.mp3";
    } else {
        return [NSString stringWithFormat:@"fold_card%d_F.mp3",rand()%2+1];
    }
}

- (NSString*)raiseBetSoundEffect
{
    return @"raise_bet.mp3";
}

- (NSString*)raiseBetHumanSound:(BOOL)gender
{
    if (gender) {
        return @"raise_bet1_M.mp3";
    } else {
        return @"raise_bet1_F.mp3";
    }
}

- (NSString*)clickButtonSound
{
    return @"click_button.mp3";
}

- (NSString*)dealCardAppear
{
    return @"dealer_appear.mp3";
}

- (NSString*)dealCard
{
    return @"deal_card.mp3";
}

- (NSString*)dealCardDisappear
{
    return @"dealer_disappear.mp3";
}

- (NSString*)fireworks
{
    return @"fireworks.mp3";
}

- (NSString*)flee
{
    return @"flee.mp3";
}

- (NSString*)fullMoney
{
    return @"full_monney.mp3";
}

- (NSString*)gameBGM
{
    return @"game_bg.mp3";
}

- (NSString*)gameOver
{
    return @"game_over.mp3";
}

- (NSString*)gameWin
{
    return @"game_win.mp3";
}

- (NSString*)getChips
{
    return @"get_chips.mp3";
}

@end
