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
@property (assign, nonatomic) ZJHAvatarView *avatar;

@property (assign, nonatomic) UserPosition pos;

@property (assign, nonatomic) ZJHPokerView *pokersView;
@property (assign, nonatomic) CGSize pokerSize;
@property (assign, nonatomic) CGFloat gap;
@property (assign, nonatomic) UILabel *totalBetLabel;
@property (assign, nonatomic) UIImageView *totalBetBg;

+ (ZJHUserPosInfo *)userPosInfoWithPos:(UserPosition)pos
                                avatar:(ZJHAvatarView*)avatar
                            pokersView:(ZJHPokerView*)pokersView
                             pokerSize:(CGSize)pokerSize
                                   gap:(CGFloat)gap
                         totalBetLabel:(UILabel *)totalBetLabel
                            totalBetBg:(UIImageView *)totalBetBg;

@end
