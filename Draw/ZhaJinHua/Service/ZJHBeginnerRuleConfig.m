//
//  ZJHBeginnerRuleConfig.m
//  Draw
//
//  Created by 王 小涛 on 12-11-30.
//
//

#import "ZJHBeginnerRuleConfig.h"
#import "ZJHImageManager.h"
#import "ZJHGameController.h"

#define TEXT_COLOR_ENABLED [UIColor colorWithRed:199.0/255.0 green:252.0/255.0 blue:254.0/255.0 alpha:1]
#define TEXT_COLOR_DISENABLED [UIColor colorWithRed:68.0/255.0 green:109.0/255.0 blue:110.0/255.0 alpha:1]

@implementation ZJHBeginnerRuleConfig

- (NSArray *)chipValues
{
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:10], [NSNumber numberWithInt:25], [NSNumber numberWithInt:50], nil];
}

- (UIView *)createButtons:(PokerView *)pokerView
{
    UIView *view = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, TWO_BUTTONS_HOLDER_VIEW_WIDTH, TWO_BUTTONS_HOLDER_VIEW_HEIGHT)] autorelease];
    
    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:view.bounds] autorelease];
    imageView.image = [[ZJHImageManager defaultManager] twoButtonsHolderBgImage];
    
    UIButton *showCardButton = [[[UIButton alloc] initWithFrame:CGRectMake(SHOW_CARD_BUTTON_X_OFFSET, SHOW_CARD_BUTTON_Y_OFFSET, BUTTON_WIDTH, BUTTON_HEIGHT)] autorelease];
//    showCardButton.tag = SHOW_CARD_BUTTON_TAG;
    [showCardButton setBackgroundImage:[[ZJHImageManager defaultManager] showCardButtonBgImage] forState:UIControlStateNormal];
    [showCardButton setTitle:NSLS(@"kShowCard") forState:UIControlStateNormal];
    showCardButton.titleLabel.font = BUTTON_FONT;
    showCardButton.titleLabel.textAlignment = UITextAlignmentCenter;

    if ([[ZJHGameService defaultService] canIShowCard:pokerView.poker.pokerId]) {
        [showCardButton setTitleColor:TEXT_COLOR_ENABLED forState:UIControlStateNormal];
        [showCardButton addTarget:pokerView action:@selector(clickShowCardButton:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [showCardButton setTitleColor:TEXT_COLOR_DISENABLED forState:UIControlStateNormal];
        showCardButton.enabled = NO;
    }

    
    UIButton *changeCardButton = [[[UIButton alloc] initWithFrame:CGRectMake(CHANGE_CARD_BUTTON_X_OFFSET, CHANGE_CARD_BUTTON_Y_OFFSET, BUTTON_WIDTH, BUTTON_HEIGHT)] autorelease];
//    changeCardButton.tag = CHANGE_CARD_BUTTON_TAG;
    [changeCardButton setBackgroundImage:[[ZJHImageManager defaultManager] showCardButtonBgImage] forState:UIControlStateNormal];
    [changeCardButton setTitle:NSLS(@"kChangeCard") forState:UIControlStateNormal];
    changeCardButton.titleLabel.font = BUTTON_FONT;
    changeCardButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    if ([[ZJHGameService defaultService] canIChangeCard]) {
        [changeCardButton setTitleColor:TEXT_COLOR_ENABLED forState:UIControlStateNormal];
        [changeCardButton addTarget:pokerView action:@selector(clickChangeCardButton:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [changeCardButton setTitleColor:TEXT_COLOR_DISENABLED forState:UIControlStateNormal];
        changeCardButton.enabled = NO;
    }
    
    [view addSubview:imageView];
    [view addSubview:showCardButton];
    [view addSubview:changeCardButton];
    
    return view;
}

- (int)maxPlayerNum
{
    return 5;
}

- (UIImage *)gameBgImage
{
    return [[ZJHImageManager defaultManager] gameBgImage];
}


- (NSMutableDictionary *)initAllAvatar:(ZJHGameController *)controller
{    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[self maxPlayerNum]];
    
    ZJHMyAvatarView *myAvatar = [self bigAvatarWithFrame:controller.centerAvatar.frame];
    
    [dic setValue:[ZJHUserPosInfo userPosInfoWithPos:UserPositionCenter
                                              avatar:myAvatar
                                          pokersView:controller.centerPokers
                                       totalBetLabel:controller.centerTotalBet
                                          totalBetBg:controller.centerTotalBetBg]
           forKey:[NSString stringWithFormat:@"%d", UserPositionCenter]];
    
    [dic setValue:[ZJHUserPosInfo userPosInfoWithPos:UserPositionLeft
                                              avatar:[self avatarWithFrame:controller.leftAvatar.frame]
                                          pokersView:controller.leftPokers
                                       totalBetLabel:controller.leftTotalBet
                                          totalBetBg:controller.leftTotalBetBg]
           forKey:[NSString stringWithFormat:@"%d", UserPositionLeft]];

    [dic setValue:[ZJHUserPosInfo userPosInfoWithPos:UserPositionLeftTop
                                              avatar:[self avatarWithFrame:controller.leftTopAvatar.frame]
                                          pokersView:controller.leftTopPokers
                                       totalBetLabel:controller.leftTopTotalBet
                                          totalBetBg:controller.leftTopTotalBetBg]
           forKey:[NSString stringWithFormat:@"%d", UserPositionLeftTop]];
    
    [dic setValue:[ZJHUserPosInfo userPosInfoWithPos:UserPositionRight
                                              avatar:[self avatarWithFrame:controller.rightAvatar.frame]
                                          pokersView:controller.rightPokers
                                       totalBetLabel:controller.rightTotalBet
                                          totalBetBg:controller.rightTotalBetBg]
           forKey:[NSString stringWithFormat:@"%d", UserPositionRight]];

    [dic setValue:[ZJHUserPosInfo userPosInfoWithPos:UserPositionRightTop
                                              avatar:[self avatarWithFrame:controller.rightTopAvatar.frame]
                                          pokersView:controller.rightTopPokers
                                       totalBetLabel:controller.rightTopTotalBet
                                          totalBetBg:controller.rightTopTotalBetBg]
           forKey:[NSString stringWithFormat:@"%d", UserPositionRightTop]];
    
    return dic;
}

- (ZJHMyAvatarView *)bigAvatarWithFrame:(CGRect)frame
{
    ZJHMyAvatarView* myAvatar = [ZJHMyAvatarView createZJHMyAvatarView];
    [myAvatar setFrame:frame];
    
    return myAvatar;
}


- (ZJHAvatarView *)avatarWithFrame:(CGRect)frame
{
    ZJHAvatarView* avatar = [ZJHAvatarView createZJHAvatarView];
    [avatar setFrame:frame];
    
    return avatar;
}





@end
