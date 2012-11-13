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
#import "PPResourceService.h"

@interface ZJHImageManager()
{
    PPResourceService *_resService;
}

@end

static ZJHImageManager* shareInstance;

@implementation ZJHImageManager

+ (ZJHImageManager*)defaultManager
{
    if (shareInstance == nil) {
        shareInstance = [[ZJHImageManager alloc] init];
    }
    return shareInstance;
}

- (id)init
{
    if (self = [super init]) {
        _resService = [PPResourceService defaultService];
    }
    
    return self;
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
            return [_resService imageByName:@"poker_suit_spade"];
            break;
            
        case PBPokerSuitPokerSuitHeart:
            return [_resService imageByName:@"poker_suit_heart"];
            break;
            
        case PBPokerSuitPokerSuitClub:
            return [_resService imageByName:@"poker_suit_club"];
            break;
            
        case PBPokerSuitPokerSuitDiamond:
            return [_resService imageByName:@"poker_suit_diamond"];
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
            return [_resService imageByName:@"poker_body_J"];
            break;
            
        case PBPokerRankPokerRankQ:
            return [_resService imageByName:@"poker_body_Q"];
            break;
            
        case PBPokerRankPokerRankK:
            return [_resService imageByName:@"poker_body_K"];
            break;
            
        default:
            return nil;
            break;
    }
}

- (UIImage*)pokerTickImage
{
    return [_resService imageByName:@""];
}

- (UIImage*)pokerFrontBgImage
{
    return [_resService imageByName:@"poker_front_bg"];
}

- (UIImage*)pokerBackImage
{
    return [_resService imageByName:@"poker_back_bg"];
}

- (UIImage*)pokerFoldBackImage
{
    return [_resService imageByName:@"poker_fold_back_bg"];
}

- (UIImage*)pokerLoseBackImage{
    return [_resService imageByName:@"poker_lose_back_bg"];
}

- (UIImage*)showCardButtonBgImage
{
    return [_resService imageByName:@"show_card_button"];
}

- (UIImage*)showCardButtonDisableBgImage
{
    return [_resService imageByName:@"show_card_button_disable"];
}

- (UIImage*)chipImageForChipValue:(int)chipValue;
{
    switch (chipValue) {
        case 5:
            return [_resService imageByName:@"chip_5"];
            break;
            
        case 10:
            return [_resService imageByName:@"chip_10"];
            break;
            
        case 25:
            return [_resService imageByName:@"chip_25"];
            break;
            
        case 50:
            return [_resService imageByName:@"chip_50"];
            break;
            
        case 100:
            return [_resService imageByName:@"chip_100"];
            break;
            
        case 250:
            return [_resService imageByName:@"chip_250"];
            break;
            
        case 500:
            return [_resService imageByName:@"chip_500"];
            break;
            
        case 1000:
            return [_resService imageByName:@"chip_1000"];
            break;
            
        default:
            return nil;
            break;
    }
}

- (UIImage*)chipsSelectViewBgImage
{
    return [_resService imageByName:@""];
}


#pragma mark - pravite methods

