//
//  ZJHDualRuleConfig.m
//  Draw
//
//  Created by 王 小涛 on 12-12-7.
//
//

#import "ZJHDualRuleConfig.h"

#import "ZJHImageManager.h"
#import "ZJHPokerView.h"

@implementation ZJHDualRuleConfig

- (NSString *)getRoomListTitle
{
    return NSLS(@"kHomeMenuTypeZJHVSSite");
}

- (NSArray *)chipValues
{
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:10], [NSNumber numberWithInt:25], [NSNumber numberWithInt:50], [NSNumber numberWithInt:100], nil];
}

- (int)maxPlayerNum
{
    return 2;
}

- (UIImage *)gameBgImage
{
    return [[ZJHImageManager defaultManager] dualGameBgImage];
}

- (NSMutableDictionary *)initAllAvatar:(ZJHGameController *)controller
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[self maxPlayerNum]];
    
    ZJHMyAvatarView *myAvatar = [self bigAvatarWithFrame:controller.centerAvatar.frame];
    
    CGSize pokerSize = CGSizeMake(BIG_POKER_VIEW_WIDTH, BIG_POKER_VIEW_HEIGHT);
    CGFloat gap = BIG_POKER_GAP;

    [dic setObject:[ZJHUserPosInfo userPosInfoWithPos:UserPositionCenter
                                              avatar:myAvatar
                                          pokersView:controller.centerPokers
                                           pokerSize:pokerSize
                                                 gap:gap
                                       totalBetLabel:controller.centerTotalBet
                                          totalBetBg:controller.centerTotalBetBg]
           forKey:[NSString stringWithFormat:@"%d", UserPositionCenter]];
    
    ZJHMyAvatarView *heAvatar = [self bigAvatarWithFrame:controller.centerUpAvatar.frame];

    gap = SMALL_POKER_GAP;
    
    [dic setObject:[ZJHUserPosInfo userPosInfoWithPos:UserPositionCenterUp
                                              avatar:heAvatar
                                          pokersView:controller.centerUpPokers
                                           pokerSize:pokerSize
                                                 gap:gap
                                       totalBetLabel:controller.centerUpTotalBet
                                          totalBetBg:controller.centerUpTotalBetBg]
           forKey:[NSString stringWithFormat:@"%d", UserPositionCenterUp]];
        
    return dic;
}


- (UserPosition)positionBySeatIndex:(int)index
{
    switch (index) {
        case 0:
            return UserPositionCenter;
            break;
        case 1:
            return UserPositionCenterUp;
            break;
        default:
            return -1;
            break;
    }
}



@end
