//
//  ZJHUserPosInfo.m
//  Draw
//
//  Created by 王 小涛 on 12-12-4.
//
//

#import "ZJHUserPosInfo.h"

@implementation ZJHUserPosInfo

- (void)dealloc
{
    [super dealloc];
}

- (ZJHUserPosInfo *)initWithPos:(UserPosition)pos
                         avatar:(ZJHAvatarView*)avatar
                     pokersView:(ZJHPokerView*)pokersView
                      pokerSize:(CGSize)pokerSize
                            gap:(CGFloat)gap
                  totalBetLabel:(UILabel *)totalBetLabel
                     totalBetBg:(UIImageView *)totalBetBg;
{
    if (self = [super init]) {
        self.avatar = avatar;
        self.pos = pos;
        self.pokersView = pokersView;
        self.totalBetLabel = totalBetLabel;
        self.totalBetBg = totalBetBg;
        self.pokerSize = pokerSize;
        self.gap = gap;
    }
    
    return self;
}

+ (ZJHUserPosInfo *)userPosInfoWithPos:(UserPosition)pos
                                avatar:(ZJHAvatarView*)avatar
                            pokersView:(ZJHPokerView*)pokersView
                             pokerSize:(CGSize)pokerSize
                                   gap:(CGFloat)gap
                         totalBetLabel:(UILabel *)totalBetLabel
                            totalBetBg:(UIImageView *)totalBetBg;
{
    return [[[ZJHUserPosInfo alloc] initWithPos:pos
                                        avatar:avatar
                                    pokersView:pokersView
                                     pokerSize:pokerSize
                                           gap:gap
                                 totalBetLabel:totalBetLabel
                                    totalBetBg:totalBetBg] autorelease];
}



@end
