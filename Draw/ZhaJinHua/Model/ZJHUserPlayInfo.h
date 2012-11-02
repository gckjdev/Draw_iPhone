//
//  ZJHUserPlayInfo.h
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import <Foundation/Foundation.h>
#import "ZhaJinHua.pb.h"
#import "Poker.h"

#define ZJH_NUM_POKER_PER_USER 3

@interface ZJHUserPlayInfo : NSObject

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

+ (ZJHUserPlayInfo *)fromPBZJHUserPlayInfo:(PBZJHUserPlayInfo *)pbZJHUserPlayInfo;

- (void)setPokersFaceUp:(NSArray *)pokerIds;
- (Poker *)poker:(int)pokerId;
- (int)betCount;

- (BOOL)hasShield;

- (BOOL)canCompareCard;
- (BOOL)canCheckCard;
- (BOOL)canFoldCard;
- (BOOL)canShowCard:(int)cardId;


@end
