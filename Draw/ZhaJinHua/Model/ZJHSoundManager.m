//
//  ZJHSoundManager.m
//  Draw
//
//  Created by Kira on 12-11-7.
//
//

#import "ZJHSoundManager.h"
#import "PPResourceService.h"
#import "GameResource.h"

static ZJHSoundManager* shareInstance;

@interface ZJHSoundManager()
{
    PPResourceService* _resourceService;
}


@end

@implementation ZJHSoundManager

+ (ZJHSoundManager*)defaultManager
{
    if (shareInstance == nil) {
        shareInstance = [[ZJHSoundManager alloc] init];
    }
    return shareInstance;
}

- (id)init
{
    self = [super init];
    _resourceService = [PPResourceService defaultService];
    return self;
}

- (NSURL*)betSoundEffect
{
    return [_resourceService audioURLByName:@"bet.mp3" inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];
}

- (NSURL*)betHumanSound:(BOOL)gender
{
    if (gender) {
        return [_resourceService audioURLByName:[NSString stringWithFormat:@"bet%d_M.mp3",rand()%3+1]
                              inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];
//        return ;
    } else {
        return [_resourceService audioURLByName:[NSString stringWithFormat:@"bet%d_F.mp3",rand()%3+1]
                              inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];
//        return [NSString stringWithFormat:@"bet%d_F.mp3",rand()%4+1];
    }
}

- (NSURL*)checkCardSoundEffect
{
    return [_resourceService audioURLByName:@"check_card.mp3" inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];;
}

- (NSURL*)checkCardHumanSound:(BOOL)gender
{
    if (gender) {
        return [_resourceService audioURLByName:@"check_card1_M.mp3" inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];;
    } else {
        return [_resourceService audioURLByName:[NSString stringWithFormat:@"check_card%d_F.mp3",rand()%2+1]
                              inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];;
    }
}

- (NSURL*)compareCardSoundEffect
{
    return nil;
}

- (NSURL*)compareCardHumanSound:(BOOL)gender
{
    if (gender) {
        return [_resourceService audioURLByName:@"compare_card1_M.mp3" inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];;
    } else {
        return [_resourceService audioURLByName:@"compare_card1_F.mp3" inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];;
    }
}

- (NSURL*)foldCardSoundEffect
{
    return nil;
}

- (NSURL*)foldCardHumanSound:(BOOL)gender
{
    if (gender) {
        return [_resourceService audioURLByName:@"fold_card1_M.mp3" inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];;
    } else {
        return [_resourceService audioURLByName:[NSString stringWithFormat:@"fold_card%d_F.mp3",rand()%2+1]
                              inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];;
    }
}

- (NSURL*)raiseBetSoundEffect
{
    return [_resourceService audioURLByName:@"raise_bet.mp3" inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];;
}

- (NSURL*)raiseBetHumanSound:(BOOL)gender
{
    if (gender) {
        return [_resourceService audioURLByName:@"raise_bet1_M.mp3" inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];
    } else {
        return [_resourceService audioURLByName:@"raise_bet1_F.mp3" inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];
    }
}

- (NSURL*)clickButtonSound
{
    return [_resourceService audioURLByName:@"click_button.mp3" inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];;
}

- (NSURL*)dealCardAppear
{
    return [_resourceService audioURLByName:@"dealer_appear.mp3" inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];;
}

- (NSURL*)dealCard
{
    return [_resourceService audioURLByName:@"deal_card.mp3" inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];;
}

- (NSURL*)dealCardDisappear
{
    return [_resourceService audioURLByName:@"dealer_disappear.mp3" inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];;
}

- (NSURL*)fireworks
{
    return [_resourceService audioURLByName:@"fireworks.mp3" inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];;
}

- (NSURL*)flee
{
    return [_resourceService audioURLByName:@"flee.mp3" inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];;
}

- (NSURL*)fullMoney
{
    return [_resourceService audioURLByName:@"full_monney.mp3" inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];;
}

- (NSURL*)gameBGM
{
    return [_resourceService audioURLByName:@"game_bg.mp3" inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];;
}

- (NSURL*)gameOver
{
    return [_resourceService audioURLByName:@"game_over.mp3" inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];;
}

- (NSURL*)gameWin
{
    return [_resourceService audioURLByName:@"game_win.mp3" inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];;
}

- (NSURL*)getChips
{
    return [_resourceService audioURLByName:@"get_chips.mp3" inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];;
}

- (NSURL*)fallingCoins
{
    return [_resourceService audioURLByName:@"fallingCoinBGM.mp3" inResourcePackage:RESOURCE_PACKAGE_ZJH_AUDIO];
}

@end
