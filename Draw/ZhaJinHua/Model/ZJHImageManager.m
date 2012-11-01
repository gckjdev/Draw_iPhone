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

- (UIImage*)counterImageForCounter:(int)counter
{
    return [[ShareImageManager defaultManager] coinImage];
}


@end
