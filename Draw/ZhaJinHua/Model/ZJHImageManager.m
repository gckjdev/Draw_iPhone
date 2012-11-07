//
//  ZJHImageManager.m
//  Draw
//
//  Created by Kira on 12-10-25.
//
//

#import "ZJHImageManager.h"
#import "ZhaJinHua.pb.h"
#import "ShareImageManager.h"

static ZJHImageManager* shareInstance;

@implementation ZJHImageManager

+ (ZJHImageManager*)defaultManager
{
    if (shareInstance == nil) {
        shareInstance = [[ZJHImageManager alloc] init];
    }
    return shareInstance;
}

- (UIImage*)pokerRankImage:(Poker*)poker
{
    switch (poker.suit) {
        case PBPokerSuitPokerSuitHeart:
        case PBPokerSuitPokerSuitDiamond:
            return [self redPokerRankImage:poker];
            break;
            
        case PBPokerSuitPokerSuitSpade:
        case PBPokerSuitPokerSuitClub:
            return [self blackPokerRankImage:poker];
            
            break;
            
        default:
            return nil;
            break;
    }
}

- (UIImage*)pokerSuitImage:(Poker*)poker
{
    switch (poker.suit) {
        case PBPokerSuitPokerSuitSpade:
            return [UIImage imageNamed:@"poker_suit_spade.png"];
            break;
            
        case PBPokerSuitPokerSuitHeart:
            return [UIImage imageNamed:@"poker_suit_heart.png"];
            break;
            
        case PBPokerSuitPokerSuitClub:
            return [UIImage imageNamed:@"poker_suit_club.png"];
            break;
            
        case PBPokerSuitPokerSuitDiamond:
            return [UIImage imageNamed:@"poker_suit_diamond.png"];
            break;
            
        default:
            return nil;
            break;
    }
}

- (UIImage*)pokerBodyImage:(Poker*)poker
{
    switch (poker.rank) {
        case PBPokerRankPokerRank2:
        case PBPokerRankPokerRank3:
        case PBPokerRankPokerRank4:
        case PBPokerRankPokerRank5:
        case PBPokerRankPokerRank6:
        case PBPokerRankPokerRank7:
        case PBPokerRankPokerRank8:
        case PBPokerRankPokerRank9:
        case PBPokerRankPokerRank10:
        case PBPokerRankPokerRankA:
            return [self pokerBodyImageWithPokerSuit:poker.suit];
            break;
            
        case PBPokerRankPokerRankJ:
            return [UIImage imageNamed:@"poker_body_J.png"];
            break;
            
        case PBPokerRankPokerRankQ:
            return [UIImage imageNamed:@"poker_body_Q.png"];
            break;
            
        case PBPokerRankPokerRankK:
            return [UIImage imageNamed:@"poker_body_K.png"];
            break;
            
        default:
            return nil;
            break;
    }
}

- (UIImage*)pokerTickImage
{
    return [UIImage imageNamed:@""];
}

- (UIImage*)pokerFrontBgImage
{
    return [UIImage imageNamed:@"poker_front_bg.png"];
}

- (UIImage*)pokerBackImage
{
    return [UIImage imageNamed:@"poker_back_bg.png"];
}

- (UIImage*)pokerFoldBackImage
{
    return [UIImage imageNamed:@"poker_fold_back_bg.png"];
}

- (UIImage*)pokerLoseBackImage{
    return [UIImage imageNamed:@"poker_lose_back_bg.png"];
}

- (UIImage*)showCardButtonBgImage
{
    return [UIImage imageNamed:@"show_card_button.png"];
}

- (UIImage*)chipImageForChipValue:(int)chipValue;
{
    switch (chipValue) {
        case 5:
            return [UIImage imageNamed:@"chip_5@2x.png"];
            break;
            
        case 10:
            return [UIImage imageNamed:@"chip_10@2x.png"];
            break;
            
        case 25:
            return [UIImage imageNamed:@"chip_25@2x.png"];
            break;
            
        case 50:
            return [UIImage imageNamed:@"chip_50@2x.png"];
            break;
            
        case 100:
            return [UIImage imageNamed:@"chip_100@2x.png"];
            break;
            
        case 250:
            return [UIImage imageNamed:@"chip_250@2x.png"];
            break;
            
        case 500:
            return [UIImage imageNamed:@"chip_500@2x.png"];
            break;
            
        case 1000:
            return [UIImage imageNamed:@"chip_1000@2x.png"];
            break;
            
        default:
            return nil;
            break;
    }
}

- (UIImage*)chipsSelectViewBgImage
{
    return [UIImage imageNamed:@""];
}


#pragma mark - pravite methods

- (UIImage *)redPokerRankImage:(Poker*)poker
{
    switch (poker.rank) {
            
        case PBPokerRankPokerRank2:
            return [UIImage imageNamed:@"poker_rank_red_2.png"];
            break;
            
        case PBPokerRankPokerRank3:
            return [UIImage imageNamed:@"poker_rank_red_3.png"];
            break;
            
        case PBPokerRankPokerRank4:
            return [UIImage imageNamed:@"poker_rank_red_4.png"];
            break;
            
        case PBPokerRankPokerRank5:
            return [UIImage imageNamed:@"poker_rank_red_5.png"];
            break;
            
        case PBPokerRankPokerRank6:
            return [UIImage imageNamed:@"poker_rank_red_6.png"];
            break;
            
        case PBPokerRankPokerRank7:
            return [UIImage imageNamed:@"poker_rank_red_7.png"];
            break;
            
        case PBPokerRankPokerRank8:
            return [UIImage imageNamed:@"poker_rank_red_8.png"];
            break;
            
        case PBPokerRankPokerRank9:
            return [UIImage imageNamed:@"poker_rank_red_9.png"];
            break;
            
        case PBPokerRankPokerRank10:
            return [UIImage imageNamed:@"poker_rank_red_10.png"];
            break;
            
        case PBPokerRankPokerRankJ:
            return [UIImage imageNamed:@"poker_rank_red_J.png"];
            break;
            
        case PBPokerRankPokerRankQ:
            return [UIImage imageNamed:@"poker_rank_red_Q.png"];
            break;
            
        case PBPokerRankPokerRankK:
            return [UIImage imageNamed:@"poker_rank_red_K.png"];
            break;
            
        case PBPokerRankPokerRankA:
            return [UIImage imageNamed:@"poker_rank_red_A.png"];
            break;
            
        default:
            return nil;
            break;
    }
}

