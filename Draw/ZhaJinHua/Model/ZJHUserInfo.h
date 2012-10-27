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

#define ZJH_NUM_POKER_PER_USER 3

@interface ZJHUserInfo : NSObject

@property (readonly, copy, nonatomic) NSString *userId;
@property (retain, nonatomic) NSArray *pokers;
@property (assign, nonatomic) PBZJHCardType cardType;
@property (assign, nonatomic) int totalBet;
@property (assign, nonatomic) BOOL isAutoBet;
@property (assign, nonatomic) PBZJHUserAction lastAction;

@property (assign, nonatomic) BOOL alreadCheckCard;
@property (assign, nonatomic) BOOL alreadFoldCard;
@property (assign, nonatomic) BOOL alreadShowCard;
@property (assign, nonatomic) BOOL alreadLose;

- (ZJHUserInfo *)fromPBZJHUserInfo:(PBZJHUserInfo *)pbZJHUserInfo;
//- (ZJHUserInfo *)updateWithPokers:(PBZJHUserPoker *)pokers;

- (void)setPokersFaceUp:(NSArray *)pokerIds;
- (Poker *)poker:(int)pokerId;
- (int)betCount;

- (BOOL)canBeCompare;
- (BOOL)hasShield;

@end