- (UIImage *)redPokerRankImage:(Poker*)poker
{
    switch (poker.rank) {
            
        case PBPokerRankPokerRank2:
            return [_resService imageByName:@"poker_rank_red_2"];
            break;
            
        case PBPokerRankPokerRank3:
            return [_resService imageByName:@"poker_rank_red_3"];
            break;
            
        case PBPokerRankPokerRank4:
            return [_resService imageByName:@"poker_rank_red_4"];
            break;
            
        case PBPokerRankPokerRank5:
            return [_resService imageByName:@"poker_rank_red_5"];
            break;
            
        case PBPokerRankPokerRank6:
            return [_resService imageByName:@"poker_rank_red_6"];
            break;
            
        case PBPokerRankPokerRank7:
            return [_resService imageByName:@"poker_rank_red_7"];
            break;
            
        case PBPokerRankPokerRank8:
            return [_resService imageByName:@"poker_rank_red_8"];
            break;
            
        case PBPokerRankPokerRank9:
            return [_resService imageByName:@"poker_rank_red_9"];
            break;
            
        case PBPokerRankPokerRank10:
            return [_resService imageByName:@"poker_rank_red_10"];
            break;
            
        case PBPokerRankPokerRankJ:
            return [_resService imageByName:@"poker_rank_red_J"];
            break;
            
        case PBPokerRankPokerRankQ:
            return [_resService imageByName:@"poker_rank_red_Q"];
            break;
            
        case PBPokerRankPokerRankK:
            return [_resService imageByName:@"poker_rank_red_K"];
            break;
            
        case PBPokerRankPokerRankA:
            return [_resService imageByName:@"poker_rank_red_A"];
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
            return [_resService imageByName:@"poker_rank_black_2"];
            break;
            
        case PBPokerRankPokerRank3:
            return [_resService imageByName:@"poker_rank_black_3"];
            break;
            
        case PBPokerRankPokerRank4:
            return [_resService imageByName:@"poker_rank_black_4"];
            break;
            
        case PBPokerRankPokerRank5:
            return [_resService imageByName:@"poker_rank_black_5"];
            break;
            
        case PBPokerRankPokerRank6:
            return [_resService imageByName:@"poker_rank_black_6"];
            break;
            
        case PBPokerRankPokerRank7:
            return [_resService imageByName:@"poker_rank_black_7"];
            break;
            
        case PBPokerRankPokerRank8:
            return [_resService imageByName:@"poker_rank_black_8"];
            break;
            
        case PBPokerRankPokerRank9:
            return [_resService imageByName:@"poker_rank_black_9"];
            break;
            
        case PBPokerRankPokerRank10:
            return [_resService imageByName:@"poker_rank_black_10"];
            break;
            
        case PBPokerRankPokerRankJ:
            return [_resService imageByName:@"poker_rank_black_J"];
            break;
            
        case PBPokerRankPokerRankQ:
            return [_resService imageByName:@"poker_rank_black_Q"];
            break;
            
        case PBPokerRankPokerRankK:
            return [_resService imageByName:@"poker_rank_black_K"];
            break;
            
        case PBPokerRankPokerRankA:
            return [_resService imageByName:@"poker_rank_black_A"];
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
            return [_resService imageByName:@"poker_body_spade"];
            break;
            
        case PBPokerSuitPokerSuitHeart:
            return [_resService imageByName:@"poker_body_heart"];
            break;
            
        case PBPokerSuitPokerSuitClub:
            return [_resService imageByName:@"poker_body_club"];
            break;
            
        case PBPokerSuitPokerSuitDiamond:
            return [_resService imageByName:@"poker_body_diamond"];
            break;
            
        default:
            return nil;
            break;
    }
}

- (UIImage*)noUserAvatarBackground
{
    return [_resService imageByName:@"avatar_default"];
}
- (UIImage*)avatarBackground
{
    return [_resService imageByName:@"zjh_other_plyer_avatar"];
}
- (UIImage*)myAvatarBackground
{
    return [_resService imageByName:@"zjh_my_avatar_bg"];
}


- (UIImage*)moneyTreeImage
{
    return [_resService imageByName:@"zjh_money_tree"];
}

- (UIImage*)betBtnBgImage
{
    return [_resService imageByName:@"zjh_bet"];
}

- (UIImage*)raiseBetBtnBgImage
{
    return [_resService imageByName:@"zjh_raise_bet"];
}


- (UIImage*)autoBetBtnBgImage
{
    return [_resService imageByName:@"zjh_auto_bet"];
}

- (UIImage*)autoBetBtnOnBgImage
{
    return [_resService imageByName:@"zjh_auto_bet_on"];
}



- (UIImage*)compareCardBtnBgImage
{
    return [_resService imageByName:@"zjh_compare_card"];
}


- (UIImage*)checkCardBtnBgImage
{
    return [_resService imageByName:@"zjh_check_card"];
}


- (UIImage*)foldCardBtnBgImage
{
    return [_resService imageByName:@"zjh_fold_card"];
}

