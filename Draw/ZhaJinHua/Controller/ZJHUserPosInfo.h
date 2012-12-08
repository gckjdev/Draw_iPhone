//
//  ZJHUserPosInfo.h
//  Draw
//
//  Created by 王 小涛 on 12-12-4.
//
//

#import <Foundation/Foundation.h>
#import "ZJHAvatarView.h"
#import "ZJHMyAvatarView.h"
#import "ZJHConstance.h"
#import "ZJHPokerView.h"

@interface ZJHUserPosInfo : NSObject
@property (retain, nonatomic) ZJHAvatarView *avatar;

@property (assign, nonatomic) UserPosition pos;

@property (retain, nonatomic) ZJHPokerView *pokersView;
@property (retain, nonatomic) UILabel *totalBetLabel;
@property (retain, nonatomic) UIImageView *totalBetBg;

+ (ZJHUserPosInfo *)userPosInfoWithPos:(UserPosition)pos
                                avatar:(ZJHAvatarView*)avatar
                            pokersView:(ZJHPokerView*)pokersView
                         totalBetLabel:(UILabel *)totalBetLabel
                            totalBetBg:(UIImageView *)totalBetBg;

@end
