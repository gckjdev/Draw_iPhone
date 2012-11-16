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
#import "GameResource.h"
//#import "UIImageUtil.h"

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
            return [_resService imageByName:@"poker_suit_spade" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerSuitPokerSuitHeart:
            return [_resService imageByName:@"poker_suit_heart" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerSuitPokerSuitClub:
            return [_resService imageByName:@"poker_suit_club" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerSuitPokerSuitDiamond:
            return [_resService imageByName:@"poker_suit_diamond" inResourcePackage:RESOURCE_PACKAGE_ZJH];
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
            return [_resService imageByName:@"poker_body_J" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRankQ:
            return [_resService imageByName:@"poker_body_Q" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRankK:
            return [_resService imageByName:@"poker_body_K" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        default:
            return nil;
            break;
    }
}

- (UIImage*)pokerTickImage
{
    return [_resService imageByName:@"" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage*)pokerFrontBgImage
{
    return [_resService imageByName:@"poker_front_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage*)pokerBackImage
{
    return [_resService imageByName:@"poker_back_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage*)pokerFoldBackImage
{
    return [_resService imageByName:@"poker_fold_back_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage*)pokerLoseBackImage{
    return [_resService imageByName:@"poker_lose_back_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage*)showCardButtonBgImage
{
    return [_resService imageByName:@"show_card_button" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage*)showCardButtonDisableBgImage
{
    return [_resService imageByName:@"show_card_button_disable" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage*)chipImageForChipValue:(int)chipValue;
{
    switch (chipValue) {
        case 5:
            return [_resService imageByName:@"chip_5" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case 10:
            return [_resService imageByName:@"chip_10" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case 25:
            return [_resService imageByName:@"chip_25" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case 50:
            return [_resService imageByName:@"chip_50" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case 100:
            return [_resService imageByName:@"chip_100" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case 250:
            return [_resService imageByName:@"chip_250" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case 500:
            return [_resService imageByName:@"chip_500" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case 1000:
            return [_resService imageByName:@"chip_1000" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        default:
            return nil;
            break;
    }
}

- (UIImage*)chipsSelectViewBgImage
{
    return [_resService imageByName:@"" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}


#pragma mark - pravite methods

- (UIImage *)redPokerRankImage:(Poker*)poker
{
    switch (poker.rank) {
            
        case PBPokerRankPokerRank2:
            return [_resService imageByName:@"poker_rank_red_2" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRank3:
            return [_resService imageByName:@"poker_rank_red_3" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRank4:
            return [_resService imageByName:@"poker_rank_red_4" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRank5:
            return [_resService imageByName:@"poker_rank_red_5" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRank6:
            return [_resService imageByName:@"poker_rank_red_6" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRank7:
            return [_resService imageByName:@"poker_rank_red_7" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRank8:
            return [_resService imageByName:@"poker_rank_red_8" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRank9:
            return [_resService imageByName:@"poker_rank_red_9" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRank10:
            return [_resService imageByName:@"poker_rank_red_10" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRankJ:
            return [_resService imageByName:@"poker_rank_red_J" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRankQ:
            return [_resService imageByName:@"poker_rank_red_Q" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRankK:
            return [_resService imageByName:@"poker_rank_red_K" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRankA:
            return [_resService imageByName:@"poker_rank_red_A" inResourcePackage:RESOURCE_PACKAGE_ZJH];
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
            return [_resService imageByName:@"poker_rank_black_2" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRank3:
            return [_resService imageByName:@"poker_rank_black_3" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRank4:
            return [_resService imageByName:@"poker_rank_black_4" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRank5:
            return [_resService imageByName:@"poker_rank_black_5" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRank6:
            return [_resService imageByName:@"poker_rank_black_6" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRank7:
            return [_resService imageByName:@"poker_rank_black_7" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRank8:
            return [_resService imageByName:@"poker_rank_black_8" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRank9:
            return [_resService imageByName:@"poker_rank_black_9" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRank10:
            return [_resService imageByName:@"poker_rank_black_10" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRankJ:
            return [_resService imageByName:@"poker_rank_black_J" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRankQ:
            return [_resService imageByName:@"poker_rank_black_Q" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRankK:
            return [_resService imageByName:@"poker_rank_black_K" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerRankPokerRankA:
            return [_resService imageByName:@"poker_rank_black_A" inResourcePackage:RESOURCE_PACKAGE_ZJH];
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
            return [_resService imageByName:@"poker_body_spade" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerSuitPokerSuitHeart:
            return [_resService imageByName:@"poker_body_heart" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerSuitPokerSuitClub:
            return [_resService imageByName:@"poker_body_club" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case PBPokerSuitPokerSuitDiamond:
            return [_resService imageByName:@"poker_body_diamond" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        default:
            return nil;
            break;
    }
}

- (UIImage*)noUserAvatarBackground
{
    return [_resService imageByName:@"avatar_default" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}
- (UIImage*)avatarBackground
{
    return [_resService imageByName:@"zjh_other_plyer_avatar" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}
- (UIImage*)myAvatarBackground
{
    return [_resService imageByName:@"zjh_my_avatar_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}


- (UIImage*)moneyTreeImage
{
    return [_resService imageByName:@"zjh_money_tree" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage*)bigMoneyTreeImage
{
    return [_resService imageByName:@"zjh_money_tree_big" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage*)moneyTreeCoinLightImage
{
    return [_resService imageByName:@"zjh_money_tree_coin_shining_light" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage*)moneyTreeCoinImage
{
    return [_resService imageByName:@"zjh_money_tree_coin" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage*)betBtnBgImage
{
    return [_resService imageByName:@"zjh_bet" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage*)raiseBetBtnBgImage
{
    return [_resService imageByName:@"zjh_raise_bet" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}


- (UIImage*)autoBetBtnBgImage
{
    return [_resService imageByName:@"zjh_auto_bet" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage*)autoBetBtnOnBgImage
{
    return [_resService imageByName:@"zjh_auto_bet_on" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}



- (UIImage*)compareCardBtnBgImage
{
    return [_resService imageByName:@"zjh_compare_card" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}


- (UIImage*)checkCardBtnBgImage
{
    return [_resService imageByName:@"zjh_check_card" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}


- (UIImage*)foldCardBtnBgImage
{
    return [_resService imageByName:@"zjh_fold_card" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage*)betBtnDisableBgImage
{
    return [_resService imageByName:@"zjh_bet_disable" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage*)raiseBetBtnDisableBgImage
{
    return [_resService imageByName:@"zjh_raise_bet_disable" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}


- (UIImage*)autoBetBtnDisableBgImage
{
    return [_resService imageByName:@"zjh_auto_bet_disable" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}


- (UIImage*)compareCardBtnDisableBgImage
{
    return [_resService imageByName:@"zjh_compare_card_disable" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}


- (UIImage*)checkCardBtnDisableBgImage
{
    return [_resService imageByName:@"zjh_check_card_disable" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}


- (UIImage*)foldCardBtnDisableBgImage
{
    return [_resService imageByName:@"zjh_fold_card_disable" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage*)bombImage
{
//    return [_resService imageByName:@"zjh_arrow" inResourcePackage:RESOURCE_PACKAGE_ZJH];
    
    return [UIImage imageNamed:@"zjh_arrow@2x.png"];
}

- (UIImage*)bombImageLight
{
    //    return [_resService imageByName:@"zjh_arrow_light" inResourcePackage:RESOURCE_PACKAGE_ZJH];
    
    return [UIImage imageNamed:@"zjh_arrow_light@2x.png"];
}

- (UIImage*)vsImage
{
    return [_resService imageByName:@"zjh_vs" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)betActionImage:(UserPosition)position
{
    switch (position) {
        case UserPositionCenter:
        case UserPositionLeft:
        case UserPositionLeftTop:
            return [_resService imageByName:@"zjh_bet1" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case UserPositionRight:
        case UserPositionRightTop:
            return [_resService imageByName:@"zjh_bet2" inResourcePackage:RESOURCE_PACKAGE_ZJH];
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
            return [_resService imageByName:@"zjh_raise_bet1" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case UserPositionRight:
        case UserPositionRightTop:
            return [_resService imageByName:@"zjh_raise_bet2" inResourcePackage:RESOURCE_PACKAGE_ZJH];
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
            return [_resService imageByName:@"zjh_check_card1" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case UserPositionRight:
        case UserPositionRightTop:
            return [_resService imageByName:@"zjh_check_card2" inResourcePackage:RESOURCE_PACKAGE_ZJH];
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
            return [_resService imageByName:@"zjh_compare_card1" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case UserPositionRight:
        case UserPositionRightTop:
            return [_resService imageByName:@"zjh_compare_card2" inResourcePackage:RESOURCE_PACKAGE_ZJH];
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
            return [_resService imageByName:@"zjh_fold_card1" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case UserPositionRight:
        case UserPositionRightTop:
            return [_resService imageByName:@"zjh_fold_card2" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        default:
            return nil;
            break;
    }
}

- (UIImage *)gameBgImage
{
    return [_resService imageByName:@"zjh_game_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)totalBetBgImage
{
    return [_resService imageByName:@"zjh_game_total_bet_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)userTotalBetBgImage
{
    return [_resService imageByName:@"zjh_user_bet_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];

//    return [[_resService imageByName:@"zjh_user_bet_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH] stretchableImageWithLeftCapWidth:25 topCapHeight:0];
}

- (UIImage *)buttonsHolderBgImage
{
    return [_resService imageByName:@"zjh_button_holder_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)runawayButtonImage
{
    return [_resService imageByName:@"zjh_runaway" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)settingButtonImage
{
    return [_resService imageByName:@"zjh_game_setting" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)chatButtonImage
{
    return [_resService imageByName:@"zjh_chat_button" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

@end