- (UIImage*)betBtnDisableBgImage
{
    return [_resService imageByName:@"zjh_bet_disable"];
}

- (UIImage*)raiseBetBtnDisableBgImage
{
    return [_resService imageByName:@"zjh_raise_bet_disable"];
}


- (UIImage*)autoBetBtnDisableBgImage
{
    return [_resService imageByName:@"zjh_auto_bet_disable"];
}


- (UIImage*)compareCardBtnDisableBgImage
{
    return [_resService imageByName:@"zjh_compare_card_disable"];
}


- (UIImage*)checkCardBtnDisableBgImage
{
    return [_resService imageByName:@"zjh_check_card_disable"];
}


- (UIImage*)foldCardBtnDisableBgImage
{
    return [_resService imageByName:@"zjh_fold_card_disable"];
}

- (UIImage*)bombImage
{
    NSArray *bombs = [NSArray arrayWithObjects:@"bomb1", @"bomb2", @"bomb3", nil];
    return [_resService imageByName:[bombs objectAtIndex:(rand() % [bombs count])]];
}

- (UIImage*)vsImage
{
    return [_resService imageByName:@"zjh_vs"];
}

- (UIImage *)betActionImage:(UserPosition)position
{
    switch (position) {
        case UserPositionCenter:
        case UserPositionLeft:
        case UserPositionLeftTop:
            return [_resService imageByName:@"zjh_bet1"];
            break;
            
        case UserPositionRight:
        case UserPositionRightTop:
            return [_resService imageByName:@"zjh_bet2"];
            break;
            
        default:
            return nil;
            break;
    }
}

- (UIImage *)raiseBetActionImage:(UserPosition)position
{
    switch (position) {
        case UserPositionCenter:
        case UserPositionLeft:
        case UserPositionLeftTop:
            return [_resService imageByName:@"zjh_raise_bet1"];
            break;
            
        case UserPositionRight:
        case UserPositionRightTop:
            return [_resService imageByName:@"zjh_raise_bet2"];
            break;
            
        default:
            return nil;
            break;
    }
}

- (UIImage *)checkCardActionImage:(UserPosition)position
{
    switch (position) {
        case UserPositionCenter:
        case UserPositionLeft:
        case UserPositionLeftTop:
            return [_resService imageByName:@"zjh_check_card1"];
            break;
            
        case UserPositionRight:
        case UserPositionRightTop:
            return [_resService imageByName:@"zjh_check_card2"];
            break;
            
        default:
            return nil;
            break;
    }
}

- (UIImage *)compareCardActionImage:(UserPosition)position
{
    switch (position) {
        case UserPositionCenter:
        case UserPositionLeft:
        case UserPositionLeftTop:
            return [_resService imageByName:@"zjh_compare_card1"];
            break;
            
        case UserPositionRight:
        case UserPositionRightTop:
            return [_resService imageByName:@"zjh_compare_card2"];
            break;
            
        default:
            return nil;
            break;
    }
}

- (UIImage *)foldCardActionImage:(UserPosition)position
{
    switch (position) {
        case UserPositionCenter:
        case UserPositionLeft:
        case UserPositionLeftTop:
            return [_resService imageByName:@"zjh_fold_card1"];
            break;
            
        case UserPositionRight:
        case UserPositionRightTop:
            return [_resService imageByName:@"zjh_fold_card2"];
            break;
            
        default:
            return nil;
            break;
    }
}

- (UIImage *)gameBgImage
{
    return [_resService imageByName:@"zjh_game_bg"];
}

- (UIImage *)totalBetBgImage
{
    return [_resService imageByName:@"zjh_game_total_bet_bg"];
}

- (UIImage *)buttonsHolderBgImage
{
    return [_resService imageByName:@"zjh_button_holder_bg"];
}

- (UIImage *)runawayButtonImage
{
    return [_resService imageByName:@"zjh_runaway"];
}

- (UIImage *)settingButtonImage
{
    return [_resService imageByName:@"zjh_game_setting"];
}

- (UIImage *)chatButtonImage
{
    return [_resService imageByName:@"zjh_chat_button"];
}

@end