- (UIImage *)blackPokerRankImage:(Poker*)poker
{
    switch (poker.rank) {
            
        case PBPokerRankPokerRank2:
            return [UIImage imageNamed:@"poker_rank_black_2.png"];
            break;
            
        case PBPokerRankPokerRank3:
            return [UIImage imageNamed:@"poker_rank_black_3.png"];
            break;
            
        case PBPokerRankPokerRank4:
            return [UIImage imageNamed:@"poker_rank_black_4.png"];
            break;
            
        case PBPokerRankPokerRank5:
            return [UIImage imageNamed:@"poker_rank_black_5.png"];
            break;
            
        case PBPokerRankPokerRank6:
            return [UIImage imageNamed:@"poker_rank_black_6.png"];
            break;
            
        case PBPokerRankPokerRank7:
            return [UIImage imageNamed:@"poker_rank_black_7.png"];
            break;
            
        case PBPokerRankPokerRank8:
            return [UIImage imageNamed:@"poker_rank_black_8.png"];
            break;
            
        case PBPokerRankPokerRank9:
            return [UIImage imageNamed:@"poker_rank_black_9.png"];
            break;
            
        case PBPokerRankPokerRank10:
            return [UIImage imageNamed:@"poker_rank_black_10.png"];
            break;
            
        case PBPokerRankPokerRankJ:
            return [UIImage imageNamed:@"poker_rank_black_J.png"];
            break;
            
        case PBPokerRankPokerRankQ:
            return [UIImage imageNamed:@"poker_rank_black_Q.png"];
            break;
            
        case PBPokerRankPokerRankK:
            return [UIImage imageNamed:@"poker_rank_black_K.png"];
            break;
            
        case PBPokerRankPokerRankA:
            return [UIImage imageNamed:@"poker_rank_black_A.png"];
            break;
            
        default:
            return nil;
            break;
    }
}

- (UIImage*)pokerBodyImageWithPokerSuit:(PBPokerSuit)suit
{
    switch (suit) {
        case PBPokerSuitPokerSuitSpade:
            return [UIImage imageNamed:@"poker_body_spade.png"];
            break;
            
        case PBPokerSuitPokerSuitHeart:
            return [UIImage imageNamed:@"poker_body_heart.png"];
            break;
            
        case PBPokerSuitPokerSuitClub:
            return [UIImage imageNamed:@"poker_body_club.png"];
            break;
            
        case PBPokerSuitPokerSuitDiamond:
            return [UIImage imageNamed:@"poker_body_diamond.png"];
            break;
            
        default:
            return nil;
            break;
    }
}

- (UIImage*)noUserAvatarBackground
{
    return [UIImage imageNamed:@"avatar_default.png"];
}
- (UIImage*)avatarBackground
{
    return [UIImage imageNamed:@"zjh_other_plyer_avatar.png"];
}
- (UIImage*)myAvatarBackground
{
    return [UIImage imageNamed:@"zjh_my_avatar_bg.png"];
}


- (UIImage*)moneyTreeImage
{
    return [UIImage imageNamed:@"tree.png"];
}

- (UIImage*)betBtnBgImage
{
    return [UIImage imageNamed:@"zjh_bet@2x.png"];
}

- (UIImage*)raiseBetBtnBgImage
{
    return [UIImage imageNamed:@"zjh_raise_bet@2x.png"];
}


- (UIImage*)autoBetBtnBgImage
{
    return [UIImage imageNamed:@"zjh_auto_bet@2x.png"];
}


- (UIImage*)compareCardBtnBgImage
{
    return [UIImage imageNamed:@"zjh_compare_card@2x.png"];
}


- (UIImage*)checkCardBtnBgImage
{
    return [UIImage imageNamed:@"zjh_check_card@2x.png"];
}


- (UIImage*)foldCardBtnBgImage
{
    return [UIImage imageNamed:@"zjh_fold_card@2x.png"];
}

- (UIImage*)betBtnDisableBgImage
{
    return [UIImage imageNamed:@"zjh_bet_disable@2x.png"];
}

- (UIImage*)raiseBetBtnDisableBgImage
{
    return [UIImage imageNamed:@"zjh_raise_bet_disable@2x.png"];
}


- (UIImage*)autoBetBtnDisableBgImage
{
    return [UIImage imageNamed:@"zjh_auto_bet_disable@2x.png"];
}


- (UIImage*)compareCardBtnDisableBgImage
{
    return [UIImage imageNamed:@"zjh_compare_card_disable@2x.png"];
}


- (UIImage*)checkCardBtnDisableBgImage
{
    return [UIImage imageNamed:@"zjh_check_card_disable@2x.png"];
}


- (UIImage*)foldCardBtnDisableBgImage
{
    return [UIImage imageNamed:@"zjh_fold_card_disable@2x.png"];
}




@end
