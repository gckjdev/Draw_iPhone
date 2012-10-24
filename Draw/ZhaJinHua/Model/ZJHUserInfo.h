//
//  ZJHUserInfo.h
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import <Foundation/Foundation.h>
#import "ZhaJinHua.pb.h"
#import "Poker.h"

@interface ZJHUserInfo : NSObject

@property (readonly, copy, nonatomic) NSString *userId;
@property (retain, nonatomic) NSArray *pokers;
@property (assign, nonatomic) PBZJHCardType cardType;
@property (assign, nonatomic) int totalBet;
@property (assign, nonatomic) BOOL isAutoBet;
@property (assign, nonatomic) PBZJHUserState userState;
@property (assign, nonatomic) BOOL canBeCompared;

@property (assign, nonatomic) BOOL alreadChecked;
@property (assign, nonatomic) BOOL alreadFold;
@property (assign, nonatomic) BOOL ;

+ (ZJHUserInfo *)userInfoFromPBZJHUserInfo:(PBZJHUserInfo *)pbZJHUserInfo;

- (void)reset;
- (void)setPokerFaceUp:(int)pokerId;
- (Poker *)poker:(int)pokerId;

@end
