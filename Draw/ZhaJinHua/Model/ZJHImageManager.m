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
#import "UIImageUtil.h"
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
    return [_resService imageByName:@"show_card_button_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)twoButtonsHolderBgImage
{
    return [_resService imageByName:@"show_change_card_button_popup_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)oneButtonHolderBgImage
{
    return [_resService imageByName:@"show_card_button_popup_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

//- (UIImage*)showCardButtonDisableBgImage
//{
//    return [_resService imageByName:@"show_card_button_disable" inResourcePackage:RESOURCE_PACKAGE_ZJH];
//}

- (UIImage *)showCardFlagImage
{
    return [_resService imageByName:@"zjh_show_card_flag" inResourcePackage:RESOURCE_PACKAGE_ZJH];
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
    return [_resService imageByName:@"chips_select_bg_image" inResourcePackage:RESOURCE_PACKAGE_ZJH];
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

- (UIImage*)noUserBigAvatarBackground
{
    return [_resService imageByName:@"avatar_default_big" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)coinsImage
{
    return [_resService imageByName:@"coin" inResourcePackage:RESOURCE_PACKAGE_ZJH];
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
    return [_resService imageByName:@"coin" inResourcePackage:RESOURCE_PACKAGE_ZJH];
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
    return [_resService imageByName:@"zjh_arrow" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage*)bombImageLight
{
    return [_resService imageByName:@"zjh_arrow_light" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage*)vsImage
{
    return [_resService imageByName:@"zjh_vs" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)chatMesssgeBgImage:(UserPosition)position;
{
    switch (position) {
        case UserPositionCenter:
            return [[_resService imageByName:@"chat_message_bg_center" inResourcePackage:RESOURCE_PACKAGE_ZJH] stretchableImageWithLeftCapWidth:12 topCapHeight:15];

        case UserPositionCenterUp:
            return [[_resService imageByName:@"chat_message_bg_center_up" inResourcePackage:RESOURCE_PACKAGE_ZJH] stretchableImageWithLeftCapWidth:12 topCapHeight:20];

        case UserPositionLeft:
        case UserPositionLeftTop:
            return [[_resService imageByName:@"chat_message_bg_left" inResourcePackage:RESOURCE_PACKAGE_ZJH] stretchableImageWithLeftCapWidth:12 topCapHeight:12];

            
        case UserPositionRight:
        case UserPositionRightTop:
            return [[_resService imageByName:@"chat_message_bg_right" inResourcePackage:RESOURCE_PACKAGE_ZJH] stretchableImageWithLeftCapWidth:12 topCapHeight:12];
            break;
            
        default:
            return nil;
            break;
    }
}

- (UIImage *)betActionImage:(UserPosition)position
{
    switch (position) {
        case UserPositionCenter:
        case UserPositionCenterUp:
        case UserPositionLeft:
        case UserPositionLeftTop:
            return [[_resService imageByName:@"zjh_bet1" inResourcePackage:RESOURCE_PACKAGE_ZJH] stretchableImageWithLeftCapWidth:24 topCapHeight:10];
            break;
            
        case UserPositionRight:
        case UserPositionRightTop:
            return [[_resService imageByName:@"zjh_bet2" inResourcePackage:RESOURCE_PACKAGE_ZJH] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
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
        case UserPositionCenterUp:
        case UserPositionLeft:
        case UserPositionLeftTop:
            return [[_resService imageByName:@"zjh_raise_bet1" inResourcePackage:RESOURCE_PACKAGE_ZJH] stretchableImageWithLeftCapWidth:24 topCapHeight:10];
            break;
            
        case UserPositionRight:
        case UserPositionRightTop:
            return [[_resService imageByName:@"zjh_raise_bet2" inResourcePackage:RESOURCE_PACKAGE_ZJH] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
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
        case UserPositionCenterUp:
        case UserPositionLeft:
        case UserPositionLeftTop:
            return [[_resService imageByName:@"zjh_check_card1" inResourcePackage:RESOURCE_PACKAGE_ZJH] stretchableImageWithLeftCapWidth:24 topCapHeight:10];
            break;
            
        case UserPositionRight:
        case UserPositionRightTop:
            return [[_resService imageByName:@"zjh_check_card2" inResourcePackage:RESOURCE_PACKAGE_ZJH] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
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
        case UserPositionCenterUp:
        case UserPositionLeft:
        case UserPositionLeftTop:
            return [[_resService imageByName:@"zjh_compare_card1" inResourcePackage:RESOURCE_PACKAGE_ZJH] stretchableImageWithLeftCapWidth:24 topCapHeight:10];
            break;
            
        case UserPositionRight:
        case UserPositionRightTop:
            return [[_resService imageByName:@"zjh_compare_card2" inResourcePackage:RESOURCE_PACKAGE_ZJH] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
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
        case UserPositionCenterUp:
        case UserPositionLeft:
        case UserPositionLeftTop:
            return [[_resService imageByName:@"zjh_fold_card1" inResourcePackage:RESOURCE_PACKAGE_ZJH] stretchableImageWithLeftCapWidth:24 topCapHeight:10];
            break;
            
        case UserPositionRight:
        case UserPositionRightTop:
            return [[_resService imageByName:@"zjh_fold_card2" inResourcePackage:RESOURCE_PACKAGE_ZJH] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
            break;
            
        default:
            return nil;
            break;
    }
}

- (UIImage *)gameBgImage
{
    switch ([DeviceDetection deviceScreenType]) {
        case DEVICE_SCREEN_IPAD:
        case DEVICE_SCREEN_NEW_IPAD:
            return [_resService imageByName:@"zjh_game_bg_ipad" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case DEVICE_SCREEN_IPHONE5:
            return [_resService imageByName:@"zjh_game_bg_ip5" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case DEVICE_SCREEN_IPHONE:
            return [_resService imageByName:@"zjh_game_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (UIImage *)dualGameBgImage
{
    switch ([DeviceDetection deviceScreenType]) {
        case DEVICE_SCREEN_IPAD:
        case DEVICE_SCREEN_NEW_IPAD:
            return [_resService imageByName:@"zjh_game_bg_dual_ipad" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case DEVICE_SCREEN_IPHONE5:
            return [_resService imageByName:@"zjh_game_bg_dual_ip5" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case DEVICE_SCREEN_IPHONE:
            return [_resService imageByName:@"zjh_game_bg_dual" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (UIImage *)totalBetBgImage
{
    return [_resService imageByName:@"zjh_game_total_bet_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)userTotalBetBgImage
{
    return [_resService imageByName:@"zjh_user_bet_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)buttonsHolderBgImage
{
    switch ([DeviceDetection deviceScreenType]) {
        case DEVICE_SCREEN_IPAD:
        case DEVICE_SCREEN_NEW_IPAD:
            return [_resService imageByName:@"zjh_button_holder_bg_ipad" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        case DEVICE_SCREEN_IPHONE5:
        case DEVICE_SCREEN_IPHONE:
            return [_resService imageByName:@"zjh_button_holder_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];
            break;
            
        default:
            break;
    }
    
    return nil;
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

- (UIImage *)roomBackgroundImage
{
    return [_resService imageByName:@"dice_room_background" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)cardTypeBgImage
{
    return [_resService imageByName:@"zjh_card_type_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)roomTitleBgImage
{
    return [_resService imageByName:@"zjh_room_title_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)moneyTreePopupMessageBackground
{
    return [_resService imageByName:@"zjh_money_tree_pop_message_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)zjhCardTypesNoteBgImage
{
    return [[_resService imageByName:@"zjh_card_types_note_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH] stretchableImageWithLeftCapWidth:50 topCapHeight:0];
}

- (UIImage *)specialCardTypeImage
{
    return [_resService imageByName:@"zjh_special_card_type_image" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage*)dispatcherImage
{
    return [_resService imageByName:@"dispatcher" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage*)ZJHUserInfoBackgroundImage
{
    return [UIImage strectchableImageName:@"ZJHUserInfoBackground"];
}

- (UIImage *)dialogBgImage
{
    return [_resService imageByName:@"zjh_dialog_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)dialogBtnImage
{
    return [_resService imageByName:@"zjh_dialog_btn" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)audioOff
{
    return [_resService imageByName:@"zjh_audio_off" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)audioOn
{
    return [_resService imageByName:@"zjh_audio_on" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)musicOn
{
    return [_resService imageByName:@"zjh_music_on" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)musicOff
{
    return [_resService imageByName:@"zjh_music_off" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)settingsBgImage
{
    return [_resService imageByName:@"zjh_setting_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)settingsLeftSelected
{
    return [_resService imageByName:@"zjh_settingleft_selected" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)settingsLeftUnselected
{
    return [_resService imageByName:@"zjh_settingleft_unselect" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)settingsRightSelected
{
    return [_resService imageByName:@"zjh_settingright_selected" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)settingsRightUnselected
{
    return [_resService imageByName:@"zjh_settingright_unselect" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

#pragma mark - dialog image manager protocol

- (UIImage*)commonDialogBgImage
{
    return [_resService imageByName:@"zjh_dialog_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}
- (UIImage*)commonDialogLeftBtnImage
{
    return [UIImage strectchableImageName:@"zjh_dialog_btn"];
}
- (UIImage*)commonDialogRightBtnImage
{
    return [UIImage strectchableImageName:@"zjh_dialog_btn"];
}

- (UIImage *)commonDialogHeaderImage
{
    return nil;
}

- (UIImage *)inputDialogBgImage
{
    return [_resService imageByName:@"zjh_dialog_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage*)inputDialogInputBgImage
{
//    return [UIImage strectchableImageName:@"zjh_input_bg.png" leftCapWidth:15 topCapHeight:15];
    return [UIImage strectchableImageName:@"zjh_input_bg"];
}
- (UIImage*)inputDialogLeftBtnImage
{
    return [UIImage strectchableImageName:@"zjh_dialog_btn"];
}
- (UIImage*)inputDialogRightBtnImage
{
    return [UIImage strectchableImageName:@"zjh_dialog_btn"];
}

- (UIImage *)headerBgImage
{
    return nil;
}
- (UIImage *)roomListBgImage
{
    return [_resService imageByName:@"zjh_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}
- (UIImage *)roomListLeftBtnSelectedImage
{
    return [_resService imageByName:@"tab_left_selected" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}
- (UIImage *)roomListLeftBtnUnselectedImage
{
    return [_resService imageByName:@"tab_left_unselect" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}
- (UIImage *)roomListRightBtnSelectedImage
{
    return [_resService imageByName:@"tab_right_selected" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}
- (UIImage *)roomListRightBtnUnselectedImage
{
    return [_resService imageByName:@"tab_right_unselect" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}

- (UIImage *)roomListCenterBtnSelectedImage
{
    return [_resService imageByName:@"tab_center_unselect" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}
- (UIImage *)roomListCenterBtnUnselectedImage
{
    return [_resService imageByName:@"tab_center_unselect" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}

- (UIImage *)roomListBackBtnImage
{
    return [_resService imageByName:@"zjh_back" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}
- (UIImage *)roomListCellBgImage
{
    return [_resService imageByName:@"room_item" inResourcePackage:RESOURCE_PACKAGE_COMMON];
}

- (UIImage *)roomListCreateRoomBtnBgImage
{
    return [UIImage strectchableImageName:@"zjh_dialog_btn"];
}
- (UIImage *)roomListFastEntryBtnBgImage
{
    return [UIImage strectchableImageName:@"zjh_dialog_btn"];
}

- (UIImage *)userInfoFollowBtnImage
{
//    return [_resService imageByName:@"zjh_user_info_follow" inResourcePackage:RESOURCE_PACKAGE_ZJH];
    return [UIImage strectchableImageName:@"zjh_dialog_btn"];
}
- (UIImage *)userInfoTalkBtnImage
{
//    return [_resService imageByName:@"zjh_user_info_talk" inResourcePackage:RESOURCE_PACKAGE_ZJH];
    return [UIImage strectchableImageName:@"zjh_dialog_btn"];
}

- (UIImage *)bulletinAccessoryImage
{
    return [_resService imageByName:@"" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}
- (UIImage *)bulletinBackgroundImage
{
    return [_resService stretchableImageWithImageName:@"bulletin_bg" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}
- (UIImage *)bulletinButtomImage
{
    return [_resService imageByName:@"" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}
- (UIImage *)bulletinDateBackgroundImage
{
    return [_resService imageByName:@"" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}
- (UIImage *)bulletinTimeBackgroundImage
{
    return [_resService imageByName:@"" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}
- (UIImage *)bulletinTopImage
{
    return [_resService imageByName:@"" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}
- (UIImage *)bulletinCloseImage
{
    return [_resService imageByName:@"" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}
- (UIImage *)bulletinNewImage
{
    return [_resService imageByName:@"" inResourcePackage:RESOURCE_PACKAGE_ZJH];
}

- (UIImage *)timeoutActionBetImage
{
    return [UIImage imageNamed:@"timeout_action_bet@2x.png"];
}

- (UIImage *)timeoutActionFoldImage
{
    return [UIImage imageNamed:@"timeout_action_fold@2x.png"];
}


@end
